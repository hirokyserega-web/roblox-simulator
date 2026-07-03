-- Окно Ежедневных наград (DailyRewardsWindow)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DailyConfig = require(ReplicatedStorage.Shared.config.DailyConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local Panel = require(script.Parent.Parent.components.Panel)
local UIManager = require(script.Parent.Parent.UIManager)

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

		local border = card:FindFirstChild("SelectionBox")
		if border then
			if i == targetDay then
				border.Color3 = Color3.fromRGB(241, 196, 15)
				card.BackgroundColor3 = Color3.fromRGB(45, 40, 30)
			else
				border.Color3 = Theme.Colors.Stroke
				card.BackgroundColor3 = Theme.Colors.BackgroundSecondary
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
		Size = UDim2.new(0, 440, 0, 320),
		Position = UDim2.new(0.5, -220, 0.5, -160),
		Parent = screenGui,
		OnClose = function()
			rewardsPanel.Close()
		end
	})

	UIManager.registerWindow("Rewards", rewardsPanel)

	streakGrid = Instance.new("Frame")
	streakGrid.Size = UDim2.new(1, -20, 0, 175)
	streakGrid.Position = UDim2.new(0, 10, 0, 10)
	streakGrid.BackgroundTransparency = 1
	streakGrid.Parent = rewardsPanel.Content

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

	claimButtonComponent = Button.create({
		Text = "ЗАБРАТЬ НАГРАДУ",
		Color = Theme.Colors.Success,
		Size = UDim2.new(0, 180, 0, 42),
		Position = UDim2.new(0.05, 10, 1, -55),
		Parent = rewardsPanel.Content,
		OnClick = function()
			claimDailyEvent:FireServer()
		end
	})

	-- Кнопка для открытия промокодов
	local promoBtn = Button.create({
		Text = "🏷️ ПРОМОКОДЫ",
		Color = Theme.Colors.Accent,
		Size = UDim2.new(0, 180, 0, 42),
		Position = UDim2.new(0.5, 20, 1, -55),
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
