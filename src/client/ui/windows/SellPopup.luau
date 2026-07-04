-- Candy Sell Popup Window (React version)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local function SellPopup(props)
	local visible = props.Visible
	local onClose = props.OnClose
	local sellValue = props.SellValue or 0

	if not visible then return nil end

	local function confirmSell()
		Remotes.getEvent("SellGhosts"):FireServer()
		if onClose then onClose() end
	end

	return React.createElement(Panel, {
		Title = "SELL GHOSTS",
		Size = UDim2.new(0, 420, 0, 280),
		OnClose = onClose,
	}, {
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 18),
		}),

		-- Message
		MessageText = React.createElement("TextLabel", {
			Size = UDim2.new(1, -20, 0, 40),
			BackgroundTransparency = 1,
			Text = string.format("Are you sure you want to sell your ghosts for <font color='#00FF55'>$%d</font>?", sellValue),
			RichText = true,
			Font = Theme.Fonts.Main,
			TextColor3 = Theme.Colors.Text,
			TextSize = 18,
			TextWrapped = true,
		}, {
			Shadow = React.createElement("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 1.5,
			})
		}),

		-- Confirm Button Row
		ConfirmBtnRow = React.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 52),
			BackgroundTransparency = 1,
		}, {
			Button = React.createElement(Button, {
				Text = "💰 CONFIRM & SELL GHOSTS",
				Color = Theme.Colors.Success,
				Size = UDim2.new(1, 0, 1, 0),
				OnClick = confirmSell,
			})
		})
	})
end

return SellPopup
