-- Candy Detector Widget (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)

local function DetectorWidget(props)
	local position = props.Position or UDim2.new(0, 20, 0.5, -241)
	local signal = math.clamp(props.Signal or 0, 0, 1)
	local rarity = props.Rarity or "NONE"

	local fillRef = React.useRef(nil)

	React.useEffect(function()
		if fillRef.current then
			local targetSize = UDim2.new(signal, 0, 1, 0)
			local targetColor = Theme.Colors.Info:Lerp(Theme.Colors.Error or Theme.Colors.Red, signal)
			
			TweenService:Create(fillRef.current, TweenInfo.new(0.1), {
				Size = targetSize,
				BackgroundColor3 = targetColor
			}):Play()
		end
	end, {signal})

	return React.createElement("Frame", {
		Name = "DetectorWidget",
		Size = UDim2.new(0, 160, 0, 80),
		Position = position,
		BackgroundColor3 = Theme.Colors.Panel,
		BackgroundTransparency = 1 - (Theme.Colors.PanelOpacity or 0.8),
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = Theme.Sizes.CornerRadius,
		}),
		Stroke = React.createElement("UIStroke", {
			Color = Theme.Colors.Stroke,
			Thickness = 2,
		}),

		Title = React.createElement("TextLabel", {
			Name = "Label",
			Size = UDim2.new(1, 0, 0, 25),
			BackgroundTransparency = 1,
			Text = "SIGNAL STRENGTH",
			Font = Theme.Fonts.Bold,
			TextColor3 = Theme.Colors.TextSecondary,
			TextSize = 12,
		}),

		Meter = React.createElement("Frame", {
			Name = "Meter",
			Size = UDim2.new(1, -20, 0, 12),
			Position = UDim2.new(0.5, 0, 0, 40),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Theme.Colors.Background,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			Fill = React.createElement("Frame", {
				Name = "Fill",
				ref = fillRef,
				Size = UDim2.new(signal, 0, 1, 0),
				BackgroundColor3 = Theme.Colors.Info,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(1, 0),
				})
			})
		}),

		RarityLabel = React.createElement("TextLabel", {
			Name = "RarityLabel",
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 1, -25),
			BackgroundTransparency = 1,
			Text = string.upper(rarity),
			Font = Theme.Fonts.Main,
			TextColor3 = Theme.RarityColors[rarity] or Theme.Colors.Text,
			TextSize = 16,
		})
	})
end

return DetectorWidget

