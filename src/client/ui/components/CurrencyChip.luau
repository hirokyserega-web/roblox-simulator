-- Candy Currency Chip Component (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)

local function CurrencyChip(props)
	local currencyType = props.CurrencyType or "Money"
	local size = props.Size or UDim2.new(0, 150, 0, 40)
	local position = props.Position or UDim2.new(0, 0, 0, 0)
	local value = props.Value or 0
	local layoutOrder = props.LayoutOrder

	local icons = {
		Money = "rbxassetid://15264875322",
		Crystals = "rbxassetid://15264875154",
	}
	
	local icon = icons[currencyType] or ""

	return React.createElement("Frame", {
		Name = "CurrencyChip_" .. currencyType,
		Size = size,
		Position = position,
		BackgroundColor3 = Theme.Colors.Background,
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = Theme.Sizes.CornerPill or UDim.new(0, 20),
		}),
		Stroke = React.createElement("UIStroke", {
			Color = Theme.Colors.Stroke,
			Thickness = Theme.Sizes.StrokeThickness,
		}),

		Icon = React.createElement("ImageLabel", {
			Name = "Icon",
			Size = UDim2.new(0, 28, 0, 28),
			Position = UDim2.new(0, 6, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Image = icon,
		}),

		Value = React.createElement("TextLabel", {
			Name = "Value",
			Size = UDim2.new(1, -45, 1, 0),
			Position = UDim2.new(0, 40, 0, 0),
			BackgroundTransparency = 1,
			Text = tostring(value),
			Font = Theme.Fonts.Main,
			TextColor3 = Theme.Colors.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextScaled = true,
		}, {
			Stroke = React.createElement("UIStroke", {
				Color = Theme.Colors.Stroke,
				Thickness = 1.2,
			}),
			Padding = React.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 6),
			})
		})
	})
end

return CurrencyChip

