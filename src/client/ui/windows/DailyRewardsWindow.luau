-- DailyRewardsWindow (React version)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
local DailyConfig = require(ReplicatedStorage.Shared.config.DailyConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local UIManager = {
	ShowToast = function(...)
		if _G.UIManager then
			_G.UIManager.ShowToast(...)
		end
	end,
	openWindow = function(...)
		if _G.UIManager then
			_G.UIManager.openWindow(...)
		end
	end,
}


local claimDailyEvent = Remotes.getEvent("ClaimDaily")

local function DailyRewardsWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose

	local player = Players.LocalPlayer

	local streak, setStreak = React.useState(player:GetAttribute("DailyStreak") or 0)
	local cooldown, setCooldown = React.useState(player:GetAttribute("DailyCooldown") or 0)
	local currentTime, setCurrentTime = React.useState(os.time())

	React.useEffect(function()
		local c1 = player:GetAttributeChangedSignal("DailyStreak"):Connect(function()
			setStreak(player:GetAttribute("DailyStreak") or 0)
		end)
		local c2 = player:GetAttributeChangedSignal("DailyCooldown"):Connect(function()
			setCooldown(player:GetAttribute("DailyCooldown") or 0)
		end)

		return function()
			c1:Disconnect()
			c2:Disconnect()
		end
	end, {})

	React.useEffect(function()
		local active = true
		task.spawn(function()
			while active do
				setCurrentTime(os.time())
				task.wait(1)
			end
		end)
		return function()
			active = false
		end
	end, {})

	if not visible then return nil end

	local isClaimable = currentTime >= cooldown
	local targetDay = isClaimable and ((streak % 7) + 1) or streak
	if targetDay == 0 then targetDay = 1 end

	local claimText = "ЗАБРАТЬ НАГРАДУ"
	local claimEnabled = true

	if not isClaimable then
		local timeLeft = cooldown - currentTime
		if timeLeft > 0 then
			local hours = math.floor(timeLeft / 3600)
			local mins = math.floor((timeLeft % 3600) / 60)
			local secs = timeLeft % 60
			claimText = string.format("%02d:%02d:%02d", hours, mins, secs)
			claimEnabled = false
		end
	end

	local gridItems = {
		GridLayout = React.createElement("UIGridLayout", {
			CellSize = UDim2.new(0, 92, 0, 92),
			CellPadding = UDim2.new(0, 13, 0, 12),
		})
	}

	for i = 1, 7 do
		local conf = DailyConfig[i]
		local strokeColor = Theme.Colors.Stroke
		local strokeThickness = Theme.Sizes.BorderWidth or 2
		local bgColor = Theme.Colors.BackgroundSecondary
		local glowVisible = false

		if i == targetDay then
			strokeColor = Color3.fromRGB(241, 196, 15)
			strokeThickness = (Theme.Sizes.BorderWidth or 2) + 1
			bgColor = Color3.fromRGB(50, 42, 25)
			glowVisible = true
		elseif i < targetDay then
			strokeColor = Theme.Colors.Success
			strokeThickness = (Theme.Sizes.BorderWidth or 2) - 1
			bgColor = Color3.fromRGB(25, 45, 30)
		end

		gridItems["Day_" .. i] = React.createElement("Frame", {
			Name = "DayCard_" .. i,
			BackgroundTransparency = 1,
			LayoutOrder = i,
		}, {
			CardShadow = React.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(15, 16, 25),
				BorderSizePixel = 0,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = Theme.Sizes.CornerRadius,
				})
			}),

			CardTop = React.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, -4),
				Position = UDim2.new(0, 0, 0, -4),
				BackgroundColor3 = bgColor,
				BorderSizePixel = 0,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = Theme.Sizes.CornerRadius,
				}),
				Stroke = React.createElement("UIStroke", {
					Thickness = strokeThickness,
					Color = strokeColor,
				}),
				Gradient = React.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 220))
					}),
					Rotation = 90,
				}),

				Glow = glowVisible and React.createElement("ImageLabel", {
					Size = UDim2.new(1, 16, 1, 16),
					Position = UDim2.new(0, -8, 0, -8),
					BackgroundTransparency = 1,
					Image = "rbxassetid://13848416805",
					ImageColor3 = Color3.fromRGB(241, 196, 15),
					ImageTransparency = 0.5,
				}) or nil,

				DayLabel = React.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, 22),
					Position = UDim2.new(0, 0, 0, 8),
					BackgroundTransparency = 1,
					Font = Theme.Fonts.Title,
					TextSize = 12,
					TextColor3 = Theme.Colors.TextSecondary,
					Text = "ДЕНЬ " .. i,
				}, {
					Stroke = React.createElement("UIStroke", {
						Color = Color3.new(0, 0, 0),
						Thickness = 0.8,
					})
				}),

				Icon = React.createElement("TextLabel", {
					Size = UDim2.new(0, 26, 0, 26),
					Position = UDim2.new(0.5, -13, 0, 32),
					BackgroundTransparency = 1,
					Font = Theme.Fonts.Title,
					TextSize = 20,
					Text = (conf.RewardType == "Money") and "💵" or "💎",
				}),

				ValLabel = React.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, 22),
					Position = UDim2.new(0, 0, 1, -26),
					BackgroundTransparency = 1,
					Font = Theme.Fonts.Title,
					TextSize = 11,
					TextColor3 = Theme.Colors.Text,
					Text = conf.DisplayName,
				}, {
					Stroke = React.createElement("UIStroke", {
						Color = Color3.new(0, 0, 0),
						Thickness = 0.8,
					})
				})
			})
		})
	end

	return React.createElement(Panel, {
		Title = "ЕЖЕДНЕВНЫЕ НАГРАДЫ",
		Size = UDim2.new(0, 480, 0, 360),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Visible = true,
		OnClose = onClose,
	}, {
		Grid = React.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 200),
			Position = UDim2.new(0, 10, 0, 15),
			BackgroundTransparency = 1,
		}, gridItems),

		ClaimBtn = React.createElement(Button, {
			Text = claimText,
			Color = Theme.Colors.Success,
			Size = UDim2.new(0, 210, 0, 44),
			Position = UDim2.new(0.02, 10, 1, -55),
			Enabled = claimEnabled,
			OnClick = function()
				claimDailyEvent:FireServer()
			end
		}),

		PromoBtn = React.createElement(Button, {
			Text = "🏷️ ПРОМОКОДЫ",
			Color = Theme.Colors.Accent,
			Size = UDim2.new(0, 210, 0, 44),
			Position = UDim2.new(0.5, 10, 1, -55),
			OnClick = function()
				if onClose then onClose() end
				UIManager.openWindow("Codes")
			end
		})
	})
end

return DailyRewardsWindow

