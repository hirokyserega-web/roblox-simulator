-- Candy Bag Widget
local Theme = require(script.Parent.Parent.theme.Theme)
local ProgressBar = require(script.Parent.Parent.components.ProgressBar)

local BagWidget = {}

function BagWidget.create(options)
	local parent = options.Parent

	local container = Instance.new("Frame")
	container.Name = "BagWidget"
	container.Size = UDim2.new(0, 160, 0, 75)
	container.Position = options.Position or UDim2.new(1, -170, 0.4, -90)
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
	title.Text = "INVENTORY"
	title.Font = Theme.Fonts.Bold
	title.TextColor3 = Theme.Colors.TextSecondary
	title.TextSize = 12
	title.Parent = container

	local bar = ProgressBar.create({
		Parent = container,
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.new(0.5, 0, 0, 35),
		AnchorPoint = Vector2.new(0.5, 0),
		Color = Theme.Colors.Orange
	})

	local countLabel = Instance.new("TextLabel")
	countLabel.Name = "CountLabel"
	countLabel.Size = UDim2.new(1, 0, 0, 20)
	countLabel.Position = UDim2.new(0, 0, 1, -22)
	countLabel.BackgroundTransparency = 1
	countLabel.Text = "0 / 10"
	countLabel.Font = Theme.Fonts.Main
	countLabel.TextColor3 = Theme.Colors.Text
	countLabel.TextSize = 16
	countLabel.Parent = container

	local api = {}
	api.Instance = container

	function api.Update(count, maxCap)
		countLabel.Text = string.format("%d / %d", count, maxCap)
		bar.SetProgress(count / maxCap)
		if count >= maxCap then
			bar.SetColor(Theme.Colors.Red)
		else
			bar.SetColor(Theme.Colors.Orange)
		end
	end

	return api
end

return BagWidget
