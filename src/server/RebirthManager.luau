-- Менеджер перерождений (Rebirths): обработка запросов, валидация и начисление наград
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local NetworkEvents = require(ReplicatedStorage.Shared.NetworkEvents)
local PlayerStateManager = require(script.Parent.PlayerStateManager)

local RebirthManager = {}

-- Инициализация менеджера ребитхов
function RebirthManager.init()
	local rebirthEvent = NetworkEvents.getEvent("RequestRebirth")
	rebirthEvent.OnServerEvent:Connect(RebirthManager.onRebirthRequest)
	
	print("Менеджер перерождений успешно запущен!")
end

-- Обработка запроса игрока на ребитх
function RebirthManager.onRebirthRequest(player: Player)
	local currentMoney = PlayerStateManager.getStat(player, "Money")
	local cost = PlayerStateManager.getRebirthCost(player)
	
	if currentMoney >= cost then
		-- Считаем награду в кристаллах
		local crystalsReward = PlayerStateManager.getRebirthCrystalsReward(player)
		
		-- Выполняем перерождение (СБРОС прогресса):
		-- 1. Сбрасываем деньги в 0 (стандарт для симуляторов)
		PlayerStateManager.setStat(player, "Money", 0)
		
		-- 2. Очищаем рюкзак
		PlayerStateManager.clearGhosts(player)
		
		-- 3. Увеличиваем количество ребитхов
		PlayerStateManager.addStat(player, "Rebirths", 1)
		
		-- 4. Начисляем кристаллы
		PlayerStateManager.addStat(player, "Crystals", crystalsReward)
		
		print(string.format("Игрок %s совершил перерождение! Списано: %d монет, Получено Кристаллов: %d", player.Name, cost, crystalsReward))
	else
		warn(string.format("Игрок %s пытался совершить ребитх без достаточного количества монет (Имеет: %d, Нужно: %d)", player.Name, currentMoney, cost))
	end
end

return RebirthManager
