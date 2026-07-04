-- Candy Panel Component (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local CurrencyChip = require(script.Parent.Parent.components.CurrencyChip)

local function Panel(props)
	local size = props.Size or UDim2.new(0, 400, 0, 300)
	local position = props.Position or UDim2.new(0.5, 0, 0.5, 0)
	local anchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5)
	local title = props.Title or ""
	local showBalance = props.ShowBalance or false
	local balanceValue = props.BalanceValue or 0
	local visible = props.Visible ~= false

	if not visible then return nil end

	return React.createElement("Frame", {
		Name = "CandyPanel_" .. tostring(title),
		Size = size,
		Position = position,
		AnchorPoint = anchorPoint,
		BackgroundColor3 = Theme.Colors.Panel,
		BackgroundTransparency = 1 - (Theme.Colors.PanelOpacity or 0.9),
		BorderSizePixel = 0,
		ZIndex = props.ZIndex or 10,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = Theme.Sizes.CornerPanel or UDim.new(0, 16),
		}),
		Stroke = React.createElement("UIStroke", {
			Color = Theme.Colors.Stroke,
			Thickness = 3,
		}),

		Header = React.createElement("Frame", {
			Name = "Header",
			Size = UDim2.new(1, 0, 0, 60),
			BackgroundTransparency = 1,
		}, {
			TitleLabel = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = title:upper(),
				Font = Theme.Fonts.Title,
				TextSize = 28,
				TextColor3 = Theme.Colors.Text,
			}),

			CloseButton = React.createElement("TextButton", {
				Name = "CloseButton",
				Size = UDim2.new(0, 32, 0, 32),
				Position = UDim2.new(1, -15, 0, 15),
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = Theme.Colors.Error or Color3.fromRGB(255, 63, 75),
				Text = "X",
				Font = Theme.Fonts.Bold,
				TextColor3 = Theme.Colors.Text,

				[React.Event.Activated] = function()
					if props.OnClose then props.OnClose() end
				end,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				})
			})
		}),

		BalanceChip = showBalance and React.createElement(CurrencyChip, {
			CurrencyType = "Money",
			Value = balanceValue,
			Position = UDim2.new(0.5, -75, 0, 60),
		}) or nil,

		Content = React.createElement("Frame", {
			Name = "Content",
			Size = UDim2.new(1, -20, 1, -80),
			Position = UDim2.new(0.5, 0, 0, 70),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
		}, props.children)
	})
end

return Panel

