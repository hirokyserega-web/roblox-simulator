-- Candy Inventory Window (React version)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local function InventoryWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose

	-- Mock ghost inventories representing current mockup setup (Spook x3)
	local ghosts = {
		{ Id = "G1", Name = "Green Spook", Rarity = "Uncommon", Icon = "👻" },
		{ Id = "G2", Name = "White Spook", Rarity = "Common", Icon = "👻" },
		{ Id = "G3", Name = "Blue Spook", Rarity = "Rare", Icon = "👻" },
	}

	if not visible then return nil end

	local function requestSell()
		Remotes.getEvent("SellGhosts"):FireServer()
		if onClose then onClose() end
	end

	local gridChildren = {
		GridLayout = React.createElement("UIGridLayout", {
			CellSize = UDim2.new(0, 95, 0, 110),
			CellPadding = UDim2.new(0, 12, 0, 12),
			FillDirectionMaxCells = 4,
			StartCorner = Enum.StartCorner.TopLeft,
		})
	}

	for _, g in ipairs(ghosts) do
		local rarityColor = Theme.RarityColors[g.Rarity] or Theme.Colors.Text

		gridChildren[g.Id] = React.createElement("Frame", {
			Size = UDim2.new(0, 95, 0, 110),
			BackgroundColor3 = Color3.fromHex("12142B"),
			BorderSizePixel = 0,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerButton,
			}),
			Stroke = React.createElement("UIStroke", {
				Color = Theme.Colors.Stroke,
				Thickness = 2,
			}),

			-- Title details
			Label = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 24),
				Position = UDim2.new(0, 0, 0, 4),
				BackgroundTransparency = 1,
				Text = g.Name,
				Font = Theme.Fonts.Main,
				TextColor3 = rarityColor,
				TextSize = 12,
			}),

			-- Ghost Sprite Emoji
			Emoji = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 44),
				Position = UDim2.new(0, 0, 0, 26),
				BackgroundTransparency = 1,
				Text = g.Icon,
				TextSize = 28,
				Font = Theme.Fonts.Main,
			}),

			-- Rarity label below
			RarityText = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.new(0, 0, 1, -22),
				BackgroundTransparency = 1,
				Text = g.Rarity:upper(),
				Font = Theme.Fonts.Main,
				TextColor3 = Theme.Colors.TextSecondary,
				TextSize = 9,
			})
		})
	end

	return React.createElement(Panel, {
		Title = "GHOST INVENTORY",
		Size = UDim2.new(0, 480, 0, 360),
		OnClose = onClose,
	}, {
		-- Scrolling grid container holding the list of ghosts
		GridScroll = React.createElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 0.72, 0),
			BackgroundTransparency = 1,
			CanvasSize = UDim2.new(0, 0, 0, 240),
			ScrollBarThickness = 6,
			ScrollBarImageColor3 = Theme.Colors.Stroke,
		}, gridChildren),

		-- Sell Button Row
		SellBtnRow = React.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 52),
			Position = UDim2.new(0, 10, 1, -62),
			BackgroundTransparency = 1,
		}, {
			Button = React.createElement(Button, {
				Text = "💰 SELL ALL CAPTURED GHOSTS",
				Color = Theme.Colors.Success,
				Size = UDim2.new(1, 0, 1, 0),
				OnClick = requestSell,
			})
		})
	})
end

return InventoryWindow
