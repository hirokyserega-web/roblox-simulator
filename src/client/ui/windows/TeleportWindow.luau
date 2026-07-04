-- Candy Teleport Window (React version)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local function TeleportWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose

	if not visible then return nil end

	local worlds = {
		{ Id = "Cemetery", Name = "Night Cemetery 🌲", Unlocked = true },
		{ Id = "Castle", Name = "Dracula Castle 🏰", Unlocked = false, Cost = 5000 },
		{ Id = "Graveyard", Name = "Haunted Swamps 👻", Unlocked = false, Cost = 25000 },
	}

	local worldCards = {
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 12),
		})
	}

	for _, w in ipairs(worlds) do
		local desc = w.Unlocked and "Fully Unlocked & Free" or string.format("Unlocks at $%d", w.Cost)
		local btnText = w.Unlocked and "TELEPORT 🌀" or "LOCKED 🔒"
		local btnColor = w.Unlocked and Theme.Colors.Success or Theme.Colors.Error

		worldCards[w.Id] = React.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 68),
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

			-- Left description details
			LabelContainer = React.createElement("Frame", {
				Size = UDim2.new(0.6, 0, 1, 0),
				Position = UDim2.new(0, 15, 0, 0),
				BackgroundTransparency = 1,
			}, {
				Layout = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, 4),
				}),

				Title = React.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, 22),
					BackgroundTransparency = 1,
					Text = w.Name,
					Font = Theme.Fonts.Main,
					TextColor3 = Theme.Colors.Text,
					TextSize = 18,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, {
					Shadow = React.createElement("UIStroke", {
						Color = Color3.fromRGB(0, 0, 0),
						Thickness = 1.2,
					})
				}),

				Sub = React.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, 16),
					BackgroundTransparency = 1,
					Text = desc,
					Font = Theme.Fonts.Main,
					TextColor3 = Theme.Colors.TextSecondary,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
			}),

			-- Action Button on right
			ActionButton = React.createElement("Frame", {
				Size = UDim2.new(0.35, -10, 0, 44),
				Position = UDim2.new(1, -15, 0.5, -22),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 1,
			}, {
				Btn = React.createElement(Button, {
					Text = btnText,
					Color = btnColor,
					Size = UDim2.new(1, 0, 1, 0),
					OnClick = function()
						if w.Unlocked then
							Remotes.getEvent("TeleportRequest"):FireServer(w.Id)
							if onClose then onClose() end
						end
					end
				})
			})
		})
	end

	return React.createElement(Panel, {
		Title = "WORLD PORTALS",
		Size = UDim2.new(0, 460, 0, 350),
		OnClose = onClose,
	}, {
		Scroll = React.createElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			CanvasSize = UDim2.new(0, 0, 0, 240),
			ScrollBarThickness = 6,
			ScrollBarImageColor3 = Theme.Colors.Stroke,
		}, worldCards)
	})
end

return TeleportWindow
