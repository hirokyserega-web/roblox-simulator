-- Candy HUD Component (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local CurrencyChip = require(script.Parent.Parent.components.CurrencyChip)
local DetectorWidget = require(script.Parent.DetectorWidget)
local BagWidget = require(script.Parent.BagWidget)
local CaptureBar = require(script.Parent.CaptureBar)

local function HUD(props)
	local openWindow = props.OpenWindow
	local playerStats = props.PlayerStats or {}
	local detectorStats = props.DetectorStats or {}
	local captureStats = props.CaptureStats or {}

	local dockButtons = {
		{ Name = "Shop", Text = "🛒", Color = Theme.Colors.Accent },
		{ Name = "Inventory", Text = "🎒", Color = Theme.Colors.Accent },
		{ Name = "Pets", Text = "👾", Color = Theme.Colors.Accent },
		{ Name = "Leaderboard", Text = "🏆", Color = Theme.Colors.Accent },
		{ Name = "Teleport", Text = "🗺️", Color = Theme.Colors.Accent },
		{ Name = "Rewards", Text = "🎁", Color = Theme.Colors.Warning },
		{ Name = "Rebirth", Text = "⚡", Color = Theme.Colors.Accent },
		{ Name = "Settings", Text = "⚙️", Color = Theme.Colors.BackgroundSecondary }
	}

	local dockChildren = {
		GridLayout = React.createElement("UIGridLayout", {
			CellSize = UDim2.new(0, 72, 0, 72),
			CellPadding = UDim2.new(0, 10, 0, 10),
			FillDirectionMaxCells = 2,
			StartCorner = Enum.StartCorner.TopLeft,
		})
	}

	for i, item in ipairs(dockButtons) do
		dockChildren[item.Name] = React.createElement(Button, {
			Text = item.Text,
			Color = item.Color,
			Size = UDim2.new(0, 72, 0, 72),
			TextSize = 34,
			CornerRadius = UDim.new(0.5, 0),
			OnClick = function()
				if openWindow then openWindow(item.Name) end
			end
		})
	end

	return React.createElement("Frame", {
		Name = "HUD",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		-- Балансы валют (Нижний левый угол)
		MoneyChip = React.createElement(CurrencyChip, {
			CurrencyType = "Money",
			Value = playerStats.Money or 0,
			Position = UDim2.new(0, 20, 1, -55),
		}),

		CrystalChip = React.createElement(CurrencyChip, {
			CurrencyType = "Crystals",
			Value = playerStats.Crystals or 0,
			Position = UDim2.new(0, 20, 1, -100),
		}),

		-- Виджеты детектора и рюкзака
		Detector = React.createElement(DetectorWidget, {
			Signal = detectorStats.Signal or 0,
			Rarity = detectorStats.Rarity or "NONE",
			Position = UDim2.new(0, 20, 0.5, -241),
		}),

		Bag = React.createElement(BagWidget, {
			Count = playerStats.BagCount or 0,
			MaxCapacity = playerStats.BagMax or 10,
			Position = UDim2.new(1, -170, 0.4, -90),
		}),

		-- Шкала захвата призрака
		Capture = React.createElement(CaptureBar, {
			Visible = captureStats.Visible or false,
			GhostName = captureStats.GhostName or "GHOST",
			GhostRarity = captureStats.GhostRarity or "Common",
			Progress = captureStats.Progress or 0,
			ShakeTrigger = captureStats.ShakeTrigger or 0,
		}),

		-- Док-панель кнопок
		Dock = React.createElement("Frame", {
			Name = "Dock",
			Size = UDim2.new(0, 154, 0, 318),
			Position = UDim2.new(0, 20, 0.5, -120),
			BackgroundTransparency = 1,
		}, dockChildren)
	})
end

return HUD
