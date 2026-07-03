-- Candy Capture Bar Overlay
local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Parent.theme.Theme)
local ProgressBar = require(script.Parent.Parent.components.ProgressBar)

local CaptureBar = {}

function CaptureBar.create(options)
	local parent = options.Parent

	local container = Instance.new("Frame")
	container.Name = "CaptureOverlay"
	container.Size = UDim2.new(0, 350, 0, 100)
	container.Position = UDim2.new(0.5, 0, 0.2, 0)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.BackgroundTransparency = 1
	container.Visible = false
	container.Parent = parent

	local panel = Instance.new("Frame")
	panel.Name = "Main"
	panel.Size = UDim2.new(1, 0, 1, 0)
	panel.BackgroundColor3 = Theme.Colors.Panel
	panel.Parent = container
	
	Instance.new("UICorner", panel).CornerRadius = Theme.Sizes.CornerRadius
	local stroke = Instance.new("UIStroke", panel)
	stroke.Color = Theme.Colors.Stroke
	stroke.Thickness = 3

	local ghostName = Instance.new("TextLabel")
	ghostName.Name = "GhostName"
	ghostName.Size = UDim2.new(1, 0, 0, 40)
	ghostName.BackgroundTransparency = 1
	ghostName.Text = "GHOST"
	ghostName.Font = Theme.Fonts.Title
	ghostName.TextColor3 = Theme.Colors.Text
	ghostName.TextSize = 24
	ghostName.Parent = panel

	local bar = ProgressBar.create({
		Parent = panel,
		Size = UDim2.new(1, -40, 0, 30),
		Position = UDim2.new(0.5, 0, 1, -35),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Color = Theme.Colors.Info
	})

	local api = {}
	api.Instance = container

	function api.Show(ghostInfo)
		ghostName.Text = string.upper(ghostInfo.Name or "GHOST")
		ghostName.TextColor3 = Theme.RarityColors[ghostInfo.Rarity] or Theme.Colors.Text
		bar.SetProgress(0)
		container.Visible = true
		container.GroupTransparency = 1
		TweenService:Create(container, TweenInfo.new(0.3), {GroupTransparency = 0}):Play()
	end

	function api.SetProgress(v)
		bar.SetProgress(v)
	end

	function api.Hide()
		local t = TweenService:Create(container, TweenInfo.new(0.2), {GroupTransparency = 1})
		t:Play()
		t.Completed:Connect(function() container.Visible = false end)
	end

	function api.Shake()
		local origPos = container.Position
		for i = 1, 4 do
			container.Position = origPos + UDim2.new(0, math.random(-5, 5), 0, math.random(-5, 5))
			task.wait(0.05)
		end
		container.Position = origPos
	end

	return api
end

return CaptureBar
