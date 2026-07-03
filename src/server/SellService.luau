-- Сервис продажи привидений на Черном Рынке (Sell Zone)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local GhostConfig = require(ReplicatedStorage.Shared.config.GhostConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local InventoryService = require(ServerScriptService.Server.InventoryService)
local CurrencyService = require(ServerScriptService.Server.CurrencyService)

local SellService = {}
local blackMarketZone = nil
local proximityPrompt = nil

-- Инициализация черного рынка
function SellService.init()
	-- Создаем физическую плиту Черного рынка
	blackMarketZone = Workspace:FindFirstChild("BlackMarketZone")
	if not blackMarketZone then
		blackMarketZone = Instance.new("Part")
		blackMarketZone.Name = "BlackMarketZone"
		blackMarketZone.Position = GameConfig.BlackMarketPosition
		blackMarketZone.Size = GameConfig.BlackMarketSize
		blackMarketZone.Anchored = true
		blackMarketZone.CanCollide = false
		blackMarketZone.Transparency = 0.5
		blackMarketZone.Material = Enum.Material.Neon
		blackMarketZone.Color = Color3.fromRGB(30, 30, 35) -- Темный металлический цвет
		blackMarketZone.Parent = Workspace

		-- Визуальная рамка зоны продажи
		local selectionBox = Instance.new("SelectionBox")
		selectionBox.Adornee = blackMarketZone
		selectionBox.Color3 = Color3.fromRGB(46, 204, 113) -- Зеленая рамка
		selectionBox.LineThickness = 0.05
		selectionBox.Parent = blackMarketZone

		-- Название над зоной
		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 4, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = blackMarketZone
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = "BLACK MARKET"
		label.TextColor3 = Color3.fromRGB(46, 204, 113)
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.FredokaOne
		label.TextSize = 16
		label.Parent = billboard
	end

	-- Добавляем ProximityPrompt для взаимодействия
	proximityPrompt = blackMarketZone:FindFirstChildOfClass("ProximityPrompt")
	if not proximityPrompt then
		proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.ObjectText = "Черный рынок"
		proximityPrompt.ActionText = "Продать"
		proximityPrompt.KeyboardKeyCode = Enum.KeyCode.E
		proximityPrompt.MaxActivationDistance = 8
		proximityPrompt.Parent = blackMarketZone
	end

	-- Подключаем обработчик активации ProximityPrompt
	proximityPrompt.Triggered:Connect(SellService.onSellTriggered)

	-- Также слушаем сетевое событие (на случай вызова из интерфейса на клиенте)
	local requestSellEvent = Remotes.getEvent("RequestSell")
	requestSellEvent.OnServerEvent:Connect(SellService.onSellTriggered)

	print("[SELL SERVICE] Сервис Черного Рынка успешно запущен!")
end

-- Логика обработки продажи
function SellService.onSellTriggered(player: Player)
	local character = player.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- 1. Валидация дистанции до Черного рынка на сервере
	local distance = (rootPart.Position - blackMarketZone.Position).Magnitude
	if distance > GameConfig.SellDistance then
		warn(string.format("[SELL SERVICE] Игрок %s пытался продать вещи слишком далеко от рынка (Дистанция: %.1f)", player.Name, distance))
		return
	end

	-- 2. Очищаем инвентарь игрока и получаем пойманных призраков
	local caughtGhosts = InventoryService.clearInventory(player)
	
	if #caughtGhosts == 0 then
		-- Рюкзак пуст
		local notificationEvent = Remotes.getEvent("ShowNotification")
		notificationEvent:FireClient(player, "Ваш рюкзак пуст!")
		return
	end

	-- 3. Подсчитываем общую стоимость на основе GhostConfig
	local totalEarnings = 0
	for _, rarity in ipairs(caughtGhosts) do
		local ghostInfo = GhostConfig[rarity]
		if ghostInfo then
			totalEarnings = totalEarnings + ghostInfo.BasePrice
		end
	end

	-- Получаем и применяем множитель питомцев
	local PetService = require(ServerScriptService.Server.PetService)
	local multiplier = PetService.getMultiplier(player)
	local finalEarnings = math.floor(totalEarnings * multiplier)

	-- 4. Начисляем монеты
	if finalEarnings > 0 then
		CurrencyService.add(player, "Money", finalEarnings)
		
		-- Уведомляем клиента о успешной продаже
		local notificationEvent = Remotes.getEvent("ShowNotification")
		local msg = string.format("Продано призраков: %d. Получено: +%d Монет", #caughtGhosts, finalEarnings)
		if multiplier > 1.0 then
			msg = msg .. string.format(" (Множитель: x%.1f)", multiplier)
		end
		notificationEvent:FireClient(player, msg)
		
		-- Синхронизируем очищенный инвентарь с клиентом
		local inventoryUpdateEvent = Remotes.getEvent("InventoryUpdate")
		inventoryUpdateEvent:FireClient(player, InventoryService.getInventory(player))
		
		-- Визуальный эффект: рамка загорается зеленым при сделке
		local originalColor = blackMarketZone.Color
		blackMarketZone.Color = Color3.fromRGB(46, 204, 113)
		task.delay(0.5, function()
			blackMarketZone.Color = originalColor
		end)
	end
end

return SellService
