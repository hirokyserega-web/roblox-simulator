-- Окно Перерождения (RebirthWindow) - Премиум-редизайн под референс
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local RebirthConfig = require(ReplicatedStorage.Shared.config.RebirthConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local Panel = require(script.Parent.Parent.components.Panel)
local UIManager = _G.UIManager

local player = Players.LocalPlayer
local requestRebirthEvent = Remotes.getEvent("RequestRebirth")

local RebirthWindow = {}
local rebirthPanel = nil
local rebirthsLabel = nil
local multiplierLabel = nil
local costLabel = nil
local actionButton = nil

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

local function updateRebirthUI()
	if not rebirthPanel then return end

	local rebirths = player:GetAttribute("Rebirths") or 0
	local money = player:GetAttribute("Money") or 0

	local cost = RebirthConfig.getCost(rebirths)
	local multiplier = 1.0 + (rebirths * RebirthConfig.MultiplierPerRebirth)

	rebirthsLabel.Text = string.format("🔄 ТЕКУЩИЕ ПЕРЕРОЖДЕНИЯ: %d", rebirths)
	multiplierLabel.Text = string.format("✨ МНОЖИТЕЛЬ МОНЕТ: x%.1f", multiplier)
	costLabel.Text = string.format("💵 СТОИМОСТЬ: $%s", formatNumber(cost))

	if actionButton then
		actionButton.Destroy()
		actionButton = nil
	end

	local canAfford = money >= cost

	actionButton = Button.create({
		Text = "СОВЕРШИТЬ ПЕРЕРОДЕНИЕ",
		Color = canAfford and Theme.Colors.Success or Theme.Colors.Error,
		Size = UDim2.new(1, -40, 0, 48),
		Position = UDim2.new(0, 20, 1, -65),
		Parent = rebirthPanel.Content,
		OnClick = function()
			if canAfford then
				-- Всплывающий диалог "Точно?"
				local confirmFrame = Instance.new("Frame")
				confirmFrame.Size = UDim2.new(0, 260, 0, 140)
				confirmFrame.Position = UDim2.new(0.5, -130, 0.5, -70)
				confirmFrame.BackgroundColor3 = Theme.Colors.Background
				confirmFrame.ZIndex = 300
				confirmFrame.Parent = UIManager.getScreenGui()

				local crn = Instance.new("UICorner")
				crn.CornerRadius = Theme.Sizes.CornerRadius
				crn.Parent = confirmFrame

				local strk = Instance.new("UIStroke")
				strk.Thickness = Theme.Sizes.BorderWidth
				strk.Color = Theme.Colors.Warning
				strk.Parent = confirmFrame

				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, -20, 0, 50)
				lbl.Position = UDim2.new(0, 10, 0, 15)
				lbl.BackgroundTransparency = 1
				lbl.Font = Theme.Fonts.Title
				lbl.TextSize = 13
				lbl.TextColor3 = Theme.Colors.Text
				lbl.TextWrapped = true
				lbl.Text = "ВНИМАНИЕ! Это сбросит ваши монеты и уровни улучшений!"
				lbl.Parent = confirmFrame

				local yesBtn = Button.create({
					Text = "ДА",
					Color = Theme.Colors.Success,
					Size = UDim2.new(0, 90, 0, 36),
					Position = UDim2.new(0.1, 0, 0.6, 10),
					Parent = confirmFrame,
					OnClick = function()
						requestRebirthEvent:FireServer()
						confirmFrame:Destroy()
						rebirthPanel.Close()
					end
				})

				local noBtn = Button.create({
					Text = "ОТМЕНА",
					Color = Theme.Colors.Error,
					Size = UDim2.new(0, 90, 0, 36),
					Position = UDim2.new(0.55, 0, 0.6, 10),
					Parent = confirmFrame,
					OnClick = function()
						confirmFrame:Destroy()
					end
				})
			else
				UIManager.ShowToast(string.format("Недостаточно монет! Требуется: $%s", formatNumber(cost)), "Error")
			end
		end
	})
