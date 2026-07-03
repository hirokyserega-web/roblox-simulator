-- Клиентский контроллер HUD (HudController)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Подгрузка темы и компонентов UI Kit
local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local CurrencyChip = require(script.Parent.Parent.components.CurrencyChip)
local UIManager = require(script.Parent.Parent.UIManager)

-- Локальные виджеты
local DetectorWidget = require(script.Parent.DetectorWidget)
local BagWidget = require(script.Parent.BagWidget)
local CaptureBar = require(script.Parent.CaptureBar)

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)

local player = Players.LocalPlayer

-- Элементы HUD
local screenGui = nil
local moneyChip = nil
local crystalChip = nil
local detector = nil
local bag = nil
local captureBar = nil

-- Создание макета HUD
local function createHUD()
	screenGui = UIManager.getScreenGui()

	-- ==========================================
	-- ВЕРХНЯЯ ПАНЕЛЬ
	-- ==========================================
	local topBar = Instance.new("Frame")
	topBar.Name = "TopHUD"
	topBar.Size = UDim2.new(1, 0, 0, 60)
	topBar.Position = UDim2.new(0, 0, 0, 10)
	topBar.BackgroundTransparency = 1
	topBar.Parent = screenGui

	-- Фишка монет
	moneyChip = CurrencyChip.create({
		CurrencyType = "Money",
		Size = UDim2.new(0, 150, 0, 40),
		Position = UDim2.new(0, 20, 0, 10),
		Parent = topBar
	})

	-- Фишка кристаллов
	crystalChip = CurrencyChip.create({
		CurrencyType = "Crystals",
		Size = UDim2.new(0, 130, 0, 40),
		Position = UDim2.new(0, 180, 0, 10),
		Parent = topBar
	})

	-- Кнопка Rebirth
	local rebirthBtn = Button.create({
		Text = "⚡ REBIRTH",
		Color = Theme.Colors.Accent,
		Size = UDim2.new(0, 110, 0, 40),
		Position = UDim2.new(1, -210, 0, 14),
		Parent = topBar,
		OnClick = function()
			UIManager.openWindow("Rebirth")
		end
	})

	-- Кнопка Настроек ⚙️
	local settingsBtn = Button.create({
		Text = "⚙️",
		Color = Theme.Colors.BackgroundSecondary,
		Size = UDim2.new(0, 40, 0, 40),
		Position = UDim2.new(1, -70, 0, 14),
		TextSize = 18,
		Parent = topBar,
		OnClick = function()
			UIManager.openWindow("Settings")
		end
	})

	-- ==========================================
	-- ВИДЖЕТЫ
	-- ==========================================
	detector = DetectorWidget.create({
		Parent = screenGui,
		Position = UDim2.new(0, 20, 0.4, -90)
	})

	bag = BagWidget.create({
		Parent = screenGui,
		Position = UDim2.new(1, -170, 0.4, -90)
	})

	captureBar = CaptureBar.create({
		Parent = screenGui
	})

	-- Экспортируем функции CaptureBar глобально для контроллеров
	_G.ShowCapture = function(ghostInfo) captureBar.Show(ghostInfo) end
	_G.SetCaptureProgress = function(v) captureBar.SetProgress(v) end
	_G.HideCapture = function() captureBar.Hide() end
	_G.ShakeCapture = function() captureBar.Shake() end

	-- ==========================================
	-- НИЖНЯЯ ПАНЕЛЬ DOCK (6 КНОПОК)
	-- ==========================================
	local dock = Instance.new("Frame")
	dock.Name = "Dock"
	dock.Size = UDim2.new(0, 640, 0, 60)
	dock.Position = UDim2.new(0.5, -320, 1, -80)
	dock.BackgroundTransparency = 1
	dock.Parent = screenGui

	local dockLayout = Instance.new("UIListLayout")
	dockLayout.FillDirection = Enum.FillDirection.Horizontal
	dockLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	dockLayout.Padding = UDim.new(0, 10)
	dockLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	dockLayout.Parent = dock

	local dockButtons = {
		{ Name = "Shop", Text = "🛒 Магазин", Color = Theme.Colors.Accent },
		{ Name = "Inventory", Text = "🎒 Рюкзак", Color = Theme.Colors.Accent },
		{ Name = "Pets", Text = "👾 Питомцы", Color = Theme.Colors.Accent },
		{ Name = "Leaderboard", Text = "🏆 Топ", Color = Theme.Colors.Accent },
		{ Name = "Teleport", Text = "🗺️ Телепорт", Color = Theme.Colors.Accent },
		{ Name = "Rewards", Text = "🎁 Награды", Color = Theme.Colors.Warning }
	}

	for _, item in ipairs(dockButtons) do
		local btn = Button.create({
			Text = item.Text,
			Color = item.Color,
			Size = UDim2.new(0, 95, 0, 44),
			TextSize = 11,
			Parent = dock,
			OnClick = function()
				UIManager.openWindow(item.Name)
			end
		})
	end
end

-- Обработка балансов игрока
local function connectAttributes()
	local function updateMoney()
		local money = player:GetAttribute("Money") or 0
		moneyChip.SetValue(money)
	end
	
	local function updateCrystals()
		local crystals = player:GetAttribute("Crystals") or 0
		crystalChip.SetValue(crystals)
	end

	player:GetAttributeChangedSignal("Money"):Connect(updateMoney)
	player:GetAttributeChangedSignal("Crystals"):Connect(updateCrystals)

	updateMoney()
	updateCrystals()
end

-- Подписка на обновление рюкзака
Remotes.getEvent("InventoryUpdate").OnClientEvent:Connect(function(inventory)
	if bag and inventory then
		local count = #inventory.Ghosts
		local maxCap = inventory.MaxCapacity
		bag.Update(count, maxCap)
	end
end)

-- Обновление Детектора Сигналов
local function startDetectorLoop()
	local localGhostsFolder = Workspace:WaitForChild("LocalGhosts", 15)

	RunService.Heartbeat:Connect(function()
		local character = player.Character
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		if not rootPart or not localGhostsFolder or not detector then return end

		local closestGhost = nil
		local minDistance = math.huge

		for _, ghost in ipairs(localGhostsFolder:GetChildren()) do
			if ghost:IsA("BasePart") then
				local distance = (rootPart.Position - ghost.Position).Magnitude
				if distance < minDistance then
					minDistance = distance
					closestGhost = ghost
				end
			end
		end

		local maxRange = player:GetAttribute("DetectorRadius") or GameConfig.DefaultDetectorRadius

		if closestGhost and minDistance <= maxRange then
			local factor = 1 - (minDistance / maxRange)
			detector.SetSignal(factor)

			local rarity = closestGhost:GetAttribute("Rarity") or "Common"
			detector.SetRarity(rarity)
		else
			detector.SetSignal(0)
		end
	end)
end

-- Инициализация
createHUD()
connectAttributes()
startDetectorLoop()

print("[HUD CONTROLLER] Модульный HUD успешно запущен!")
