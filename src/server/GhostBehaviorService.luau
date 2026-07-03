-- Сервис ИИ поведения призраков на сервере (Управление логическими объектами в ReplicatedStorage)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local GhostConfig = require(ReplicatedStorage.Shared.config.GhostConfig)
local UpgradeConfig = require(ReplicatedStorage.Shared.config.UpgradeConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local InventoryService = require(script.Parent.InventoryService)

local GhostBehaviorService = {}
local playerGhostsFolder = nil
local locationsFolder = nil
local active = false

-- Вспомогательная функция телепортации логического призрака
local function teleportGhost(ghostFolder: Folder, zonePart: Part)
	if not zonePart then return end
	local zoneSize = zonePart.Size
	local zonePos = zonePart.Position
	local randomX = zonePos.X + (math.random() - 0.5) * zoneSize.X
	local randomZ = zonePos.Z + (math.random() - 0.5) * zoneSize.Z
	local spawnY = zonePos.Y + (zoneSize.Y / 2) + 1.5
	
	ghostFolder:SetAttribute("Position", Vector3.new(randomX, spawnY, randomZ))
end

-- Инициализация сервиса
function GhostBehaviorService.init()
	playerGhostsFolder = ReplicatedStorage:FindFirstChild("PlayerGhosts")
	locationsFolder = Workspace:FindFirstChild("Locations")

	if not playerGhostsFolder or not locationsFolder then
		warn("[GHOST BEHAVIOR] Не найдены папки PlayerGhosts или Locations!")
		return
	end

	active = true

	-- Запускаем цикл ИИ для каждого игрока каждые 0.1 секунды
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

-- Основной цикл обновления ИИ
function GhostBehaviorService.tick(dt: number)
	for _, pFolder in ipairs(playerGhostsFolder:GetChildren()) do
		local userId = tonumber(pFolder.Name)
		if not userId then continue end

		local player = Players:GetPlayerByUserId(userId)
		if not player or not player.Parent then continue end

		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")
		
		-- Если персонаж жив, обрабатываем ИИ призраков конкретно для него
		if hrp and humanoid and humanoid.Health > 0 then
			local playerPos = hrp.Position

			for _, ghostFolder in ipairs(pFolder:GetChildren()) do
				if not ghostFolder:IsA("Folder") then continue end

				-- Считываем локацию призрака и её плиту
				local zoneName = ghostFolder:GetAttribute("SpawnZoneName") or "StarterArea"
				local zonePart = locationsFolder:FindFirstChild("Zone_" .. zoneName)
				if not zonePart then continue end

				-- Границы зоны спавна для ограничения движения
				local minX = zonePart.Position.X - zonePart.Size.X / 2
				local maxX = zonePart.Position.X + zonePart.Size.X / 2
				local minZ = zonePart.Position.Z - zonePart.Size.Z / 2
				local maxZ = zonePart.Position.Z + zonePart.Size.Z / 2

				-- Считываем атрибуты призрака
				local behaviorType = ghostFolder:GetAttribute("BehaviorType") or "Passive"
				local speed = ghostFolder:GetAttribute("Speed") or 0
				local fleeRange = ghostFolder:GetAttribute("FleeRange") or 15
				local aggroRange = ghostFolder:GetAttribute("AggroRange") or 25
				local teleportInterval = ghostFolder:GetAttribute("TeleportInterval") or 0
				local scareInterval = ghostFolder:GetAttribute("ScareInterval") or 10
				local currentPos = ghostFolder:GetAttribute("Position") or zonePart.Position

				local minDistance = (playerPos - currentPos).Magnitude

				-- Логика поведения
				if behaviorType == "Fleeing" and minDistance < fleeRange then
					-- Убегающий призрак (движется ОТ игрока)
					local direction = (currentPos - playerPos) * Vector3.new(1, 0, 1)
					if direction.Magnitude > 0 then
						local moveDir = direction.Unit
						local targetPos = currentPos + moveDir * speed * dt
						
						local clampedX = math.clamp(targetPos.X, minX, maxX)
						local clampedZ = math.clamp(targetPos.Z, minZ, maxZ)
						
						ghostFolder:SetAttribute("Position", Vector3.new(clampedX, currentPos.Y, clampedZ))
					end

				elseif behaviorType == "Aggressive" and minDistance < aggroRange then
					-- Агрессивный призрак (движется К игроку)
					local direction = (playerPos - currentPos) * Vector3.new(1, 0, 1)
					if direction.Magnitude > 0 then
						local moveDir = direction.Unit
						local targetPos = currentPos + moveDir * speed * dt
						
						local clampedX = math.clamp(targetPos.X, minX, maxX)
						local clampedZ = math.clamp(targetPos.Z, minZ, maxZ)
						
						ghostFolder:SetAttribute("Position", Vector3.new(clampedX, currentPos.Y, clampedZ))
					end

					-- Атака/Оглушение (Stun) при контакте
					if minDistance < 4 then
						if not player:GetAttribute("IsStunned") then
							player:SetAttribute("IsStunned", true)
							humanoid.WalkSpeed = 0

							-- Сбрасываем 1 привидение из рюкзака игрока
							local inv = InventoryService.getInventory(player)
							if #inv.Ghosts > 0 then
								table.remove(inv.Ghosts, #inv.Ghosts)
								local inventoryUpdateEvent = Remotes.getEvent("InventoryUpdate")
								inventoryUpdateEvent:FireClient(player, inv)
							end

							-- Запускаем испуг/атаку на клиенте
							local scareEvent = Remotes.getEvent("ScarePlayer")
							scareEvent:FireClient(player, "ATK")

							-- Телепортируем призрака прочь в его локации
							teleportGhost(ghostFolder, zonePart)

							-- Возвращаем скорость через 2 секунды
							task.delay(2, function()
								if player and player.Parent then
									player:SetAttribute("IsStunned", nil)
									local speedLvl = player:GetAttribute("WalkSpeedLvl") or 1
									local normalSpeed = UpgradeConfig.WalkSpeed.Levels[speedLvl].Value
									local char = player.Character
									local hum = char and char:FindFirstChildOfClass("Humanoid")
									if hum then
										hum.WalkSpeed = normalSpeed
									end
								end
							end)
						end
					end
				end

				-- 4. Периодическое поведение: Телепортация (для Teleport/Aggressive/Secret)
				if teleportInterval > 0 then
					local lastTeleport = ghostFolder:GetAttribute("LastTeleport") or 0
					if tick() - lastTeleport >= teleportInterval then
						ghostFolder:SetAttribute("LastTeleport", tick())
						-- Шанс 30% телепортироваться, если рядом игрок
						if minDistance < 25 and math.random() <= 0.3 then
							teleportGhost(ghostFolder, zonePart)
							print(string.format("[GHOST BEHAVIOR] Логический призрак %s для игрока %s телепортировался!", ghostFolder.Name, player.Name))
						end
					end
				end

				-- 5. Периодическое поведение: Испуг (Scare)
				if minDistance < 12 then
					local lastScare = ghostFolder:GetAttribute("LastScare") or 0
					if tick() - lastScare >= scareInterval then
						ghostFolder:SetAttribute("LastScare", tick())
						local scareEvent = Remotes.getEvent("ScarePlayer")
						scareEvent:FireClient(player, "SCARE")
					end
				end
			end
		end
	end
end

-- Деактивация сервиса
function GhostBehaviorService.stop()
	active = false
end

return GhostBehaviorService
