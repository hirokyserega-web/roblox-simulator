-- Клиентский UI Инвентаря призраков (Inventory UI)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GhostConfig = require(ReplicatedStorage.Shared.config.GhostConfig)
local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

-- Подгрузка темы и компонентов UI Kit
local Theme = require(script.Parent.ui.theme.Theme)
local Button = require(script.Parent.ui.components.Button)
local Panel = require(script.Parent.ui.components.Panel)
local ItemCard = require(script.Parent.ui.components.ItemCard)
local UIManager = require(script.Parent.ui.UIManager)

local player = Players.LocalPlayer
local requestSellEvent = Remotes.getEvent("RequestSell")
local inventoryUpdateEvent = Remotes.getEvent("InventoryUpdate")

local inventoryPanel = nil
local scrollFrame = nil
local valueLabel = nil
local sellButtonComponent = nil

local lastInventory = {}

-- Перерисовка карточек в инвентаре
local function renderInventoryUI()
	if not scrollFrame then return end

	-- Очищаем
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Группируем по редкости, чтобы показать количество
	local counts = {}
	local totalValue = 0

	for _, rarity in ipairs(lastInventory.Ghosts or {}) do
		counts[rarity] = (counts[rarity] or 0) + 1
		local conf = GhostConfig[rarity]
		if conf then
			totalValue = totalValue + conf.BasePrice
		end
	end

	valueLabel.Text = string.format("Общая ценность рюкзака: $%d", totalValue)

	-- Заполняем сетку сгруппированными карточками
	for rarity, count in pairs(counts) do
		local conf = GhostConfig[rarity]
		if not conf then continue end

		local cardWrapper = Instance.new("Frame")
		cardWrapper.Size = UDim2.new(0, 90, 0, 105)
		cardWrapper.BackgroundTransparency = 1
		cardWrapper.Parent = scrollFrame

		local card = ItemCard.create({
			Title = rarity:upper(),
			Rarity = rarity,
			IconColor = conf.Color,
			Subtext = string.format("Кол-во: x%d", count),
			Parent = cardWrapper
		})
	end

	local totalItems = 0
	for _, _ in pairs(counts) do totalItems = totalItems + 1 end
	local rows = math.ceil(totalItems / 3)
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, rows * 115)
end

-- Обновление активности кнопки "Продать" на основе дистанции до Черного рынка
local function checkSellZoneDistance()
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local market = Workspace:FindFirstChild("BlackMarketZone")

	if hrp and market and sellButtonComponent then
		local distance = (hrp.Position - market.Position).Magnitude
		local isNear = distance <= GameConfig.SellDistance

		if isNear and lastInventory.Ghosts and #lastInventory.Ghosts > 0 then
			sellButtonComponent.SetEnabled(true)
		else
			sellButtonComponent.SetEnabled(false)
		end
	end
end

-- Инициализация
local function init()
	local screenGui = UIManager.getScreenGui()

	-- Создаем премиум-панель
	inventoryPanel = Panel.create({
		Title = "РЮКЗАК ИНВЕНТАРЯ",
		Size = UDim2.new(0, 380, 0, 350),
		Position = UDim2.new(0.5, -190, 0.5, -175),
		Parent = screenGui,
		OnClose = function()
			inventoryPanel.Close()
		end
	})

	UIManager.registerWindow("Inventory", inventoryPanel)

	-- Текст ценности
	valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(1, -20, 0, 25)
	valueLabel.Position = UDim2.new(0, 10, 0, 10)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Font = Theme.Fonts.Bold
	valueLabel.TextSize = 13
	valueLabel.TextColor3 = Theme.Colors.Success
	valueLabel.Text = "Общая ценность рюкзака: $0"
	valueLabel.Parent = inventoryPanel.Content

	-- Скролл сетки
	scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, 0, 1, -95)
	scrollFrame.Position = UDim2.new(0, 0, 0, 40)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = inventoryPanel.Content

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 95, 0, 110)
	gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
	gridLayout.Parent = scrollFrame

	-- Кнопка продать всё
	sellButtonComponent = Button.create({
		Text = "ПРОДАТЬ ВСЁ (В зоне)",
		Color = Theme.Colors.Success,
		Size = UDim2.new(0, 240, 0, 42),
		Position = UDim2.new(0.5, -120, 1, -50),
		Parent = inventoryPanel.Content,
		OnClick = function()
			requestSellEvent:FireServer()
			inventoryPanel.Close()
		end
	})

	-- Подписка на обновление инвентаря
	inventoryUpdateEvent.OnClientEvent:Connect(function(inventory)
		lastInventory = inventory
		renderInventoryUI()
	end)

	-- Цикл проверки доступности зоны продажи
	task.spawn(function()
		while true do
			checkSellZoneDistance()
			task.wait(1)
		end
	end)
end

init()
print("[INVENTORY UI] Интерфейс рюкзака успешно загружен!")
