-- Клиентский контроллер HUD (Валюта, Сумка, Уведомления)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Сетевые события
local inventoryUpdateEvent = Remotes.getEvent("InventoryUpdate")
local notificationEvent = Remotes.getEvent("ShowNotification")

-- Элементы интерфейса
local screenGui = nil
local moneyLabel = nil
local bagLabel = nil
local notificationLabel = nil

-- Вспомогательная функция форматирования чисел
local function formatNumber(value: number): string
	local formatted = tostring(value)
	while true do  
		local k
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

-- Всплывающее текстовое уведомление (эффект плавного затухания)
local function showNotification(text: string)
	if not notificationLabel then return end
	
	notificationLabel.Text = text
	notificationLabel.TextTransparency = 0
	notificationLabel.TextStrokeTransparency = 0
	
	-- Ждем 1.2 секунды и запускаем плавное исчезновение
	task.delay(1.2, function()
		local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tweenText = TweenService:Create(notificationLabel, tweenInfo, {TextTransparency = 1})
		local tweenStroke = TweenService:Create(notificationLabel, tweenInfo, {TextStrokeTransparency = 1})
		
		tweenText:Play()
		tweenStroke:Play()
	end)
end

-- Экспортируем функцию уведомлений в глобальную область, чтобы TrapController мог ее вызывать
_G.ShowNotification = showNotification

-- Создание интерфейса
local function createHUD()
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GameHUD"
	screenGui.ResetOnSpawn = false

	-- Панель в верхнем правом углу
	local frame = Instance.new("Frame")
	frame.Name = "HUDFrame"
	frame.Size = UDim2.new(0, 200, 0, 80)
	frame.Position = UDim2.new(1, -220, 0, 110) -- Размещаем чуть ниже детектора и рюкзака
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	-- Градиент для рамки
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 50)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 30))
	})
	gradient.Parent = frame

	-- Лейбл монет
	moneyLabel = Instance.new("TextLabel")
	moneyLabel.Name = "MoneyLabel"
	moneyLabel.Size = UDim2.new(1, -20, 0, 30)
	moneyLabel.Position = UDim2.new(0, 10, 0, 10)
	moneyLabel.BackgroundTransparency = 1
	moneyLabel.Font = Enum.Font.FredokaOne
	moneyLabel.TextSize = 16
	moneyLabel.TextColor3 = Color3.fromRGB(241, 196, 15) -- Золотой цвет
	moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
	moneyLabel.Text = "MONEY: $0"
	moneyLabel.Parent = frame

	-- Лейбл сумки
	bagLabel = Instance.new("TextLabel")
	bagLabel.Name = "BagLabel"
	bagLabel.Size = UDim2.new(1, -20, 0, 30)
	bagLabel.Position = UDim2.new(0, 10, 0, 40)
	bagLabel.BackgroundTransparency = 1
	bagLabel.Font = Enum.Font.FredokaOne
	bagLabel.TextSize = 16
	bagLabel.TextColor3 = Color3.fromRGB(46, 204, 113) -- Зеленый цвет
	bagLabel.TextXAlignment = Enum.TextXAlignment.Left
	bagLabel.Text = string.format("BAG: 0 / %d", GameConfig.DefaultBagCapacity)
	bagLabel.Parent = frame

	-- Текст уведомлений в центре экрана
	notificationLabel = Instance.new("TextLabel")
	notificationLabel.Name = "NotificationLabel"
	notificationLabel.Size = UDim2.new(0, 500, 0, 50)
	notificationLabel.Position = UDim2.new(0.5, -250, 0.35, 0)
	notificationLabel.BackgroundTransparency = 1
	notificationLabel.Font = Enum.Font.FredokaOne
	notificationLabel.TextSize = 24
	notificationLabel.TextColor3 = Color3.fromRGB(231, 76, 60) -- Ярко-красный
	notificationLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	notificationLabel.TextStrokeTransparency = 0
	notificationLabel.Text = ""
	notificationLabel.Parent = screenGui

	screenGui.Parent = playerGui
end

-- Подписка на обновление валюты
local function startCurrencyController()
	local function updateMoney()
		local money = player:GetAttribute("Money") or 0
		if moneyLabel then
			moneyLabel.Text = string.format("MONEY: $%s", formatNumber(money))
		end
	end

	player:GetAttributeChangedSignal("Money"):Connect(updateMoney)
	
	-- Первоначальный апдейт
	updateMoney()
end

-- Подписка на обновление инвентаря
inventoryUpdateEvent.OnClientEvent:Connect(function(inventory)
	if inventory and inventory.Ghosts then
		local count = #inventory.Ghosts
		local maxCap = inventory.MaxCapacity
		if bagLabel then
			bagLabel.Text = string.format("BAG: %d / %d", count, maxCap)
		end
	end
end)

-- Слушаем уведомления от сервера
notificationEvent.OnClientEvent:Connect(function(message)
	showNotification(message)
end)

-- Эффекты испуга и атаки привидений
local Lighting = game:GetService("Lighting")

local function applyBlurEffect()
	local blur = Lighting:FindFirstChild("SpookyBlur")
	if not blur then
		blur = Instance.new("BlurEffect")
		blur.Name = "SpookyBlur"
		blur.Size = 0
		blur.Parent = Lighting
	end
	
	blur.Size = 24
	
	local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(blur, tweenInfo, {Size = 0})
	tween:Play()
end

local function cameraShake(duration: number, intensity: number)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	local startTime = tick()
	task.spawn(function()
		while tick() - startTime < duration do
			local offset = Vector3.new(
				(math.random() - 0.5) * intensity,
				(math.random() - 0.5) * intensity,
				0
			)
			humanoid.CameraOffset = offset
			task.wait()
		end
		humanoid.CameraOffset = Vector3.new(0, 0, 0)
	end)
end

local function playSpookySound()
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://134012243" -- Смех призрака
	sound.Volume = 0.8
	sound.Parent = Workspace
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

-- Слушаем событие испуга
local scareEvent = Remotes.getEvent("ScarePlayer")
scareEvent.OnClientEvent:Connect(function(scareType)
	applyBlurEffect()
	playSpookySound()
	
	if scareType == "ATK" then
		cameraShake(1.5, 1.2)
		showNotification("ОГЛУШЕН! ПОТЕРЯН 1 ПРИЗРАК!")
	else
		cameraShake(0.8, 0.5)
		showNotification("БУ! Рядом призрак!")
	end
end)

-- Запуск HUD
createHUD()
startCurrencyController()

print("HUD client controller started (with Scare FX)")

