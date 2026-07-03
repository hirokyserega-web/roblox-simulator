local Players = game:GetService("Players")

local LeaderstatsManager = {}

-- Initialize leaderstats for a player
function LeaderstatsManager.setupPlayer(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = 0
	money.Parent = leaderstats

	local crystals = Instance.new("IntValue")
	crystals.Name = "Crystals"
	crystals.Value = 0
	crystals.Parent = leaderstats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = leaderstats
	
	print("Leaderstats successfully set up for player: " .. player.Name)
end

-- Helpers to change values safely
function LeaderstatsManager.addMoney(player: Player, amount: number)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local money = leaderstats:FindFirstChild("Money")
		if money then
			money.Value = money.Value + amount
		end
	end
end

function LeaderstatsManager.addCrystals(player: Player, amount: number)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local crystals = leaderstats:FindFirstChild("Crystals")
		if crystals then
			crystals.Value = crystals.Value + amount
		end
	end
end

function LeaderstatsManager.addRebirths(player: Player, amount: number)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local rebirths = leaderstats:FindFirstChild("Rebirths")
		if rebirths then
			rebirths.Value = rebirths.Value + amount
		end
	end
end

return LeaderstatsManager
