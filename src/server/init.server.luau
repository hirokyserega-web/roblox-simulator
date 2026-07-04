-- Точка входа сервера для Ghost Hunter Simulator
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local LocationConfig = require(ReplicatedStorage.Shared.config.LocationConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local GhostSpawner = require(ServerScriptService.Server.GhostSpawner)
local InventoryService = require(ServerScriptService.Server.InventoryService)
local CaptureService = require(ServerScriptService.Server.CaptureService)
local CurrencyService = require(ServerScriptService.Server.CurrencyService)
local SellService = require(ServerScriptService.Server.SellService)
local UpgradeService = require(ServerScriptService.Server.UpgradeService)
local DataService = require(ServerScriptService.Server.DataService)
local LeaderboardService = require(ServerScriptService.Server.LeaderboardService)
local GhostBehaviorService = require(ServerScriptService.Server.GhostBehaviorService)
local LocationService = require(ServerScriptService.Server.LocationService)
local PetService = require(ServerScriptService.Server.PetService)
local RebirthService = require(ServerScriptService.Server.RebirthService)
local PromoService = require(ServerScriptService.Server.PromoService)
local DailyRewardService = require(ServerScriptService.Server.DailyRewardService)

print("Server started")

-- Функция создания или получения зоны спавна привидений
local function getOrCreateSpawnZone(): Part
	local spawnZone = Workspace:FindFirstChild("SpawnZone")
	if not spawnZone then
		spawnZone = Instance.new("Part")
		spawnZone.Name = "SpawnZone"
		spawnZone.Position = GameConfig.SpawnZonePosition or Vector3.new(0, 5, 0)
		spawnZone.Size = GameConfig.SpawnZoneSize or Vector3.new(10, 1, 10)
		spawnZone.Anchored = true
		spawnZone.CanCollide = false
		spawnZone.Transparency = 0.8
		spawnZone.Material = Enum.Material.Glass
		spawnZone.Color = Color3.fromRGB(150, 220, 255) -- Голубая полупрозрачная плита
		spawnZone.Parent = Workspace
		
		-- Добавим визуальную 3D подпись над спавн-зоной
		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 5, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = spawnZone
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = "GHOST SPAWN ZONE"
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.FredokaOne
		label.TextSize = 16
		label.Parent = billboard
	end
	return spawnZone
end

-- Инициализация систем
local function init()
	-- Создаем корневую папку для локальных призраков в ReplicatedStorage
	local playerGhostsFolder = ReplicatedStorage:FindFirstChild("PlayerGhosts")
	if not playerGhostsFolder then
		playerGhostsFolder = Instance.new("Folder")
		playerGhostsFolder.Name = "PlayerGhosts"
		playerGhostsFolder.Parent = ReplicatedStorage
	end

	-- Инициализация экономики, рынка и улучшений
	SellService.init()
	UpgradeService.init()
	
	-- Инициализация сохранения
	DataService.init()
	
	-- Инициализация лидерборда
	LeaderboardService.init()
	
	-- Инициализация логики локаций
	LocationService.init()

	-- Создание спавн-зоны
	getOrCreateSpawnZone()

	-- Инициализация поведения призраков (ИИ)
	GhostBehaviorService.init()
	
	-- Инициализация спавнера
	GhostSpawner.init(LocationService.getZones())
	
	-- Инициализация логики питомцев
	PetService.init()
	
	-- Инициализация перерождений
	RebirthService.init()

	-- Инициализация промокодов
	PromoService.init()

	-- Инициализация ежедневных наград
	DailyRewardService.init()
	
	-- Запуск сервиса поимки
	CaptureService.init()
	
	-- Настройка игрока при входе
	local function onPlayerAdded(player: Player)
		-- Создаем личную подпапку игрока в ReplicatedStorage
		local pFolder = Instance.new("Folder")
		pFolder.Name = tostring(player.UserId)
		pFolder.Parent = playerGhostsFolder

		-- Загружаем данные из DataStore
		local loadedData = DataService.loadData(player)
		
		-- Инициализируем валюту и улучшения на основе загруженных данных
		CurrencyService.setupPlayer(player, loadedData)
		UpgradeService.setupPlayer(player, loadedData)
		InventoryService.setupPlayer(player, loadedData and loadedData.Ghosts)
		
		-- Инициализируем питомцев
		PetService.setupPlayer(player, loadedData and loadedData.Pets)
		
		-- Инициализируем перерождения
		RebirthService.setupPlayer(player, loadedData and loadedData.Rebirths)
		
		-- Инициализируем промокоды и ежедневные награды
		PromoService.setupPlayer(player, loadedData and loadedData.ClaimedCodes)
		DailyRewardService.setupPlayer(player, loadedData and loadedData.DailyStatus)

		-- Инициализируем разблокированные локации динамически
		if loadedData and loadedData.Locations then
			for zoneId, unlocked in pairs(loadedData.Locations) do
				player:SetAttribute("Zone_" .. zoneId, unlocked == true)
			end
		end
		
		-- Инициализируем персональный спавн призраков
		GhostSpawner.setupPlayer(player)

		-- Синхронизируем инвентарь
		local invData = InventoryService.getInventory(player)
		if invData then
			Remotes.getEvent("InventoryUpdate"):FireClient(player, invData)
		end
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(onPlayerAdded, player)
	end

	-- Слушаем выход игроков для сохранения и очистки памяти
	Players.PlayerRemoving:Connect(function(player)
		DataService.saveData(player)
		GhostSpawner.removePlayer(player)

		-- Удаляем логическую папку призраков игрока
		local pFolder = playerGhostsFolder:FindFirstChild(tostring(player.UserId))
		if pFolder then
			pFolder:Destroy()
		end

		InventoryService.removePlayer(player)
		CurrencyService.removePlayer(player)
		UpgradeService.removePlayer(player)
		PetService.removePlayer(player)
		RebirthService.removePlayer(player)
		PromoService.removePlayer(player)
		DailyRewardService.removePlayer(player)
	end)
end

init()
