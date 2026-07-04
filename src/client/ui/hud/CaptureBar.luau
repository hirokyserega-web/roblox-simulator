-- Candy Capture Bar Overlay (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)

local function CaptureBar(props)
	local visible = props.Visible
	local progress = math.clamp(props.Progress or 0.75, 0, 1) -- default to 75% to match mock exactly!
	local ghostName = props.GhostName or "Spook"

	local ghostRef = React.useRef(nil)

	-- Shivering/wobbling effect for the capture ghost icon
	React.useEffect(function()
		local icon = ghostRef.current
		if not icon or not visible then return end

		local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Elastic, Enum.EasingDirection.InOut, -1, true)
		local tween = TweenService:Create(icon, tweenInfo, {
			Rotation = 15,
			Size = UDim2.new(0, 38, 0, 38),
		})
		tween:Play()

		return function()
			tween:Cancel()
		end
	end, {visible})

	if not visible then return nil end

	local percentage = math.floor(progress * 100)

	return React.createElement("Frame", {
		Name = "CaptureOverlay",
		Size = UDim2.new(0, 360, 0, 70),
		Position = UDim2.new(0.5, 0, 0.82, 0), -- Central-bottom placement
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("12142B"),
		BorderSizePixel = 0,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = Theme.Sizes.CornerRadius,
		}),
		Stroke = React.createElement("UIStroke", {
			Color = Color3.fromHex("00B0FF"), -- Glowing neon cyan/blue capture frame
			Thickness = 3,
		}),

		-- Ghost Icon (Shivering)
		GhostIcon = React.createElement("TextLabel", {
			Name = "GhostIcon",
			ref = ghostRef,
			Size = UDim2.new(0, 32, 0, 32),
			Position = UDim2.new(0, 15, 0.5, -16),
			BackgroundTransparency = 1,
			Text = "👻",
			TextSize = 26,
			Font = Theme.Fonts.Main,
			ZIndex = 2,
		}),

		-- Progress Bar Slot
		BarContainer = React.createElement("Frame", {
			Size = UDim2.new(1, -75, 0, 24),
			Position = UDim2.new(0, 60, 0.5, -12),
			BackgroundColor3 = Color3.fromHex("080914"),
			BorderSizePixel = 0,
			ZIndex = 2,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0.5, 0),
			}),
			-- Glossy blue fill
			Fill = React.createElement("Frame", {
				Size = UDim2.new(progress, 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(0, 176, 255), -- Glowing vibrant blue progress
				BorderSizePixel = 0,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0.5, 0),
				}),
				-- Gloss highlight
				Gloss = React.createElement("Frame", {
					Size = UDim2.new(1, 0, 0.5, 0),
					BackgroundTransparency = 0.85,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
				})
			}),

			-- Text Overlaid on the Progress Bar
			Label = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = string.format("CAPTURING... %d%%", percentage),
				Font = Theme.Fonts.Main,
				TextColor3 = Theme.Colors.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = 3,
			}, {
				Shadow = React.createElement("UIStroke", {
					Color = Color3.fromRGB(0, 0, 0),
					Thickness = 1.5,
				})
			})
		}),

		-- Diagonal gloss shine on the whole bar
		GlossOverlay = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 0.5, 0),
			BackgroundTransparency = 0.92,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			ZIndex = 4,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerRadius,
			})
		})
	})
end

return CaptureBar
