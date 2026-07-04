-- Сервис управления инвентарем (Bag) игрока на сервере
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local GhostConfig = require(ReplicatedStorage.Shared.config.GhostConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local InventoryService = {}
local inventories = {} -- Ключ: UserId, Значение: { Ghosts = { "Common", ... }, MaxCapacity = X }

function InventoryService.setupPlayer(player: Player, initialGhosts)
	inventories[player.UserId] = {
		Ghosts = initialGhosts or {},
		MaxCapacity = GameConfig.DefaultBagCapacity
	}
end

function InventoryService.removePlayer(player: Player)
	inventories[player.UserId] = nil
end

function InventoryService.getInventory(player: Player)
	return inventories[player.UserId]
end

function InventoryService.canAddGhost(player: Player): boolean
	local inv = inventories[player.UserId]
	if not inv then return false end
	return #inv.Ghosts < inv.MaxCapacity
end

function InventoryService.addGhost(player: Player, rarity: string)
	local inv = inventories[player.UserId]
	if not inv then return end

	if #inv.Ghosts < inv.MaxCapacity then
		table.insert(inv.Ghosts, rarity)
		
		-- Синхронизируем с клиентом
		Remotes.getEvent("InventoryUpdate"):FireClient(player, inv)
		return true
	end
	return false
end

function InventoryService.clearInventory(player: Player)
	local inv = inventories[player.UserId]
	if not inv then return {} end
	
	local caught = table.clone(inv.Ghosts)
	inv.Ghosts = {}
	
	-- Синхронизируем с клиентом
	Remotes.getEvent("InventoryUpdate"):FireClient(player, inv)
	return caught
end

-- Установить максимальную вместимость
function InventoryService.setMaxCapacity(player: Player, capacity: number)
	local inv = inventories[player.UserId]
	if not inv then
		inventories[player.UserId] = {
			Ghosts = {},
			MaxCapacity = capacity
		}
	else
		inv.MaxCapacity = capacity
	end
	
	-- Уведомляем клиента об изменении лимита
	Remotes.getEvent("InventoryUpdate"):FireClient(player, inventories[player.UserId])
end

-- Регистрация RemoteFunction для получения данных клиентом
Remotes.getFunction("GetInventoryData").OnServerInvoke = function(player)
	return InventoryService.getInventory(player)
end

return InventoryService
