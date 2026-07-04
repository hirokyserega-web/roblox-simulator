-- Клиентский контроллер визуализации локальных призраков (Client-side rendering)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local GhostConfig = require(ReplicatedStorage.Shared.config.GhostConfig)

local player = Players.LocalPlayer
local playerGhostsFolder = ReplicatedStorage:WaitForChild("PlayerGhosts")
local myGhostsFolder = nil

local localGhostsFolder = nil
local activeRenderers = {} -- Ключ: Folder (логический призрак), Значение: Part (локальный парт)

-- Создаем локальную физическую деталь для призрака
local function renderGhost(entity: Folder)
	local rarityId = entity:GetAttribute("Rarity")
	local info = GhostConfig[rarityId]
	if not info then return end

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

	-- Выставляем GUID и Rarity для детектора и ловушки
	ghostPart:SetAttribute("GhostId", entity:GetAttribute("GhostId"))
	ghostPart:SetAttribute("Rarity", rarityId)
	ghostPart:SetAttribute("Value", entity:GetAttribute("Value"))

	-- Создаем надпись над призраком (Имя, Редкость)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "GhostLabel"
	billboard.Size = UDim2.new(0, 160, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 2.8, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = ghostPart

	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 1
	container.Parent = billboard

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.FredokaOne
	nameLabel.TextSize = 16
	nameLabel.TextColor3 = info.Color
	nameLabel.Text = info.Name
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextStrokeColor3 = Color3.fromRGB(13, 14, 26)
	nameLabel.Parent = container

	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.new(1, 0, 0.4, 0)
	rarityLabel.Position = UDim2.new(0, 0, 0.6, 0)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Font = Enum.Font.GothamBold
	rarityLabel.TextSize = 11
	rarityLabel.TextColor3 = Color3.fromRGB(220, 220, 220)

	local rarityText = "ОБЫЧНЫЙ"
	if rarityId == "Uncommon" then rarityText = "НЕОБЫЧНЫЙ"
	elseif rarityId == "Rare" then rarityText = "РЕДКИЙ"
	elseif rarityId == "Epic" then rarityText = "ЭПИЧЕСКИЙ"
	elseif rarityId == "Legendary" then rarityText = "ЛЕГЕНДАРНЫЙ"
	elseif rarityId == "Secret" then rarityText = "СЕКРЕТНЫЙ"
	end

	rarityLabel.Text = "[" .. rarityText .. "]"
	rarityLabel.TextStrokeTransparency = 0
	rarityLabel.TextStrokeColor3 = Color3.fromRGB(13, 14, 26)
	rarityLabel.Parent = container

	-- Добавляем легкое свечение частицами
	local attachment = Instance.new("Attachment")
	attachment.Parent = ghostPart

	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxassetid://292289454"
	emitter.Color = ColorSequence.new(info.Color)
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(1, 0)
	})
	emitter.Lifetime = NumberRange.new(0.8, 1.4)
	emitter.Rate = 12
	emitter.Speed = NumberRange.new(1, 3)
	emitter.SpreadAngle = Vector2.new(0, 360)
	emitter.Parent = attachment

	-- Ставим на начальную позицию
	local basePos = entity:GetAttribute("Position")
	if basePos then
		ghostPart.Position = basePos
	end

	ghostPart.Parent = localGhostsFolder
	activeRenderers[entity] = ghostPart
end

-- Удаление локального призрака при исчезновении логического
local function destroyGhost(entity: Folder)
	local part = activeRenderers[entity]
	if part then
		part:Destroy()
		activeRenderers[entity] = nil
	end
end

-- Инициализация рендерера
local function init()
	-- Создаем или находим папку локальных призраков в Workspace
	localGhostsFolder = Workspace:FindFirstChild("LocalGhosts")
	if not localGhostsFolder then
		localGhostsFolder = Instance.new("Folder")
		localGhostsFolder.Name = "LocalGhosts"
		localGhostsFolder.Parent = Workspace
	end

	-- Находим персональную папку логических призраков игрока (надежное бесконфликтное ожидание)
	myGhostsFolder = playerGhostsFolder:WaitForChild(tostring(player.UserId), 30)
	if not myGhostsFolder then
		while not myGhostsFolder do
			task.wait(0.5)
			myGhostsFolder = playerGhostsFolder:FindFirstChild(tostring(player.UserId))
		end
	end

	-- Слушаем новые сущности призраков
	myGhostsFolder.ChildAdded:Connect(function(child)
		if child:IsA("Folder") then
			renderGhost(child)
		end
	end)

	myGhostsFolder.ChildRemoved:Connect(function(child)
		destroyGhost(child)
	end)

	-- Отрисовываем уже существующие на момент старта скрипта
	for _, child in ipairs(myGhostsFolder:GetChildren()) do
		if child:IsA("Folder") then
			renderGhost(child)
		end
	end

	-- Плавное парение и синхронизация позиций призраков каждый кадр
	RunService.Heartbeat:Connect(function()
		for entity, part in pairs(activeRenderers) do
			if entity and entity.Parent and part and part.Parent then
				local basePos = entity:GetAttribute("Position")
				local floatSeed = entity:GetAttribute("FloatSeed") or 0
				
				if basePos then
					-- Синусоидальное колебание высоты
					local floatOffset = math.sin(tick() * 2.5 + floatSeed) * 0.75
					part.Position = basePos + Vector3.new(0, floatOffset, 0)
				end
			else
				-- Защита от утечек памяти: чистим сломанные ссылки
				destroyGhost(entity)
			end
		end
	end)

	print("[GHOST RENDERER] Клиентский отрисовщик призраков запущен!")
end

init()
