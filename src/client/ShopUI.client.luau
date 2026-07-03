-- Клиентский контроллер UI магазина (Shop UI)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local UpgradeConfig = require(ReplicatedStorage.Shared.config.UpgradeConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Сетевые события
local buyUpgradeEvent = Remotes.getEvent("BuyUpgrade")

-- Ссылка на элементы UI
local screenGui = nil
local shopFrame = nil
local upgradeCards = {} -- Список карт для каждого улучшения

-- Вспомогательная функция форматирования чисел
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

-- Функция обновления кнопки покупки конкретного улучшения
local function updateCard(upgradeType: string)
	local card = upgradeCards[upgradeType]
	if not card then return end

	local config = UpgradeConfig[upgradeType]
	local level = player:GetAttribute(upgradeType .. "Lvl") or 1

	-- Обновляем уровень на карточке
	card.LevelLabel.Text = string.format("Уровень: %d / %d", level, config.MaxLevel)

	if level >= config.MaxLevel then
		card.BuyButton.Text = "МАКС."
		card.BuyButton.BackgroundColor3 = Color3.fromRGB(127, 140, 141) -- Серый
		card.BuyButton.AutoButtonColor = false
	else
		local nextLevel = level + 1
		local cost = config.Levels[nextLevel].Cost
		card.BuyButton.Text = string.format("$%s", formatNumber(cost))
		card.BuyButton.AutoButtonColor = true

		-- Меняем цвет в зависимости от того, хватает ли денег
		local currentMoney = player:GetAttribute("Money") or 0
		if currentMoney >= cost then
			card.BuyButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Зеленый (доступно)
		else
			card.BuyButton.BackgroundColor3 = Color3.fromRGB(192, 57, 43) -- Темно-красный (недоступно)
		end
	end
end

-- Функция для обновления всех карт в магазине при изменении баланса монет
local function updateAllCards()
	for upgradeType, _ in pairs(UpgradeConfig) do
		updateCard(upgradeType)
	end
end

-- Создание интерфейса магазина
local function createShopUI()
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ShopHUD"
	screenGui.ResetOnSpawn = false

	-- Кнопка открытия магазина на левой части экрана
	local shopBtn = Instance.new("TextButton")
	shopBtn.Name = "ShopButton"
	shopBtn.Size = UDim2.new(0, 80, 0, 45)
	shopBtn.Position = UDim2.new(0, 20, 0.45, 0)
	shopBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185) -- Красивый синий
	shopBtn.BorderSizePixel = 0
	shopBtn.Font = Enum.Font.FredokaOne
	shopBtn.TextSize = 16
	shopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	shopBtn.Text = "SHOP"
	shopBtn.Parent = screenGui

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = shopBtn

	-- Основная панель магазина
	shopFrame = Instance.new("Frame")
	shopFrame.Name = "ShopFrame"
	shopFrame.Size = UDim2.new(0, 420, 0, 340)
	shopFrame.Position = UDim2.new(0.5, -210, 0.5, -170)
	shopFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	shopFrame.BackgroundTransparency = 0.15
	shopFrame.BorderSizePixel = 0
	shopFrame.Visible = false
	shopFrame.Parent = screenGui

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 12)
	frameCorner.Parent = shopFrame

	-- Заголовок магазина
	local title = Instance.new("TextLabel")
	title.Name = "TitleLabel"
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Position = UDim2.new(0, 0, 0, 10)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.FredokaOne
	title.TextSize = 20
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Text = "МАГАЗИН УЛУЧШЕНИЙ"
	title.Parent = shopFrame

	-- Кнопка закрытия "X"
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -40, 0, 10)
	closeBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Красный
	closeBtn.BorderSizePixel = 0
	closeBtn.Font = Enum.Font.FredokaOne
	closeBtn.TextSize = 14
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Text = "X"
	closeBtn.Parent = shopFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeBtn

	-- Прокручиваемый список апгрейдов
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "UpgradesScroll"
	scrollFrame.Size = UDim2.new(1, -30, 1, -70)
	scrollFrame.Position = UDim2.new(0, 15, 0, 55)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 330) -- Фиксированная высота прокрутки под 4 карточки
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = shopFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = scrollFrame

	-- Создаем карточки улучшений
	local index = 1
	for upgradeType, config in pairs(UpgradeConfig) do
		local card = Instance.new("Frame")
		card.Name = upgradeType .. "Card"
		card.Size = UDim2.new(1, -10, 0, 70)
		card.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		card.BorderSizePixel = 0
		card.LayoutOrder = index
		card.Parent = scrollFrame

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 8)
		cardCorner.Parent = card

		-- Название улучшения
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(0.6, 0, 0, 25)
		nameLabel.Position = UDim2.new(0, 15, 0, 8)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Enum.Font.FredokaOne
		nameLabel.TextSize = 14
		nameLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Text = config.DisplayName
		nameLabel.Parent = card

		-- Описание улучшения
		local descLabel = Instance.new("TextLabel")
		descLabel.Name = "DescLabel"
		descLabel.Size = UDim2.new(0.6, 0, 0, 20)
		descLabel.Position = UDim2.new(0, 15, 0, 28)
		descLabel.BackgroundTransparency = 1
		descLabel.Font = Enum.Font.SourceSans
		descLabel.TextSize = 12
		descLabel.TextColor3 = Color3.fromRGB(170, 170, 180)
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.Text = config.Description
		descLabel.Parent = card

		-- Уровень
		local levelLabel = Instance.new("TextLabel")
		levelLabel.Name = "LevelLabel"
		levelLabel.Size = UDim2.new(0.6, 0, 0, 15)
		levelLabel.Position = UDim2.new(0, 15, 0, 48)
		levelLabel.BackgroundTransparency = 1
		levelLabel.Font = Enum.Font.SourceSansBold
		levelLabel.TextSize = 12
		levelLabel.TextColor3 = Color3.fromRGB(52, 152, 219) -- Синий
		levelLabel.TextXAlignment = Enum.TextXAlignment.Left
		levelLabel.Text = "Уровень: Loading..."
		levelLabel.Parent = card

		-- Кнопка улучшения
		local buyBtn = Instance.new("TextButton")
		buyBtn.Name = "BuyButton"
		buyBtn.Size = UDim2.new(0, 90, 0, 40)
		buyBtn.Position = UDim2.new(1, -105, 0.5, -20)
		buyBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
		buyBtn.BorderSizePixel = 0
		buyBtn.Font = Enum.Font.FredokaOne
		buyBtn.TextSize = 14
		buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		buyBtn.Text = "$0"
		buyBtn.Parent = card

		local buyCorner = Instance.new("UICorner")
		buyCorner.CornerRadius = UDim.new(0, 8)
		buyCorner.Parent = buyBtn

		-- Сохраняем ссылки для апдейтов
		upgradeCards[upgradeType] = {
			LevelLabel = levelLabel,
			BuyButton = buyBtn
		}

		-- Нажатие на кнопку улучшения
		buyBtn.MouseButton1Click:Connect(function()
			buyUpgradeEvent:FireServer(upgradeType)
		end)

		index = index + 1
	end

	-- Открытие/Закрытие по кликам
	shopBtn.MouseButton1Click:Connect(function()
		shopFrame.Visible = not shopFrame.Visible
		if shopFrame.Visible then
			updateAllCards()
		end
	end)

	closeBtn.MouseButton1Click:Connect(function()
		shopFrame.Visible = false
	end)

	screenGui.Parent = playerGui
end

-- Инициализация и слушатели событий изменений на игроке
local function init()
	createShopUI()

	-- Подписываемся на изменения уровней апгрейдов на игроке
	for upgradeType, _ in pairs(UpgradeConfig) do
		player:GetAttributeChangedSignal(upgradeType .. "Lvl"):Connect(function()
			updateCard(upgradeType)
		end)
	end

	-- Подписываемся на изменение баланса монет для подкраски доступных улучшений
	player:GetAttributeChangedSignal("Money"):Connect(updateAllCards)

	-- Первоначальный апдейт
	updateAllCards()
end

init()
print("ShopUI client controller started")
