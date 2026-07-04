-- Candy Currency Chip Component (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)

local function formatNumber(n)
	local left, num, right = string.match(tostring(n), '^([^%d]*%d+)(%d*)(.-)$')
	return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end

local function CurrencyChip(props)
	local currencyType = props.CurrencyType or "Money"
	local size = props.Size or UDim2.new(0, 220, 0, 48) -- Wider size to accommodate +500
	local position = props.Position or UDim2.new(0, 0, 0, 0)
	local value = props.Value or 0
	local layoutOrder = props.LayoutOrder

	local isMoney = currencyType == "Money"
	local icon = isMoney and "💵" or "💎"
	local iconColor = isMoney and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(0, 229, 255)

	-- Custom text layout incorporating the +500 indicator for Money
	local displayText = ""
	if isMoney then
		displayText = string.format("$ %s <font color='#00FF55'>+500</font>", formatNumber(value))
	else
		displayText = string.format("💎 %s", formatNumber(value))
	end

	return React.createElement("Frame", {
		Name = currencyType .. "Chip",
		Size = size,
		Position = position,
		LayoutOrder = layoutOrder,
		BackgroundColor3 = Theme.Colors.BackgroundSecondary,
		BorderSizePixel = 0,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0.5, 0), -- Rounded pill
		}),
		Stroke = React.createElement("UIStroke", {
			Color = Theme.Colors.Stroke,
			Thickness = 3,
		}),
		
		-- Icon Container
		IconLabel = React.createElement("TextLabel", {
			Name = "IconLabel",
			Size = UDim2.new(0, 36, 0, 36),
			Position = UDim2.new(0, 6, 0.5, -18),
			BackgroundTransparency = 1,
			Text = icon,
			TextSize = 24,
			Font = Theme.Fonts.Main,
			TextColor3 = iconColor,
			ZIndex = 2,
		}),

		-- Value with rich text
		ValueLabel = React.createElement("TextLabel", {
			Name = "ValueLabel",
			Size = UDim2.new(1, -50, 1, 0),
			Position = UDim2.new(0, 44, 0, 0),
			BackgroundTransparency = 1,
			Text = displayText,
			RichText = true,
			Font = Theme.Fonts.Main,
			TextColor3 = Theme.Colors.Text,
			TextSize = 20,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 2,
		}, {
			-- Inner soft text shadow
			Shadow = React.createElement("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 1.5,
			})
		}),

		-- Glossy light reflection overlay
		GlossReflection = React.createElement("Frame", {
			Name = "GlossReflection",
			Size = UDim2.new(1, 0, 0.5, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 0.85,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			ZIndex = 3,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0.5, 0),
			})
		})
	})
end

return CurrencyChip
