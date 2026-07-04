-- Candy Egg/Pet Window (React version)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local function EggWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose

	if not visible then return nil end

	local eggs = {
		{ Id = "CommonEgg", Name = "Common Spook Egg 🥚", Cost = 500, Icon = "🥚" },
		{ Id = "GoldenEgg", Name = "Premium Gold Egg 🏆", Cost = 5000, Icon = "🥚" },
	}

	local gridChildren = {
		GridLayout = React.createElement("UIGridLayout", {
			CellSize = UDim2.new(0, 195, 0, 140),
			CellPadding = UDim2.new(0, 16, 0, 16),
			FillDirectionMaxCells = 2,
			StartCorner = Enum.StartCorner.TopLeft,
		})
	}

	for _, egg in ipairs(eggs) do
		local isGolden = egg.Id == "GoldenEgg"
		local strokeColor = isGolden and Color3.fromRGB(255, 179, 0) or Theme.Colors.Stroke

		gridChildren[egg.Id] = React.createElement("Frame", {
			Size = UDim2.new(0, 195, 0, 140),
			BackgroundColor3 = Color3.fromHex("12142B"),
			BorderSizePixel = 0,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerButton,
			}),
			Stroke = React.createElement("UIStroke", {
				Color = strokeColor,
				Thickness = 2.5,
			}),

			-- Title
			Title = React.createElement("TextLabel", {
				Size = UDim2.new(1, -20, 0, 24),
				Position = UDim2.new(0, 10, 0, 10),
				BackgroundTransparency = 1,
				Text = egg.Name,
				Font = Theme.Fonts.Main,
				TextColor3 = Theme.Colors.Text,
				TextSize = 14,
			}, {
				Shadow = React.createElement("UIStroke", {
					Color = Color3.fromRGB(0, 0, 0),
					Thickness = 1.2,
				})
			}),

			-- Large Egg Icon
			EggIcon = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 50),
				Position = UDim2.new(0, 0, 0, 32),
				BackgroundTransparency = 1,
				Text = "🥚",
				TextSize = 36,
				Font = Theme.Fonts.Main,
				TextColor3 = isGolden and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 255, 255),
			}),

			-- Cost Label
			CostText = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.new(0, 0, 1, -62),
				BackgroundTransparency = 1,
				Text = string.format("Cost: $%d", egg.Cost),
				Font = Theme.Fonts.Main,
				TextColor3 = Theme.Colors.TextSecondary,
				TextSize = 12,
			}),

			-- Action Buy Button inside card
			ActionButton = React.createElement("Frame", {
				Size = UDim2.new(1, -30, 0, 32),
				Position = UDim2.new(0, 15, 1, -38),
				BackgroundTransparency = 1,
			}, {
				Btn = React.createElement(Button, {
					Text = "HATCH EGG",
					Color = Theme.Colors.Success,
					Size = UDim2.new(1, 0, 1, 0),
					OnClick = function()
						Remotes.getEvent("HatchEggRequest"):FireServer(egg.Id)
						if onClose then onClose() end
					end
				})
			})
		})
	end

	return React.createElement(Panel, {
		Title = "PETS & EGGS SHOP",
		Size = UDim2.new(0, 480, 0, 360),
		OnClose = onClose,
	}, {
		-- Scrolling egg grid
		Scroll = React.createElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			CanvasSize = UDim2.new(0, 0, 0, 200),
			ScrollBarThickness = 6,
			ScrollBarImageColor3 = Theme.Colors.Stroke,
		}, gridChildren)
	})
end

return EggWindow
