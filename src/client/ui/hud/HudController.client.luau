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
	-- НИЖНИЙ ЛЕВЫЙ УГОЛ (Балансы валют)
	-- ==========================================
	moneyChip = CurrencyChip.create({
		CurrencyType = "Money",
		Size = UDim2.new(0, 150, 0, 40),
		Position = UDim2.new(0, 20, 1, -55),
		Parent = screenGui
	})

	crystalChip = CurrencyChip.create({
		CurrencyType = "Crystals",
		Size = UDim2.new(0, 130, 0, 40),
		Position = UDim2.new(0, 175, 1, -55),
		Parent = screenGui
	})

	-- ==========================================
	-- ВИДЖЕТЫ (Левая и Правая стороны)
	-- ==========================================
	-- Детектор расположен вертикально прямо НАД док-панелью кнопок
	detector = DetectorWidget.create({
		Parent = screenGui,
		Position = UDim2.new(0, 20, 0.5, -205)
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
	-- СЛЕВА ПО ЦЕНТРУ: DOCK (2 КОЛОНКИ, КРУПНЫЕ КРУГЛЫЕ КНОПКИ)
	-- ==========================================
	local dock = Instance.new("Frame")
	dock.Name = "Dock"
	dock.Size = UDim2.new(0, 118, 0, 246)
	dock.Position = UDim2.new(0, 20, 0.5, -123)
	dock.BackgroundTransparency = 1
	dock.Parent = screenGui

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 54, 0, 54)
	gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
	gridLayout.FillDirectionMaxCells = 2
	gridLayout.StartCorner = Enum.StartCorner.TopLeft
	gridLayout.Parent = dock

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
