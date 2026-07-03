-- Клиентский UI Наград и Промокодов (Rewards UI)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local DailyConfig = require(ReplicatedStorage.Shared.config.DailyConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

-- Подгрузка темы и компонентов UI Kit
local Theme = require(script.Parent.ui.theme.Theme)
local Button = require(script.Parent.ui.components.Button)
local Panel = require(script.Parent.ui.components.Panel)
local UIManager = require(script.Parent.ui.UIManager)

local player = Players.LocalPlayer
local claimDailyEvent = Remotes.getEvent("ClaimDaily")
local redeemCodeEvent = Remotes.getEvent("RedeemCode")

local rewardsPanel = nil
local dailyTabFrame = nil
local promoTabFrame = nil
local streakGrid = nil

-- Компоненты кнопок
local claimButtonComponent = nil
local redeemButtonComponent = nil
local dailyTabBtnComponent = nil
local promoTabBtnComponent = nil

-- Обновление сетки ежедневных наград
local function updateDailyGrid()
	if not streakGrid then return end

	local currentStreak = player:GetAttribute("DailyStreak") or 0
	local cooldownTime = player:GetAttribute("DailyCooldown") or 0
	local now = os.time()
	local isClaimable = now >= cooldownTime

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
				-- Золотая рамка для текущего активного дня
				border.Color3 = Color3.fromRGB(241, 196, 15)
				card.BackgroundColor3 = Color3.fromRGB(45, 40, 30)
			else
				border.Color3 = Theme.Colors.Stroke
				card.BackgroundColor3 = Theme.Colors.BackgroundSecondary
			end
		end
	end
end

-- Обновление таймера и активности кнопки клейма
local function updateCooldownTimer()
	if not claimButtonComponent then return end

	local cooldownTime = player:GetAttribute("DailyCooldown") or 0
	local now = os.time()

	if now >= cooldownTime then
		claimButtonComponent.SetText("ЗАБРАТЬ НАГРАДУ")
		claimButtonComponent.SetEnabled(true)
	else
		local timeLeft = cooldownTime - now
		local hours = math.floor(timeLeft / 3600)
		local mins = math.floor((timeLeft % 3600) / 60)
		local secs = timeLeft % 60
		claimButtonComponent.SetText(string.format("%02d:%02d:%02d", hours, mins, secs))
		claimButtonComponent.SetEnabled(false)
	end
end

-- Инициализация интерфейса
local function init()
	local screenGui = UIManager.getScreenGui()

	-- Создаем премиум-панель
	rewardsPanel = Panel.create({
		Title = "НАГРАДЫ И ПРОМОКОДЫ",
		Size = UDim2.new(0, 440, 0, 360),
		Position = UDim2.new(0.5, -220, 0.5, -180),
		Parent = screenGui,
		OnClose = function()
			rewardsPanel.Close()
		end
	})

	UIManager.registerWindow("Rewards", rewardsPanel)

	-- Вкладки
	local tabsContainer = Instance.new("Frame")
	tabsContainer.Size = UDim2.new(1, 0, 0, 45)
	tabsContainer.BackgroundTransparency = 1
	tabsContainer.Parent = rewardsPanel.Content

	-- Создаем кнопки вкладок через фабрику кнопок
	dailyTabBtnComponent = Button.create({
		Text = "ЕЖЕДНЕВНО",
		Color = Theme.Colors.Accent,
		Size = UDim2.new(0, 140, 0, 35),
		Position = UDim2.new(0, 10, 0, 5),
		TextSize = 12,
		Parent = tabsContainer,
		OnClick = function()
			dailyTabFrame.Visible = true
			promoTabFrame.Visible = false
			updateDailyGrid()
		end
	})

	promoTabBtnComponent = Button.create({
		Text = "ПРОМОКОДЫ",
		Color = Theme.Colors.BackgroundSecondary,
		Size = UDim2.new(0, 140, 0, 35),
		Position = UDim2.new(0, 160, 0, 5),
		TextSize = 12,
		Parent = tabsContainer,
		OnClick = function()
			dailyTabFrame.Visible = false
			promoTabFrame.Visible = true
		end
	})

	-- Контейнеры контента
	dailyTabFrame = Instance.new("Frame")
	dailyTabFrame.Size = UDim2.new(1, 0, 1, -45)
	dailyTabFrame.Position = UDim2.new(0, 0, 0, 45)
	dailyTabFrame.BackgroundTransparency = 1
	dailyTabFrame.Parent = rewardsPanel.Content

	promoTabFrame = Instance.new("Frame")
	promoTabFrame.Size = UDim2.new(1, 0, 1, -45)
	promoTabFrame.Position = UDim2.new(0, 0, 0, 45)
	promoTabFrame.BackgroundTransparency = 1
	promoTabFrame.Visible = false
	promoTabFrame.Parent = rewardsPanel.Content

	-- ==========================================
	-- НАСТРОЙКА ВКЛАДКИ "ЕЖЕДНЕВНО"
	-- ==========================================
	streakGrid = Instance.new("Frame")
	streakGrid.Size = UDim2.new(1, -20, 0, 175)
	streakGrid.Position = UDim2.new(0, 10, 0, 10)
	streakGrid.BackgroundTransparency = 1
	streakGrid.Parent = dailyTabFrame

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 85, 0, 80)
	gridLayout.CellPadding = UDim2.new(0, 12, 0, 12)
	gridLayout.Parent = streakGrid

	for i = 1, 7 do
		local card = Instance.new("Frame")
		card.Name = "DayCard_" .. i
		card.BackgroundColor3 = Theme.Colors.BackgroundSecondary
		card.BorderSizePixel = 0
		card.Parent = streakGrid

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = Theme.Sizes.CornerRadius
		cardCorner.Parent = card

		local border = Instance.new("UIStroke")
		border.Name = "SelectionBox"
		border.Thickness = Theme.Sizes.BorderWidth - 1
		border.Color = Theme.Colors.Stroke
		border.Parent = card

		local dayLabel = Instance.new("TextLabel")
		dayLabel.Size = UDim2.new(1, 0, 0, 20)
		dayLabel.Position = UDim2.new(0, 0, 0, 6)
		dayLabel.BackgroundTransparency = 1
		dayLabel.Font = Theme.Fonts.Title
		dayLabel.TextSize = 11
		dayLabel.TextColor3 = Theme.Colors.TextSecondary
		dayLabel.Text = "День " .. i
		dayLabel.Parent = card

		local conf = DailyConfig[i]

		-- Иконка Монеты/Кристаллы
		local icon = Instance.new("TextLabel")
		icon.Size = UDim2.new(0, 20, 0, 20)
		icon.Position = UDim2.new(0.5, -10, 0, 28)
		icon.BackgroundTransparency = 1
		icon.Font = Theme.Fonts.Title
		icon.TextSize = 14
		icon.Text = (conf.RewardType == "Money") and "💵" or "💎"
		icon.Parent = card

		local valLabel = Instance.new("TextLabel")
		valLabel.Size = UDim2.new(1, 0, 0, 20)
		valLabel.Position = UDim2.new(0, 0, 1, -24)
		valLabel.BackgroundTransparency = 1
		valLabel.Font = Theme.Fonts.Title
		valLabel.TextSize = 10
		valLabel.TextColor3 = Theme.Colors.Text
		valLabel.Text = conf.DisplayName
		valLabel.Parent = card
	end

	-- Кнопка получения награды
	claimButtonComponent = Button.create({
		Text = "ЗАБРАТЬ НАГРАДУ",
		Color = Theme.Colors.Success,
		Size = UDim2.new(0, 220, 0, 42),
		Position = UDim2.new(0.5, -110, 1, -55),
		Parent = dailyTabFrame,
		OnClick = function()
			claimDailyEvent:FireServer()
		end
	})

	-- ==========================================
	-- НАСТРОЙКА ВКЛАДКИ "ПРОМОКОДЫ"
	-- ==========================================
	local promoDesc = Instance.new("TextLabel")
	promoDesc.Size = UDim2.new(1, -40, 0, 40)
	promoDesc.Position = UDim2.new(0, 20, 0, 20)
	promoDesc.BackgroundTransparency = 1
	promoDesc.Font = Theme.Fonts.Body
	promoDesc.TextSize = 14
	promoDesc.TextColor3 = Theme.Colors.TextSecondary
	promoDesc.Text = "Введите действующий промокод, чтобы получить награду:"
	promoDesc.Parent = promoTabFrame

	local codeBox = Instance.new("TextBox")
	codeBox.Name = "CodeTextBox"
	codeBox.Size = UDim2.new(0, 260, 0, 40)
	codeBox.Position = UDim2.new(0.5, -130, 0.35, 0)
	codeBox.BackgroundColor3 = Theme.Colors.BackgroundSecondary
	codeBox.BorderSizePixel = 0
	codeBox.Font = Theme.Fonts.Title
	codeBox.TextSize = 16
	codeBox.TextColor3 = Theme.Colors.Text
	codeBox.PlaceholderColor3 = Theme.Colors.TextSecondary
	codeBox.PlaceholderText = "ВВЕДИТЕ КОД..."
	codeBox.Text = ""
	codeBox.ClearTextOnFocus = false
	codeBox.Parent = promoTabFrame

	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = Theme.Sizes.CornerRadius
	boxCorner.Parent = codeBox

	local boxStroke = Instance.new("UIStroke")
	boxStroke.Thickness = Theme.Sizes.BorderWidth - 1
	boxStroke.Color = Theme.Colors.Stroke
	boxStroke.Parent = codeBox

	-- Кнопка активации
	redeemButtonComponent = Button.create({
		Text = "АКТИВИРОВАТЬ",
		Color = Theme.Colors.Accent,
		Size = UDim2.new(0, 160, 0, 40),
		Position = UDim2.new(0.5, -80, 0.6, 10),
		Parent = promoTabFrame,
		OnClick = function()
			local text = codeBox.Text
			if text ~= "" then
				redeemCodeEvent:FireServer(text)
				codeBox.Text = ""
			else
				UIManager.ShowToast("Введите код перед отправкой!", "Warning")
			end
		end
	})

	-- Слушаем изменения серии и кулдауна с сервера
	player:GetAttributeChangedSignal("DailyStreak"):Connect(function()
		updateDailyGrid()
		updateCooldownTimer()
	end)
	player:GetAttributeChangedSignal("DailyCooldown"):Connect(function()
		updateDailyGrid()
		updateCooldownTimer()
	end)

	-- Запуск цикла таймера
	task.spawn(function()
		while true do
			updateCooldownTimer()
			task.wait(1)
		end
	end)

	updateDailyGrid()
	updateCooldownTimer()
end

init()
print("[REWARDS UI] Интерфейс наград успешно загружен!")
