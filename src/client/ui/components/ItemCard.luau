-- Candy Item Card Component
local Theme = require(script.Parent.Parent.theme.Theme)

local CardFactory = {}

function CardFactory.create(options)
	local rarity = options.Rarity or "Common"
	local rarityColor = Theme.RarityColors[rarity] or Theme.RarityColors.Common
	local name = options.Name or "Item"
	local icon = options.Icon or ""
	local size = options.Size or UDim2.new(0, 100, 0, 120)
	local parent = options.Parent

	local card = Instance.new("Frame")
	card.Name = "Card_" .. name
	card.Size = size
	card.BackgroundColor3 = Theme.Colors.Panel
	card.BorderSizePixel = 0
	card.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Sizes.CornerButton
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Colors.Stroke
	stroke.Thickness = Theme.Sizes.StrokeThickness
	stroke.Parent = card

	-- Background Glow (Rarity based)
	local glow = Instance.new("Frame")
	glow.Name = "RarityGlow"
	glow.Size = UDim2.new(1, 0, 1, 0)
	glow.BackgroundTransparency = 0.8
	glow.BackgroundColor3 = rarityColor
	glow.BorderSizePixel = 0
	glow.Parent = card
	
	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = Theme.Sizes.CornerButton
	glowCorner.Parent = glow

	-- Icon
	local iconImg = Instance.new("ImageLabel")
	iconImg.Size = UDim2.new(0.7, 0, 0.6, 0)
	iconImg.Position = UDim2.new(0.5, 0, 0.1, 0)
	iconImg.AnchorPoint = Vector2.new(0.5, 0)
	iconImg.BackgroundTransparency = 1
	iconImg.Image = icon
	iconImg.Parent = card

	-- Name
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0, 24)
	label.Position = UDim2.new(0.5, 0, 0.9, 0)
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.BackgroundTransparency = 1
	label.Text = name:upper()
	label.Font = Theme.Fonts.Main
	label.TextColor3 = Theme.Colors.Text
	label.TextScaled = true
	label.Parent = card

	local ts = Instance.new("UIStroke")
	ts.Color = Theme.Colors.Stroke
	ts.Thickness = 1
	ts.Parent = label

	return card
end

return CardFactory
