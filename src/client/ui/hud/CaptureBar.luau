-- Candy Capture Bar Overlay
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Theme = require(script.Parent.Parent.theme.Theme)
local ProgressBar = require(script.Parent.Parent.components.ProgressBar)

local CaptureBar = {}

function CaptureBar.create(options)
	local parent = options.Parent

	local container = Instance.new("Frame")
	container.Name = "CaptureOverlayFrame"
	container.Size = UDim2.new(0, 320, 0, 60)
	container.Position = UDim2.new(0.5, -160, 1, -150)
	container.BackgroundColor3 = Theme.Colors.Panel
	container.BackgroundTransparency = 0.2
	container.BorderSizePixel = 0
	container.Visible = false
	container.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Sizes.CornerPanel
	corner.Parent = container

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = Theme.Sizes.StrokeThickness
	stroke.Color = Theme.Colors.Stroke
	stroke.Parent = container

	-- Ghost Icon
	local ghostIcon = Instance.new("TextLabel")
	ghostIcon.Size = UDim2.new(0, 40, 0, 40)
	ghostIcon.Position = UDim2.new(0, 10, 0.5, -20)
	ghostIcon.BackgroundTransparency = 1
	ghostIcon.Font = Theme.Fonts.Title
	ghostIcon.TextSize = 24
	ghostIcon.Text = "👻"
	ghostIcon.Parent = container

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -60, 0, 20)
	title.Position = UDim2.new(0, 50, 0, 6)
	title.BackgroundTransparency = 1
	title.Font = Theme.Fonts.Main
	title.TextSize = 14
	title.TextColor3 = Theme.Colors.Text
	title.Text = "HOLD MOUSE BUTTON!"
	title.Parent = container
	
	local ts = Instance.new("UIStroke")
	ts.Color = Theme.Colors.Stroke
	ts.Thickness = 0.8
	ts.Parent = title

	-- Progress Bar
	local pBar = ProgressBar.create({
		Size = UDim2.new(1, -60, 0, 16),
		Position = UDim2.new(0, 50, 1, -26),
		Color = Theme.Colors.Green,
		Parent = container
	})

	local api = {}
	api.Instance = container

	function api.Show(ghostInfo)
		local rarity = ghostInfo.Rarity or "Common"
		local rColor = Theme.RarityColors[rarity] or Theme.Colors.Green

		pBar.SetColor(rColor)
		pBar.SetProgress(0)
		container.Visible = true
	end

	function api.SetProgress(value)
		pBar.SetProgress(value)
	end

	function api.Shake()
		-- Shake logic implementation
	end

	function api.Hide()
		container.Visible = false
	end

	return api
end

return CaptureBar
