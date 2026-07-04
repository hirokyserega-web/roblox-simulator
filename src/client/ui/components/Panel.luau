local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Button)
local function Panel(props)
	local title = props.Title or "WINDOW"
	local size = props.Size or UDim2.new(0, 440, 0, 340)
	local onClose = props.OnClose
	local children = props[React.Children] or {}
	return React.createElement("Frame", {
		Name = title .. "Panel",
		Size = size,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("12142B"),
		BorderSizePixel = 0,
		ZIndex = 200,
	}, {
		Corner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 10) }),
		Stroke = React.createElement("UIStroke", { Color = Theme.Colors.Stroke, Thickness = 2.5 }),
		Header = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundTransparency = 1,
			ZIndex = 201,
		}, {
			Label = React.createElement("TextLabel", {
				Size = UDim2.new(1, -60, 1, 0),
				Position = UDim2.new(0, 20, 0, 0),
				BackgroundTransparency = 1,
				Text = title:upper(),
				Font = Theme.Fonts.Main,
				TextColor3 = Theme.Colors.Text,
				TextSize = 22,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
			CloseBtn = React.createElement("Frame", {
				Size = UDim2.new(0, 36, 0, 36),
				Position = UDim2.new(1, -12, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 1,
			}, {
				Btn = React.createElement(Button, {
					Text = "X",
					BaseColor = Theme.Colors.Error,
					Size = UDim2.new(1, 0, 1, 0),
					OnClick = onClose,
				})
			})
		}),
		Content = React.createElement("Frame", {
			Size = UDim2.new(1, -30, 1, -75),
			Position = UDim2.new(0.5, 0, 0, 60),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			ZIndex = 201,
		}, children)
	})
end
return Panel
