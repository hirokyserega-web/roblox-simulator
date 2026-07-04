-- SellPopup (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)

local function formatNumber(value: number): string
	local formatted = tostring(value)
	while true do  
		local k
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

local function SellPopup(props)
	local earnings = props.Earnings or 0
	local caughtGhosts = props.Ghosts or {}

	local counts = {}
	for _, rarity in ipairs(caughtGhosts) do
		counts[rarity] = (counts[rarity] or 0) + 1
	end

	local listItems = {
		ListLayout = React.createElement("UIListLayout", {
			Padding = UDim.new(0, 4),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		})
	}

	for rarity, count in pairs(counts) do
		listItems["Rarity_" .. rarity] = React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, 16),
			BackgroundTransparency = 1,
			Font = Theme.Fonts.Bold,
			TextSize = 12,
			TextColor3 = Theme.RarityColors[rarity] or Theme.Colors.Text,
			Text = string.format("%s: %d призраков", rarity:upper(), count),
		})
	end

	return React.createElement("Frame", {
		Name = "SellPopupFrame",
		Size = UDim2.new(0, 280, 0, 200),
		Position = UDim2.new(0.5, -140, 0.45, -100),
		BackgroundColor3 = Theme.Colors.Background,
		BorderSizePixel = 0,
		ZIndex = 250,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = Theme.Sizes.CornerRadius,
		}),
		Stroke = React.createElement("UIStroke", {
			Thickness = Theme.Sizes.BorderWidth or 2,
			Color = Theme.Colors.Success,
		}),

		Header = React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, 30),
			Position = UDim2.new(0, 0, 0, 12),
			BackgroundTransparency = 1,
			Font = Theme.Fonts.Title,
			TextSize = 14,
			TextColor3 = Theme.Colors.TextSecondary,
			Text = "УСПЕШНАЯ ПРОДАЖА",
		}),

		Earnings = React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, 45),
			Position = UDim2.new(0, 0, 0, 38),
			BackgroundTransparency = 1,
			Font = Theme.Fonts.Title,
			TextSize = 32,
			TextColor3 = Theme.Colors.Success,
			Text = string.format("+$%s 💰", formatNumber(earnings)),
		}),

		ListContainer = React.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 60),
			Position = UDim2.new(0, 10, 0, 85),
			BackgroundTransparency = 1,
		}, listItems)
	})
end

return SellPopup