end

function RebirthWindow.init()
	local screenGui = UIManager.getScreenGui()

	rebirthPanel = Panel.create({
		Title = "ПЕРЕРОЖДЕНИЯ",
		Size = UDim2.new(0, 380, 0, 310),
		Position = UDim2.new(0.5, -190, 0.5, -155),
		Parent = screenGui,
		OnClose = function()
			rebirthPanel.Close()
		end
	})

	UIManager.registerWindow("Rebirth", rebirthPanel)

	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -20, 1, -20)
	container.Position = UDim2.new(0, 10, 0, 10)
	container.BackgroundTransparency = 1
	container.Parent = rebirthPanel.Content

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Parent = container

	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(1, -20, 0, 45)
	desc.BackgroundTransparency = 1
	desc.Font = Theme.Fonts.Title
	desc.TextSize = 12
	desc.TextColor3 = Theme.Colors.TextSecondary
	desc.TextWrapped = true
	desc.Text = "Сбросьте монеты и улучшения, чтобы получить колоссальный постоянный множитель монет!"
	desc.Parent = container

	-- Подложка для статов
	local statsBox = Instance.new("Frame")
	statsBox.Size = UDim2.new(1, -20, 0, 120)
	statsBox.BackgroundColor3 = Theme.Colors.BackgroundSecondary
	statsBox.BorderSizePixel = 0
	statsBox.Parent = container

	local sbCorner = Instance.new("UICorner")
	sbCorner.CornerRadius = Theme.Sizes.CornerRadius
	sbCorner.Parent = statsBox

	local sbStroke = Instance.new("UIStroke")
	sbStroke.Thickness = Theme.Sizes.BorderWidth
	sbStroke.Color = Theme.Colors.Stroke
	sbStroke.Parent = statsBox

	rebirthsLabel = Instance.new("TextLabel")
	rebirthsLabel.Size = UDim2.new(1, -30, 0, 30)
	rebirthsLabel.Position = UDim2.new(0, 15, 0, 12)
	rebirthsLabel.BackgroundTransparency = 1
	rebirthsLabel.Font = Theme.Fonts.Title
	rebirthsLabel.TextSize = 13
	rebirthsLabel.TextColor3 = Theme.Colors.Text
	rebirthsLabel.TextXAlignment = Enum.TextXAlignment.Left
	rebirthsLabel.Text = "🔄 ТЕКУЩИЕ ПЕРЕРОЖДЕНИЯ: 0"
	rebirthsLabel.Parent = statsBox

	multiplierLabel = Instance.new("TextLabel")
	multiplierLabel.Size = UDim2.new(1, -30, 0, 30)
	multiplierLabel.Position = UDim2.new(0, 15, 0, 44)
	multiplierLabel.BackgroundTransparency = 1
	multiplierLabel.Font = Theme.Fonts.Title
	multiplierLabel.TextSize = 13
	multiplierLabel.TextColor3 = Theme.Colors.Success
	multiplierLabel.TextXAlignment = Enum.TextXAlignment.Left
	multiplierLabel.Text = "✨ МНОЖИТЕЛЬ МОНЕТ: x1.0"
	multiplierLabel.Parent = statsBox

	costLabel = Instance.new("TextLabel")
	costLabel.Size = UDim2.new(1, -30, 0, 30)
	costLabel.Position = UDim2.new(0, 15, 0, 76)
	costLabel.BackgroundTransparency = 1
	costLabel.Font = Theme.Fonts.Title
	costLabel.TextSize = 13
	costLabel.TextColor3 = Theme.Colors.Warning
	costLabel.TextXAlignment = Enum.TextXAlignment.Left
	costLabel.Text = "💵 СТОИМОСТЬ: $10,000"
	costLabel.Parent = statsBox

	player:GetAttributeChangedSignal("Money"):Connect(updateRebirthUI)
	player:GetAttributeChangedSignal("Rebirths"):Connect(updateRebirthUI)

	updateRebirthUI()
end

RebirthWindow.init()

return RebirthWindow
