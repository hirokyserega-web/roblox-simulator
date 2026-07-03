-- Клиентский контроллер ловушки (Client Input & Catching)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local UpgradeConfig = require(ReplicatedStorage.Shared.config.UpgradeConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

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
local currentProgressBarGui = nil

-- Функция сброса захвата
local function resetCapture()
	activeGhost = nil
	captureProgress = 0
	if currentProgressBarGui then
		currentProgressBarGui:Destroy()
		currentProgressBarGui = nil
	end
end

-- Всплывающее предупреждение через глобальную функцию HUD
local function triggerNotification(text: string)
	if _G.ShowNotification then
		_G.ShowNotification(text)
	else
		print("[TrapController] " .. text)
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
	if currentProgressBarGui then
		local fill = currentProgressBarGui.Frame:FindFirstChild("Fill")
		if fill then
			fill.Size = UDim2.new(math.clamp(captureProgress, 0, 1), 0, 1, 0)
		end
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
