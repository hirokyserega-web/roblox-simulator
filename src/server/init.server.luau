-- Главный серверный скрипт инициализации Ghost Hunter Simulator
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local PlayerStateManager = require(ServerScriptService.Server.PlayerStateManager)
local GhostManager = require(ServerScriptService.Server.GhostManager)
local SellManager = require(ServerScriptService.Server.SellManager)
local RebirthManager = require(ServerScriptService.Server.RebirthManager)

-- Автоматическое создание зон, если они не созданы в Workspace
local function setupMapParts()
	local spawnZone = Workspace:FindFirstChild("SpawnZone")
	if not spawnZone then
		spawnZone = Instance.new("Part")
		spawnZone.Name = "SpawnZone"
		spawnZone.Position = GameConfig.Map.SpawnZonePosition
		spawnZone.Size = GameConfig.Map.SpawnZoneSize
		spawnZone.Anchored = true
		spawnZone.CanCollide = false
		spawnZone.Transparency = 0.7
		spawnZone.Material = Enum.Material.Glass
		spawnZone.Color = Color3.fromRGB(173, 216, 230) -- Light Blue
		spawnZone.Parent = Workspace
		
		-- Текст-подсказка над зоной
		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 4, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = spawnZone
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = "GHOST SPAWN AREA"
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.FredokaOne
		label.TextSize = 16
		label.Parent = billboard
	end

	local sellZone = Workspace:FindFirstChild("SellZone")
	if not sellZone then
		sellZone = Instance.new("Part")
		sellZone.Name = "SellZone"
		sellZone.Position = GameConfig.Map.SellZonePosition
		sellZone.Size = GameConfig.Map.SellZoneSize
		sellZone.Anchored = true
		sellZone.CanCollide = false
		sellZone.Transparency = 0.5
		sellZone.Material = Enum.Material.Neon
		sellZone.Color = Color3.fromRGB(255, 85, 85) -- Soft Red
		sellZone.Parent = Workspace
		
		-- Текст-подсказка над зоной продажи
		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 4, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = sellZone
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = "SELL ZONE"
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.FredokaOne
		label.TextSize = 16
		label.Parent = billboard
	end
	
	return spawnZone, sellZone
end

-- Событие входа игрока
local function onPlayerAdded(player: Player)
	PlayerStateManager.setupPlayer(player)
end

-- Точка входа сервера
local function main()
	local spawnZone, sellZone = setupMapParts()
	
	-- Инициализируем менеджеры
	GhostManager.init(spawnZone)
	SellManager.init(sellZone)
	RebirthManager.init()

	-- Подключение событий игроков
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(onPlayerAdded, player)
	end
	
	print("[SERVER INITIALIZED SUCCESSFULLY] Ghost Hunter Simulator готовы к работе!")
end

main()
