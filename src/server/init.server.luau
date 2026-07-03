-- Точка входа сервера для Ghost Hunter Simulator
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local GhostSpawner = require(ServerScriptService.Server.GhostSpawner)
local InventoryService = require(ServerScriptService.Server.InventoryService)
local CaptureService = require(ServerScriptService.Server.CaptureService)
local CurrencyService = require(ServerScriptService.Server.CurrencyService)
local SellService = require(ServerScriptService.Server.SellService)
local UpgradeService = require(ServerScriptService.Server.UpgradeService)
local DataService = require(ServerScriptService.Server.DataService)
local LeaderboardService = require(ServerScriptService.Server.LeaderboardService)

print("Server started")

-- Функция создания или получения зоны спавна привидений
local function getOrCreateSpawnZone(): Part
	local spawnZone = Workspace:FindFirstChild("SpawnZone")
	if not spawnZone then
		spawnZone = Instance.new("Part")
		spawnZone.Name = "SpawnZone"
		spawnZone.Position = GameConfig.SpawnZonePosition
		spawnZone.Size = GameConfig.SpawnZoneSize
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
	local spawnZone = getOrCreateSpawnZone()
	
	-- Инициализация игровой экономики, рынка и улучшений
	SellService.init()
	UpgradeService.init()
	
	-- Инициализация системы сохранения
	DataService.init()
	
	-- Инициализация глобальной таблицы рекордов
	LeaderboardService.init()
	
	-- Запуск спавнера
	GhostSpawner.start(spawnZone)
	
	-- Запуск сервиса поимки
	CaptureService.init()
	
	-- Настройка игрока при входе
	local function onPlayerAdded(player: Player)
		-- Загружаем данные из DataStore
		local loadedData = DataService.loadData(player)
		
		-- Инициализируем валюту и улучшения на основе загруженных данных
		CurrencyService.setupPlayer(player, loadedData)
		UpgradeService.setupPlayer(player, loadedData)
		
		-- Синхронизируем пустой стартовый инвентарь
		local inventoryUpdateEvent = Remotes.getEvent("InventoryUpdate")
		inventoryUpdateEvent:FireClient(player, InventoryService.getInventory(player))
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(onPlayerAdded, player)
	end

	-- Слушаем выход игроков для сохранения и очистки памяти
	Players.PlayerRemoving:Connect(function(player)
		-- Сохраняем данные игрока перед его выходом
		DataService.saveData(player)
		
		InventoryService.removePlayer(player)
		CurrencyService.removePlayer(player)
		UpgradeService.removePlayer(player)
	end)
end

init()
