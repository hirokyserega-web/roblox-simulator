-- Окно Инвентаря призраков (InventoryWindow)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GhostConfig = require(ReplicatedStorage.Shared.config.GhostConfig)
local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local Panel = require(script.Parent.Parent.components.Panel)
local ItemCard = require(script.Parent.Parent.components.ItemCard)
local UIManager = _G.UIManager

local player = Players.LocalPlayer
local requestSellEvent = Remotes.getEvent("RequestSell")
local inventoryUpdateEvent = Remotes.getEvent("InventoryUpdate")

local InventoryWindow = {}
local inventoryPanel = nil
local scrollFrame = nil
local valueLabel = nil
local sellButtonComponent = nil
local lastInventory = {}

-- Функция для определения редкости экипированного призрака
local function getEquippedGhostRarity()
	local char = player.Character
	if char then
		for _, child in ipairs(char:GetChildren()) do
			if child:IsA("Tool") and child:GetAttribute("IsGhost") then
				return child:GetAttribute("Rarity")
			end
		end
	end
	return nil
end

local function renderInventoryUI()
	if not scrollFrame then return end

	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

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

	-- Получаем текущий надетый тип призрака
	local equippedRarity = getEquippedGhostRarity()

	for rarity, count in pairs(counts) do
		local conf = GhostConfig[rarity]
		if not conf then continue end

		local cardWrapper = Instance.new("Frame")
		cardWrapper.Size = UDim2.new(0, 90, 0, 105)
		cardWrapper.BackgroundTransparency = 1
		cardWrapper.Parent = scrollFrame

		local isCurrentlyEquipped = (equippedRarity == rarity)

		local card = ItemCard.create({
			Title = rarity:upper(),
			Rarity = rarity,
			IconColor = conf.Color,
			Subtext = string.format("Кол-во: x%d", count),
			Equipped = isCurrentlyEquipped, -- Передаем статус экипировки в карточку
			Parent = cardWrapper,
			OnClick = function()
				local char = player.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if not hum then return end

				if isCurrentlyEquipped then
					-- Снимаем призрака (убираем инструмент)
					hum:UnequipTools()
				else
					-- Ищем инструмент этого призрака в рюкзаке
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
							-- Сначала убираем другие инструменты
							hum:UnequipTools()
							-- Экипируем призрака
							hum:EquipTool(tool)
						end
					end
				end
				-- Мгновенно перерисовываем UI для обновления подсветки карточек
				renderInventoryUI()
			end
		})
	end

	local totalItems = 0
	for _, _ in pairs(counts) do totalItems = totalItems + 1 end
	local rows = math.ceil(totalItems / 3)
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, rows * 115)
end

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

function InventoryWindow.init()
	local screenGui = UIManager.getScreenGui()

	inventoryPanel = Panel.create({
		Title = "РЮКЗАК ИНВЕНТАРЯ",
		Size = UDim2.new(0, 380, 0, 350),
		Position = UDim2.new(0.5, -190, 0.5, -175),
		Parent = screenGui,
		OnClose = function()
			inventoryPanel.Close()
		end
	})

	-- Переопределяем метод Open, чтобы обновлять UI и статус экипированных призраков при открытии
	local originalOpen = inventoryPanel.Open
	function inventoryPanel.Open()
		originalOpen()
		renderInventoryUI()
	end

	UIManager.registerWindow("Inventory", inventoryPanel)

	valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(1, -20, 0, 25)
	valueLabel.Position = UDim2.new(0, 10, 0, 10)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Font = Theme.Fonts.Bold
	valueLabel.TextSize = 13
	valueLabel.TextColor3 = Theme.Colors.Success
	valueLabel.Text = "Общая ценность рюкзака: $0"
	valueLabel.Parent = inventoryPanel.Content

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

	inventoryUpdateEvent.OnClientEvent:Connect(function(inventory)
		lastInventory = inventory
		renderInventoryUI()
	end)

	-- Динамическое обновление UI при экипировке/разэкипировке через внешние события или хотбар
	local charConnection = nil
	local function setupCharacterListeners(char)
		if charConnection then charConnection:Disconnect() end
		charConnection = char.ChildAdded:Connect(function(child)
			if child:IsA("Tool") and child:GetAttribute("IsGhost") then
				task.defer(renderInventoryUI)
			end
		end)
		
		char.ChildRemoved:Connect(function(child)
			if child:IsA("Tool") and child:GetAttribute("IsGhost") then
				task.defer(renderInventoryUI)
			end
		end)
	end

	player.CharacterAdded:Connect(setupCharacterListeners)
	if player.Character then
		setupCharacterListeners(player.Character)
	end

	task.spawn(function()
		while true do
			checkSellZoneDistance()
			task.wait(1)
		end
	end)
end

InventoryWindow.init()

return InventoryWindow
