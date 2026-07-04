-- Candy Rebirth Window (React version)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local function RebirthWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose
	local money = props.Money or 0
	local rebirths = props.Rebirths or 0

	-- Scale cost based on current rebirth count
	local cost = 100000 + (rebirths * 50000)
	local canRebirth = money >= cost

	if not visible then return nil end

	local function requestRebirth()
		if canRebirth then
			Remotes.getEvent("RequestRebirth"):FireServer()
		end
	end

	return React.createElement(Panel, {
		Title = "REBIRTH SYSTEM",
		Size = UDim2.new(0, 450, 0, 340),
		OnClose = onClose,
	}, {
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 16),
		}),

		-- Rebirth Title info
		TitleLabel = React.createElement("TextLabel", {
			Size = UDim2.new(1, -20, 0, 36),
			BackgroundTransparency = 1,
			Text = "RESET STATS FOR PERMANENT MULTIPLIERS!",
			Font = Theme.Fonts.Main,
			TextColor3 = Color3.fromHex("00B0FF"), -- Neon blue
			TextSize = 16,
			TextWrapped = true,
		}, {
			Stroke = React.createElement("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 1.5,
			})
		}),

		-- Rebirth stats container
		StatsFrame = React.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 100),
			BackgroundColor3 = Color3.fromHex("12142B"),
			BorderSizePixel = 0,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerButton,
			}),
			Stroke = React.createElement("UIStroke", {
				Color = Theme.Colors.Stroke,
				Thickness = 2.5,
			}),
			Layout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 10),
			}),

			ActiveMult = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundTransparency = 1,
				Text = string.format("Current Multiplier: <font color='#00FF55'>x%.1f</font>", 1.0 + (rebirths * 0.5)),
				RichText = true,
				Font = Theme.Fonts.Main,
				TextColor3 = Theme.Colors.Text,
				TextSize = 18,
			}),

			CostText = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundTransparency = 1,
				Text = string.format("Required Money: <font color='#FF4B4B'>$%s</font> / $%s", tostring(cost), tostring(money)),
				RichText = true,
				Font = Theme.Fonts.Main,
				TextColor3 = Theme.Colors.TextSecondary,
				TextSize = 16,
			})
		}),

		-- Trigger Action Row
		ActionRow = React.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 52),
			BackgroundTransparency = 1,
		}, {
			Button = React.createElement(Button, {
				Text = canRebirth and "⚡ REBIRTH NOW!" or "⚡ NOT ENOUGH CASH",
				Color = canRebirth and Theme.Colors.Accent or Theme.Colors.Error,
				Size = UDim2.new(1, 0, 1, 0),
				OnClick = requestRebirth,
			})
		})
	})
end

return RebirthWindow
