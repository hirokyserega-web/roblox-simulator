-- Candy 3D Button Component
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Theme = require(script.Parent.Parent.theme.Theme)

local ButtonFactory = {}

local function playSound(id)
	if not id or id == "" then return end
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = 0.5
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Connect(function() sound:Destroy() end)
end

function ButtonFactory.create(options)
	local text = options.Text or "BUTTON"
	local baseColor = options.Color or Theme.Colors.Purple
	local size = options.Size or UDim2.new(0, 160, 0, 50)
	local position = options.Position or UDim2.new(0, 0, 0, 0)
	local parent = options.Parent
	local enabled = true

	local container = Instance.new("Frame")
	container.Name = "CandyButton_" .. text
	container.Size = size
	container.Position = position
	container.BackgroundTransparency = 1
	container.Parent = parent

	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 0, 1, 0)
	shadow.Position = UDim2.new(0, 0, 0, Theme.Sizes.ButtonDepth)
	shadow.BackgroundColor3 = Theme.Colors.Stroke
	shadow.Parent = container
	Instance.new("UICorner", shadow).CornerRadius = Theme.Sizes.CornerButton

	local face = Instance.new("TextButton")
	face.Name = "ButtonTop" -- Alias for ShopWindow compatibility
	face.Size = UDim2.new(1, 0, 1, 0)
	face.BackgroundColor3 = baseColor
	face.AutoButtonColor = false
	face.Text = text
	face.Font = Theme.Fonts.Bold
	face.TextSize = 18
	face.TextColor3 = Theme.Colors.Text
	face.Parent = container
	Instance.new("UICorner", face).CornerRadius = Theme.Sizes.CornerButton
	
	local stroke = Instance.new("UIStroke", face)
	stroke.Color = Theme.Colors.Stroke
	stroke.Thickness = Theme.Sizes.StrokeThickness
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local gradient = Instance.new("UIGradient", face)
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
	})
	gradient.Rotation = 90

	local api = {}
	api.Instance = face

	function api.SetEnabled(value)
		enabled = value
		face.Active = value
		face.BackgroundColor3 = value and baseColor or Color3.fromRGB(150, 150, 150)
		shadow.Visible = value
	end

	function api.Destroy()
		container:Destroy()
	end

	face.MouseButton1Down:Connect(function()
		if not enabled then return end
		face.Position = UDim2.new(0, 0, 0, Theme.Sizes.ButtonDepth / 2)
		playSound(Theme.Sounds.Click)
	end)

	face.MouseButton1Up:Connect(function()
		face.Position = UDim2.new(0, 0, 0, 0)
	end)

	face.MouseButton1Click:Connect(function()
		if not enabled then return end
		if options.OnClick then options.OnClick() end
	end)

	return api
end

return ButtonFactory
