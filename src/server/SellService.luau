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

function SellService.init()
	local sellEvent = Remotes.getEvent("RequestSell")
	sellEvent.OnServerEvent:Connect(function(player)
		SellService.sellInventory(player)
	end)

	-- Create physical zone if not exists
	if not Workspace:FindFirstChild("BlackMarketZone") then
		local sellPart = Instance.new("Part")
		sellPart.Name = "BlackMarketZone"
		sellPart.Position = GameConfig.BlackMarketPosition or Vector3.new(30, 0, 30)
		sellPart.Size = GameConfig.BlackMarketSize or Vector3.new(15, 1, 15)
		sellPart.Anchored = true
		sellPart.CanCollide = false
		sellPart.Transparency = 0.5
		sellPart.Color = Color3.fromRGB(80, 0, 200)
		sellPart.Parent = Workspace
	end
	
	print("[SELL SERVICE] Сервис Черного Рынка успешно запущен!")
end

function SellService.sellInventory(player: Player)
	local inv = InventoryService.getInventory(player)
	if not inv or #inv.Ghosts == 0 then 
		Remotes.getEvent("ShowNotification"):FireClient(player, "Inventory is empty!")
		return 
	end

	local totalCash = 0
	local caught = InventoryService.clearInventory(player)

	for _, rarity in ipairs(caught) do
		local price = 10
		if GhostConfig[rarity] then
			price = GhostConfig[rarity].BasePrice
		end
		totalCash = totalCash + price
	end

	CurrencyService.add(player, "Money", totalCash)
	
	-- CRITICAL: Fire completion event
	Remotes.getEvent("SellCompleted"):FireClient(player, totalCash)
	Remotes.getEvent("ShowNotification"):FireClient(player, string.format("Sold for $%d!", totalCash))
end

return SellService
