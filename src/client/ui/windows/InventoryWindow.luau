-- InventoryWindow (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local ItemCard = require(script.Parent.Parent.components.ItemCard)
local GhostConfig = require(ReplicatedStorage.Shared.config.GhostConfig)

local function InventoryWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose
	local ghosts = props.Ghosts or {}

	local cards = {
		UIGridLayout = React.createElement("UIGridLayout", {
			CellSize = UDim2.new(0, 95, 0, 110),
			CellPadding = UDim2.new(0, 8, 0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
	}

	for i, rarityId in ipairs(ghosts) do
		local conf = GhostConfig[rarityId]
		if conf then
			cards["Ghost_" .. i] = React.createElement(ItemCard, {
				Title = conf.Name,
				Rarity = rarityId,
				Subtext = "$" .. tostring(conf.BasePrice),
				IconColor = conf.Color,
				Equipped = false,
				LayoutOrder = i,
			})
		end
	end

	return React.createElement(Panel, {
		Title = "INVENTORY",
		Visible = visible,
		OnClose = onClose,
		Size = UDim2.new(0, 440, 0, 360),
	}, {
		Scroll = React.createElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, math.ceil(#ghosts / 4) * 118),
		}, cards)
	})
end

return InventoryWindow


