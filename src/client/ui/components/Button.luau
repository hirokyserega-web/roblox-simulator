-- Candy 3D Animated Button Component (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)

local function playSound(id)
	if not id or id == "" then return end
	pcall(function()
		local sound = Instance.new("Sound")
		sound.SoundId = id
		sound.Volume = 0.5
		sound.Parent = SoundService
		sound:Play()
		sound.Ended:Connect(function() sound:Destroy() end)
	end)
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
	local scaleRef = React.useRef(nil)
	
	local buttonDepth = Theme.Sizes.ButtonDepth or 4
	local clickDepth = buttonDepth / 2

	local facePosition = isPressed and UDim2.new(0, 0, 0, clickDepth) or UDim2.new(0, 0, 0, 0)
	local faceColor = enabled and baseColor or Color3.fromRGB(150, 150, 150)

	-- Handle scale animations with TweenService
	local function playScaleTween(targetScale)
		local scaleObj = scaleRef.current
		if not scaleObj then return end
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local tween = TweenService:Create(scaleObj, tweenInfo, { Scale = targetScale })
		tween:Play()
	end

	return React.createElement("Frame", {
		Name = "CandyButton_" .. text,
		Size = size,
		Position = position,
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
	}, {
		-- Add UIScale for dynamic scale animations
		Scale = React.createElement("UIScale", {
			ref = scaleRef,
			Scale = 1.0,
		}),

		Shadow = enabled and React.createElement("Frame", {
			Name = "Shadow",
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, buttonDepth),
			BackgroundColor3 = Theme.Colors.Stroke,
			BorderSizePixel = 0,
			ZIndex = 1,
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
			ZIndex = 2,

			[React.Event.MouseEnter] = function()
				if not enabled then return end
				playScaleTween(1.08) -- scale up on hover
			end,

			[React.Event.MouseLeave] = function()
				setPressed(false)
				playScaleTween(1.0) -- restore base scale
			end,

			[React.Event.MouseButton1Down] = function()
				if not enabled then return end
				setPressed(true)
				playScaleTween(0.92) -- squish down on press
				playSound(Theme.Sounds and Theme.Sounds.Click)
			end,

			[React.Event.MouseButton1Up] = function()
				setPressed(false)
				playScaleTween(1.08) -- restore hover scale
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
