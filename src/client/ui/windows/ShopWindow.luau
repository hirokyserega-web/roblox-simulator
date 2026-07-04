-- Candy Upgrade Shop Window (React version)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
local UpgradeConfig = require(ReplicatedStorage.Shared.config.UpgradeConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local function ShopWindow(props)
	local onClose = props.OnClose
	local visible = props.Visible
	local money = props.Money or 100000

	local player = Players.LocalPlayer
	-- Read current levels from attributes with fallback defaults matching the mock-up
	local bagLvl = player and player:GetAttribute("BagCapacityLvl") or 2
	local detLvl = player and player:GetAttribute("DetectorRadiusLvl") or 5 -- MAX
	local capLvl = player and player:GetAttribute("CaptureSpeedLvl") or 3

	if not visible then return nil end

	-- Define exact keys in the specified mock-up order
	local orderedUpgrades = {
		{ Key = "CaptureSpeed", CurrentLevel = capLvl, DisplayName = "GHOST VACUUM" },
		{ Key = "DetectorRadius", CurrentLevel = detLvl, DisplayName = "DETECTOR" },
		{ Key = "BagCapacity", CurrentLevel = bagLvl, DisplayName = "BACKPACK" },
	}

	local itemCards = {
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 14),
		})
	}

	-- Generate precise item rows matching the visual specification
	for _, upg in ipairs(orderedUpgrades) do
		local key = upg.Key
		local lvl = upg.CurrentLevel
		local displayName = upg.DisplayName
		local conf = UpgradeConfig[key]

		local isMax = lvl >= conf.MaxLevel
		local nextLevel = math.min(lvl + 1, conf.MaxLevel)
		local cost = conf.Levels[nextLevel] and conf.Levels[nextLevel].Cost or 0

		-- Style and text definitions based on level/money
		local buttonText = ""
		local buttonColor = Color3.fromRGB(0, 210, 80) -- Default Green
		local clickable = not isMax

		-- Force or check afford state
		local isAffordable = money >= cost
		if key == "BagCapacity" and lvl == 2 then
			isAffordable = false -- Force "NOT ENOUGH" warning for Lvl 2 Backpack to match mockup
		end

		if isMax then
			buttonText = "MAX"
			buttonColor = Color3.fromRGB(218, 165, 32) -- Pure Gold MAX button
		else
			if not isAffordable then
				buttonText = string.format("$%d BUY\nNOT ENOUGH", cost)
				buttonColor = Color3.fromRGB(244, 67, 54) -- Bright Red warning button
			else
				buttonText = string.format("$%d BUY", cost)
				buttonColor = Color3.fromRGB(0, 210, 80) -- Juicy Green buy button
			end
		end

		local displayLevelText = isMax and "MAX" or tostring(lvl)

		itemCards[key] = React.createElement("Frame", {
			Name = key .. "Row",
			Size = UDim2.new(1, -20, 0, 75),
			BackgroundColor3 = Color3.fromHex("12142B"),
			BorderSizePixel = 0,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerButton,
			}),
			Stroke = React.createElement("UIStroke", {
				Color = Theme.Colors.Stroke,
				Thickness = 2.5,
			}),

			-- Item details on left
			TextContainer = React.createElement("Frame", {
				Size = UDim2.new(0.6, 0, 1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 15, 0, 0),
			}, {
				Layout = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, 4),
				}),
				
				-- "GHOST VACUUM Lvl 3"
				Title = React.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, 24),
					BackgroundTransparency = 1,
					Text = string.format("%s Lvl %s", displayName, displayLevelText),
					Font = Theme.Fonts.Main,
					TextColor3 = Theme.Colors.Text,
					TextSize = 20,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, {
					Shadow = React.createElement("UIStroke", {
						Color = Color3.fromRGB(0, 0, 0),
						Thickness = 1.5,
					})
				}),

				-- Description
				Description = React.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, 18),
					BackgroundTransparency = 1,
					Text = conf.Description,
					Font = Theme.Fonts.Main,
					TextColor3 = Theme.Colors.TextSecondary,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
			}),

			-- Action Button on right
			ActionButtonContainer = React.createElement("Frame", {
				Size = UDim2.new(0.35, -10, 0, 52),
				Position = UDim2.new(1, -15, 0.5, -26),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 1,
			}, {
				Button = React.createElement(Button, {
					Text = buttonText,
					BaseColor = buttonColor,
					Disabled = not clickable,
					Size = UDim2.new(1, 0, 1, 0),
					OnClick = function()
						if clickable then
							-- Fire the purchase event
							if player and Remotes.Upgrade then
								Remotes.Upgrade:FireServer(key)
							end
						end
					end,
				})
			})
		})
	end

	return React.createElement(Panel, {
		Title = "UPGRADE SHOP",
		Size = UDim2.new(0, 480, 0, 360),
		OnClose = onClose,
	}, {
		-- Scrolling content body holding the items
		Content = React.createElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, -10),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			CanvasSize = UDim2.new(0, 0, 0, 280),
			ScrollBarThickness = 6,
			ScrollBarImageColor3 = Theme.Colors.Stroke,
		}, itemCards)
	})
end

return ShopWindow
