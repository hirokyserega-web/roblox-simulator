-- Candy 3D Button Component (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)

local function playSound(id)
	if not id or id == "" then return end
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = 0.5
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Connect(function() sound:Destroy() end)
end

local function Button(props)
	local text = props.Text or "BUTTON"
	local baseColor = props.Color or Theme.Colors.Accent
	local size = props.Size or UDim2.new(0, 160, 0, 50)
	local position = props.Position or UDim2.new(0, 0, 0, 0)
	local enabled = props.Enabled ~= false
	local textScale = props.TextScale ~= false
	local textSize = props.TextSize or 18
	local layoutOrder = props.LayoutOrder

	local isPressed, setPressed = React.useState(false)
	
	local buttonDepth = Theme.Sizes.ButtonDepth or 4
	local clickDepth = buttonDepth / 2

	local facePosition = isPressed and UDim2.new(0, 0, 0, clickDepth) or UDim2.new(0, 0, 0, 0)
	local faceColor = enabled and baseColor or Color3.fromRGB(150, 150, 150)

	return React.createElement("Frame", {
		Name = "CandyButton_" .. text,
		Size = size,
		Position = position,
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
	}, {
		Shadow = enabled and React.createElement("Frame", {
			Name = "Shadow",
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, buttonDepth),
			BackgroundColor3 = Theme.Colors.Stroke,
			BorderSizePixel = 0,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerButton,
			})
		}) or nil,

		Face = React.createElement("TextButton", {
			Name = "ButtonTop",
			Size = UDim2.new(1, 0, 1, 0),
			Position = facePosition,
			BackgroundColor3 = faceColor,
			AutoButtonColor = false,
			Text = text,
			Font = Theme.Fonts.Title,
			TextSize = textSize,
			TextScaled = textScale,
			TextColor3 = Theme.Colors.Text,
			BorderSizePixel = 0,

			[React.Event.MouseButton1Down] = function()
				if not enabled then return end
				setPressed(true)
				playSound(Theme.Sounds.Click)
			end,

			[React.Event.MouseButton1Up] = function()
				setPressed(false)
			end,

			[React.Event.MouseLeave] = function()
				setPressed(false)
			end,

			[React.Event.Activated] = function()
				if not enabled then return end
				if props.OnClick then props.OnClick() end
			end,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerButton,
			}),
			Stroke = React.createElement("UIStroke", {
				Color = Theme.Colors.Stroke,
				Thickness = Theme.Sizes.StrokeThickness,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			}),
			Gradient = React.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
				}),
				Rotation = 90,
			})
		})
	})
end

return Button

