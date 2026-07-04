-- Candy Bag Widget (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local ProgressBar = require(script.Parent.Parent.components.ProgressBar)

local function BagWidget(props)
	local position = props.Position or UDim2.new(1, -170, 0.4, -90)
	local count = props.Count or 0
	local maxCapacity = props.MaxCapacity or 10

	local progress = count / maxCapacity
	local barColor = count >= maxCapacity and Theme.Colors.Error or Theme.Colors.Orange

	return React.createElement("Frame", {
		Name = "BagWidget",
		Size = UDim2.new(0, 160, 0, 75),
		Position = position,
		BackgroundColor3 = Theme.Colors.Panel,
		BackgroundTransparency = 1 - (Theme.Colors.PanelOpacity or 0.8),
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = Theme.Sizes.CornerRadius,
		}),
		Stroke = React.createElement("UIStroke", {
			Color = Theme.Colors.Stroke,
			Thickness = 2,
		}),

		Title = React.createElement("TextLabel", {
			Name = "Label",
			Size = UDim2.new(1, 0, 0, 25),
			BackgroundTransparency = 1,
			Text = "INVENTORY",
			Font = Theme.Fonts.Bold,
			TextColor3 = Theme.Colors.TextSecondary,
			TextSize = 12,
		}),

		Bar = React.createElement(ProgressBar, {
			Size = UDim2.new(1, -20, 0, 20),
			Position = UDim2.new(0.5, 0, 0, 35),
			AnchorPoint = Vector2.new(0.5, 0),
			Progress = progress,
			Color = barColor,
		}),

		CountLabel = React.createElement("TextLabel", {
			Name = "CountLabel",
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 1, -22),
			BackgroundTransparency = 1,
			Text = string.format("%d / %d", count, maxCapacity),
			Font = Theme.Fonts.Main,
			TextColor3 = Theme.Colors.Text,
			TextSize = 16,
		})
	})
end

return BagWidget

