-- Candy Currency Chip Component
local Theme = require(script.Parent.Parent.theme.Theme)

local ChipFactory = {}

function ChipFactory.create(options)
	local currencyType = options.CurrencyType or "Money"
	local color = options.Color or Theme.Colors.Green
	local size = options.Size or UDim2.new(0, 150, 0, 40)
	local position = options.Position or UDim2.new(0, 0, 0, 0)
	local parent = options.Parent

	-- Icons map based on CurrencyType (Placeholders)
	local icons = {
		Money = "rbxassetid://15264875322", -- Replace with real asset ID
		Crystals = "rbxassetid://15264875154",
	}
	
	local icon = icons[currencyType] or ""

	local chip = Instance.new("Frame")
	chip.Name = "CurrencyChip_" .. currencyType
	chip.Size = size
	chip.Position = position
	chip.BackgroundColor3 = Theme.Colors.Background
	chip.BorderSizePixel = 0
	chip.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Sizes.CornerPill
	corner.Parent = chip

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Colors.Stroke
	stroke.Thickness = Theme.Sizes.StrokeThickness
	stroke.Parent = chip

	-- Icon
	local iconFrame = Instance.new("ImageLabel")
	iconFrame.Name = "Icon"
	iconFrame.Size = UDim2.new(0, 28, 0, 28)
	iconFrame.Position = UDim2.new(0, 6, 0.5, 0)
	iconFrame.AnchorPoint = Vector2.new(0, 0.5)
	iconFrame.BackgroundTransparency = 1
	iconFrame.Image = icon
	iconFrame.Parent = chip

	-- Text Label
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Value"
	textLabel.Size = UDim2.new(1, -45, 1, 0)
	textLabel.Position = UDim2.new(0, 40, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "0"
	textLabel.Font = Theme.Fonts.Main
	textLabel.TextColor3 = Theme.Colors.Text
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextScaled = true
	textLabel.Parent = chip

	local ts = Instance.new("UIStroke")
	ts.Color = Theme.Colors.Stroke
	ts.Thickness = 1.2
	ts.Parent = textLabel
	
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 6)
	pad.PaddingBottom = UDim.new(0, 6)
	pad.Parent = textLabel

	local api = {}
	api.Instance = chip

	function api.SetValue(val)
		textLabel.Text = tostring(val)
	end

	return api
end

return ChipFactory
