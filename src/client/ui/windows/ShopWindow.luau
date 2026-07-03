-- Окно Магазина Улучшений (ShopWindow)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local UpgradeConfig = require(ReplicatedStorage.Shared.config.UpgradeConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local Panel = require(script.Parent.Parent.components.Panel)
local ProgressBar = require(script.Parent.Parent.components.ProgressBar)
local UIManager = require(script.Parent.Parent.UIManager)

local player = Players.LocalPlayer
local buyUpgradeEvent = Remotes.getEvent("BuyUpgrade")

local ShopWindow = {}
local shopPanel = nil
local scrollingFrame = nil
local upgradeItems = {}

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

	row.LevelLabel.Text = string.format("Ур. %d / %d", level, config.MaxLevel)
	row.ProgressBar.SetProgress(level / config.MaxLevel)

	if row.BuyButton then
		row.BuyButton.Destroy()
		row.BuyButton = nil
	end

	if level >= config.MaxLevel then
		row.BuyButton = Button.create({
			Text = "MAX",
			Color = Color3.fromHex("FF9F1C"),
			Size = UDim2.new(0, 90, 0, 36),
			Position = UDim2.new(1, -100, 0.5, -18),
			Parent = row.Frame,
			OnClick = function() end
		})
		row.BuyButton.SetEnabled(false)
	else
		local nextLevel = level + 1
		local cost = config.Levels[nextLevel].Cost
		local canAfford = currentMoney >= cost

		row.BuyButton = Button.create({
			Text = "$" .. formatNumber(cost),
			Color = canAfford and Theme.Colors.Success or Theme.Colors.Error,
			Size = UDim2.new(0, 90, 0, 36),
			Position = UDim2.new(1, -100, 0.5, -18),
			Parent = row.Frame,
			OnClick = function()
				if canAfford then
					buyUpgradeEvent:FireServer(upgradeType)
				else
					UIManager.ShowToast("Не хватает денег для улучшения!", "Error")
					-- Тряска при ошибке
					local origPos = UDim2.new(1, -100, 0.5, -18)
					local shakePos = UDim2.new(1, -95, 0.5, -18)
					task.spawn(function()
						TweenService:Create(row.BuyButton.Instance, TweenInfo.new(0.05), {Position = shakePos}):Play()
						task.wait(0.05)
						TweenService:Create(row.BuyButton.Instance, TweenInfo.new(0.05), {Position = origPos}):Play()
					end)
				end
			end
		})
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
		Title = "МАГАЗИН УЛУЧШЕНИЙ",
		Size = UDim2.new(0, 420, 0, 340),
		Position = UDim2.new(0.5, -210, 0.5, -170),
		Parent = screenGui,
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
	listLayout.Padding = UDim.new(0, 12)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Parent = scrollingFrame

	local upgradesList = { "WalkSpeed", "BagCapacity", "DetectorRadius", "CaptureSpeed" }

	for _, upgradeType in ipairs(upgradesList) do
		local config = UpgradeConfig[upgradeType]
		if not config then continue end

		local rowFrame = Instance.new("Frame")
		rowFrame.Name = "Row_" .. upgradeType
		rowFrame.Size = UDim2.new(1, -12, 0, 60)
		rowFrame.BackgroundColor3 = Theme.Colors.BackgroundSecondary
		rowFrame.BorderSizePixel = 0
		rowFrame.Parent = scrollingFrame

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = Theme.Sizes.CornerRadius
		rowCorner.Parent = rowFrame

		local rowStroke = Instance.new("UIStroke")
		rowStroke.Thickness = 1
		rowStroke.Color = Theme.Colors.Stroke
		rowStroke.Parent = rowFrame

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0, 180, 0, 25)
		nameLabel.Position = UDim2.new(0, 12, 0, 6)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Theme.Fonts.Title
		nameLabel.TextSize = 13
		nameLabel.TextColor3 = Theme.Colors.Text
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Text = config.DisplayName
		nameLabel.Parent = rowFrame

		local lvlLabel = Instance.new("TextLabel")
		lvlLabel.Size = UDim2.new(0, 180, 0, 20)
		lvlLabel.Position = UDim2.new(0, 12, 0, 32)
		lvlLabel.BackgroundTransparency = 1
		lvlLabel.Font = Theme.Fonts.Body
		lvlLabel.TextSize = 11
		lvlLabel.TextColor3 = Theme.Colors.TextSecondary
		lvlLabel.TextXAlignment = Enum.TextXAlignment.Left
		lvlLabel.Text = "Ур. 1"
		lvlLabel.Parent = rowFrame

		local pBar = ProgressBar.create({
			Size = UDim2.new(0, 100, 0, 8),
			Position = UDim2.new(0, 110, 0.5, 6),
			FillColor = Theme.Colors.Accent,
			Parent = rowFrame
		})

		upgradeItems[upgradeType] = {
			Frame = rowFrame,
			LevelLabel = lvlLabel,
			ProgressBar = pBar,
			BuyButton = nil
		}
	end

	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #upgradesList * 72)

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
