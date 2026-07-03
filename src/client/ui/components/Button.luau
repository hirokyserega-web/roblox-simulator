-- Candy 3D Button Component
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local Theme = require(script.Parent.Parent.theme.Theme)

local ButtonFactory = {}

function ButtonFactory.create(options)
	local text = options.Text or "BUTTON"
	local baseColor = options.Color or Theme.Colors.Purple
	local size = options.Size or UDim2.new(0, 160, 0, 50)
	local position = options.Position or UDim2.new(0, 0, 0, 0)
	local parent = options.Parent
	local onClick = options.OnClick
	local anchorPoint = options.AnchorPoint or Vector2.new(0, 0)
	local cornerRadius = options.CornerRadius or Theme.Sizes.CornerButton
	local textSize = options.TextSize or 24

	-- Main Container (Holds Shadow + Top)
	local container = Instance.new("Frame")
	container.Name = "CandyButton_" .. text
	container.BackgroundTransparency = 1
	container.Size = size
	container.Position = position
	container.AnchorPoint = anchorPoint
	container.Parent = parent

	-- 1) Shadow (Bottom layer)
	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 0, 1, 0)
	shadow.Position = UDim2.new(0, 0, 0, Theme.Sizes.ButtonDepth)
	shadow.BackgroundColor3 = baseColor:Lerp(Color3.new(0, 0, 0), 0.45)
	shadow.BorderSizePixel = 0
	shadow.ZIndex = 1
	shadow.Parent = container
	
	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = cornerRadius
	shadowCorner.Parent = shadow

	-- 2) Top Button (Face)
	local btn = Instance.new("TextButton")
	btn.Name = "Face"
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.Position = UDim2.new(0, 0, 0, 0)
	btn.BackgroundColor3 = baseColor
	btn.AutoButtonColor = false
	btn.Text = text
	btn.Font = Theme.Fonts.Main
	btn.TextSize = textSize
	btn.TextColor3 = Theme.Colors.Text
	btn.ZIndex = 2
	btn.Parent = container
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = cornerRadius
	btnCorner.Parent = btn

	-- Gradient Shine
	local grad = Instance.new("UIGradient")
	grad.Rotation = 90
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, baseColor:Lerp(Color3.new(1, 1, 1), 0.25)),
		ColorSequenceKeypoint.new(1, baseColor),
	})
	grad.Parent = btn

	-- Border Stroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = baseColor:Lerp(Color3.new(0, 0, 0), 0.55)
	stroke.Thickness = Theme.Sizes.StrokeThickness
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = btn

	-- Text Stroke
	local ts = Instance.new("UIStroke")
	ts.Color = Theme.Colors.Stroke
	ts.Thickness = Theme.Sizes.TextStrokeThickness
	ts.Parent = btn

	-- Padding
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 10)
	pad.Parent = btn

	-- Scale Effect
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = container

	local enabled = true

	btn.MouseEnter:Connect(function()
		if not enabled then return end
		TweenService:Create(uiScale, TweenInfo.new(0.15), {Scale = 1.05}):Play()
	end)

	btn.MouseLeave:Connect(function()
		if not enabled then return end
		TweenService:Create(uiScale, TweenInfo.new(0.15), {Scale = 1.0}):Play()
		TweenService:Create(btn, TweenInfo.new(0.1), {Position = UDim2.new(0, 0, 0, 0)}):Play()
	end)

	btn.MouseButton1Down:Connect(function()
		if not enabled then return end
		TweenService:Create(btn, TweenInfo.new(0.05), {Position = UDim2.new(0, 0, 0, Theme.Sizes.ButtonDepth)}):Play()
	end)

	btn.MouseButton1Up:Connect(function()
		if not enabled then return end
		TweenService:Create(btn, TweenInfo.new(0.1), {Position = UDim2.new(0, 0, 0, 0)}):Play()
		if onClick then onClick() end
	end)

	local api = {}
	api.Instance = container
	api.Button = btn

	function api.SetEnabled(state)
		enabled = state
		btn.BackgroundColor3 = state and baseColor or Color3.fromRGB(150, 150, 150)
		shadow.Visible = state
	end

	return api
end

return ButtonFactory
