-- Модуль для управления игровым состоянием игрока (серверный авторитет)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)

local PlayerStateManager = {}

-- Инициализация состояния и лидерборда игрока
function PlayerStateManager.setupPlayer(player: Player)
	-- 1. Лидерборд для отображения в стандартной таблице игроков
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = GameConfig.InitialStats.Money
	money.Parent = leaderstats

	local crystals = Instance.new("IntValue")
	crystals.Name = "Crystals"
	crystals.Value = GameConfig.InitialStats.Crystals
	crystals.Parent = leaderstats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = GameConfig.InitialStats.Rebirths
	rebirths.Parent = leaderstats

	-- 2. Локальные атрибуты игрока для инвентаря/рюкзака (реплицируются автоматически)
	player:SetAttribute("GhostsCount", 0)
	player:SetAttribute("BackpackValue", 0)
	player:SetAttribute("MaxCapacity", GameConfig.InitialStats.MaxCapacity)

	print("Состояние игрока успешно инициализировано для: " .. player.Name)
end

-- Получить значение характеристики (Money, Crystals, Rebirths)
function PlayerStateManager.getStat(player: Player, statName: string): number
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local statValue = leaderstats:FindFirstChild(statName)
		if statValue then
			return statValue.Value
		end
	end
	return 0
end

-- Установить значение характеристики
function PlayerStateManager.setStat(player: Player, statName: string, value: number)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local statValue = leaderstats:FindFirstChild(statName)
		if statValue then
			statValue.Value = value
		end
	end
end

-- Добавить к характеристике
function PlayerStateManager.addStat(player: Player, statName: string, amount: number)
	local current = PlayerStateManager.getStat(player, statName)
	PlayerStateManager.setStat(player, statName, current + amount)
end

-- Добавить привидение в рюкзак (возвращает true при успехе, false если рюкзак полон)
function PlayerStateManager.addGhost(player: Player, amount: number, value: number): boolean
	local currentGhosts = player:GetAttribute("GhostsCount") or 0
	local maxCapacity = player:GetAttribute("MaxCapacity") or GameConfig.InitialStats.MaxCapacity
	
	if currentGhosts + amount <= maxCapacity then
		player:SetAttribute("GhostsCount", currentGhosts + amount)
		local currentValue = player:GetAttribute("BackpackValue") or 0
		player:SetAttribute("BackpackValue", currentValue + (value * amount))
		return true
	end
	
	return false
end

-- Очистить рюкзак и вернуть (количество привидений, общая стоимость при продаже)
function PlayerStateManager.clearGhosts(player: Player): (number, number)
	local currentGhosts = player:GetAttribute("GhostsCount") or 0
	local currentValue = player:GetAttribute("BackpackValue") or 0
	
	player:SetAttribute("GhostsCount", 0)
	player:SetAttribute("BackpackValue", 0)
	
	return currentGhosts, currentValue
end

-- Рассчитать стоимость следующего ребитха
function PlayerStateManager.getRebirthCost(player: Player): number
	local currentRebirths = PlayerStateManager.getStat(player, "Rebirths")
	-- Стоимость растет по экспоненте: BaseCost * (CostMultiplier ^ currentRebirths)
	return math.floor(GameConfig.Rebirth.BaseCost * math.pow(GameConfig.Rebirth.CostMultiplier, currentRebirths))
end

-- Рассчитать награду в кристаллах за следующий ребитх
function PlayerStateManager.getRebirthCrystalsReward(player: Player): number
	local currentRebirths = PlayerStateManager.getStat(player, "Rebirths")
	return math.floor(GameConfig.Rebirth.CrystalsRewardBase * math.pow(GameConfig.Rebirth.CrystalsMultiplier, currentRebirths))
end

return PlayerStateManager
