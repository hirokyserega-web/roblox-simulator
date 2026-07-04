-- Candy Spook Panel (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)

local function SpookWidget(props)
	local position = props.Position or UDim2.new(1, -190, 0, 150)
	local count = props.Count or 3

	local slots = {
		ListLayout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 10),
		})
	}

	-- Add slots (replicating Spook x3 with cute ghost slots)
	for i = 1, 3 do
		slots["Slot" .. i] = React.createElement("Frame", {
			Size = UDim2.new(0, 42, 0, 42),
			BackgroundColor3 = Color3.fromHex("12142B"),
			BorderSizePixel = 0,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerButton,
			}),
			Stroke = React.createElement("UIStroke", {
				Color = if i <= count then Color3.fromHex("00B0FF") else Theme.Colors.Stroke,
				Thickness = 2.5,
			}),
			-- Ghost Sprite Emoji Label
			GhostIcon = i <= count and React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "👻",
				TextSize = 22,
				Font = Theme.Fonts.Main,
				TextColor3 = Theme.Colors.Text,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
			}) or nil
		})
	end

	return React.createElement("Frame", {
		Name = "SpookPanel",
		Size = UDim2.new(0, 170, 0, 110),
		Position = position,
		BackgroundColor3 = Theme.Colors.BackgroundSecondary,
		BorderSizePixel = 0,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = Theme.Sizes.CornerRadius,
		}),
		Stroke = React.createElement("UIStroke", {
			Color = Theme.Colors.Stroke,
			Thickness = 3,
		}),

		-- Title Label
		Title = React.createElement("TextLabel", {
			Name = "Title",
			Size = UDim2.new(1, -20, 0, 25),
			Position = UDim2.new(0, 10, 0, 10),
			BackgroundTransparency = 1,
			Text = string.format("Spook (x%d)", count),
			Font = Theme.Fonts.Main,
			TextColor3 = Theme.Colors.Text,
			TextSize = 18,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, {
			Shadow = React.createElement("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 1.5,
			})
		}),

		-- Grid Container holding the slots
		Grid = React.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 50),
			Position = UDim2.new(0, 10, 0, 42),
			BackgroundTransparency = 1,
		}, slots)
	})
end

return SpookWidget
