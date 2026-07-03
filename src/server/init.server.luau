local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local LeaderstatsManager = require(ServerScriptService.Server.LeaderstatsManager)

-- Handle player joining
local function onPlayerAdded(player: Player)
	LeaderstatsManager.setupPlayer(player)
end

-- Connect events
Players.PlayerAdded:Connect(onPlayerAdded)

-- Handle existing players (useful for local testing/reloads)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

print("Server initialized successfully!")
