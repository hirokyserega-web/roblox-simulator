-- Сервис управления поведением призраков на сервере (ИИ) с поддержкой зональных лимитов
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local GhostConfig = require(ReplicatedStorage.Shared.config.GhostConfig)
local UpgradeConfig = require(ReplicatedStorage.Shared.config.UpgradeConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local InventoryService = require(script.Parent.InventoryService)

local GhostBehaviorService = {}
local spawnedGhostsFolder = nil
local locationsFolder = nil
local active = false

-- Вспомогательная функция телепортации призрака в случайную точку его зоны спавна
local function teleportGhost(ghostPart: Part, zonePart: Part)
	if not zonePart then return end
	local zoneSize = zonePart.Size
	local zonePos = zonePart.Position
	local randomX = zonePos.X + (math.random() - 0.5) * zoneSize.X
	local randomZ = zonePos.Z + (math.random() - 0.5) * zoneSize.Z
	local spawnY = zonePos.Y + (zoneSize.Y / 2) + (ghostPart.Size.Y / 2) + 1.5
	
	ghostPart.Position = Vector3.new(randomX, spawnY, randomZ)
end

-- Инициализация сервиса поведения призраков
function GhostBehaviorService.init()
	spawnedGhostsFolder = Workspace:FindFirstChild("SpawnedGhosts")
	locationsFolder = Workspace:FindFirstChild("Locations")
	
	if not spawnedGhostsFolder or not locationsFolder then
		warn("[GHOST BEHAVIOR] Не найдены папка призраков или папка локаций в Workspace!")
		return
	end

	active = true

	-- Запускаем цикл ИИ призраков (каждые 0.1 секунды)
	task.spawn(function()
		local dt = 0.1
		while active do
			task.wait(dt)
			local ok, err = pcall(function()
				GhostBehaviorService.tick(dt)
			end)
			if not ok then
				warn("[GHOST BEHAVIOR] Ошибка в цикле ИИ: " .. tostring(err))
			end
		end
	end)

	print("[GHOST BEHAVIOR SERVICE] Запущен!")
end

-- Основной цикл ИИ для всех заспавненных призраков
function GhostBehaviorService.tick(dt: number)
	local ghosts = spawnedGhostsFolder:GetChildren()
	if #ghosts == 0 then return end

	local players = Players:GetPlayers()
	if #players == 0 then return end

	for _, ghost in ipairs(ghosts) do
		if not ghost:IsA("BasePart") then continue end

		-- Считываем локацию призрака и находим её плиту
		local zoneName = ghost:GetAttribute("SpawnZoneName") or "StarterArea"
		local zonePart = locationsFolder:FindFirstChild("Zone_" .. zoneName)
		if not zonePart then continue end

		-- Границы зоны спавна для ограничения движения
		local minX = zonePart.Position.X - zonePart.Size.X / 2
		local maxX = zonePart.Position.X + zonePart.Size.X / 2
		local minZ = zonePart.Position.Z - zonePart.Size.Z / 2
		local maxZ = zonePart.Position.Z + zonePart.Size.Z / 2

		-- Считываем атрибуты призрака
		local behaviorType = ghost:GetAttribute("BehaviorType") or "Passive"
		local speed = ghost:GetAttribute("Speed") or 0
		local fleeRange = ghost:GetAttribute("FleeRange") or 15
		local aggroRange = ghost:GetAttribute("AggroRange") or 25
		local teleportInterval = ghost:GetAttribute("TeleportInterval") or 0
		local scareInterval = ghost:GetAttribute("ScareInterval") or 10

		-- 1. Находим ближайшего живого игрока
		local nearestPlayer = nil
		local minDistance = math.huge
		local nearestHrp = nil

		for _, player in ipairs(players) do
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local humanoid = char and char:FindFirstChildOfClass("Humanoid")
			
			if hrp and humanoid and humanoid.Health > 0 then
				local dist = (hrp.Position - ghost.Position).Magnitude
				if dist < minDistance then
					minDistance = dist
					nearestPlayer = player
					nearestHrp = hrp
				end
			end
		end

		if not nearestPlayer or not nearestHrp then continue end
		local playerPos = nearestHrp.Position

		-- 2. Вертикальное синусоидальное парение (применяется ко всем призракам)
		local floatSeed = ghost:GetAttribute("FloatSeed") or 0
		local floatOffset = math.sin(tick() * 2.5 + floatSeed) * 0.05
		local currentPos = ghost.Position + Vector3.new(0, floatOffset, 0)

		-- 3. Выполнение логики поведения
		if behaviorType == "Fleeing" and minDistance < fleeRange then
			-- Убегающий призрак (движется ОТ игрока)
			local direction = (currentPos - playerPos) * Vector3.new(1, 0, 1) -- Движение только по X/Z
			if direction.Magnitude > 0 then
				local moveDir = direction.Unit
				local targetPos = currentPos + moveDir * speed * dt
				
				-- Ограничиваем координаты границами спавн-зоны
				local clampedX = math.clamp(targetPos.X, minX, maxX)
				local clampedZ = math.clamp(targetPos.Z, minZ, maxZ)
				
				ghost.Position = Vector3.new(clampedX, targetPos.Y, clampedZ)
			end

		elseif behaviorType == "Aggressive" and minDistance < aggroRange then
			-- Агрессивный призрак (движется К игроку)
			local direction = (playerPos - currentPos) * Vector3.new(1, 0, 1)
			if direction.Magnitude > 0 then
				local moveDir = direction.Unit
				local targetPos = currentPos + moveDir * speed * dt
				
				local clampedX = math.clamp(targetPos.X, minX, maxX)
				local clampedZ = math.clamp(targetPos.Z, minZ, maxZ)
				
				ghost.Position = Vector3.new(clampedX, targetPos.Y, clampedZ)
			end

			-- Атака/Оглушение (Stun) при контакте
			if minDistance < 4 then
				local character = nearestPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				
				if humanoid and not nearestPlayer:GetAttribute("IsStunned") then
					-- Накладываем оглушение на сервере
					nearestPlayer:SetAttribute("IsStunned", true)
					humanoid.WalkSpeed = 0

					-- Сбрасываем 1 привидение из рюкзака игрока
					local inv = InventoryService.getInventory(nearestPlayer)
					if #inv.Ghosts > 0 then
						table.remove(inv.Ghosts, #inv.Ghosts)
						-- Синхронизируем инвентарь с клиентом
						local inventoryUpdateEvent = Remotes.getEvent("InventoryUpdate")
						inventoryUpdateEvent:FireClient(nearestPlayer, inv)
					end

					-- Запускаем испуг/атаку на клиенте
					local scareEvent = Remotes.getEvent("ScarePlayer")
					scareEvent:FireClient(nearestPlayer, "ATK")

					-- Телепортируем призрака прочь, чтобы не стан-лочить игрока бесконечно
					teleportGhost(ghost, zonePart)

					-- Возвращаем скорость через 2 секунды
					task.delay(2, function()
						if nearestPlayer and nearestPlayer.Parent then
							nearestPlayer:SetAttribute("IsStunned", nil)
							local speedLvl = nearestPlayer:GetAttribute("WalkSpeedLvl") or 1
							local normalSpeed = UpgradeConfig.WalkSpeed.Levels[speedLvl].Value
							local char = nearestPlayer.Character
							local hum = char and char:FindFirstChildOfClass("Humanoid")
							if hum then
								hum.WalkSpeed = normalSpeed
							end
						end
					end)
				end
			end
		else
			-- Пассивные призраки просто стоят на месте и парят
			ghost.Position = currentPos
		end

		-- 4. Периодическое поведение: Телепортация (для Teleport/Aggressive/Secret)
		if teleportInterval > 0 then
			local lastTeleport = ghost:GetAttribute("LastTeleport") or 0
			if tick() - lastTeleport >= teleportInterval then
				ghost:SetAttribute("LastTeleport", tick())
				-- Шанс 30% телепортироваться, если рядом есть игрок (например, пытается поймать)
				if minDistance < 25 and math.random() <= 0.3 then
					teleportGhost(ghost, zonePart)
					print("[GHOST BEHAVIOR] Призрак " .. ghost.Name .. " телепортировался!")
				end
			end
		end

		-- 5. Периодическое поведение: Испуг (Scare)
		if minDistance < 12 then
			local lastScare = ghost:GetAttribute("LastScare") or 0
			if tick() - lastScare >= scareInterval then
				ghost:SetAttribute("LastScare", tick())
				-- Запускаем испуг на клиенте
				local scareEvent = Remotes.getEvent("ScarePlayer")
				scareEvent:FireClient(nearestPlayer, "SCARE")
			end
		end
	end
end

-- Деактивация сервиса
function GhostBehaviorService.stop()
	active = false
end

return GhostBehaviorService
