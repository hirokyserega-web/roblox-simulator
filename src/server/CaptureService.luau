-- Сервис валидации и обработки поимки призраков на сервере с защитой от читов
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local InventoryService = require(script.Parent.InventoryService)

local CaptureService = {}
local playerGhostsFolder = nil

-- Инициализация сервиса поимки
function CaptureService.init()
	playerGhostsFolder = ReplicatedStorage:FindFirstChild("PlayerGhosts")
	
	-- Слушаем запросы на поимку от клиентов
	local captureEvent = Remotes.getEvent("CaptureGhost")
	captureEvent.OnServerEvent:Connect(CaptureService.onCaptureRequest)
	
	print("[CAPTURE SERVICE] Сервис поимки призраков с античитом успешно запущен!")
end

-- Обработка запроса от клиента
function CaptureService.onCaptureRequest(player: Player, ghostId: string)
	if not playerGhostsFolder then return end
	if type(ghostId) ~= "string" then return end

	-- 1. Находим логическую папку призраков игрока
	local pFolder = playerGhostsFolder:FindFirstChild(tostring(player.UserId))
	if not pFolder then return end

	-- Ищем конкретного призрака по его уникальному GhostId (GUID)
	local ghostEntity = nil
	for _, entity in ipairs(pFolder:GetChildren()) do
		if entity:GetAttribute("GhostId") == ghostId then
			ghostEntity = entity
			break
		end
	end

	-- Если призрак не найден (уже поймали или не существовал)
	if not ghostEntity then
		warn(string.format("[CAPTURE SERVICE] Игрок %s передал невалидный GhostId: %s", player.Name, ghostId))
		return
	end

	-- 2. Проверяем состояние персонажа
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- 3. АНТИЧИТ: Проверка разблокировки зоны
	local zoneId = ghostEntity:GetAttribute("SpawnZoneName") or "StarterArea"
	local isStarter = (zoneId == "StarterArea")
	local isUnlocked = isStarter or (player:GetAttribute("Unlocked_" .. zoneId) == true)

	if not isUnlocked then
		warn(string.format("[CAPTURE SERVICE] АНТИЧИТ: Игрок %s пытался поймать призрака в закрытой локации %s!", player.Name, zoneId))
		return
	end

	-- 4. АНТИЧИТ: Проверка расстояния до авторитетной серверной позиции призрака
	local ghostPos = ghostEntity:GetAttribute("Position")
	if not ghostPos then return end

	local distance = (rootPart.Position - ghostPos).Magnitude
	local maxAllowedDistance = GameConfig.TrapRange + 5

	if distance > maxAllowedDistance then
		warn(string.format("[CAPTURE SERVICE] АНТИЧИТ: Игрок %s пытался поймать призрака слишком далеко! (Дистанция: %.1f, Макс: %.1f)", player.Name, distance, maxAllowedDistance))
		return
	end

	-- 5. Проверка вместимости сумки
	if InventoryService.isFull(player) then
		local notificationEvent = Remotes.getEvent("ShowNotification")
		notificationEvent:FireClient(player, "Сумка полна!")
		return
	end

	-- 6. Считываем редкость и начисляем награду
	local rarity = ghostEntity:GetAttribute("Rarity")
	if not rarity then return end

	-- Удаляем логическую сущность на сервере
	ghostEntity:Destroy()

	-- Добавляем в инвентарь игрока
	local success = InventoryService.addGhost(player, rarity)
	if success then
		print(string.format("[CAPTURE SERVICE] Игрок %s успешно поймал призрака: %s в зоне %s", player.Name, rarity, zoneId))
		
		-- Синхронизируем инвентарь с клиентом
		local inventoryUpdateEvent = Remotes.getEvent("InventoryUpdate")
		inventoryUpdateEvent:FireClient(player, InventoryService.getInventory(player))
	end
end

return CaptureService
