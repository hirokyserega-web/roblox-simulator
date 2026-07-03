-- Клиентский контроллер ловушки и инвентаря
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

-- Сетевые события
local captureGhostEvent = Remotes.getEvent("CaptureGhost")
local inventoryUpdateEvent = Remotes.getEvent("InventoryUpdate")
local notificationEvent = Remotes.getEvent("ShowNotification")

-- Состояние инвентаря на клиенте
local currentBagCount = 0
local maxBagCapacity = GameConfig.DefaultBagCapacity

-- Состояние поимки
local activeGhost = nil
local captureProgress = 0
local isHolding = false
local currentProgressBarGui = nil

-- UI элементы сумки и уведомлений
local bagLabel = nil
local notificationLabel = nil

-- Создание HUD сумки (Bag HUD)
local function createBagHUD()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BagHUD"
	screenGui.ResetOnSpawn = false

	-- Панель в верхнем правом углу
	local frame = Instance.new("Frame")
	frame.Name = "BagFrame"
	frame.Size = UDim2.new(0, 180, 0, 50)
	frame.Position = UDim2.new(1, -205, 0, 25)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	bagLabel = Instance.new("TextLabel")
	bagLabel.Name = "BagLabel"
	bagLabel.Size = UDim2.new(1, 0, 1, 0)
	bagLabel.BackgroundTransparency = 1
	bagLabel.Font = Enum.Font.FredokaOne
	bagLabel.TextSize = 16
	bagLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
	bagLabel.Text = string.format("BAG: %d / %d", currentBagCount, maxBagCapacity)
	bagLabel.Parent = frame

	-- Контейнер для всплывающих уведомлений в центре экрана
	notificationLabel = Instance.new("TextLabel")
	notificationLabel.Name = "NotificationLabel"
	notificationLabel.Size = UDim2.new(0, 400, 0, 50)
	notificationLabel.Position = UDim2.new(0.5, -200, 0.4, 0)
	notificationLabel.BackgroundTransparency = 1
	notificationLabel.Font = Enum.Font.FredokaOne
	notificationLabel.TextSize = 28
	notificationLabel.TextColor3 = Color3.fromRGB(231, 76, 60) -- Ярко-красный
	notificationLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	notificationLabel.TextStrokeTransparency = 0
	notificationLabel.Text = ""
	notificationLabel.Parent = screenGui

	screenGui.Parent = playerGui
end

-- Всплывающее текстовое уведомление (красивый эффект появления и затухания)
local function showNotification(text: string)
	if not notificationLabel then return end
	
	notificationLabel.Text = text
	notificationLabel.TextTransparency = 0
	notificationLabel.TextStrokeTransparency = 0
	
	-- Ждем секунду и запускаем плавное исчезновение
	task.delay(1, function()
		local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tweenText = TweenService:Create(notificationLabel, tweenInfo, {TextTransparency = 1})
		local tweenStroke = TweenService:Create(notificationLabel, tweenInfo, {TextStrokeTransparency = 1})
		
		tweenText:Play()
		tweenStroke:Play()
	end)
end

-- Сброс захвата
local function resetCapture()
	activeGhost = nil
	captureProgress = 0
	if currentProgressBarGui then
		currentProgressBarGui:Destroy()
		currentProgressBarGui = nil
	end
end

-- Создание прогресс-бара над призраком
local function createProgressBar(ghostPart: Part)
	if currentProgressBarGui then
		currentProgressBarGui:Destroy()
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "CaptureProgressGui"
	billboard.Size = UDim2.new(0, 100, 0, 10)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = ghostPart

	local background = Instance.new("Frame")
	background.Size = UDim2.new(1, 0, 1, 0)
	background.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	background.BorderSizePixel = 0
	background.Parent = billboard

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = background

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Зеленый
	fill.BorderSizePixel = 0
	fill.Parent = background

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 4)
	fillCorner.Parent = fill

	currentProgressBarGui = billboard
end

-- Обработка клика/зажатия
local function onInputBegan(input: InputObject, processed: boolean)
	if processed then return end

	local inputType = input.UserInputType
	if inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch then
		isHolding = true
		
		local target = mouse.Target
		local spawnedGhostsFolder = Workspace:FindFirstChild("SpawnedGhosts")
		
		if target and spawnedGhostsFolder and target:IsDescendantOf(spawnedGhostsFolder) then
			local character = player.Character
			if not character then return end
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if not rootPart then return end

			-- Проверяем дистанцию
			local distance = (rootPart.Position - target.Position).Magnitude
			if distance <= GameConfig.TrapRange then
				-- Проверяем лимит сумки
				if currentBagCount >= maxBagCapacity then
					showNotification("Сумка полна!")
					return
				end

				-- Начинаем захват призрака
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

-- Обновление каждую секунду/кадр
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

	-- Условия прекращения поимки:
	-- 1. Отошел слишком далеко
	-- 2. Призрак уничтожен или пропал
	-- 3. Курсор больше не на призраке
	local distance = (rootPart.Position - activeGhost.Position).Magnitude
	if distance > GameConfig.TrapRange or not activeGhost.Parent or mouse.Target ~= activeGhost then
		resetCapture()
		return
	end

	-- Увеличиваем прогресс
	captureProgress = captureProgress + dt / GameConfig.CaptureTime
	
	-- Обновляем заполнение полосы
	if currentProgressBarGui then
		local fill = currentProgressBarGui.Frame:FindFirstChild("Fill")
		if fill then
			fill.Size = UDim2.new(math.clamp(captureProgress, 0, 1), 0, 1, 0)
		end
	end

	-- Если 100% — захватываем!
	if captureProgress >= 1 then
		local ghostToCapture = activeGhost
		resetCapture()
		captureGhostEvent:FireServer(ghostToCapture)
	end
end

-- Подключения событий
UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)
RunService.Heartbeat:Connect(onHeartbeat)

-- Слушаем синхронизацию инвентаря от сервера
inventoryUpdateEvent.OnClientEvent:Connect(function(inventory)
	if inventory and inventory.Ghosts then
		currentBagCount = #inventory.Ghosts
		maxBagCapacity = inventory.MaxCapacity
		if bagLabel then
			bagLabel.Text = string.format("BAG: %d / %d", currentBagCount, maxBagCapacity)
		end
	end
end)

-- Слушаем уведомления от сервера (например, античит или серверные проверки)
notificationEvent.OnClientEvent:Connect(function(message)
	showNotification(message)
end)

-- Инициализируем UI при старте
createBagHUD()
print("TrapController started")
