-- Candy Item Card Component (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)

local function ItemCard(props)
	local title = props.Title or "ITEM"
	local rarity = props.Rarity or "Common"
	local subtext = props.Subtext or ""
	local iconColor = props.IconColor or Theme.Colors.Text
	local equipped = props.Equipped or false

	local strokeColor = equipped and Theme.Colors.Success or Theme.Colors.Stroke
	local strokeThickness = equipped and 3 or 2

	return React.createElement("TextButton", {
		Name = "Card_" .. title,
		Size = UDim2.new(0, 95, 0, 110),
		BackgroundColor3 = Theme.Colors.Panel,
		AutoButtonColor = false,
		Text = "",

		[React.Event.Activated] = function()
			if props.OnClick then props.OnClick() end
		end,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = Theme.Sizes.CornerRadius,
		}),
		Stroke = React.createElement("UIStroke", {
			Color = strokeColor,
			Thickness = strokeThickness,
		}),

		TitleLabel = React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 0, 5),
			BackgroundTransparency = 1,
			Text = title,
			Font = Theme.Fonts.Bold,
			TextSize = 12,
			TextColor3 = Theme.RarityColors[rarity] or Theme.Colors.Text,
		}),

		Icon = React.createElement("Frame", {
			Size = UDim2.new(0, 40, 0, 40),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = iconColor,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			})
		}),

		Sub = React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, 15),
			Position = UDim2.new(0, 0, 1, -20),
			BackgroundTransparency = 1,
			Text = subtext,
			Font = Theme.Fonts.Main,
			TextSize = 10,
			TextColor3 = Theme.Colors.TextSecondary,
		}),

		EquippedLabel = equipped and React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, 15),
			Position = UDim2.new(0, 0, 0, 20),
			BackgroundTransparency = 1,
			Text = "EQUIPPED",
			Font = Theme.Fonts.Bold,
			TextSize = 9,
			TextColor3 = Theme.Colors.Success,
		}) or nil
	})
end

return ItemCard

