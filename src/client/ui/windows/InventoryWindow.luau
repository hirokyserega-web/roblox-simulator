-- Современное окно Инвентаря (InventoryWindow) с предпросмотром
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GhostConfig = require(ReplicatedStorage.Shared.config.GhostConfig)
local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local ItemCard = require(script.Parent.Parent.components.ItemCard)
local Panel = require(script.Parent.Parent.components.Panel)

local InventoryWindow = {}
local player = Players.LocalPlayer
local windowFrame = nil
local gridFrame = nil
local detailsPanel = nil
local capacityLabel = nil
local capacityFill = nil

local selectedRarity = nil

-- Функция создания 3D превью
local function createPreview(rarity, parent)
	local conf = GhostConfig[rarity]
	if not conf then return end
	
	local viewport = Instance.new("ViewportFrame")
	viewport.Size = UDim2.new(1, 0, 1, 0)
	viewport.BackgroundTransparency = 1
	viewport.Parent = parent
	
	local camera = Instance.new("Camera")
	camera.FieldOfView = 30
	viewport.CurrentCamera = camera
	camera.Parent = viewport
	
	local ghostModel = Instance.new("Part")
	ghostModel.Shape = Enum.PartType.Ball
	ghostModel.Size = Vector3.new(2, 2, 2)
	ghostModel.Color = conf.Color
	ghostModel.Material = Enum.Material.Neon
	ghostModel.Transparency = 0.2
	ghostModel.Position = Vector3.new(0, 0, 0)
	ghostModel.Parent = viewport
	
	camera.CFrame = CFrame.new(Vector3.new(0, 0, 8), ghostModel.Position)
	
	-- Анимация вращения
	task.spawn(function()
		while viewport.Parent == parent do
			ghostModel.CFrame = ghostModel.CFrame * CFrame.Angles(0, math.rad(2), 0)
			task.wait()
		end
	end)
end

-- Обновление панели деталей
local function updateDetails(rarity)
	selectedRarity = rarity
	detailsPanel:ClearAllChildren()
	
	if not rarity then
		local placeholder = Instance.new("TextLabel")
		placeholder.Size = UDim2.new(1, 0, 1, 0)
		placeholder.BackgroundTransparency = 1
		placeholder.Text = "Выберите призрака"
		placeholder.TextColor3 = Theme.Colors.TextSecondary
		placeholder.Font = Enum.Font.GothamMedium
		placeholder.TextSize = 18
		placeholder.Parent = detailsPanel
		return
	end
	
	local conf = GhostConfig[rarity]
	
	-- Контейнер превью
	local previewContainer = Instance.new("Frame")
	previewContainer.Size = UDim2.new(0.8, 0, 0.4, 0)
	previewContainer.Position = UDim2.new(0.1, 0, 0.05, 0)
	previewContainer.BackgroundColor3 = Color3.new(0, 0, 0)
	previewContainer.BackgroundTransparency = 0.5
	previewContainer.Parent = detailsPanel
	
	local uiCorner = Instance.new("UICorner")
	uiCorner.Parent = previewContainer
	
	createPreview(rarity, previewContainer)
	
	-- Инфо
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.1, 0)
	nameLabel.Position = UDim2.new(0, 0, 0.5, 0)
	nameLabel.Text = conf.Name:upper()
	nameLabel.TextColor3 = Theme.Colors.Text
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 22
	nameLabel.BackgroundTransparency = 1
	nameLabel.Parent = detailsPanel
	
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.new(1, 0, 0.05, 0)
	rarityLabel.Position = UDim2.new(0, 0, 0.6, 0)
	rarityLabel.Text = rarity
	rarityLabel.TextColor3 = Theme.RarityColors[rarity] or Color3.new(1, 1, 1)
	rarityLabel.Font = Enum.Font.GothamMedium
	rarityLabel.TextSize = 16
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Parent = detailsPanel
	
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(1, 0, 0.05, 0)
	priceLabel.Position = UDim2.new(0, 0, 0.7, 0)
	priceLabel.Text = "Цена: 💵 " .. conf.BasePrice
	priceLabel.TextColor3 = Theme.Colors.Green
	priceLabel.Font = Enum.Font.GothamBold
	priceLabel.TextSize = 18
	priceLabel.BackgroundTransparency = 1
	priceLabel.Parent = detailsPanel

	-- Кнопка экипировки
	local hum = player.Character and player.Character:FindFirstChild("Humanoid")
	local isEquipped = false
	if hum then
		for _, tool in ipairs(player.Character:GetChildren()) do
			if tool:IsA("Tool") and tool:GetAttribute("IsGhost") and tool:GetAttribute("Rarity") == rarity then
				isEquipped = true
				break
			end
		end
	end

	local equipBtn = Button.create({
		Text = isEquipped and "УБРАТЬ" or "ВЗЯТЬ В РУКИ",
		Color = isEquipped and Theme.Colors.Red or Theme.Colors.Green,
		Position = UDim2.new(0.1, 0, 0.85, 0),
		Size = UDim2.new(0.8, 0, 0.1, 0),
		Parent = detailsPanel,
		OnClick = function()
			if not hum then return end
			if isEquipped then
				hum:UnequipTools()
			else
				local backpack = player:FindFirstChild("Backpack")
				if backpack then
					local tool = nil
					for _, child in ipairs(backpack:GetChildren()) do
						if child:IsA("Tool") and child:GetAttribute("IsGhost") and child:GetAttribute("Rarity") == rarity then
							tool = child
							break
						end
					end
					if tool then
						hum:UnequipTools()
						hum:EquipTool(tool)
					end
				end
			end
			updateDetails(rarity) -- Обновить кнопку
		end
	})
