-- Сервис улучшения характеристик игрока на сервере
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local UpgradeConfig = require(ReplicatedStorage.Shared.config.UpgradeConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CurrencyService = require(ServerScriptService.Server.CurrencyService)
local InventoryService = require(ServerScriptService.Server.InventoryService)

local UpgradeService = {}
local playerUpgrades = {} -- Ключ: UserId, Значение: { BagCapacity = 1, WalkSpeed = 1, ... }

-- Применить эффект улучшения скорости бега к персонажу
local function applyWalkSpeed(player: Player, level: number)
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local speedValue = UpgradeConfig.WalkSpeed.Levels[level].Value
	humanoid.WalkSpeed = speedValue
end

-- Инициализация апгрейдов игрока при входе
function UpgradeService.setupPlayer(player: Player, loadedData: table?)
	local userId = player.UserId
	
	local bagLvl = 1
	local speedLvl = 1
	local detLvl = 1
	local capLvl = 1
	
	if loadedData and loadedData.Upgrades then
		local upg = loadedData.Upgrades
		if upg.BagCapacity then bagLvl = upg.BagCapacity end
		if upg.WalkSpeed then speedLvl = upg.WalkSpeed end
		if upg.DetectorRadius then detLvl = upg.DetectorRadius end
		if upg.CaptureSpeed then capLvl = upg.CaptureSpeed end
	end
	
	playerUpgrades[userId] = {
		BagCapacity = bagLvl,
		WalkSpeed = speedLvl,
		DetectorRadius = detLvl,
		CaptureSpeed = capLvl
	}

	-- Выставляем атрибуты уровней для клиента
	player:SetAttribute("BagCapacityLvl", bagLvl)
	player:SetAttribute("WalkSpeedLvl", speedLvl)
	player:SetAttribute("DetectorRadiusLvl", detLvl)
	player:SetAttribute("CaptureSpeedLvl", capLvl)

	-- Выставляем вместимость инвентаря
	local initialCapacity = UpgradeConfig.BagCapacity.Levels[bagLvl].Value
	InventoryService.setMaxCapacity(player, initialCapacity)

	-- Отслеживаем спавн персонажа для переприменения скорости бега
	player.CharacterAdded:Connect(function(character)
		-- Даем небольшую задержку, чтобы Roblox успел применить стандартные настройки персонажа
		task.wait(0.1)
		local upgrades = playerUpgrades[userId]
		if upgrades then
			applyWalkSpeed(player, upgrades.WalkSpeed)
		end
	end)

	-- Если персонаж уже загрузился
	if player.Character then
		applyWalkSpeed(player, speedLvl)
	end
end

-- Инициализация RemoteEvent и запуск сервиса
function UpgradeService.init()
	local buyUpgradeEvent = Remotes.getEvent("BuyUpgrade")
	buyUpgradeEvent.OnServerEvent:Connect(UpgradeService.onBuyUpgradeRequest)
	
	print("[UPGRADE SERVICE] Сервис улучшений успешно запущен!")
end

-- Обработка запроса на покупку апгрейда
function UpgradeService.onBuyUpgradeRequest(player: Player, upgradeType: string)
	local userId = player.UserId
	local upgrades = playerUpgrades[userId]
	
	if not upgrades then return end
	if upgrades[upgradeType] == nil then
		warn(string.format("[UPGRADE SERVICE] Неверный тип апгрейда от игрока %s: %s", player.Name, tostring(upgradeType)))
		return
	end

	local currentLevel = upgrades[upgradeType]
	local config = UpgradeConfig[upgradeType]
	
	-- Проверяем лимит уровня
	if currentLevel >= config.MaxLevel then
		local notificationEvent = Remotes.getEvent("ShowNotification")
		notificationEvent:FireClient(player, "Достигнут максимальный уровень улучшения!")
		return
	end

	-- Проверяем стоимость
	local nextLevel = currentLevel + 1
	local cost = config.Levels[nextLevel].Cost
	
	-- Списываем баланс
	local success = CurrencyService.spend(player, "Money", cost)
	if success then
		-- Повышаем уровень
		upgrades[upgradeType] = nextLevel
		player:SetAttribute(upgradeType .. "Lvl", nextLevel)

		-- Применяем эффекты апгрейда
		if upgradeType == "WalkSpeed" then
			applyWalkSpeed(player, nextLevel)
		elseif upgradeType == "BagCapacity" then
			local newCapacity = config.Levels[nextLevel].Value
			InventoryService.setMaxCapacity(player, newCapacity)
			
			-- Синхронизируем лимиты инвентаря с HUD клиента
			local inventoryUpdateEvent = Remotes.getEvent("InventoryUpdate")
			inventoryUpdateEvent:FireClient(player, InventoryService.getInventory(player))
		end

		print(string.format("[UPGRADE SERVICE] Игрок %s улучшил %s до Lvl %d. Списано: %d Монет", player.Name, upgradeType, nextLevel, cost))
		
		-- Уведомление на клиенте
		local notificationEvent = Remotes.getEvent("ShowNotification")
		notificationEvent:FireClient(player, string.format("Улучшено: %s до Ур. %d!", config.DisplayName, nextLevel))
	else
		-- Уведомление о нехватке денег
		local notificationEvent = Remotes.getEvent("ShowNotification")
		notificationEvent:FireClient(player, "Недостаточно монет для улучшения!")
	end
end

-- Очистка памяти при выходе игрока
function UpgradeService.removePlayer(player: Player)
	playerUpgrades[player.UserId] = nil
end

return UpgradeService
