-- Сервис управления перерождениями игроков на сервере
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RebirthConfig = require(ReplicatedStorage.Shared.config.RebirthConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CurrencyService = require(ServerScriptService.Server.CurrencyService)
local UpgradeService = require(ServerScriptService.Server.UpgradeService)

local RebirthService = {}
local playerRebirths = {}

function RebirthService.init()
	local requestRebirthEvent = Remotes.getEvent("RequestRebirth")
	requestRebirthEvent.OnServerEvent:Connect(RebirthService.onRebirthRequest)
	
	print("[REBIRTH SERVICE] Сервис перерождений успешно запущен!")
end

function RebirthService.setupPlayer(player: Player, loadedRebirths: number?)
	local userId = player.UserId
	local rebirthCount = loadedRebirths or 0
	playerRebirths[userId] = rebirthCount
	player:SetAttribute("Rebirths", rebirthCount)

	local leaderstats = player:WaitForChild("leaderstats", 5)
	if leaderstats then
		local rebirthsValue = leaderstats:FindFirstChild("Rebirths") or Instance.new("IntValue")
		rebirthsValue.Name = "Rebirths"
		rebirthsValue.Value = rebirthCount
		rebirthsValue.Parent = leaderstats
	end
end

function RebirthService.onRebirthRequest(player: Player)
	local userId = player.UserId
	local currentRebirths = playerRebirths[userId] or 0
	
	local cost = RebirthConfig.getCost(currentRebirths)
	local currentMoney = CurrencyService.get(player, "Money")

	if currentMoney >= cost then
		CurrencyService.spend(player, "Money", currentMoney)

		local newRebirths = currentRebirths + 1
		playerRebirths[userId] = newRebirths
		player:SetAttribute("Rebirths", newRebirths)

		local leaderstats = player:FindFirstChild("leaderstats")
		local rebirthsValue = leaderstats and leaderstats:FindFirstChild("Rebirths")
		if rebirthsValue then
			rebirthsValue.Value = newRebirths
		end

		UpgradeService.resetPlayer(player)

		-- Reset location attributes
		for _, attr in ipairs({"Unlocked_ForestArea", "Unlocked_MansionArea"}) do
			player:SetAttribute(attr, false)
		end

		local multiplier = 1.0 + (newRebirths * RebirthConfig.MultiplierPerRebirth)
		Remotes.getEvent("ShowNotification"):FireClient(player, string.format("Rebirth complete! Multiplier: x%.1f", multiplier))
	else
		Remotes.getEvent("ShowNotification"):FireClient(player, "Not enough money!")
	end
end

function RebirthService.removePlayer(player: Player)
	playerRebirths[player.UserId] = nil
end

return RebirthService
