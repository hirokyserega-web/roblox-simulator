-- Окно Магазина Улучшений (ShopWindow) - Полный редизайн под стиль референса
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local UpgradeConfig = require(ReplicatedStorage.Shared.config.UpgradeConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local Panel = require(script.Parent.Parent.components.Panel)
local ProgressBar = require(script.Parent.Parent.components.ProgressBar)
local UIManager = _G.UIManager

local player = Players.LocalPlayer
local buyUpgradeEvent = Remotes.getEvent("BuyUpgrade")

local ShopWindow = {}
local shopPanel = nil
local scrollingFrame = nil
local upgradeItems = {}

-- Соответствие улучшений и красивых эмодзи-иконок
local UPGRADE_ICONS = {
	WalkSpeed = { Emoji = "⚡", Color = Color3.fromHex("ffb703") },
	BagCapacity = { Emoji = "🎒", Color = Color3.fromHex("02c39a") },
	DetectorRadius = { Emoji = "📡", Color = Color3.fromHex("00b4d8") },
	CaptureSpeed = { Emoji = "🌀", Color = Color3.fromHex("9d4edd") }
}

-- Форматирование чисел
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

-- Обновление строки улучшения
local function updateUpgradeRow(upgradeType: string)
	local row = upgradeItems[upgradeType]
	if not row then return end

	local config = UpgradeConfig[upgradeType]
	local level = player:GetAttribute(upgradeType .. "Lvl") or 1
	local currentMoney = player:GetAttribute("Money") or 0

	row.LevelLabel.Text = string.format("Lvl %d / %d", level, config.MaxLevel)
	row.ProgressBar.SetProgress(level / config.MaxLevel)

	if row.BuyButton then
		row.BuyButton.Destroy()
		row.BuyButton = nil
	end

	if level >= config.MaxLevel then
		row.BuyButton = Button.create({
			Text = "MAX",
			Color = Color3.fromHex("e5a93b"), -- Оранжево-золотой
			Size = UDim2.new(0, 95, 0, 42),
			Position = UDim2.new(1, -110, 0.5, -21),
			Parent = row.Frame,
			OnClick = function() end
		})
		row.BuyButton.SetEnabled(false)
	else
		local nextLevel = level + 1
		local cost = config.Levels[nextLevel].Cost
		local canAfford = currentMoney >= cost

		-- Создаем сочную кнопку с 2-строчным текстом как на скриншоте
		row.BuyButton = Button.create({
			Text = "", -- Очищаем стандартный текст для кастомной разметки
			Color = canAfford and Theme.Colors.Success or Theme.Colors.Error,
			Size = UDim2.new(0, 95, 0, 42),
			Position = UDim2.new(1, -110, 0.5, -21),
			Parent = row.Frame,
			OnClick = function()
				if canAfford then
					buyUpgradeEvent:FireServer(upgradeType)
				else
					UIManager.ShowToast("Не хватает денег для улучшения!", "Error")
					-- Эффект тряски при ошибке покупки
					local origPos = UDim2.new(1, -110, 0.5, -21)
					local shakePos = UDim2.new(1, -105, 0.5, -21)
					task.spawn(function()
						TweenService:Create(row.BuyButton.Instance, TweenInfo.new(0.05), {Position = shakePos}):Play()
						task.wait(0.05)
						TweenService:Create(row.BuyButton.Instance, TweenInfo.new(0.05), {Position = origPos}):Play()
					end)
				end
			end
		})

		-- Кастомные надписи внутри кнопки
		local topPart = row.BuyButton.Instance:FindFirstChild("ButtonTop")
		if topPart then
			local priceLabel = Instance.new("TextLabel")
			priceLabel.Name = "PriceLabel"
			priceLabel.Size = UDim2.new(1, 0, 0.5, 0)
			priceLabel.Position = UDim2.new(0, 0, 0, 2)
			priceLabel.BackgroundTransparency = 1
			priceLabel.Font = Theme.Fonts.Title
			priceLabel.TextSize = 13
			priceLabel.TextColor3 = Color3.new(1, 1, 1)
			priceLabel.Text = "$" .. formatNumber(cost)
			priceLabel.TextStrokeTransparency = 0.5
			priceLabel.TextStrokeColor3 = Theme.Colors.Stroke
			priceLabel.Parent = topPart

			local actionLabel = Instance.new("TextLabel")
			actionLabel.Name = "ActionLabel"
			actionLabel.Size = UDim2.new(1, 0, 0.5, 0)
			actionLabel.Position = UDim2.new(0, 0, 0.5, -2)
			actionLabel.BackgroundTransparency = 1
			actionLabel.Font = Theme.Fonts.Title
			actionLabel.TextSize = 10
			actionLabel.TextColor3 = canAfford and Color3.new(1, 1, 1) or Color3.fromRGB(255, 200, 200)
			actionLabel.Text = canAfford and "BUY" or "NOT ENOUGH"
			actionLabel.TextStrokeTransparency = 0.6
			actionLabel.TextStrokeColor3 = Theme.Colors.Stroke
			actionLabel.Parent = topPart
		end
	end
end

local function updateAllRows()
	for upgradeType, _ in pairs(UpgradeConfig) do
		updateUpgradeRow(upgradeType)
	end
end

-- Инициализация и авторегистрация
function ShopWindow.init()
	local screenGui = UIManager.getScreenGui()

	shopPanel = Panel.create({
		Title = "UPGRADE SHOP",
		Size = UDim2.new(0, 440, 0, 380),
		Position = UDim2.new(0.5, -220, 0.5, -190),
		Parent = screenGui,
		ShowBalance = true, -- Показывать баланс на панельке под заголовком
		OnClose = function()
			shopPanel.Close()
		end
	})

	UIManager.registerWindow("Shop", shopPanel)

	scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.ScrollBarThickness = 6
	scrollingFrame.Parent = shopPanel.Content

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Parent = scrollingFrame

	local upgradesList = { "WalkSpeed", "BagCapacity", "DetectorRadius", "CaptureSpeed" }

	for _, upgradeType in ipairs(upgradesList) do
		local config = UpgradeConfig[upgradeType]
		if not config then continue end

		local iconData = UPGRADE_ICONS[upgradeType] or { Emoji = "⭐", Color = Theme.Colors.Accent }

		-- Фрейм строки (Ряд)
		local rowFrame = Instance.new("Frame")
		rowFrame.Name = "Row_" .. upgradeType
		rowFrame.Size = UDim2.new(1, -12, 0, 72) -- Увеличенная высота ряда под скриншот
		rowFrame.BackgroundColor3 = Theme.Colors.BackgroundSecondary
		rowFrame.BorderSizePixel = 0
		rowFrame.Parent = scrollingFrame

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = Theme.Sizes.CornerRadius
		rowCorner.Parent = rowFrame

		-- Стильная темная обводка
		local rowStroke = Instance.new("UIStroke")
		rowStroke.Thickness = 2
		rowStroke.Color = Theme.Colors.Stroke
		rowStroke.Parent = rowFrame

		-- Контейнер иконки на левой стороне
		local iconContainer = Instance.new("Frame")
		iconContainer.Name = "IconContainer"
		iconContainer.Size = UDim2.new(0, 52, 0, 52)
		iconContainer.Position = UDim2.new(0, 10, 0.5, -26)
		iconContainer.BackgroundColor3 = Theme.Colors.Background
		iconContainer.BorderSizePixel = 0
		iconContainer.Parent = rowFrame

		local iconCorner = Instance.new("UICorner")
		iconCorner.CornerRadius = UDim.new(0, 12)
		iconCorner.Parent = iconContainer

		local iconStroke = Instance.new("UIStroke")
		iconStroke.Thickness = 2
		iconStroke.Color = iconData.Color
		iconStroke.Parent = iconContainer

		-- Отображение сочного 3D эмодзи-иконки внутри контейнера
		local iconEmoji = Instance.new("TextLabel")
		iconEmoji.Size = UDim2.new(1, 0, 1, 0)
		iconEmoji.BackgroundTransparency = 1
		iconEmoji.Font = Theme.Fonts.Title
		iconEmoji.TextSize = 28
		iconEmoji.Text = iconData.Emoji
		iconEmoji.Parent = iconContainer

		-- Название улучшения
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0, 200, 0, 22)
		nameLabel.Position = UDim2.new(0, 72, 0, 10)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Theme.Fonts.Title
		nameLabel.TextSize = 14
		nameLabel.TextColor3 = Theme.Colors.Text
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Text = string.upper(config.DisplayName)
		nameLabel.TextStrokeTransparency = 0.8
		nameLabel.TextStrokeColor3 = Theme.Colors.Stroke
		nameLabel.Parent = rowFrame

		-- Уровень улучшения
		local lvlLabel = Instance.new("TextLabel")
		lvlLabel.Size = UDim2.new(0, 200, 0, 18)
		lvlLabel.Position = UDim2.new(0, 72, 0, 30)
		lvlLabel.BackgroundTransparency = 1
		lvlLabel.Font = Theme.Fonts.Body
		lvlLabel.TextSize = 11
		lvlLabel.TextColor3 = Theme.Colors.TextSecondary
		lvlLabel.TextXAlignment = Enum.TextXAlignment.Left
		lvlLabel.Text = "Lvl 1"
		lvlLabel.Parent = rowFrame

		-- Прогресс-бар
		local pBar = ProgressBar.create({
			Size = UDim2.new(0, 120, 0, 8),
			Position = UDim2.new(0, 72, 0, 52),
			FillColor = iconData.Color, -- Индивидуальный цвет полоски прогресса
			Parent = rowFrame
		})

		upgradeItems[upgradeType] = {
			Frame = rowFrame,
			LevelLabel = lvlLabel,
			ProgressBar = pBar,
			BuyButton = nil
		}
	end

	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #upgradesList * 82)

	player:GetAttributeChangedSignal("Money"):Connect(updateAllRows)
	for _, upType in ipairs(upgradesList) do
		player:GetAttributeChangedSignal(upType .. "Lvl"):Connect(function()
			updateUpgradeRow(upType)
		end)
	end

	updateAllRows()
end

-- Автозапуск инициализации
ShopWindow.init()

return ShopWindow
