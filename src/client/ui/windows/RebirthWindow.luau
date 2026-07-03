-- Окно Перерождения (RebirthWindow)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local RebirthConfig = require(ReplicatedStorage.Shared.config.RebirthConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local Panel = require(script.Parent.Parent.components.Panel)
local UIManager = require(script.Parent.Parent.UIManager)

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

	rebirthsLabel.Text = string.format("Текущие перерождения: %d", rebirths)
	multiplierLabel.Text = string.format("Множитель монет: x%.1f", multiplier)
	costLabel.Text = string.format("Цена следующего перерождения: $%s", formatNumber(cost))

	if actionButton then
		actionButton.Destroy()
		actionButton = nil
	end

	local canAfford = money >= cost

	actionButton = Button.create({
		Text = "ПЕРЕРОДИТЬСЯ",
		Color = canAfford and Theme.Colors.Success or Theme.Colors.Error,
		Size = UDim2.new(0, 200, 0, 44),
		Position = UDim2.new(0.5, -100, 1, -55),
		Parent = rebirthPanel.Content,
		OnClick = function()
			if canAfford then
				-- Всплывающий диалог "Точно?"
				local confirmFrame = Instance.new("Frame")
				confirmFrame.Size = UDim2.new(0, 240, 0, 120)
				confirmFrame.Position = UDim2.new(0.5, -120, 0.5, -60)
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
				lbl.Size = UDim2.new(1, -20, 0, 40)
				lbl.Position = UDim2.new(0, 10, 0, 15)
				lbl.BackgroundTransparency = 1
				lbl.Font = Theme.Fonts.Title
				lbl.TextSize = 13
				lbl.TextColor3 = Theme.Colors.Text
				lbl.Text = "Вы уверены? Это сбросит монеты!"
				lbl.Parent = confirmFrame

				local yesBtn = Button.create({
					Text = "ДА",
					Color = Theme.Colors.Success,
					Size = UDim2.new(0, 80, 0, 32),
					Position = UDim2.new(0.15, 0, 0.6, 10),
					Parent = confirmFrame,
					OnClick = function()
						requestRebirthEvent:FireServer()
						confirmFrame:Destroy()
						rebirthPanel.Close()
					end
				})

				local noBtn = Button.create({
					Text = "НЕТ",
					Color = Theme.Colors.Error,
					Size = UDim2.new(0, 80, 0, 32),
					Position = UDim2.new(0.55, 0, 0.6, 10),
					Parent = confirmFrame,
					OnClick = function()
						confirmFrame:Destroy()
					end
				})
			else
				UIManager.ShowToast(string.format("Не хватает монет для перерождения! Нужно: $%s", formatNumber(cost)), "Error")
			end
		end
	})
end

function RebirthWindow.init()
	local screenGui = UIManager.getScreenGui()

	rebirthPanel = Panel.create({
		Title = "ПЕРЕРОЖДЕНИЕ",
		Size = UDim2.new(0, 360, 0, 270),
		Position = UDim2.new(0.5, -180, 0.5, -135),
		Parent = screenGui,
		OnClose = function()
			rebirthPanel.Close()
		end
	})

	UIManager.registerWindow("Rebirth", rebirthPanel)

	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(1, -40, 0, 45)
	desc.Position = UDim2.new(0, 20, 0, 10)
	desc.BackgroundTransparency = 1
	desc.Font = Theme.Fonts.Body
	desc.TextSize = 13
	desc.TextColor3 = Theme.Colors.TextSecondary
	desc.TextWrapped = true
	desc.Text = "Сбрасывает монеты, локации и уровни улучшений в обмен на постоянный множитель монет!"
	desc.Parent = rebirthPanel.Content

	rebirthsLabel = Instance.new("TextLabel")
	rebirthsLabel.Size = UDim2.new(1, -40, 0, 25)
	rebirthsLabel.Position = UDim2.new(0, 20, 0, 65)
	rebirthsLabel.BackgroundTransparency = 1
	rebirthsLabel.Font = Theme.Fonts.Title
	rebirthsLabel.TextSize = 15
	rebirthsLabel.TextColor3 = Theme.Colors.Text
	rebirthsLabel.Text = "Текущие перерождения: 0"
	rebirthsLabel.Parent = rebirthPanel.Content

	multiplierLabel = Instance.new("TextLabel")
	multiplierLabel.Size = UDim2.new(1, -40, 0, 25)
	multiplierLabel.Position = UDim2.new(0, 20, 0, 90)
	multiplierLabel.BackgroundTransparency = 1
	multiplierLabel.Font = Theme.Fonts.Title
	multiplierLabel.TextSize = 15
	multiplierLabel.TextColor3 = Theme.Colors.Success
	multiplierLabel.Text = "Множитель монет: x1.0"
	multiplierLabel.Parent = rebirthPanel.Content

	costLabel = Instance.new("TextLabel")
	costLabel.Size = UDim2.new(1, -40, 0, 25)
	costLabel.Position = UDim2.new(0, 20, 0, 115)
	costLabel.BackgroundTransparency = 1
	costLabel.Font = Theme.Fonts.Title
	costLabel.TextSize = 14
	costLabel.TextColor3 = Theme.Colors.Warning
	costLabel.Text = "Цена следующего перерождения: $10,000"
	costLabel.Parent = rebirthPanel.Content

	player:GetAttributeChangedSignal("Money"):Connect(updateRebirthUI)
	player:GetAttributeChangedSignal("Rebirths"):Connect(updateRebirthUI)

	updateRebirthUI()
end

RebirthWindow.init()

return RebirthWindow
