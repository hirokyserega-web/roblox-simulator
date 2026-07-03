-- Клиентский контроллер UI наград и промокодов (Rewards & Promo Codes UI)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local DailyConfig = require(ReplicatedStorage.Shared.config.DailyConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Сетевые события
local claimDailyEvent = Remotes.getEvent("ClaimDaily")
local redeemCodeEvent = Remotes.getEvent("RedeemCode")

-- Ссылка на элементы UI
local screenGui = nil
local rewardsFrame = nil
local dailyTabFrame = nil
local promoTabFrame = nil
local claimButton = nil
local streakGrid = nil

-- Вспомогательная функция обновления сетки ежедневных дней
local function updateDailyGrid()
	if not streakGrid then return end

	local currentStreak = player:GetAttribute("DailyStreak") or 0
	local cooldownTime = player:GetAttribute("DailyCooldown") or 0
	local now = os.time()
	local isClaimable = now >= cooldownTime

	-- Находим следующий день для получения
	local targetDay = 1
	if isClaimable then
		targetDay = (currentStreak % 7) + 1
	else
		targetDay = currentStreak
	end

	for i = 1, 7 do
		local card = streakGrid:FindFirstChild("DayCard_" .. i)
		if not card then continue end

		local border = card:FindFirstChild("SelectionBox")
		if border then
			if i == targetDay then
				-- Подсвечиваем следующий доступный (или текущий) день золотом
				border.Color3 = Color3.fromRGB(241, 196, 15)
				card.BackgroundColor3 = Color3.fromRGB(45, 40, 30)
			else
				border.Color3 = Color3.fromRGB(80, 80, 85)
				card.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
			end
		end
	end
end

-- Обновление таймера на кнопке клейма
local function updateCooldownTimer()
	if not claimButton then return end

	local cooldownTime = player:GetAttribute("DailyCooldown") or 0
	local now = os.time()

	if now >= cooldownTime then
		claimButton.Text = "ЗАБРАТЬ НАГРАДУ"
		claimButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Зеленая
		claimButton.AutoButtonColor = true
	else
		local timeLeft = cooldownTime - now
		local hours = math.floor(timeLeft / 3600)
		local mins = math.floor((timeLeft % 3600) / 60)
		local secs = timeLeft % 60
		claimButton.Text = string.format("Доступно через %02d:%02d:%02d", hours, mins, secs)
		claimButton.BackgroundColor3 = Color3.fromRGB(127, 140, 141) -- Серая
		claimButton.AutoButtonColor = false
	end
end

-- Создание интерфейса наград
local function createRewardsUI()
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RewardsHUD"
	screenGui.ResetOnSpawn = false

	-- Кнопка открытия меню наград на левой стороне экрана
	local openBtn = Instance.new("TextButton")
	openBtn.Name = "RewardsButton"
	openBtn.Size = UDim2.new(0, 80, 0, 45)
	openBtn.Position = UDim2.new(0, 20, 0.45, 165) -- Под кнопкой REBIRTH
	openBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34) -- Оранжевый
	openBtn.BorderSizePixel = 0
	openBtn.Font = Enum.Font.FredokaOne
	openBtn.TextSize = 13
	openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	openBtn.Text = "REWARDS"
	openBtn.Parent = screenGui

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = openBtn

	-- Главная панель меню
	rewardsFrame = Instance.new("Frame")
	rewardsFrame.Name = "RewardsFrame"
	rewardsFrame.Size = UDim2.new(0, 440, 0, 360)
	rewardsFrame.Position = UDim2.new(0.5, -220, 0.5, -180)
	rewardsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	rewardsFrame.BackgroundTransparency = 0.15
	rewardsFrame.BorderSizePixel = 0
	rewardsFrame.Visible = false
	rewardsFrame.Parent = screenGui

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 12)
	frameCorner.Parent = rewardsFrame

	-- Кнопка закрытия
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -40, 0, 10)
	closeBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
	closeBtn.BorderSizePixel = 0
	closeBtn.Font = Enum.Font.FredokaOne
	closeBtn.TextSize = 14
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Text = "X"
	closeBtn.Parent = rewardsFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeBtn

	-- Вкладка: Ежедневные награды
	local dailyTabBtn = Instance.new("TextButton")
	dailyTabBtn.Name = "DailyTabButton"
	dailyTabBtn.Size = UDim2.new(0, 150, 0, 35)
	dailyTabBtn.Position = UDim2.new(0, 20, 0, 10)
	dailyTabBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185) -- Активная
	dailyTabBtn.BorderSizePixel = 0
	dailyTabBtn.Font = Enum.Font.FredokaOne
	dailyTabBtn.TextSize = 13
	dailyTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	dailyTabBtn.Text = "ЕЖЕДНЕВНО"
	dailyTabBtn.Parent = rewardsFrame

	local tab1Corner = Instance.new("UICorner")
	tab1Corner.CornerRadius = UDim.new(0, 6)
	tab1Corner.Parent = dailyTabBtn

	-- Вкладка: Промокоды
	local promoTabBtn = Instance.new("TextButton")
	promoTabBtn.Name = "PromoTabButton"
	promoTabBtn.Size = UDim2.new(0, 150, 0, 35)
	promoTabBtn.Position = UDim2.new(0, 180, 0, 10)
	promoTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45) -- Неактивная
	promoTabBtn.BorderSizePixel = 0
	promoTabBtn.Font = Enum.Font.FredokaOne
	promoTabBtn.TextSize = 13
	promoTabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
	promoTabBtn.Text = "ПРОМОКОДЫ"
	promoTabBtn.Parent = rewardsFrame

	local tab2Corner = Instance.new("UICorner")
	tab2Corner.CornerRadius = UDim.new(0, 6)
	tab2Corner.Parent = promoTabBtn

	-- Контейнер вкладки "Ежедневно"
	dailyTabFrame = Instance.new("Frame")
	dailyTabFrame.Name = "DailyTabFrame"
	dailyTabFrame.Size = UDim2.new(1, -40, 1, -70)
	dailyTabFrame.Position = UDim2.new(0, 20, 0, 55)
	dailyTabFrame.BackgroundTransparency = 1
	dailyTabFrame.Parent = rewardsFrame

	-- Контейнер вкладки "Промокоды"
	promoTabFrame = Instance.new("Frame")
	promoTabFrame.Name = "PromoTabFrame"
	promoTabFrame.Size = UDim2.new(1, -40, 1, -70)
	promoTabFrame.Position = UDim2.new(0, 20, 0, 55)
	promoTabFrame.BackgroundTransparency = 1
	promoTabFrame.Visible = false
	promoTabFrame.Parent = rewardsFrame

	-- ==========================================
	-- НАСТРОЙКА ВКЛАДКИ "ЕЖЕДНЕВНО"
	-- ==========================================
	streakGrid = Instance.new("Frame")
	streakGrid.Name = "StreakGrid"
	streakGrid.Size = UDim2.new(1, 0, 0, 185)
	streakGrid.Position = UDim2.new(0, 0, 0, 10)
	streakGrid.BackgroundTransparency = 1
	streakGrid.Parent = dailyTabFrame

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 85, 0, 85)
	gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
	gridLayout.Parent = streakGrid

	-- Генерируем 7 карточек дней
	for i = 1, 7 do
		local card = Instance.new("Frame")
		card.Name = "DayCard_" .. i
		card.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		card.BorderSizePixel = 0
		card.Parent = streakGrid

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 8)
		cardCorner.Parent = card

		local border = Instance.new("SelectionBox")
		border.Name = "SelectionBox"
		border.Adornee = card
		border.LineThickness = 0.05
		border.Color3 = Color3.fromRGB(80, 80, 85)
		border.Parent = card

		-- Текст дня
		local dayLabel = Instance.new("TextLabel")
		dayLabel.Name = "DayLabel"
		dayLabel.Size = UDim2.new(1, 0, 0, 25)
		dayLabel.Position = UDim2.new(0, 0, 0, 6)
		dayLabel.BackgroundTransparency = 1
		dayLabel.Font = Enum.Font.FredokaOne
		dayLabel.TextSize = 12
		dayLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
		dayLabel.Text = "День " .. i
		dayLabel.Parent = card

		-- Иконка награды (простой круг)
		local rewardCircle = Instance.new("Frame")
		rewardCircle.Name = "Icon"
		rewardCircle.Size = UDim2.new(0, 16, 0, 16)
		rewardCircle.Position = UDim2.new(0.5, -8, 0, 33)
		
		-- Разные цвета иконок для Монет / Кристаллов
		local conf = DailyConfig[i]
		if conf.RewardType == "Money" then
			rewardCircle.BackgroundColor3 = Color3.fromRGB(241, 196, 15) -- Желтый
		else
			rewardCircle.BackgroundColor3 = Color3.fromRGB(52, 152, 219) -- Синий
		end
		rewardCircle.BorderSizePixel = 0
		rewardCircle.Parent = card

		local circleCorner = Instance.new("UICorner")
		circleCorner.CornerRadius = UDim.new(1, 0)
		circleCorner.Parent = rewardCircle

		-- Значение награды
		local valLabel = Instance.new("TextLabel")
		valLabel.Name = "ValueLabel"
		valLabel.Size = UDim2.new(1, 0, 0, 25)
		valLabel.Position = UDim2.new(0, 0, 1, -28)
		valLabel.BackgroundTransparency = 1
		valLabel.Font = Enum.Font.FredokaOne
		valLabel.TextSize = 11
		valLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		valLabel.Text = conf.DisplayName
		valLabel.Parent = card
	end

	-- Кнопка забрать награду
	claimButton = Instance.new("TextButton")
	claimButton.Name = "ClaimButton"
	claimButton.Size = UDim2.new(0, 240, 0, 45)
	claimButton.Position = UDim2.new(0.5, -120, 1, -55)
	claimButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
	claimButton.BorderSizePixel = 0
	claimButton.Font = Enum.Font.FredokaOne
	claimButton.TextSize = 16
	claimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	claimButton.Text = "ЗАБРАТЬ НАГРАДУ"
	claimButton.Parent = dailyTabFrame

	local claimCorner = Instance.new("UICorner")
	claimCorner.CornerRadius = UDim.new(0, 8)
	claimCorner.Parent = claimButton

	-- ==========================================
	-- НАСТРОЙКА ВКЛАДКИ "ПРОМОКОДЫ"
	-- ==========================================
	local promoDesc = Instance.new("TextLabel")
	promoDesc.Name = "Desc"
	promoDesc.Size = UDim2.new(1, -40, 0, 40)
	promoDesc.Position = UDim2.new(0, 20, 0, 20)
	promoDesc.BackgroundTransparency = 1
	promoDesc.Font = Enum.Font.SourceSans
	promoDesc.TextSize = 14
	promoDesc.TextColor3 = Color3.fromRGB(170, 170, 180)
	promoDesc.Text = "Введите действующий промокод, чтобы получить награду:"
	promoDesc.Parent = promoTabFrame

	local codeBox = Instance.new("TextBox")
	codeBox.Name = "CodeTextBox"
	codeBox.Size = UDim2.new(0, 260, 0, 40)
	codeBox.Position = UDim2.new(0.5, -130, 0.35, 0)
	codeBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	codeBox.BorderSizePixel = 0
	codeBox.Font = Enum.Font.FredokaOne
	codeBox.TextSize = 16
	codeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	codeBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
	codeBox.PlaceholderText = "ВВЕДИТЕ КОД..."
	codeBox.Text = ""
	codeBox.ClearTextOnFocus = false
	codeBox.Parent = promoTabFrame

	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 8)
	boxCorner.Parent = codeBox

	local redeemBtn = Instance.new("TextButton")
	redeemBtn.Name = "RedeemButton"
	redeemBtn.Size = UDim2.new(0, 160, 0, 40)
	redeemBtn.Position = UDim2.new(0.5, -80, 0.6, 0)
	redeemBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
	redeemBtn.BorderSizePixel = 0
	redeemBtn.Font = Enum.Font.FredokaOne
	redeemBtn.TextSize = 14
	redeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	redeemBtn.Text = "АКТИВИРОВАТЬ"
	redeemBtn.Parent = promoTabFrame

	local redCorner = Instance.new("UICorner")
	redCorner.CornerRadius = UDim.new(0, 8)
	redCorner.Parent = redeemBtn

	-- ==========================================
	-- КНОПКИ И ПЕРЕКЛЮЧЕНИЯ
	-- ==========================================
	dailyTabBtn.MouseButton1Click:Connect(function()
		dailyTabFrame.Visible = true
		promoTabFrame.Visible = false
		
		dailyTabBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
		dailyTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		
		promoTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		promoTabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
		
		updateDailyGrid()
	end)

	promoTabBtn.MouseButton1Click:Connect(function()
		dailyTabFrame.Visible = false
		promoTabFrame.Visible = true
		
		promoTabBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
		promoTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		
		dailyTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		dailyTabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
	end)

	openBtn.MouseButton1Click:Connect(function()
		rewardsFrame.Visible = not rewardsFrame.Visible
		if rewardsFrame.Visible then
			updateDailyGrid()
			updateCooldownTimer()
		end
	end)

	closeBtn.MouseButton1Click:Connect(function()
		rewardsFrame.Visible = false
	end)

	claimButton.MouseButton1Click:Connect(function()
		local cooldownTime = player:GetAttribute("DailyCooldown") or 0
		if os.time() >= cooldownTime then
			claimDailyEvent:FireServer()
		end
	end)

	redeemBtn.MouseButton1Click:Connect(function()
		local code = codeBox.Text
		if code ~= "" then
			redeemCodeEvent:FireServer(code)
			codeBox.Text = "" -- Сбрасываем поле ввода
		end
	end)

	screenGui.Parent = playerGui
end

-- Инициализация и слушатели
local function init()
	createRewardsUI()

	-- Слушаем изменения серии и кулдауна с сервера
	player:GetAttributeChangedSignal("DailyStreak"):Connect(function()
		updateDailyGrid()
		updateCooldownTimer()
	end)
	player:GetAttributeChangedSignal("DailyCooldown"):Connect(function()
		updateDailyGrid()
		updateCooldownTimer()
	end)

	-- Запускаем обновление таймера раз в секунду
	task.spawn(function()
		while true do
			updateCooldownTimer()
			task.wait(1)
		end
	end)
end

init()
print("RewardsUI client controller started")
