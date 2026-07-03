-- Сервис генерации локаций и управления барьерами покупки
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local LocationConfig = require(ReplicatedStorage.Shared.config.LocationConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CurrencyService = require(ServerScriptService.Server.CurrencyService)

local LocationService = {}
local zonesFolder = nil
local generatedZones = {}

-- Создание 3D текста над табличкой покупки
local function createSignBillboard(signPart: Part, text: string)
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = signPart

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(241, 196, 15) -- Золотой
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.Font = Enum.Font.FredokaOne
	label.TextSize = 14
	label.Parent = billboard
end

-- Инициализация локаций
function LocationService.init()
	-- Создаем или находим папку локаций в Workspace
	zonesFolder = Workspace:FindFirstChild("Locations")
	if not zonesFolder then
		zonesFolder = Instance.new("Folder")
		zonesFolder.Name = "Locations"
		zonesFolder.Parent = Workspace
	end

	-- Генерация локаций на основе конфига
	for zoneId, config in pairs(LocationConfig) do
		local zonePart = Workspace:FindFirstChild("Zone_" .. zoneId)
		if not zonePart then
			zonePart = Instance.new("Part")
			zonePart.Name = "Zone_" .. zoneId
			zonePart.Position = config.Position
			zonePart.Size = config.Size
			zonePart.Anchored = true
			zonePart.CanCollide = false
			zonePart.Transparency = 0.8
			zonePart.Material = Enum.Material.Glass
			
			-- Цветовое отличие локаций
			if zoneId == "StarterArea" then
				zonePart.Color = Color3.fromRGB(150, 220, 255) -- Голубой
			elseif zoneId == "ForestArea" then
				zonePart.Color = Color3.fromRGB(150, 255, 150) -- Зеленый
			elseif zoneId == "MansionArea" then
				zonePart.Color = Color3.fromRGB(255, 150, 150) -- Красный
			end
			
			zonePart.Parent = zonesFolder
			
			-- 3D подпись над локацией
			local billboard = Instance.new("BillboardGui")
			billboard.Size = UDim2.new(0, 250, 0, 50)
			billboard.StudsOffset = Vector3.new(0, 5, 0)
			billboard.AlwaysOnTop = true
			billboard.Parent = zonePart
			
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Text = config.DisplayName:upper()
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
			label.TextStrokeTransparency = 0
			label.Font = Enum.Font.FredokaOne
			label.TextSize = 16
			label.Parent = billboard
		end

		generatedZones[zoneId] = zonePart

		-- Если у локации есть барьер покупки
		if config.BarrierPosition and config.BarrierSize then
			local barrierName = "Barrier_" .. zoneId
			local barrierPart = Workspace:FindFirstChild(barrierName)
			
			if not barrierPart then
				barrierPart = Instance.new("Part")
				barrierPart.Name = barrierName
				barrierPart.Position = config.BarrierPosition
				barrierPart.Size = config.BarrierSize
				barrierPart.Anchored = true
				barrierPart.CanCollide = true
				barrierPart.Transparency = 0.5
				barrierPart.Color = Color3.fromRGB(231, 76, 60) -- Красный барьер
				barrierPart.Material = Enum.Material.ForceField
				barrierPart.Parent = zonesFolder
			end

			-- Создаем табличку покупки с ProximityPrompt
			local signName = "Sign_" .. zoneId
			local signPart = Workspace:FindFirstChild(signName)
			
			if not signPart then
				signPart = Instance.new("Part")
				signPart.Name = signName
				signPart.Position = config.SignPosition
				signPart.Size = Vector3.new(3, 4, 3)
				signPart.Anchored = true
				signPart.CanCollide = true
				signPart.Color = Color3.fromRGB(120, 80, 50) -- Деревянная тумба
				signPart.Material = Enum.Material.Wood
				signPart.Parent = zonesFolder

				createSignBillboard(signPart, string.format("Разблокировать: %s\nЦена: $%d", config.DisplayName, config.Cost))

				-- Добавляем ProximityPrompt для покупки
				local prompt = Instance.new("ProximityPrompt")
				prompt.ObjectText = config.DisplayName
				prompt.ActionText = "Купить зону"
				prompt.KeyboardKeyCode = Enum.KeyCode.E
				prompt.MaxActivationDistance = 8
				prompt.RequiresLineOfSight = false
				prompt.Parent = signPart

				prompt.Triggered:Connect(function(player)
					LocationService.processZonePurchase(player, zoneId)
				end)
			end
		end
	end

	print("[LOCATION SERVICE] Локации успешно инициализированы!")
end

-- Обработка покупки зоны игроком
function LocationService.processZonePurchase(player: Player, zoneId: string)
	local config = LocationConfig[zoneId]
	if not config then return end

	-- Проверяем, разблокирована ли уже
	if player:GetAttribute("Unlocked_" .. zoneId) == true then
		local notificationEvent = Remotes.getEvent("ShowNotification")
		notificationEvent:FireClient(player, "Вы уже разблокировали эту локацию!")
		return
	end

	local cost = config.Cost
	local success = CurrencyService.spend(player, "Money", cost)
	
	if success then
		-- Выставляем статус разблокировки
		player:SetAttribute("Unlocked_" .. zoneId, true)
		
		print(string.format("[LOCATION SERVICE] Игрок %s разблокировал зону %s за %d монет", player.Name, zoneId, cost))

		local notificationEvent = Remotes.getEvent("ShowNotification")
		notificationEvent:FireClient(player, string.format("Разблокировано: %s!", config.DisplayName))
	else
		local notificationEvent = Remotes.getEvent("ShowNotification")
		notificationEvent:FireClient(player, "Недостаточно монет для покупки локации!")
	end
end

-- Получить сгенерированные плиты зон
function LocationService.getZones(): table
	return generatedZones
end

return LocationService
