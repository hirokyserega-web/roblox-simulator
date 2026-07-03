-- Клиентский контроллер ловушки (Client Input & Catching)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local UpgradeConfig = require(ReplicatedStorage.Shared.config.UpgradeConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

-- Подгрузка темы и компонентов UI Kit
local Theme = require(script.Parent.ui.theme.Theme)
local ProgressBar = require(script.Parent.ui.components.ProgressBar)
local UIManager = require(script.Parent.ui.UIManager)

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Сетевые события
local captureGhostEvent = Remotes.getEvent("CaptureGhost")
local inventoryUpdateEvent = Remotes.getEvent("InventoryUpdate")

-- Локальное состояние рюкзака
local currentBagCount = 0
local maxBagCapacity = GameConfig.DefaultBagCapacity

-- Состояние захвата
local activeGhost = nil
local captureProgress = 0
local isHolding = false

local captureBarContainer = nil
local captureProgressBar = nil

-- Функция сброса захвата
local function resetCapture()
	activeGhost = nil
	captureProgress = 0
	if captureBarContainer then
		captureBarContainer:Destroy()
		captureBarContainer = nil
	end
	captureProgressBar = nil
end

-- Всплывающее предупреждение через UIManager
local function triggerNotification(text: string, nType: string?)
	UIManager.ShowToast(text, nType or "Warning")
end

-- Создание прогресс-бара по центру-низу экрана
local function createProgressBar(ghostPart: Part)
	if captureBarContainer then
		captureBarContainer:Destroy()
	end

	local screenGui = UIManager.getScreenGui()
	local rarity = ghostPart:GetAttribute("Rarity") or "Common"
	local rColor = Theme.RarityColors[rarity] or Theme.Colors.Success

	-- 1. Контейнер полоски захвата
	captureBarContainer = Instance.new("Frame")
	captureBarContainer.Name = "CaptureOverlayFrame"
	captureBarContainer.Size = UDim2.new(0, 300, 0, 50)
	captureBarContainer.Position = UDim2.new(0.5, -150, 1, -145) -- Над док-панелью кнопок
	captureBarContainer.BackgroundColor3 = Theme.Colors.Background
	captureBarContainer.BackgroundTransparency = 0.2
	captureBarContainer.BorderSizePixel = 0
	captureBarContainer.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Sizes.CornerRadius
	corner.Parent = captureBarContainer

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = Theme.Sizes.BorderWidth
	stroke.Color = Theme.Colors.Stroke
	stroke.Parent = captureBarContainer

	-- 2. Иконка призрака слева
	local ghostIcon = Instance.new("TextLabel")
	ghostIcon.Size = UDim2.new(0, 30, 0, 30)
	ghostIcon.Position = UDim2.new(0, 8, 0.5, -15)
	ghostIcon.BackgroundTransparency = 1
	ghostIcon.Font = Theme.Fonts.Title
	ghostIcon.TextSize = 18
	ghostIcon.Text = "👻"
	ghostIcon.Parent = captureBarContainer

	local iconStroke = Instance.new("UIStroke")
	iconStroke.Thickness = 1
	iconStroke.Color = rColor -- Цвет редкости призрака
	iconStroke.Parent = ghostIcon

	-- 3. Подпись «Удерживай!»
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -55, 0, 18)
	title.Position = UDim2.new(0, 48, 0, 4)
	title.BackgroundTransparency = 1
	title.Font = Theme.Fonts.Title
	title.TextSize = 10
	title.TextColor3 = Theme.Colors.Text
	title.Text = "УДЕРЖИВАЙ КНОПКУ МЫШИ!"
	title.Parent = captureBarContainer

	-- 4. Линейный прогресс-бар
	captureProgressBar = ProgressBar.create({
		Size = UDim2.new(1, -55, 0, 10),
		Position = UDim2.new(0, 48, 1, -20),
		FillColor = rColor,
		Parent = captureBarContainer
	})
end

-- Обработка нажатия кнопки мыши / тапа по экрану
local function onInputBegan(input: InputObject, processed: boolean)
	if processed then return end

	local inputType = input.UserInputType
	if inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch then
		isHolding = true
		
		local target = mouse.Target
		local localGhostsFolder = Workspace:FindFirstChild("LocalGhosts")
		
		if target and localGhostsFolder and target:IsDescendantOf(localGhostsFolder) then
			local character = player.Character
			if not character then return end
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if not rootPart then return end

			-- Валидация дистанции
			local distance = (rootPart.Position - target.Position).Magnitude
			if distance <= GameConfig.TrapRange then
				-- Валидация переполнения сумки
				if currentBagCount >= maxBagCapacity then
					triggerNotification("Сумка полна!")
					return
				end

				-- Начинаем поимку
				activeGhost = target
				captureProgress = 0
				createProgressBar(activeGhost)
			end
		end
	end
end

-- Обработка отпускания кнопки
local function onInputEnded(input: InputObject, processed: boolean)
	local inputType = input.UserInputType
	if inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch then
		isHolding = false
		resetCapture()
	end
end

-- Обновление каждый кадр
local function onHeartbeat(dt: number)
	if not activeGhost then return end

	local character = player.Character
	if not character or not isHolding then
		resetCapture()
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		resetCapture()
		return
	end

	-- Проверяем, не исчез ли призрак, не отошел ли игрок далеко и наведен ли прицел
	local distance = (rootPart.Position - activeGhost.Position).Magnitude
	if distance > GameConfig.TrapRange or not activeGhost.Parent or mouse.Target ~= activeGhost then
		resetCapture()
		return
	end

	-- Рассчитываем скорость захвата на основе уровня улучшения
	local level = player:GetAttribute("CaptureSpeedLvl") or 1
	local captureTime = UpgradeConfig.CaptureSpeed.Levels[level].Value

	-- Рассчитываем прогресс захвата
	captureProgress = captureProgress + dt / captureTime
	
	-- Визуализируем прогресс
	if captureProgressBar then
		captureProgressBar.SetProgress(captureProgress)
	end

	-- Успешный захват
	if captureProgress >= 1 then
		local ghostId = activeGhost:GetAttribute("GhostId")
		resetCapture()
		if ghostId then
			captureGhostEvent:FireServer(ghostId)
		end
	end
end

-- Подписка на обновление инвентаря для отслеживания лимита на клиенте
inventoryUpdateEvent.OnClientEvent:Connect(function(inventory)
	if inventory and inventory.Ghosts then
		currentBagCount = #inventory.Ghosts
		maxBagCapacity = inventory.MaxCapacity
	end
end)

-- Подключения событий ввода
UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)
RunService.Heartbeat:Connect(onHeartbeat)

print("TrapController initialized (Capture logic)")
