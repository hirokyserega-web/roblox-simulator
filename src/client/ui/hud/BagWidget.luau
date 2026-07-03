-- Candy Bag Widget
local Theme = require(script.Parent.Parent.theme.Theme)
local ProgressBar = require(script.Parent.Parent.components.ProgressBar)

local BagWidget = {}

function BagWidget.create(options)
	local parent = options.Parent

	local container = Instance.new("Frame")
	container.Name = "BagWidget"
	container.Size = UDim2.new(0, 160, 0, 75)
	container.Position = options.Position or UDim2.new(1, -180, 0.4, -90)
	container.BackgroundColor3 = Theme.Colors.Panel
	container.BackgroundTransparency = 0.2
	container.BorderSizePixel = 0
	container.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Sizes.CornerPanel
	corner.Parent = container

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = Theme.Sizes.StrokeThickness
	stroke.Color = Theme.Colors.Stroke
	stroke.Parent = container

	-- Bag Icon
	local bagIcon = Instance.new("TextLabel")
	bagIcon.Size = UDim2.new(0, 40, 0, 40)
	bagIcon.Position = UDim2.new(0, 10, 0, 8)
	bagIcon.BackgroundTransparency = 1
	bagIcon.Font = Theme.Fonts.Title
	bagIcon.TextSize = 24
	bagIcon.Text = "🎒"
	bagIcon.Parent = container

	-- Capacity Text
	local countLabel = Instance.new("TextLabel")
	countLabel.Size = UDim2.new(1, -60, 0, 30)
	countLabel.Position = UDim2.new(0, 55, 0, 12)
	countLabel.BackgroundTransparency = 1
	countLabel.Font = Theme.Fonts.Main
	countLabel.TextSize = 18
	countLabel.TextColor3 = Theme.Colors.Text
	countLabel.Text = "0 / 10"
	countLabel.Parent = container
	
	local ts = Instance.new("UIStroke")
	ts.Color = Theme.Colors.Stroke
	ts.Thickness = 1
	ts.Parent = countLabel

	-- Progress Bar
	local progress = ProgressBar.create({
		Size = UDim2.new(1, -20, 0, 14),
		Position = UDim2.new(0, 10, 1, -22),
		Color = Theme.Colors.Green,
		Parent = container
	})

	local api = {}
	api.Instance = container

	function api.Update(count, maxCapacity)
		countLabel.Text = string.format("%d / %d", count, maxCapacity)
		progress.SetProgress(count / maxCapacity)

		if count >= maxCapacity then
			countLabel.TextColor3 = Theme.Colors.Red
			bagIcon.Text = "🚨"
		else
			countLabel.TextColor3 = Theme.Colors.Text
			bagIcon.Text = "🎒"
		end
	end

	return api
end

return BagWidget
