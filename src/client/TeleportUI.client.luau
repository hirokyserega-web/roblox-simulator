-- Клиентский UI Телепортации по локациям (Teleport UI)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocationConfig = require(ReplicatedStorage.Shared.config.LocationConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

-- Подгрузка темы и компонентов UI Kit
local Theme = require(script.Parent.ui.theme.Theme)
local Button = require(script.Parent.ui.components.Button)
local Panel = require(script.Parent.ui.components.Panel)
local UIManager = require(script.Parent.ui.UIManager)

local player = Players.LocalPlayer
local teleportRequest = Remotes.getEvent("TeleportRequest")
local buyZoneRequest = Remotes.getEvent("BuyZoneRequest")

local teleportPanel = nil
local scrollingFrame = nil
local zoneRows = {}

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

-- Обновление строки конкретной локации
local function updateZoneRow(zoneId: string)
	local row = zoneRows[zoneId]
	if not row then return end

	local config = LocationConfig[zoneId]
	local isUnlocked = (zoneId == "StarterArea") or (player:GetAttribute("Unlocked_" .. zoneId) == true)
	local currentMoney = player:GetAttribute("Money") or 0

	-- Очищаем старую кнопку действия
	if row.ActionButton then
		row.ActionButton.Destroy()
		row.ActionButton = nil
	end

	if isUnlocked then
		row.StatusLabel.Text = "РАЗБЛОКИРОВАНО"
		row.StatusLabel.TextColor3 = Theme.Colors.Success

		row.ActionButton = Button.create({
			Text = "ТЕЛЕПОРТ",
			Color = Theme.Colors.Success,
			Size = UDim2.new(0, 100, 0, 36),
			Position = UDim2.new(1, -110, 0.5, -18),
			Parent = row.Frame,
			OnClick = function()
				teleportRequest:FireServer(zoneId)
				teleportPanel.Close()
			end
		})
	else
		local cost = config.Cost
		row.StatusLabel.Text = string.format("Цена: $%s", formatNumber(cost))
		row.StatusLabel.TextColor3 = Theme.Colors.Warning

		local canAfford = currentMoney >= cost

		row.ActionButton = Button.create({
			Text = "КУПИТЬ",
			Color = canAfford and Theme.Colors.Accent or Theme.Colors.Error,
			Size = UDim2.new(0, 100, 0, 36),
			Position = UDim2.new(1, -110, 0.5, -18),
			Parent = row.Frame,
			OnClick = function()
				if canAfford then
					buyZoneRequest:FireServer(zoneId)
				else
					UIManager.ShowToast("Не хватает монет для покупки этой зоны!", "Error")
				end
			end
		})
	end
end

-- Обновление всех строк при изменении баланса/статуса
local function updateAllZones()
	for zoneId, _ in pairs(LocationConfig) do
		updateZoneRow(zoneId)
	end
end

-- Инициализация UI
local function init()
	local screenGui = UIManager.getScreenGui()

	-- Создаем премиум-панель телепортов
	teleportPanel = Panel.create({
		Title = "ТЕЛЕПОРТАЦИЯ",
		Size = UDim2.new(0, 380, 0, 300),
		Position = UDim2.new(0.5, -190, 0.5, -150),
		Parent = screenGui,
		OnClose = function()
			teleportPanel.Close()
		end
	})

	UIManager.registerWindow("Teleport", teleportPanel)

	-- Скролл для локаций
	scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Size = UDim2.new(1, 0, 1, -10)
	scrollingFrame.Position = UDim2.new(0, 0, 0, 5)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.ScrollBarThickness = 6
	scrollingFrame.Parent = teleportPanel.Content

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Parent = scrollingFrame

	-- Сортируем локации по цене
	local sortedZones = {}
	for zoneId, config in pairs(LocationConfig) do
		table.insert(sortedZones, { Id = zoneId, Cost = config.Cost, Name = config.DisplayName })
	end
	table.sort(sortedZones, function(a, b) return a.Cost < b.Cost end)

	for _, item in ipairs(sortedZones) do
		local zoneId = item.Id

		local rowFrame = Instance.new("Frame")
		rowFrame.Name = "Row_" .. zoneId
		rowFrame.Size = UDim2.new(1, -12, 0, 56)
		rowFrame.BackgroundColor3 = Theme.Colors.BackgroundSecondary
		rowFrame.BorderSizePixel = 0
		rowFrame.Parent = scrollingFrame

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = Theme.Sizes.CornerRadius
		rowCorner.Parent = rowFrame

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1
		stroke.Color = Theme.Colors.Stroke
		stroke.Parent = rowFrame

		-- Название зоны
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0, 160, 0, 22)
		nameLabel.Position = UDim2.new(0, 12, 0, 6)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Theme.Fonts.Title
		nameLabel.TextSize = 13
		nameLabel.TextColor3 = Theme.Colors.Text
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Text = item.Name
		nameLabel.Parent = rowFrame

		-- Статус / Цена
		local statusLabel = Instance.new("TextLabel")
		statusLabel.Size = UDim2.new(0, 160, 0, 20)
		statusLabel.Position = UDim2.new(0, 12, 1, -24)
		statusLabel.BackgroundTransparency = 1
		statusLabel.Font = Theme.Fonts.Body
		statusLabel.TextSize = 11
		statusLabel.TextXAlignment = Enum.TextXAlignment.Left
		statusLabel.Parent = rowFrame

		zoneRows[zoneId] = {
			Frame = rowFrame,
			StatusLabel = statusLabel,
			ActionButton = nil
		}
	end

	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #sortedZones * 66)

	-- Слушаем обновления денег и параметров разблокировки
	player:GetAttributeChangedSignal("Money"):Connect(updateAllZones)
	for zoneId, _ in pairs(LocationConfig) do
		player:GetAttributeChangedSignal("Unlocked_" .. zoneId):Connect(function()
			updateZoneRow(zoneId)
		end)
	end

	updateAllZones()
end

init()
print("[TELEPORT UI] Интерфейс телепортов успешно загружен!")
