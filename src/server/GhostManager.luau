-- Менеджер привидений: спавн на сервере, валидация поимки и сетевые события
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local NetworkEvents = require(ReplicatedStorage.Shared.NetworkEvents)
local PlayerStateManager = require(script.Parent.PlayerStateManager)

local GhostManager = {}
local spawnedGhostsFolder = nil
local spawnZone = nil

-- Инициализация менеджера
function GhostManager.init(zonePart: Part)
	spawnZone = zonePart
	
	-- Создаем папку для привидений в Workspace
	spawnedGhostsFolder = Workspace:FindFirstChild("SpawnedGhosts")
	if not spawnedGhostsFolder then
		spawnedGhostsFolder = Instance.new("Folder")
		spawnedGhostsFolder.Name = "SpawnedGhosts"
		spawnedGhostsFolder.Parent = Workspace
	end

	-- Получаем сетевое событие поимки
	local catchEvent = NetworkEvents.getEvent("CatchGhost")
	catchEvent.OnServerEvent:Connect(GhostManager.onCatchRequest)

	-- Запускаем цикл спавна в отдельном потоке
	task.spawn(function()
		while true do
			task.wait(GameConfig.Ghosts.SpawnInterval)
			GhostManager.spawnGhost()
		end
	end)
	
	print("Менеджер привидений успешно запущен!")
end

-- Логика спавна одиночного привидения
function GhostManager.spawnGhost()
	if not spawnZone or not spawnedGhostsFolder then return end

	-- Проверяем лимит привидений
	local currentCount = #spawnedGhostsFolder:GetChildren()
	if currentCount >= GameConfig.Ghosts.MaxGhostsInZone then
		return
	end

	-- Выбор типа привидения случайным образом
	local rand = math.random(1, 100)
	local ghostType = "Common"
	if rand > 90 then
		ghostType = "Epic"
	elseif rand > 70 then
		ghostType = "Rare"
	end

	local info = GameConfig.Ghosts.Types[ghostType]
	if not info then return end

	-- Создаем физическую модель привидения (Part)
	local ghostPart = Instance.new("Part")
	ghostPart.Name = info.Name
	ghostPart.Shape = Enum.PartType.Ball
	ghostPart.Size = info.Size
	ghostPart.Color = info.Color
	ghostPart.Material = Enum.Material.Neon
	ghostPart.CanCollide = false
	ghostPart.Anchored = true
	ghostPart.TopSurface = Enum.SurfaceType.Smooth
	ghostPart.BottomSurface = Enum.SurfaceType.Smooth

	-- Вычисляем случайную позицию в пределах SpawnZone
	local zoneSize = spawnZone.Size
	local zonePos = spawnZone.Position
	local randomX = zonePos.X + (math.random() - 0.5) * zoneSize.X
	local randomZ = zonePos.Z + (math.random() - 0.5) * zoneSize.Z
	local spawnY = zonePos.Y + (zoneSize.Y / 2) + (ghostPart.Size.Y / 2) + 2 -- Слегка приподнято над землей

	ghostPart.Position = Vector3.new(randomX, spawnY, randomZ)

	-- Записываем атрибуты
	ghostPart:SetAttribute("GhostType", ghostType)
	ghostPart:SetAttribute("Health", info.MaxHealth)
	ghostPart:SetAttribute("MaxHealth", info.MaxHealth)
	ghostPart:SetAttribute("Value", info.Value)

	-- Создаем красивый BillboardGui с индикатором здоровья над привидением
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "InfoGui"
	billboard.Size = UDim2.new(0, 150, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = ghostPart

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.Font = Enum.Font.FredokaOne
	label.TextSize = 14
	label.Text = string.format("%s\nHP: %d/%d", info.Name, info.MaxHealth, info.MaxHealth)
	label.Parent = billboard

	ghostPart.Parent = spawnedGhostsFolder
end

-- Обработка сетевого запроса от клиента на поимку привидения
function GhostManager.onCatchRequest(player: Player, ghostPart: Instance)
	-- Проверка безопасности: объект должен существовать и находиться в нашей папке
	if not ghostPart or not ghostPart:IsDescendantOf(spawnedGhostsFolder) then
		return
	end

	-- Валидация дистанции
	local character = player.Character
	if not character then return end
	local primaryPart = character.PrimaryPart
	if not primaryPart then return end

	local distance = (primaryPart.Position - ghostPart.Position).Magnitude
	if distance > GameConfig.Ghosts.CatchDistance then
		warn(string.format("Игрок %s пытался поймать привидение слишком далеко (дистанция: %.1f)", player.Name, distance))
		return
	end

	-- Валидация вместимости рюкзака
	local currentGhosts = player:GetAttribute("GhostsCount") or 0
	local maxCapacity = player:GetAttribute("MaxCapacity") or GameConfig.InitialStats.MaxCapacity
	if currentGhosts >= maxCapacity then
		-- Рюкзак полон, отправляем уведомление клиенту (если потребуется)
		return
	end

	-- Наносим урон привидению
	local health = ghostPart:GetAttribute("Health") or 0
	local maxHealth = ghostPart:GetAttribute("MaxHealth") or 1
	local ghostType = ghostPart:GetAttribute("GhostType") or "Common"
	
	health = health - 1
	
	if health <= 0 then
		-- Привидение поймано!
		local ghostValue = ghostPart:GetAttribute("Value") or 10
		ghostPart:Destroy()
		
		-- Добавляем в инвентарь игрока
		local success = PlayerStateManager.addGhost(player, 1, ghostValue)
		if success then
			print(string.format("Игрок %s успешно поймал %s (Ценность: %d)!", player.Name, ghostType, ghostValue))
		end
	else
		-- Обновляем здоровье и GUI
		ghostPart:SetAttribute("Health", health)
		local infoGui = ghostPart:FindFirstChild("InfoGui")
		if infoGui then
			local label = infoGui:FindFirstChildOfClass("TextLabel")
			if label then
				local info = GameConfig.Ghosts.Types[ghostType]
				label.Text = string.format("%s\nHP: %d/%d", info.Name, health, maxHealth)
			end
		end
	end
end

return GhostManager
