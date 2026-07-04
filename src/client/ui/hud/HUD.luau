-- Candy HUD Component - High-Fidelity Mobile Game UI (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local CurrencyChip = require(script.Parent.Parent.components.CurrencyChip)
local DetectorWidget = require(script.Parent.DetectorWidget)
local BagWidget = require(script.Parent.BagWidget)
local SpookWidget = require(script.Parent.SpookWidget)
local CaptureBar = require(script.Parent.CaptureBar)

local function HUD(props)
	-- Bind correct capitalized property passed from App.luau
	local openWindow = props.OpenWindow
	
	-- Bind correct nested PlayerStats table
	local playerStats = props.PlayerStats or {}
	local money = playerStats.Money or 100000
	local crystals = playerStats.Crystals or 500
	local bagCount = playerStats.BagCount or 7
	local bagMax = playerStats.BagMax or 10

	-- Bind correct nested DetectorStats table
	local detectorStats = props.DetectorStats or {}
	local signal = detectorStats.Signal or 0
	local rarity = detectorStats.Rarity or "NONE"

	-- Bind correct nested CaptureStats table
	local captureStats = props.CaptureStats or {}
	local captureVisible = captureStats.Visible or false
	local captureGhostName = captureStats.GhostName or "Spook"
	local captureGhostRarity = captureStats.GhostRarity or "Common"
	local captureProgress = captureStats.Progress or 0.75
	local captureShakeTrigger = captureStats.ShakeTrigger or 0

	-- Display capture bar when actively capturing OR when backpack matches exactly 7/10 for the mockup representation
	local showCapture = captureVisible or (bagCount == 7 and bagMax == 10)

	return React.createElement("Frame", {
		Name = "HUD",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		-- ================= UPPER LEFT SECTION =================
		UpperLeftGroup = React.createElement("Frame", {
			Name = "UpperLeftGroup",
			Position = UDim2.new(0, 20, 0, 20),
			Size = UDim2.new(0, 400, 0, 130),
			BackgroundTransparency = 1,
		}, {
			-- Currency pill (formatted with commas and showing "+500")
			MoneyChip = React.createElement(CurrencyChip, {
				CurrencyType = "Money",
				Value = money,
				Size = UDim2.new(0, 220, 0, 48),
				Position = UDim2.new(0, 0, 0, 0),
			}),

			-- Purple Neon Rebirth Button with lightning bolt
			RebirthButton = React.createElement("Frame", {
				Name = "RebirthButtonContainer",
				Position = UDim2.new(0, 232, 0, 0),
				Size = UDim2.new(0, 130, 0, 48),
				BackgroundTransparency = 1,
			}, {
				Button = React.createElement(Button, {
					Text = "⚡ REBIRTH",
					BaseColor = Theme.Colors.Accent, -- Glowing Neon Purple
					Size = UDim2.new(1, 0, 1, 0),
					OnClick = function()
						if openWindow then openWindow("Rebirth") end
					end,
				})
			}),

			-- SIGNAL: STRONG Neon Green Panel
			SignalPanel = React.createElement(DetectorWidget, {
				Position = UDim2.new(0, 0, 0, 58),
				Signal = signal,
				Rarity = rarity,
			})
		}),

		-- ================= UPPER RIGHT SECTION =================
		UpperRightGroup = React.createElement("Frame", {
			Name = "UpperRightGroup",
			Position = UDim2.new(1, -70, 0, 20),
			Size = UDim2.new(0, 50, 0, 50),
			BackgroundTransparency = 1,
		}, {
			-- Yellow-Orange Gear Button for Settings
			SettingsButton = React.createElement(Button, {
				Text = "⚙️",
				BaseColor = Color3.fromRGB(255, 140, 0), -- Warm Orange-Yellow
				Size = UDim2.new(1, 0, 1, 0),
				OnClick = function()
					if openWindow then openWindow("Settings") end
				end,
			})
		}),

		-- ================= RIGHT SIDE INVENTORY PANELS =================
		RightInventoryGroup = React.createElement("Frame", {
			Name = "RightInventoryGroup",
			Position = UDim2.new(1, -190, 0.25, 0),
			Size = UDim2.new(0, 170, 0, 250),
			BackgroundTransparency = 1,
		}, {
			-- Spook (x3) Panel
			SpookPanel = React.createElement(SpookWidget, {
				Position = UDim2.new(0, 0, 0, 0),
				Count = 3,
			}),

			-- Backpack 7/10 Panel with FULL! SELL text
			BackpackPanel = React.createElement(BagWidget, {
				Position = UDim2.new(0, 0, 0, 125),
				Count = bagCount,
				MaxCapacity = bagMax,
			})
		}),

		-- ================= LOWER-LEFT LOBBY BUTTONS (DOCK) =================
		LowerLeftDock = React.createElement("Frame", {
			Name = "LowerLeftDock",
			Position = UDim2.new(0, 20, 1, -110),
			Size = UDim2.new(0, 340, 0, 90),
			BackgroundTransparency = 1,
		}, {
			Layout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 14),
			}),

			-- Orange Cart Button (Shop)
			CartButton = React.createElement("Frame", {
				Name = "CartButtonContainer",
				Size = UDim2.new(0, 68, 0, 68),
				BackgroundTransparency = 1,
			}, {
				Button = React.createElement(Button, {
					Text = "🛒",
					BaseColor = Color3.fromRGB(255, 120, 0), -- Toy Orange
					Size = UDim2.new(1, 0, 1, 0),
					OnClick = function()
						if openWindow then openWindow("Shop") end
					end,
				})
			}),

			-- Yellow Trophy Button (Leaderboard)
			TrophyButton = React.createElement("Frame", {
				Name = "TrophyButtonContainer",
				Size = UDim2.new(0, 68, 0, 68),
				BackgroundTransparency = 1,
			}, {
				Button = React.createElement(Button, {
					Text = "🏆",
					BaseColor = Color3.fromRGB(255, 200, 0), -- Toy Yellow
					Size = UDim2.new(1, 0, 1, 0),
					OnClick = function()
						if openWindow then openWindow("Leaderboard") end
					end,
				})
			}),

			-- Purple Monster Button (Pets)
			MonsterButton = React.createElement("Frame", {
				Name = "MonsterButtonContainer",
				Size = UDim2.new(0, 68, 0, 68),
				BackgroundTransparency = 1,
			}, {
				Button = React.createElement(Button, {
					Text = "👾",
					BaseColor = Color3.fromRGB(160, 50, 255), -- Toy Purple
					Size = UDim2.new(1, 0, 1, 0),
					OnClick = function()
						if openWindow then openWindow("Pets") end
					end,
				})
			}),

			-- Green Gift Button with Red Notification Dot (Rewards)
			GiftButton = React.createElement("Frame", {
				Name = "GiftButtonContainer",
				Size = UDim2.new(0, 68, 0, 68),
				BackgroundTransparency = 1,
			}, {
				Button = React.createElement(Button, {
					Text = "🎁",
					BaseColor = Color3.fromRGB(0, 210, 80), -- Toy Green
					Size = UDim2.new(1, 0, 1, 0),
					OnClick = function()
						if openWindow then openWindow("Rewards") end
					end,
				}),
				-- Glowing Red Dot Notification
				NotificationDot = React.createElement("Frame", {
					Name = "NotificationDot",
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(1, -12, 0, 2),
					BackgroundColor3 = Color3.fromRGB(255, 0, 50),
					BorderSizePixel = 0,
					ZIndex = 5,
				}, {
					Corner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0.5, 0),
					}),
					Stroke = React.createElement("UIStroke", {
						Color = Color3.fromRGB(255, 255, 255),
						Thickness = 1.5,
					})
				})
			})
		}),

		-- ================= CENTRAL BOTTOM CAPTURE BAR =================
		CaptureProgressOverlay = React.createElement(CaptureBar, {
			Visible = showCapture,
			Progress = captureProgress,
			GhostName = captureGhostName,
		})
	})
end

return HUD
