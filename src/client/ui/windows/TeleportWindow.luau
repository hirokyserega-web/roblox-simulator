-- TeleportWindow (React version)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
local LocationConfig = require(ReplicatedStorage.Shared.config.LocationConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local UIManager = {
	ShowToast = function(...)
		if _G.UIManager then
			_G.UIManager.ShowToast(...)
		end
	end,
	openWindow = function(...)
		if _G.UIManager then
			_G.UIManager.openWindow(...)
		end
	end,
}


local teleportRequest = Remotes.getEvent("TeleportRequest")
local buyZoneRequest = Remotes.getEvent("BuyZoneRequest")

local function formatNumber(value: number): string
	local formatted = tostring(value)
	while true do  
		local k
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

local function TeleportWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose
	local money = props.Money or 0

	local player = Players.LocalPlayer

	local unlocked, setUnlocked = React.useState(function()
		local initial = {}
		for zoneId, _ in pairs(LocationConfig) do
			initial[zoneId] = (zoneId == "StarterArea") or (player:GetAttribute("Unlocked_" .. zoneId) == true)
		end
		return initial
	end)

	React.useEffect(function()
		local connections = {}
		for zoneId, _ in pairs(LocationConfig) do
			if zoneId ~= "StarterArea" then
				local conn = player:GetAttributeChangedSignal("Unlocked_" .. zoneId):Connect(function()
					setUnlocked(function(current)
						local copy = table.clone(current)
						copy[zoneId] = player:GetAttribute("Unlocked_" .. zoneId) == true
						return copy
					end)
				end)
				table.insert(connections, conn)
			end
		end

		return function()
			for _, conn in ipairs(connections) do
				conn:Disconnect()
			end
		end
	end, {})

	if not visible then return nil end

	local sortedZones = {}
	for zoneId, config in pairs(LocationConfig) do
		table.insert(sortedZones, { Id = zoneId, Cost = config.Cost, Name = config.DisplayName })
	end
	table.sort(sortedZones, function(a, b) return a.Cost < b.Cost end)

	local rows = {
		ListLayout = React.createElement("UIListLayout", {
			Padding = UDim.new(0, 10),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		})
	}

	for _, item in ipairs(sortedZones) do
		local zoneId = item.Id
		local isUnlocked = unlocked[zoneId]
		local cost = item.Cost
		local canAfford = money >= cost

		local statusText = isUnlocked and "РАЗБЛОКИРОВАНО" or string.format("Цена: $%s", formatNumber(cost))
		local statusColor = isUnlocked and Theme.Colors.Success or Theme.Colors.Warning

		local actionText = isUnlocked and "ТЕЛЕПОРТ" or "КУПИТЬ"
		local actionColor = isUnlocked and Theme.Colors.Success or (canAfford and Theme.Colors.Accent or Theme.Colors.Error)

		rows["Zone_" .. zoneId] = React.createElement("Frame", {
			Size = UDim2.new(1, -12, 0, 56),
			BackgroundColor3 = Theme.Colors.BackgroundSecondary,
			BorderSizePixel = 0,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerRadius,
			}),
			Stroke = React.createElement("UIStroke", {
				Thickness = 1,
				Color = Theme.Colors.Stroke,
			}),

			NameLabel = React.createElement("TextLabel", {
				Size = UDim2.new(0, 160, 0, 22),
				Position = UDim2.new(0, 12, 0, 6),
				BackgroundTransparency = 1,
				Font = Theme.Fonts.Title,
				TextSize = 13,
				TextColor3 = Theme.Colors.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = item.Name,
			}),

			StatusLabel = React.createElement("TextLabel", {
				Size = UDim2.new(0, 160, 0, 20),
				Position = UDim2.new(0, 12, 1, -24),
				BackgroundTransparency = 1,
				Font = Theme.Fonts.Body,
				TextSize = 11,
				TextColor3 = statusColor,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = statusText,
			}),

			ActionButton = React.createElement(Button, {
				Text = actionText,
				Color = actionColor,
				Size = UDim2.new(0, 100, 0, 36),
				Position = UDim2.new(1, -110, 0.5, -18),
				OnClick = function()
					if isUnlocked then
						teleportRequest:FireServer(zoneId)
						if onClose then onClose() end
					else
						if canAfford then
							buyZoneRequest:FireServer(zoneId)
						else
							UIManager.ShowToast("Не хватает монет для покупки этой зоны!", "Error")
						end
					end
				end
			})
		})
	end

	return React.createElement(Panel, {
		Title = "ТЕЛЕПОРТАЦИЯ",
		Size = UDim2.new(0, 380, 0, 300),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Visible = true,
		OnClose = onClose,
	}, {
		Scroll = React.createElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, -10),
			Position = UDim2.new(0, 0, 0, 5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 6,
			CanvasSize = UDim2.new(0, 0, 0, #sortedZones * 66),
		}, rows)
	})
end

return TeleportWindow

