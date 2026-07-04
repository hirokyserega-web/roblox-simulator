-- Candy Capture Progress Bar (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)

local function CaptureBar(props)
	local visible, setVisible = React.useState(false)
	local progress, setProgress = React.useState(0)
	local ghostName, setGhostName = React.useState("Ghost")

	React.useEffect(function()
		-- Export callbacks to global table for controller to call
		_G.SetCaptureProgress = function(newVal)
			setProgress(newVal)
			if newVal > 0 and newVal < 1 then setVisible(true) else setVisible(false) end
		end

		_G.SetCaptureGhostName = function(name)
			setGhostName(name)
		end

		_G.CloseCaptureUI = function()
			setVisible(false)
			setProgress(0)
		end
		
		return function()
			_G.SetCaptureProgress = nil
			_G.SetCaptureGhostName = nil
			_G.CloseCaptureUI = nil
		end
	end, {})

	if not visible then return nil end

	return React.createElement("Frame", {
		Size = UDim2.new(0, 400, 0, 80),
		Position = UDim2.new(0.5, 0, 1, -150),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.5,
		ZIndex = 500,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = Theme.Sizes.CornerRadius,
		}),
		Stroke = React.createElement("UIStroke", {
			Color = Theme.Colors.Info,
			Thickness = 2,
		}),

		GhostLabel = React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, 30),
			Position = UDim2.new(0, 0, 0, 5),
			BackgroundTransparency = 1,
			Text = "CATCHING: " .. string.upper(ghostName),
			TextColor3 = Color3.new(1, 1, 1),
			Font = Theme.Fonts.Bold,
			TextSize = 18,
		}),

		BarContainer = React.createElement("Frame", {
			Size = UDim2.new(0.9, 0, 0, 24),
			Position = UDim2.new(0.5, 0, 0.75, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),
			ProgressFill = React.createElement("Frame", {
				Size = UDim2.new(progress, 0, 1, 0),
				BackgroundColor3 = Theme.Colors.Info,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 12),
				}),
				Gradient = React.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))
					}),
					Rotation = 90,
				})
			})
		})
	})
end

return CaptureBar
