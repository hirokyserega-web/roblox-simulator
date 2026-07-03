-- Сервис управления инвентарем игрока на сервере (в оперативной памяти)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)

local InventoryService = {}
local inventories = {} -- Ключ: UserId, Значение: { Ghosts = { "Common", ... }, MaxCapacity = X }

-- Инициализировать или получить инвентарь игрока
function InventoryService.getInventory(player: Player)
	local userId = player.UserId
	if not inventories[userId] then
		inventories[userId] = {
			Ghosts = {},
			MaxCapacity = GameConfig.DefaultBagCapacity
		}
	end
	return inventories[userId]
end

-- Добавить призрака в инвентарь (возвращает true при успехе, false если рюкзак полон)
function InventoryService.addGhost(player: Player, rarity: string): boolean
	local inv = InventoryService.getInventory(player)
	if #inv.Ghosts < inv.MaxCapacity then
		table.insert(inv.Ghosts, rarity)
		return true
	end
	return false
end

-- Очистить рюкзак и вернуть список привидений
function InventoryService.clearInventory(player: Player): {string}
	local inv = InventoryService.getInventory(player)
	local clearedGhosts = inv.Ghosts
	inv.Ghosts = {}
	return clearedGhosts
end

-- Проверка, заполнен ли рюкзак
function InventoryService.isFull(player: Player): boolean
	local inv = InventoryService.getInventory(player)
	return #inv.Ghosts >= inv.MaxCapacity
end

-- Получить текущее количество привидений в рюкзаке
function InventoryService.getGhostsCount(player: Player): number
	local inv = InventoryService.getInventory(player)
	return #inv.Ghosts
end

-- Очистка памяти при выходе игрока
function InventoryService.removePlayer(player: Player)
	inventories[player.UserId] = nil
end

return InventoryService
