-- Candy Daily Rewards Window (React version)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local function DailyRewardsWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose

	-- Check attribute on player for active claimed streak day
	local player = Players.LocalPlayer
	local streak = player and player:GetAttribute("DailyStreak") or 1

	if not visible then return nil end

	local function claimReward()
		Remotes.getEvent("ClaimDaily"):FireServer()
		if onClose then onClose() end
	end

	local daysChildren = {
		GridLayout = React.createElement("UIGridLayout", {
			CellSize = UDim2.new(0, 80, 0, 100),
			CellPadding = UDim2.new(0, 12, 0, 12),
			FillDirectionMaxCells = 4,
			StartCorner = Enum.StartCorner.TopLeft,
		})
	}

	-- Generate days list
	for d = 1, 8 do
		local isCurrent = d == streak
		local isClaimed = d < streak
		local icon = "🎁"
		if d == 8 then icon = "👑" end

		daysChildren["Day_" .. d] = React.createElement("Frame", {
			Size = UDim2.new(0, 80, 0, 100),
			BackgroundColor3 = if isCurrent then Color3.fromHex("1B1D36") else Color3.fromHex("12142B"),
			BorderSizePixel = 0,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerButton,
			}),
			Stroke = React.createElement("UIStroke", {
				Color = if isCurrent then Color3.fromHex("00B0FF") else Theme.Colors.Stroke,
				Thickness = if isCurrent then 2.5 else 1.5,
			}),

			-- Day Label
			DayText = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.new(0, 0, 0, 8),
				BackgroundTransparency = 1,
				Text = "DAY " .. d,
				Font = Theme.Fonts.Main,
				TextColor3 = if isCurrent then Theme.Colors.Text else Theme.Colors.TextSecondary,
				TextSize = 13,
			}),

			-- Gift Icon
			GiftIcon = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 44),
				Position = UDim2.new(0, 0, 0, 26),
				BackgroundTransparency = 1,
				Text = icon,
				TextSize = 28,
				Font = Theme.Fonts.Main,
			}),

			-- Claimed indicator / value
			StatusText = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.new(0, 0, 1, -22),
				BackgroundTransparency = 1,
				Text = if isClaimed then "CLAIMED ✅" else (isCurrent then "READY ⭐" else "LOCKED 🔒"),
				Font = Theme.Fonts.Main,
				TextColor3 = if isClaimed then Color3.fromRGB(0, 210, 80) else (isCurrent then Color3.fromRGB(255, 179, 0) else Theme.Colors.TextSecondary),
				TextSize = 10,
			})
		})
	end

	return React.createElement(Panel, {
		Title = "DAILY REWARDS",
		Size = UDim2.new(0, 450, 0, 360),
		OnClose = onClose,
	}, {
		-- Grid layout frame
		Grid = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 0.7, 0),
			BackgroundTransparency = 1,
		}, daysChildren),

		-- Bottom Claim Button
		ClaimBtnRow = React.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 52),
			Position = UDim2.new(0, 10, 1, -62),
			BackgroundTransparency = 1,
		}, {
			Button = React.createElement(Button, {
				Text = "CLAIM CURRENT DAY REWARD 🌟",
				Color = Theme.Colors.Success,
				Size = UDim2.new(1, 0, 1, 0),
				OnClick = claimReward,
			})
		})
	})
end

return DailyRewardsWindow
