local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local InventoryService = require(ServerScriptService.Server.InventoryService)
local CaptureService = {}
function CaptureService.init()
	local event = Remotes.getEvent("CaptureGhost")
	event.OnServerEvent:Connect(function(player, ghostId)
		CaptureService.onCaptureRequest(player, ghostId)
	end)
end
function CaptureService.onCaptureRequest(player, ghostId)
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local playerGhosts = ReplicatedStorage:FindFirstChild("PlayerGhosts")
	if not playerGhosts then return end
	local pFolder = playerGhosts:FindFirstChild(tostring(player.UserId))
	if not pFolder then return end
	local ghostEntity = nil
	for _, child in ipairs(pFolder:GetChildren()) do
		if child:GetAttribute("GhostId") == ghostId then
			ghostEntity = child
			break
		end
	end
	if not ghostEntity then return end
	local ghostPos = ghostEntity:GetAttribute("Position")
	if not ghostPos then return end
	if (char.HumanoidRootPart.Position - ghostPos).Magnitude > GameConfig.TrapRange + 15 then return end
	local rarity = ghostEntity:GetAttribute("Rarity")
	local success = InventoryService.addGhost(player, rarity)
	if success then ghostEntity:Destroy() else Remotes.getEvent("ShowNotification"):FireClient(player, "Сумка полна!") end
end
return CaptureService
