-- Candy Detector Widget
local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Parent.theme.Theme)

local DetectorWidget = {}

function DetectorWidget.create(options)
	local parent = options.Parent

	local container = Instance.new("Frame")
	container.Name = "DetectorWidget"
	container.Size = UDim2.new(0, 160, 0, 80)
	container.Position = options.Position or UDim2.new(0, 20, 0.5, -241)
	container.BackgroundColor3 = Theme.Colors.Panel
	container.BackgroundTransparency = 1 - (Theme.Colors.PanelOpacity or 0.8)
	container.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Sizes.CornerRadius
	corner.Parent = container

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Colors.Stroke
	stroke.Thickness = 2
	stroke.Parent = container

	local title = Instance.new("TextLabel")
	title.Name = "Label"
	title.Size = UDim2.new(1, 0, 0, 25)
	title.BackgroundTransparency = 1
	title.Text = "SIGNAL STRENGTH"
	title.Font = Theme.Fonts.Bold
	title.TextColor3 = Theme.Colors.TextSecondary
	title.TextSize = 12
	title.Parent = container

	local meter = Instance.new("Frame")
	meter.Name = "Meter"
	meter.Size = UDim2.new(1, -20, 0, 12)
	meter.Position = UDim2.new(0.5, 0, 0, 40)
	meter.AnchorPoint = Vector2.new(0.5, 0)
	meter.BackgroundColor3 = Theme.Colors.Background
	meter.Parent = container
	
	Instance.new("UICorner", meter).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Theme.Colors.Info
	fill.Parent = meter
	
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "RarityLabel"
	rarityLabel.Size = UDim2.new(1, 0, 0, 20)
	rarityLabel.Position = UDim2.new(0, 0, 1, -25)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text = "NONE"
	rarityLabel.Font = Theme.Fonts.Main
	rarityLabel.TextColor3 = Theme.Colors.Text
	rarityLabel.TextSize = 16
	rarityLabel.Parent = container

	local api = {}
	api.Instance = container

	function api.SetSignal(factor)
		local targetSize = UDim2.new(math.clamp(factor, 0, 1), 0, 1, 0)
		TweenService:Create(fill, TweenInfo.new(0.1), {Size = targetSize}):Play()
		fill.BackgroundColor3 = Theme.Colors.Info:Lerp(Theme.Colors.Red, factor)
	end

	function api.SetRarity(rarity)
		rarityLabel.Text = string.upper(rarity)
		rarityLabel.TextColor3 = Theme.RarityColors[rarity] or Theme.Colors.Text
	end

	return api
end

return DetectorWidget
