-- Candy Rebirth Window (React version)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local RebirthConfig = require(ReplicatedStorage.Shared.config.RebirthConfig)

local function RebirthWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose
	local money = props.Money or 0
	local rebirths = props.Rebirths or 0

	local cost = RebirthConfig.getCost(rebirths)
	local canRebirth = money >= cost

	if not visible then return nil end

	local function requestRebirth()
		if canRebirth then
			Remotes.getEvent("RequestRebirth"):FireServer()
		end
	end

	return React.createElement(Panel, {
		Title = "REBIRTH SYSTEM",
		Size = UDim2.new(0, 450, 0, 360),
		OnClose = onClose,
	}, {
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 20),
		}),

		Padding = React.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 20),
		}),

		-- Rebirth Title info
		TitleLabel = React.createElement("TextLabel", {
			Size = UDim2.new(1, -40, 0, 44),
			BackgroundTransparency = 1,
			Text = "RESET STATS FOR PERMANENT MULTIPLIERS!",
			Font = Theme.Fonts.Main,
			TextColor3 = Theme.Colors.Info,
			TextSize = 18,
			TextWrapped = true,
			LayoutOrder = 1,
		}, {
			Stroke = React.createElement("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 2,
			})
		}),

		-- Rebirth stats container
		StatsFrame = React.createElement("Frame", {
			Size = UDim2.new(1, -40, 0, 120),
			BackgroundColor3 = Theme.Colors.BackgroundSecondary,
			BorderSizePixel = 0,
			LayoutOrder = 2,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerButton,
			}),
			Stroke = React.createElement("UIStroke", {
				Color = Theme.Colors.Stroke,
				Thickness = 2,
			}),
			Layout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 12),
			}),

			ActiveMult = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundTransparency = 1,
				Text = string.format("Current Multiplier: <font color='#3AE374'>x%.1f</font>", 1.0 + (rebirths * RebirthConfig.MultiplierPerRebirth)),
				RichText = true,
				Font = Theme.Fonts.Main,
				TextColor3 = Theme.Colors.Text,
				TextSize = 22,
			}),

			CostText = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundTransparency = 1,
				Text = string.format("Required Money: <font color='%s'>$%d</font> / $%d", if canRebirth then "#3AE374" else "#FF3B3B", cost, money),
				RichText = true,
				Font = Theme.Fonts.Main,
				TextColor3 = Theme.Colors.TextSecondary,
				TextSize = 18,
			})
		}),

		-- Trigger Action Row
		ActionRow = React.createElement("Frame", {
			Size = UDim2.new(1, -40, 0, 60),
			BackgroundTransparency = 1,
			LayoutOrder = 3,
		}, {
			Button = React.createElement(Button, {
				Text = if canRebirth then "⚡ REBIRTH NOW!" else "⚡ NOT ENOUGH CASH",
				Color = if canRebirth then Theme.Colors.Accent else Color3.fromRGB(100, 100, 100),
				Size = UDim2.new(1, 0, 1, 0),
				OnClick = requestRebirth,
				Enabled = canRebirth,
			})
		})
	})
end

return RebirthWindow
