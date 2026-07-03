-- Модуль спавнера привидений на сервере с учетом локаций, редкостей и лимитов
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local GhostConfig = require(ReplicatedStorage.Shared.config.GhostConfig)
local LocationConfig = require(ReplicatedStorage.Shared.config.LocationConfig)

local GhostSpawner = {}
local spawnedGhostsFolder = nil
local activeZones = {}

-- Выбор случайной редкости призрака из списка разрешенных для конкретной зоны
local function chooseRandomRarityForZone(allowedGhosts: table): string
	local totalWeight = 0
	for _, rarityId in ipairs(allowedGhosts) do
		local config = GhostConfig[rarityId]
		if config then
			totalWeight = totalWeight + config.SpawnChance
		end
	end

	if totalWeight <= 0 then
		return "Common"
	end

	local randomValue = math.random() * totalWeight
	local cumulativeWeight = 0

	for _, rarityId in ipairs(allowedGhosts) do
		local config = GhostConfig[rarityId]
		if config then
			cumulativeWeight = cumulativeWeight + config.SpawnChance
			if randomValue <= cumulativeWeight then
				return rarityId
			end
		end
	end

	return allowedGhosts[1] or "Common"
end

-- Инициализация и запуск спавнера во всех локациях
function GhostSpawner.start(zonesTable: table)
	activeZones = zonesTable

	-- Создаем или находим папку для привидений в Workspace
	spawnedGhostsFolder = Workspace:FindFirstChild("SpawnedGhosts")
	if not spawnedGhostsFolder then
		spawnedGhostsFolder = Instance.new("Folder")
		spawnedGhostsFolder.Name = "SpawnedGhosts"
		spawnedGhostsFolder.Parent = Workspace
	end

	-- Запускаем отдельные потоки спавна для каждой зоны
	for zoneId, zonePart in pairs(activeZones) do
		local config = LocationConfig[zoneId]
		if not config then continue end

		task.spawn(function()
			while true do
				task.wait(GameConfig.SpawnInterval)
				local ok, err = pcall(function()
					GhostSpawner.spawnGhostInZone(zoneId, zonePart)
				end)
				if not ok then
					warn(string.format("[GHOST SPAWNER] Ошибка спавна в зоне %s: %s", zoneId, tostring(err)))
				end
			end
		end)
		print("[GHOST SPAWNER] Запущен спавн для локации: " .. config.DisplayName)
	end
end

-- Подсчет количества призраков, заспавненных в определенной зоне
local function getGhostsCountInZone(zoneId: string): number
	local count = 0
	for _, ghost in ipairs(spawnedGhostsFolder:GetChildren()) do
		if ghost:GetAttribute("SpawnZoneName") == zoneId then
			count = count + 1
		end
	end
	return count
end

-- Спавн призрака в конкретной зоне
function GhostSpawner.spawnGhostInZone(zoneId: string, zonePart: Part)
	local config = LocationConfig[zoneId]
	if not config or not spawnedGhostsFolder then return end

	-- Проверка зонального лимита
	local currentCount = getGhostsCountInZone(zoneId)
	if currentCount >= config.MaxGhosts then
		return
	end

	-- Выбор редкости
	local rarityId = chooseRandomRarityForZone(config.AllowedGhosts)
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
	ghostPart.TopSurface = Enum.SurfaceType.Smooth
	ghostPart.BottomSurface = Enum.SurfaceType.Smooth
	ghostPart.Anchored = true

	-- Вычисляем случайную позицию в границах зоны
	local zoneSize = zonePart.Size
	local zonePos = zonePart.Position
	local randomX = zonePos.X + (math.random() - 0.5) * zoneSize.X
	local randomZ = zonePos.Z + (math.random() - 0.5) * zoneSize.Z
	local spawnY = zonePos.Y + (zoneSize.Y / 2) + (ghostPart.Size.Y / 2) + 1.5

	ghostPart.Position = Vector3.new(randomX, spawnY, randomZ)

	-- Задаем необходимые атрибуты
	ghostPart:SetAttribute("Rarity", rarityId)
	ghostPart:SetAttribute("GhostId", HttpService:GenerateGUID(false))
	ghostPart:SetAttribute("Value", info.BasePrice)
	ghostPart:SetAttribute("SpawnZoneName", zoneId)

	-- Поведение призрака для GhostBehaviorService
	ghostPart:SetAttribute("BehaviorType", info.BehaviorType)
	ghostPart:SetAttribute("Speed", info.Speed)
	ghostPart:SetAttribute("FleeRange", info.FleeRange)
	ghostPart:SetAttribute("AggroRange", info.AggroRange)
	ghostPart:SetAttribute("TeleportInterval", info.TeleportInterval)
	ghostPart:SetAttribute("ScareInterval", info.ScareInterval)
	ghostPart:SetAttribute("FloatSeed", math.random() * 100)

	-- Помещаем в общую папку привидений
	ghostPart.Parent = spawnedGhostsFolder
end

return GhostSpawner
