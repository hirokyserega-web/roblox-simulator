-- Candy Progress Bar Component
local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Parent.theme.Theme)

local ProgressFactory = {}

function ProgressFactory.create(options)
	local color = options.Color or options.FillColor or Theme.Colors.Blue
	local size = options.Size or UDim2.new(1, 0, 0, 24)
	local position = options.Position or UDim2.new(0, 0, 0, 0)
	local parent = options.Parent

	local container = Instance.new("Frame")
	container.Name = "ProgressBar"
	container.Size = size
	container.Position = position
	container.BackgroundColor3 = Theme.Colors.Background
	container.BorderSizePixel = 0
	container.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Sizes.CornerButton
	corner.Parent = container

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Color = Theme.Colors.Stroke
	stroke.Parent = container

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = color
	fill.BorderSizePixel = 0
	fill.Parent = container

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = Theme.Sizes.CornerButton
	fillCorner.Parent = fill

	local api = {}
	api.Instance = container

	function api.SetProgress(value)
		value = math.clamp(value, 0, 1)
		TweenService:Create(fill, TweenInfo.new(0.3), {
			Size = UDim2.new(value, 0, 1, 0)
		}):Play()
	end

	function api.SetColor(newColor)
		fill.BackgroundColor3 = newColor
	end

	return api
end

return ProgressFactory