end

-- Основная функция обновления списка
local function refresh(data)
	gridFrame:ClearAllChildren()
	
	local uiGrid = Instance.new("UIGridLayout")
	uiGrid.CellSize = UDim2.new(0, 90, 0, 110)
	uiGrid.CellPadding = UDim2.new(0, 10, 0, 10)
	uiGrid.SortOrder = Enum.SortOrder.LayoutOrder
	uiGrid.Parent = gridFrame
	
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 5)
	padding.PaddingLeft = UDim.new(0, 5)
	padding.Parent = gridFrame

	local counts = {}
	for _, rarity in ipairs(data.Ghosts) do
		counts[rarity] = (counts[rarity] or 0) + 1
	end

	local hum = player.Character and player.Character:FindFirstChild("Humanoid")
	local equippedRarity = nil
	if hum then
		for _, tool in ipairs(player.Character:GetChildren()) do
			if tool:IsA("Tool") and tool:GetAttribute("IsGhost") then
				equippedRarity = tool:GetAttribute("Rarity")
				break
			end
		end
	end

	local rarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Divine"}
	for _, rarity in ipairs(rarities) do
		local count = counts[rarity]
		if count and count > 0 then
			local conf = GhostConfig[rarity]
			local card = ItemCard.create({
				Title = rarity:upper(),
				Rarity = rarity,
				IconColor = conf.Color,
				Subtext = "x" .. count,
				Equipped = (equippedRarity == rarity),
				Parent = gridFrame,
				OnClick = function()
					updateDetails(rarity)
				end
			})
		end
	end
	
	-- Обновление вместимости
	local current = #data.Ghosts
	local max = data.MaxCapacity
	capacityLabel.Text = string.format("ВМЕСТИМОСТЬ: %d / %d", current, max)
	capacityFill.Size = UDim2.new(math.clamp(current/max, 0, 1), 0, 1, 0)
	
	if not selectedRarity or not counts[selectedRarity] then
		updateDetails(nil)
	else
		updateDetails(selectedRarity)
	end
end

function InventoryWindow.create(options)
	local screen = options.Parent
	
	windowFrame = Panel.create({
		Title = "ИНВЕНТАРЬ ПРИЗРАКОВ",
		Size = UDim2.new(0, 600, 0, 450),
		Position = UDim2.new(0.5, -300, 0.5, -225),
		Parent = screen
	})
	
	-- Сетка слева
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "ItemsList"
	scroll.Size = UDim2.new(0.65, -20, 0.85, -40)
	scroll.Position = UDim2.new(0, 15, 0, 50)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = Theme.Colors.Accent
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = windowFrame
	gridFrame = scroll
	
	-- Панель деталей справа
	detailsPanel = Instance.new("Frame")
	detailsPanel.Name = "Details"
	detailsPanel.Size = UDim2.new(0.35, -20, 0.85, -40)
	detailsPanel.Position = UDim2.new(0.65, 5, 0, 50)
	detailsPanel.BackgroundColor3 = Theme.Colors.Panel
	detailsPanel.BackgroundTransparency = 0.5
	detailsPanel.Parent = windowFrame
	
	local uiCorner = Instance.new("UICorner")
	uiCorner.Parent = detailsPanel
	
	-- Вместимость снизу
	local capBar = Instance.new("Frame")
	capBar.Size = UDim2.new(0.95, 0, 0, 25)
	capBar.Position = UDim2.new(0.025, 0, 0.92, 0)
	capBar.BackgroundColor3 = Color3.new(0, 0, 0)
	capBar.BackgroundTransparency = 0.5
	capBar.Parent = windowFrame
	
	local capCorner = Instance.new("UICorner")
	capCorner.Parent = capBar
	
	capacityFill = Instance.new("Frame")
	capacityFill.Size = UDim2.new(0, 0, 1, 0)
	capacityFill.BackgroundColor3 = Theme.Colors.Accent
	capacityFill.Parent = capBar
	
	local fillCorner = Instance.new("UICorner")
	fillCorner.Parent = capacityFill
	
	capacityLabel = Instance.new("TextLabel")
	capacityLabel.Size = UDim2.new(1, 0, 1, 0)
	capacityLabel.BackgroundTransparency = 1
	capacityLabel.Text = "ВМЕСТИМОСТЬ: 0 / 0"
	capacityLabel.TextColor3 = Theme.Colors.Text
	capacityLabel.Font = Enum.Font.GothamBold
	capacityLabel.TextSize = 14
	capacityLabel.ZIndex = 2
	capacityLabel.Parent = capBar

	-- Слушаем обновления
	Remotes.getEvent("InventoryUpdate").OnClientEvent:Connect(refresh)
	
	-- Запрос начальных данных
	task.spawn(function()
		local data = Remotes.getFunction("GetInventoryData"):InvokeServer()
		if data then refresh(data) end
	end)
	
	windowFrame.Visible = false
	
	local window = {
		Frame = windowFrame,
		Open = function()
			windowFrame.Visible = true
			windowFrame.GroupTransparency = 1
			TweenService:Create(windowFrame, TweenInfo.new(0.3), {GroupTransparency = 0}):Play()
		end,
		Close = function()
			local tween = TweenService:Create(windowFrame, TweenInfo.new(0.2), {GroupTransparency = 1})
			tween:Play()
			tween.Completed:Connect(function() windowFrame.Visible = false end)
		end
	}
	
	return window
end

return InventoryWindow
