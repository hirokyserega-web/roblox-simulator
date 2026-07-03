-- Модуль спавнера привидений на сервере с учетом редкостей и шансов
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local GhostConfig = require(ReplicatedStorage.Shared.config.GhostConfig)

local GhostSpawner = {}
local spawnedGhostsFolder = nil
local spawnZone = nil

-- Вспомогательная функция для выбора редкости на основе весов (шансов)
local function chooseRandomRarity(): string
	-- Вычисляем общую сумму шансов
	local totalWeight = 0
	for _, config in pairs(GhostConfig) do
		totalWeight = totalWeight + config.SpawnChance
	end

	-- Выбираем случайное число в пределах общей суммы
	local randomValue = math.random() * totalWeight
	local cumulativeWeight = 0

	for rarityId, config in pairs(GhostConfig) do
		cumulativeWeight = cumulativeWeight + config.SpawnChance
		if randomValue <= cumulativeWeight then
			return rarityId
		end
	end

	return "Common" -- Резервный вариант
end

-- Инициализация и старт спавна привидений
function GhostSpawner.start(zonePart: Part)
	spawnZone = zonePart

	-- Создаем или находим папку для привидений в Workspace
	spawnedGhostsFolder = Workspace:FindFirstChild("SpawnedGhosts")
	if not spawnedGhostsFolder then
		spawnedGhostsFolder = Instance.new("Folder")
		spawnedGhostsFolder.Name = "SpawnedGhosts"
		spawnedGhostsFolder.Parent = Workspace
	end

	-- Запускаем бесконечный цикл спавна
	task.spawn(function()
		while true do
			task.wait(GameConfig.SpawnInterval)
			GhostSpawner.spawnGhost()
		end
	end)
	
	print("[GHOST SPAWNER] Запущен спавн привидений в зоне " .. spawnZone.Name)
end

-- Логика спавна одного призрака
function GhostSpawner.spawnGhost()
	if not spawnZone or not spawnedGhostsFolder then return end

	-- Проверка лимита максимального количества призраков
	local currentCount = #spawnedGhostsFolder:GetChildren()
	if currentCount >= GameConfig.MaxGhosts then
		return
	end

	-- Выбираем редкость
	local rarityId = chooseRandomRarity()
	local info = GhostConfig[rarityId]
	if not info then return end

	-- Создаем физическую часть привидения
	local ghostPart = Instance.new("Part")
	ghostPart.Name = "Ghost_" .. rarityId
	ghostPart.Shape = Enum.PartType.Ball
	ghostPart.Size = Vector3.new(3, 3, 3)
	ghostPart.Color = info.Color
	ghostPart.Material = Enum.Material.Neon
	ghostPart.CanCollide = false
	ghostPart.Anchored = true
	ghostPart.TopSurface = Enum.SurfaceType.Smooth
	ghostPart.BottomSurface = Enum.SurfaceType.Smooth

	-- Вычисляем случайную позицию в границах зоны
	local zoneSize = spawnZone.Size
	local zonePos = spawnZone.Position
	local randomX = zonePos.X + (math.random() - 0.5) * zoneSize.X
	local randomZ = zonePos.Z + (math.random() - 0.5) * zoneSize.Z
	local spawnY = zonePos.Y + (zoneSize.Y / 2) + (ghostPart.Size.Y / 2) + 1.5 -- Немного над землей

	ghostPart.Position = Vector3.new(randomX, spawnY, randomZ)

	-- Задаем необходимые атрибуты согласно ТЗ и ИИ поведению
	ghostPart:SetAttribute("Rarity", rarityId)
	ghostPart:SetAttribute("GhostId", HttpService:GenerateGUID(false))
	ghostPart:SetAttribute("Value", info.BasePrice)
	
	-- Поведение призрака для GhostBehaviorService
	ghostPart:SetAttribute("BehaviorType", info.BehaviorType)
	ghostPart:SetAttribute("Speed", info.Speed)
	ghostPart:SetAttribute("FleeRange", info.FleeRange)
	ghostPart:SetAttribute("AggroRange", info.AggroRange)
	ghostPart:SetAttribute("TeleportInterval", info.TeleportInterval)
	ghostPart:SetAttribute("ScareInterval", info.ScareInterval)
	ghostPart:SetAttribute("FloatSeed", math.random() * 100)

	-- Помещаем в папку привидений
	ghostPart.Parent = spawnedGhostsFolder
	print(string.format("[GHOST SPAWNER] Появился призрак: %s (%s). Текущее количество: %d/%d", info.Name, rarityId, #spawnedGhostsFolder:GetChildren(), GameConfig.MaxGhosts))
end

return GhostSpawner
