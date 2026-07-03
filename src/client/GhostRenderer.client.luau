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

	-- Находим персональную папку логических призраков игрока
	myGhostsFolder = playerGhostsFolder:WaitForChild(tostring(player.UserId), 15)
	if not myGhostsFolder then
		warn("[GHOST RENDERER] Не найдена папка логических призраков игрока!")
		return
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
