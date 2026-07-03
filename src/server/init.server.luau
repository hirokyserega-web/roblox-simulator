-- Точка входа сервера для Ghost Hunter Simulator
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local GhostSpawner = require(ServerScriptService.Server.GhostSpawner)
local InventoryService = require(ServerScriptService.Server.InventoryService)
local CaptureService = require(ServerScriptService.Server.CaptureService)

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
	
	-- Запуск спавнера
	GhostSpawner.start(spawnZone)
	
	-- Запуск сервиса поимки
	CaptureService.init()
	
	-- Слушаем выход игроков для очистки памяти
	Players.PlayerRemoving:Connect(function(player)
		InventoryService.removePlayer(player)
	end)
end

init()
