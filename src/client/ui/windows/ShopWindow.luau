-- ShopWindow (React version)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
local ProgressBar = require(script.Parent.Parent.components.ProgressBar)
local UpgradeConfig = require(ReplicatedStorage.Shared.config.UpgradeConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local function ShopWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose
	local money = props.Money or 0

	local player = Players.LocalPlayer

	local levels, setLevels = React.useState(function()
		local initialLevels = {}
		for uType, _ in pairs(UpgradeConfig) do
			initialLevels[uType] = player:GetAttribute(uType .. "Lvl") or 1
		end
		return initialLevels
	end)

	React.useEffect(function()
		local connections = {}
		for uType, _ in pairs(UpgradeConfig) do
			local conn = player:GetAttributeChangedSignal(uType .. "Lvl"):Connect(function()
				setLevels(function(current)
					local copy = table.clone(current)
					copy[uType] = player:GetAttribute(uType .. "Lvl") or 1
					return copy
				end)
			end)
			table.insert(connections, conn)
		end

		return function()
			for _, conn in ipairs(connections) do
				conn:Disconnect()
			end
		end
	end, {})

	local items = {
		ListLayout = React.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
		})
	}

	for uType, conf in pairs(UpgradeConfig) do
		local lvl = levels[uType] or 1
		local isMax = lvl >= conf.MaxLevel
		local cost = not isMax and conf.Levels[lvl + 1].Cost or 0
		local canBuy = money >= cost

		local buttonText = isMax and "MAX" or "$" .. tostring(cost)
		local buttonColor = isMax and Theme.Colors.BackgroundSecondary or (canBuy and Theme.Colors.Success or Theme.Colors.Error)

		items[uType] = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 60),
			BackgroundColor3 = Theme.Colors.BackgroundSecondary,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerRadius,
			}),

			Title = React.createElement("TextLabel", {
				Text = conf.DisplayName,
				Position = UDim2.new(0, 10, 0, 5),
				Size = UDim2.new(0, 200, 0, 20),
				BackgroundTransparency = 1,
				TextColor3 = Theme.Colors.Text,
				Font = Theme.Fonts.Title,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),

			Level = React.createElement("TextLabel", {
				Text = "Lvl " .. lvl .. " / " .. conf.MaxLevel,
				Position = UDim2.new(0, 10, 0, 25),
				Size = UDim2.new(0, 200, 0, 20),
				BackgroundTransparency = 1,
				TextColor3 = Theme.Colors.TextSecondary,
				Font = Theme.Fonts.Body,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),

			Progress = React.createElement(ProgressBar, {
				Size = UDim2.new(0, 150, 0, 5),
				Position = UDim2.new(0, 10, 0, 45),
				Progress = lvl / conf.MaxLevel,
			}),

			BuyButton = React.createElement(Button, {
				Text = buttonText,
				Color = buttonColor,
				Size = UDim2.new(0, 100, 0, 40),
				Position = UDim2.new(1, -110, 0.5, -20),
				OnClick = function()
					if not isMax and canBuy then
						Remotes.getEvent("BuyUpgrade"):FireServer(uType)
					end
				end
			})
		})
	end

	return React.createElement(Panel, {
		Title = "UPGRADE SHOP",
		ShowBalance = true,
		BalanceValue = money,
		Visible = visible,
		OnClose = onClose,
	}, {
		Scroll = React.createElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, items)
	})
end

return ShopWindow

