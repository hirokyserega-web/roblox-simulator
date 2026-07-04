local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local function CaptureBar(props)
	local visible = props.Visible
	local progress = props.Progress or 0
	local ghostName = props.GhostName or "GHOST"
	if not visible then return nil end
	return React.createElement("Frame", {
		Name = "CaptureOverlay",
		Size = UDim2.new(0, 320, 0, 70),
		Position = UDim2.new(0.5, 0, 0.82, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("0F1125"),
		BorderSizePixel = 0,
		ZIndex = 500,
	}, {
		Corner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 8) }),
		Stroke = React.createElement("UIStroke", { Color = Color3.fromHex("39FF14"), Thickness = 2 }),
		Title = React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 0, 8),
			BackgroundTransparency = 1,
			Text = "CAPTURING: " .. ghostName,
			Font = Theme.Fonts.Main,
			TextColor3 = Theme.Colors.Text,
			TextSize = 14,
			ZIndex = 501,
		}),
		Container = React.createElement("Frame", {
			Size = UDim2.new(0.9, 0, 0, 18),
			Position = UDim2.new(0.5, 0, 0.7, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 30),
			BorderSizePixel = 0,
			ZIndex = 501,
		}, {
			Corner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 4) }),
			Fill = React.createElement("Frame", {
				Size = UDim2.new(progress, 0, 1, 0),
				BackgroundColor3 = Color3.fromHex("39FF14"),
				BorderSizePixel = 0,
				ZIndex = 502,
			}, {
				Corner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 4) }),
			}),
			Text = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = math.floor(progress * 100) .. "%",
				Font = Theme.Fonts.Main,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 12,
				ZIndex = 503,
			}, {
				Stroke = React.createElement("UIStroke", { Thickness = 1.5 })
			})
		})
	})
end
return CaptureBar
