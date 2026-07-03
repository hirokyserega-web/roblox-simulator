-- Сервис обработки и валидации поимки привидений на сервере
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local InventoryService = require(script.Parent.InventoryService)

local CaptureService = {}
local spawnedGhostsFolder = nil

-- Инициализация сервиса
function CaptureService.init()
	spawnedGhostsFolder = Workspace:FindFirstChild("SpawnedGhosts")
	
	-- Подключаем сетевой ресивер для поимки
	local captureEvent = Remotes.getEvent("CaptureGhost")
	captureEvent.OnServerEvent:Connect(CaptureService.onCaptureRequest)
	
	print("[CAPTURE SERVICE] Сервис поимки успешно запущен!")
end

-- Обработка запроса на поимку от клиента
function CaptureService.onCaptureRequest(player: Player, ghostPart: Instance)
	if not spawnedGhostsFolder then return end

	-- 1. Античит/Проверка безопасности: существует ли привидение в нужной папке
	if not ghostPart or not ghostPart:IsDescendantOf(spawnedGhostsFolder) then
		warn(string.format("[CAPTURE SERVICE] Игрок %s передал невалидный объект привидения!", player.Name))
		return
	end

	-- 2. Проверка персонажа и HumanoidRootPart
	local character = player.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- 3. Античит/Проверка расстояния с учетом сетевого пинга (+5 студов буфер)
	local distance = (rootPart.Position - ghostPart.Position).Magnitude
	local maxAllowedDistance = GameConfig.TrapRange + 5

	if distance > maxAllowedDistance then
		warn(string.format("[CAPTURE SERVICE] Подозрение на читы! Игрок %s пытался поймать привидение слишком далеко (Расстояние: %.1f, Макс: %.1f)", player.Name, distance, maxAllowedDistance))
		return
	end

	-- 4. Проверка лимита рюкзака
	if InventoryService.isFull(player) then
		-- Отправляем уведомление на клиент о заполненности рюкзака
		local notificationEvent = Remotes.getEvent("ShowNotification")
		notificationEvent:FireClient(player, "Сумка полна!")
		return
	end

	-- 5. Получение характеристик привидения из атрибутов
	local rarity = ghostPart:GetAttribute("Rarity")
	if not rarity then
		warn("[CAPTURE SERVICE] Объект не содержит атрибута Rarity!")
		return
	end

	-- 6. Процесс поимки: удаляем привидение и добавляем в инвентарь игрока
	ghostPart:Destroy()
	local success = InventoryService.addGhost(player, rarity)
	
	if success then
		print(string.format("[CAPTURE SERVICE] Игрок %s поймал призрака: %s", player.Name, rarity))
		
		-- Отправляем обновленный инвентарь клиенту для синхронизации
		local inventoryUpdateEvent = Remotes.getEvent("InventoryUpdate")
		inventoryUpdateEvent:FireClient(player, InventoryService.getInventory(player))
	end
end

return CaptureService
