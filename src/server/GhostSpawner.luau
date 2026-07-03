-- Модуль спавнера привидений на сервере (Логический спавн в ReplicatedStorage для каждого игрока)
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local GhostConfig = require(ReplicatedStorage.Shared.config.GhostConfig)
local LocationConfig = require(ReplicatedStorage.Shared.config.LocationConfig)

local GhostSpawner = {}
local playerGhostsFolder = nil
local activeZones = {}
local activePlayerTasks = {} -- Ключ: UserId, Значение: boolean (активен ли спавнер для игрока)

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

-- Инициализация спавнера
function GhostSpawner.init(zonesTable: table)
	activeZones = zonesTable
	playerGhostsFolder = ReplicatedStorage:FindFirstChild("PlayerGhosts")
end

-- Подсчет призраков игрока в конкретной зоне
local function getPlayerGhostsCountInZone(playerFolder: Folder, zoneId: string): number
	local count = 0
	for _, entity in ipairs(playerFolder:GetChildren()) do
		if entity:GetAttribute("SpawnZoneName") == zoneId then
			count = count + 1
		end
	end
	return count
end

-- Спавн логического призрака для конкретного игрока в конкретной зоне
local function spawnLogicalGhostForPlayer(player: Player, playerFolder: Folder, zoneId: string, zonePart: Part)
	local config = LocationConfig[zoneId]
	if not config then return end

	-- Выбор редкости
	local rarityId = chooseRandomRarityForZone(config.AllowedGhosts)
	local info = GhostConfig[rarityId]
	if not info then return end

	-- Расчет случайных координат в границах зоны спавна
	local zoneSize = zonePart.Size
	local zonePos = zonePart.Position
	local randomX = zonePos.X + (math.random() - 0.5) * zoneSize.X
	local randomZ = zonePos.Z + (math.random() - 0.5) * zoneSize.Z
	local spawnY = zonePos.Y + (zoneSize.Y / 2) + 1.5 -- Высота (будущая центральная точка парта)

	local targetPosition = Vector3.new(randomX, spawnY, randomZ)

	-- Создаем логический объект (папку) призрака в ReplicatedStorage
	local ghostEntity = Instance.new("Folder")
	ghostEntity.Name = "GhostEntity_" .. rarityId

	-- Задаем все атрибуты ИИ и поимки
	ghostEntity:SetAttribute("Rarity", rarityId)
	ghostEntity:SetAttribute("GhostId", HttpService:GenerateGUID(false))
	ghostEntity:SetAttribute("Value", info.BasePrice)
	ghostEntity:SetAttribute("SpawnZoneName", zoneId)
	ghostEntity:SetAttribute("Position", targetPosition)
	
	-- Поведение
	ghostEntity:SetAttribute("BehaviorType", info.BehaviorType)
	ghostEntity:SetAttribute("Speed", info.Speed)
	ghostEntity:SetAttribute("FleeRange", info.FleeRange)
	ghostEntity:SetAttribute("AggroRange", info.AggroRange)
	ghostEntity:SetAttribute("TeleportInterval", info.TeleportInterval)
	ghostEntity:SetAttribute("ScareInterval", info.ScareInterval)
	ghostEntity:SetAttribute("FloatSeed", math.random() * 100)

	ghostEntity.Parent = playerFolder
end

-- Инициализация персонального спавна для вошедшего игрока
function GhostSpawner.setupPlayer(player: Player)
	local userId = player.UserId
	activePlayerTasks[userId] = true

	local pFolder = playerGhostsFolder:WaitForChild(tostring(userId), 10)
	if not pFolder then
		warn("[GHOST SPAWNER] Не найдена папка PlayerGhosts для игрока: " .. player.Name)
		return
	end

	-- Запускаем поток персонального спавна
	task.spawn(function()
		while activePlayerTasks[userId] and player.Parent do
			task.wait(GameConfig.SpawnInterval)
			
			-- Пробегаемся по всем локациям
			for zoneId, zonePart in pairs(activeZones) do
				local config = LocationConfig[zoneId]
				if not config then continue end

				-- Валидация античита / разблокировки:
				-- Призраки не будут спавниться в заблокированных для игрока локациях!
				local isUnlocked = (config.Cost == 0) or (player:GetAttribute("Unlocked_" .. zoneId) == true)
				if isUnlocked then
					local currentCount = getPlayerGhostsCountInZone(pFolder, zoneId)
					if currentCount < config.MaxGhosts then
						pcall(function()
							spawnLogicalGhostForPlayer(player, pFolder, zoneId, zonePart)
						end)
					end
				end
			end
		end
		print("[GHOST SPAWNER] Поток спавнера остановлен для " .. player.Name)
	end)

	print("[GHOST SPAWNER] Персональный спавнер успешно запущен для " .. player.Name)
end

-- Остановка спавнера для вышедшего игрока
function GhostSpawner.removePlayer(player: Player)
	activePlayerTasks[player.UserId] = nil
end

return GhostSpawner
