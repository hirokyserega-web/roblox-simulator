-- Candy Progress Bar Component (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)

local function ProgressBar(props)
	local size = props.Size or UDim2.new(1, 0, 0, 24)
	local position = props.Position or UDim2.new(0, 0, 0, 0)
	local progress = math.clamp(props.Progress or 0, 0, 1)
	local color = props.Color or props.FillColor or Theme.Colors.Info

	local fillRef = React.useRef(nil)

	React.useEffect(function()
		if fillRef.current then
			TweenService:Create(fillRef.current, TweenInfo.new(0.3), {
				Size = UDim2.new(progress, 0, 1, 0)
			}):Play()
		end
	end, {progress})

	return React.createElement("Frame", {
		Name = "ProgressBar",
		Size = size,
		Position = position,
		AnchorPoint = props.AnchorPoint,
		BackgroundColor3 = Theme.Colors.Background,
		BorderSizePixel = 0,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = Theme.Sizes.CornerButton,
		}),
		Stroke = React.createElement("UIStroke", {
			Thickness = 1,
			Color = Theme.Colors.Stroke,
		}),

		Fill = React.createElement("Frame", {
			Name = "Fill",
			ref = fillRef,
			Size = UDim2.new(progress, 0, 1, 0),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerButton,
			})
		})
	})
end

return ProgressBar

