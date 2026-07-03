-- Окно Ежедневных наград (DailyRewardsWindow) - Полный премиум-редизайн
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DailyConfig = require(ReplicatedStorage.Shared.config.DailyConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local Panel = require(script.Parent.Parent.components.Panel)
local UIManager = _G.UIManager

local player = Players.LocalPlayer
local claimDailyEvent = Remotes.getEvent("ClaimDaily")

local DailyRewardsWindow = {}
local rewardsPanel = nil
local streakGrid = nil
local claimButtonComponent = nil

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

		local topFrame = card:FindFirstChild("CardTop")
		local stroke = topFrame and topFrame:FindFirstChild("CardStroke")
		local glow = topFrame and topFrame:FindFirstChild("Glow")

		if topFrame and stroke then
			if i == targetDay then
				-- Текущий доступный день: сочная золотая рамка и анимация
				stroke.Color = Color3.fromRGB(241, 196, 15)
				stroke.Thickness = Theme.Sizes.BorderWidth + 1
				topFrame.BackgroundColor3 = Color3.fromRGB(50, 42, 25)
				if glow then glow.Visible = true end
			elseif i < targetDay then
				-- Пройденный день: серая/зеленая галочка и обычная рамка
				stroke.Color = Theme.Colors.Success
				stroke.Thickness = Theme.Sizes.BorderWidth - 1
				topFrame.BackgroundColor3 = Color3.fromRGB(25, 45, 30)
				if glow then glow.Visible = false end
			else
				-- Будущий день: обычная рамка
				stroke.Color = Theme.Colors.Stroke
				stroke.Thickness = Theme.Sizes.BorderWidth
				topFrame.BackgroundColor3 = Theme.Colors.BackgroundSecondary
				if glow then glow.Visible = false end
			end
		end
	end
end

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

function DailyRewardsWindow.init()
	local screenGui = UIManager.getScreenGui()

	rewardsPanel = Panel.create({
		Title = "ЕЖЕДНЕВНЫЕ НАГРАДЫ",
		Size = UDim2.new(0, 480, 0, 360),
		Position = UDim2.new(0.5, -240, 0.5, -180),
		Parent = screenGui,
		OnClose = function()
			rewardsPanel.Close()
		end
	})

	UIManager.registerWindow("Rewards", rewardsPanel)

	-- Контейнер для сетки наград
	streakGrid = Instance.new("Frame")
	streakGrid.Size = UDim2.new(1, -20, 0, 200)
	streakGrid.Position = UDim2.new(0, 10, 0, 15)
	streakGrid.BackgroundTransparency = 1
	streakGrid.Parent = rewardsPanel.Content

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 92, 0, 92)
	gridLayout.CellPadding = UDim2.new(0, 13, 0, 12)
	gridLayout.Parent = streakGrid

	for i = 1, 7 do
		-- Конструкция 3D карточки для каждого дня
		local card = Instance.new("Frame")
		card.Name = "DayCard_" .. i
		card.BackgroundTransparency = 1
		card.Parent = streakGrid

		-- Тень / Нижняя часть карточки (3D эффект)
		local cardShadow = Instance.new("Frame")
		cardShadow.Name = "CardShadow"
		cardShadow.Size = UDim2.new(1, 0, 1, 0)
		cardShadow.Position = UDim2.new(0, 0, 0, 0)
		cardShadow.BackgroundColor3 = Color3.fromRGB(15, 16, 25)
		cardShadow.BorderSizePixel = 0
		cardShadow.Parent = card

		local shadowCorner = Instance.new("UICorner")
		shadowCorner.CornerRadius = Theme.Sizes.CornerRadius
		shadowCorner.Parent = cardShadow

		-- Верхняя (нажимаемая/активная) часть карточки
		local cardTop = Instance.new("Frame")
		cardTop.Name = "CardTop"
		cardTop.Size = UDim2.new(1, 0, 1, -4)
		cardTop.Position = UDim2.new(0, 0, 0, -4)
		cardTop.BackgroundColor3 = Theme.Colors.BackgroundSecondary
		cardTop.BorderSizePixel = 0
		cardTop.Parent = card

		local topCorner = Instance.new("UICorner")
		topCorner.CornerRadius = Theme.Sizes.CornerRadius
		topCorner.Parent = cardTop

		local stroke = Instance.new("UIStroke")
		stroke.Name = "CardStroke"
		stroke.Thickness = Theme.Sizes.BorderWidth
		stroke.Color = Theme.Colors.Stroke
		stroke.Parent = cardTop

		-- Эффект градиента
		local grad = Instance.new("UIGradient")
		grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 220))
		})
		grad.Rotation = 90
		grad.Parent = cardTop

		-- Эффект свечения для текущего дня
		local glow = Instance.new("ImageLabel")
		glow.Name = "Glow"
		glow.Size = UDim2.new(1, 16, 1, 16)
		glow.Position = UDim2.new(0, -8, 0, -8)
		glow.BackgroundTransparency = 1
		glow.Image = "rbxassetid://13848416805" -- Мягкое свечение в стиле симулятора
		glow.ImageColor3 = Color3.fromRGB(241, 196, 15)
		glow.ImageTransparency = 0.5
		glow.Visible = false
		glow.Parent = cardTop

		-- Текст номера дня
		local dayLabel = Instance.new("TextLabel")
		dayLabel.Size = UDim2.new(1, 0, 0, 22)
		dayLabel.Position = UDim2.new(0, 0, 0, 8)
		dayLabel.BackgroundTransparency = 1
		dayLabel.Font = Theme.Fonts.Title
		dayLabel.TextSize = 12
		dayLabel.TextColor3 = Theme.Colors.TextSecondary
		dayLabel.TextStrokeTransparency = 0.8
		dayLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
		dayLabel.Text = "ДЕНЬ " .. i
		dayLabel.Parent = cardTop

		local conf = DailyConfig[i]

		-- Иконка награды
		local icon = Instance.new("TextLabel")
		icon.Size = UDim2.new(0, 26, 0, 26)
		icon.Position = UDim2.new(0.5, -13, 0, 32)
		icon.BackgroundTransparency = 1
		icon.Font = Theme.Fonts.Title
		icon.TextSize = 20
		icon.Text = (conf.RewardType == "Money") and "💵" or "💎"
		icon.Parent = cardTop

		-- Значение награды
		local valLabel = Instance.new("TextLabel")
		valLabel.Size = UDim2.new(1, 0, 0, 22)
		valLabel.Position = UDim2.new(0, 0, 1, -26)
		valLabel.BackgroundTransparency = 1
		valLabel.Font = Theme.Fonts.Title
		valLabel.TextSize = 11
		valLabel.TextColor3 = Theme.Colors.Text
		valLabel.TextStrokeTransparency = 0.8
		valLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
		valLabel.Text = conf.DisplayName
		valLabel.Parent = cardTop
	end

	-- Красивые 3D кнопки внизу окна
	claimButtonComponent = Button.create({
		Text = "ЗАБРАТЬ НАГРАДУ",
		Color = Theme.Colors.Success,
		Size = UDim2.new(0, 210, 0, 44),
		Position = UDim2.new(0.02, 10, 1, -55),
		Parent = rewardsPanel.Content,
		OnClick = function()
			claimDailyEvent:FireServer()
		end
	})

	local promoBtn = Button.create({
		Text = "🏷️ ПРОМОКОДЫ",
		Color = Theme.Colors.Accent,
		Size = UDim2.new(0, 210, 0, 44),
		Position = UDim2.new(0.5, 10, 1, -55),
		Parent = rewardsPanel.Content,
		OnClick = function()
			rewardsPanel.Close()
			UIManager.openWindow("Codes")
		end
	})

	player:GetAttributeChangedSignal("DailyStreak"):Connect(function()
		updateDailyGrid()
		updateCooldownTimer()
	end)
	player:GetAttributeChangedSignal("DailyCooldown"):Connect(function()
		updateDailyGrid()
		updateCooldownTimer()
	end)

	task.spawn(function()
		while true do
			updateCooldownTimer()
			task.wait(1)
		end
	end)

	updateDailyGrid()
	updateCooldownTimer()
end

DailyRewardsWindow.init()

return DailyRewardsWindow
