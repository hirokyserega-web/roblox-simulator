-- Сервис управления инвентарем (Bag) игрока на сервере
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local GhostConfig = require(ReplicatedStorage.Shared.config.GhostConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local InventoryService = {}
local inventories = {} -- Ключ: UserId, Значение: { Ghosts = { "Common", ... }, MaxCapacity = X }

-- Создать физический инструмент призрака
local function createGhostTool(player, rarity)
	local conf = GhostConfig[rarity]
	if not conf then return end
	
	local tool = Instance.new("Tool")
	tool.Name = conf.Name
	tool.ToolTip = "Редкость: " .. rarity
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	
	-- Атрибуты для идентификации
	tool:SetAttribute("IsGhost", true)
	tool:SetAttribute("Rarity", rarity)
	
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(1.2, 1.2, 1.2)
	handle.Shape = Enum.PartType.Ball
	handle.Color = conf.Color or Color3.new(1, 1, 1)
	handle.Material = Enum.Material.Neon
	handle.Transparency = 0.3
	handle.Parent = tool
	
	-- Эффект свечения
	local attachment = Instance.new("Attachment")
	attachment.Parent = handle
	
	local particles = Instance.new("ParticleEmitter")
	particles.Color = ColorSequence.new(handle.Color)
	particles.Size = NumberSequence.new(0.5, 0)
	particles.Transparency = NumberSequence.new(0.5, 1)
	particles.Lifetime = NumberRange.new(0.5, 1)
	particles.Rate = 20
	particles.Speed = NumberRange.new(1, 2)
	particles.Parent = handle
	
	tool.Parent = player.Backpack
	return tool
end

-- Настройка при входе
function InventoryService.setupPlayer(player: Player, loadedGhosts: {string}?)
	local userId = player.UserId
	inventories[userId] = {
		Ghosts = loadedGhosts or {},
		MaxCapacity = player:GetAttribute("BagCapacity") or GameConfig.DefaultBagCapacity or 10
	}
	
	-- Создаем инструменты для загруженных призраков
	for _, rarity in ipairs(inventories[userId].Ghosts) do
		createGhostTool(player, rarity)
	end
	
	Remotes.getEvent("InventoryUpdate"):FireClient(player, inventories[userId])
end

-- Получение данных для сохранения
function InventoryService.getSaveData(player: Player)
	local inv = inventories[player.UserId]
	return inv and inv.Ghosts or {}
end

-- Добавить призрака
function InventoryService.addGhost(player: Player, rarity: string): boolean
	local userId = player.UserId
	local inv = inventories[userId]
	if not inv then return false end
	
	if #inv.Ghosts >= inv.MaxCapacity then
		return false
	end
	
	table.insert(inv.Ghosts, rarity)
	createGhostTool(player, rarity)
	
	Remotes.getEvent("InventoryUpdate"):FireClient(player, inv)
	return true
end

-- Очистить инвентарь (продажа)
function InventoryService.clearInventory(player: Player)
	local userId = player.UserId
	local inv = inventories[userId]
	if not inv then return end
	
	inv.Ghosts = {}
	
	-- Удаляем инструменты
	for _, child in ipairs(player.Backpack:GetChildren()) do
		if child:IsA("Tool") and child:GetAttribute("IsGhost") then
			child:Destroy()
		end
	end
	local char = player.Character
	if char then
		for _, child in ipairs(char:GetChildren()) do
			if child:IsA("Tool") and child:GetAttribute("IsGhost") then
				child:Destroy()
			end
		end
	end
	
	Remotes.getEvent("InventoryUpdate"):FireClient(player, inv)
end

-- Получить текущий инвентарь
function InventoryService.getInventory(player: Player)
	return inventories[player.UserId]
end


-- Регистрация RemoteFunction для получения данных клиентом
Remotes.getFunction("GetInventoryData").OnServerInvoke = function(player)
	return InventoryService.getInventory(player)
end

return InventoryService

