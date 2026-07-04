-- Candy Detector Widget - SIGNAL: STRONG Panel (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)

local function DetectorWidget(props)
	local position = props.Position or UDim2.new(0, 20, 0, 75)
	local dotRef = React.useRef(nil)

	-- Pulse animation for the neon green status dot
	React.useEffect(function()
		local dot = dotRef.current
		if not dot then return end

		local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local tween = TweenService:Create(dot, tweenInfo, {
			ImageTransparency = 0.1,
			Size = UDim2.new(0, 24, 0, 24),
			Position = UDim2.new(0, 8, 0.5, -12)
		})
		tween:Play()

		return function()
			tween:Cancel()
		end
	end, {})

	return React.createElement("Frame", {
		Name = "SignalPanel",
		Size = UDim2.new(0, 220, 0, 44),
		Position = position,
		BackgroundColor3 = Color3.fromHex("12142B"),
		BorderSizePixel = 0,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = Theme.Sizes.CornerRadius,
		}),
		-- Glowing Green Neon Stroke
		Stroke = React.createElement("UIStroke", {
			Color = Color3.fromHex("39FF14"), -- Neon green
			Thickness = 3,
		}),

		-- Pulsing Green Status Dot
		StatusDot = React.createElement("ImageLabel", {
			Name = "StatusDot",
			ref = dotRef,
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(0, 12, 0.5, -8),
			BackgroundTransparency = 1,
			Image = "rbxassetid://13589886483", -- Pulsing radial glow image
			ImageColor3 = Color3.fromHex("39FF14"),
			ZIndex = 2,
		}),

		-- Text Panel
		TextLabel = React.createElement("TextLabel", {
			Name = "TextLabel",
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.new(0, 36, 0, 0),
			BackgroundTransparency = 1,
			Text = "SIGNAL: STRONG",
			Font = Theme.Fonts.Main,
			TextColor3 = Color3.fromHex("39FF14"),
			TextSize = 18,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 2,
		}, {
			Shadow = React.createElement("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 2,
			})
		}),

		-- Glossy Top Overlay
		Gloss = React.createElement("Frame", {
			Name = "Gloss",
			Size = UDim2.new(1, 0, 0.5, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 0.9,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			ZIndex = 3,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerRadius,
			})
		})
	})
end

return DetectorWidget
