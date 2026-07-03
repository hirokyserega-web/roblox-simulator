-- Клиентский UI Перерождений (Rebirth UI)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local RebirthConfig = require(ReplicatedStorage.Shared.config.RebirthConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

-- Подгрузка темы и компонентов UI Kit
local Theme = require(script.Parent.ui.theme.Theme)
local Button = require(script.Parent.ui.components.Button)
local Panel = require(script.Parent.ui.components.Panel)
local UIManager = require(script.Parent.ui.UIManager)

local player = Players.LocalPlayer
local requestRebirthEvent = Remotes.getEvent("RequestRebirth")

local rebirthPanel = nil
local rebirthsLabel = nil
local multiplierLabel = nil
local costLabel = nil
local actionButton = nil

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

-- Обновление данных о перерождении
local function updateRebirthUI()
	if not rebirthPanel then return end

	local rebirths = player:GetAttribute("Rebirths") or 0
	local money = player:GetAttribute("Money") or 0

	local cost = RebirthConfig.getCost(rebirths)
	local multiplier = 1.0 + (rebirths * RebirthConfig.MultiplierPerRebirth)

	rebirthsLabel.Text = string.format("Текущие перерождения: %d", rebirths)
	multiplierLabel.Text = string.format("Множитель монет: x%.1f", multiplier)
	costLabel.Text = string.format("Цена следующего перерождения: $%s", formatNumber(cost))

	-- Обновляем кнопку действия
	if actionButton then
		actionButton.Destroy()
		actionButton = nil
	end

	local canAfford = money >= cost

	actionButton = Button.create({
		Text = "ПЕРЕРОДИТЬСЯ",
		Color = canAfford and Theme.Colors.Success or Theme.Colors.Error,
		Size = UDim2.new(0, 200, 0, 44),
		Position = UDim2.new(0.5, -100, 1, -55),
		Parent = rebirthPanel.Content,
		OnClick = function()
			if canAfford then
				requestRebirthEvent:FireServer()
			else
				UIManager.ShowToast(string.format("Не хватает монет для перерождения! Нужно: $%s", formatNumber(cost)), "Error")
			end
		end
	})
end

-- Инициализация UI
local function init()
	local screenGui = UIManager.getScreenGui()

	-- Создаем премиум-панель
	rebirthPanel = Panel.create({
		Title = "ПЕРЕРОЖДЕНИЕ",
		Size = UDim2.new(0, 360, 0, 270),
		Position = UDim2.new(0.5, -180, 0.5, -135),
		Parent = screenGui,
		OnClose = function()
			rebirthPanel.Close()
		end
	})

	-- Регистрируем в менеджере
	UIManager.registerWindow("Rebirth", rebirthPanel)

	-- Пояснительный текст
	local desc = Instance.new("TextLabel")
	desc.Name = "DescLabel"
	desc.Size = UDim2.new(1, -40, 0, 45)
	desc.Position = UDim2.new(0, 20, 0, 10)
	desc.BackgroundTransparency = 1
	desc.Font = Theme.Fonts.Body
	desc.TextSize = 13
	desc.TextColor3 = Theme.Colors.TextSecondary
	desc.TextWrapped = true
	desc.Text = "Сбрасывает ваши монеты, локации и уровни улучшений в обмен на постоянный множитель монет!"
	desc.Parent = rebirthPanel.Content

	-- Статистика: текущие ребирхи
	rebirthsLabel = Instance.new("TextLabel")
	rebirthsLabel.Name = "RebirthsLabel"
	rebirthsLabel.Size = UDim2.new(1, -40, 0, 25)
	rebirthsLabel.Position = UDim2.new(0, 20, 0, 65)
	rebirthsLabel.BackgroundTransparency = 1
	rebirthsLabel.Font = Theme.Fonts.Title
	rebirthsLabel.TextSize = 15
	rebirthsLabel.TextColor3 = Theme.Colors.Text
	rebirthsLabel.Text = "Текущие перерождения: 0"
	rebirthsLabel.Parent = rebirthPanel.Content

	-- Множитель монет
	multiplierLabel = Instance.new("TextLabel")
	multiplierLabel.Name = "MultiplierLabel"
	multiplierLabel.Size = UDim2.new(1, -40, 0, 25)
	multiplierLabel.Position = UDim2.new(0, 20, 0, 90)
	multiplierLabel.BackgroundTransparency = 1
	multiplierLabel.Font = Theme.Fonts.Title
	multiplierLabel.TextSize = 15
	multiplierLabel.TextColor3 = Theme.Colors.Success
	multiplierLabel.Text = "Множитель монет: x1.0"
	multiplierLabel.Parent = rebirthPanel.Content

	-- Цена следующего
	costLabel = Instance.new("TextLabel")
	costLabel.Name = "CostLabel"
	costLabel.Size = UDim2.new(1, -40, 0, 25)
	costLabel.Position = UDim2.new(0, 20, 0, 115)
	costLabel.BackgroundTransparency = 1
	costLabel.Font = Theme.Fonts.Title
	costLabel.TextSize = 14
	costLabel.TextColor3 = Theme.Colors.Warning
	costLabel.Text = "Цена следующего перерождения: $10,000"
	costLabel.Parent = rebirthPanel.Content

	-- Слушаем изменения монет и ребирхов
	player:GetAttributeChangedSignal("Money"):Connect(updateRebirthUI)
	player:GetAttributeChangedSignal("Rebirths"):Connect(updateRebirthUI)

	updateRebirthUI()
end

init()
print("[REBIRTH UI] Интерфейс перерождений успешно загружен!")
