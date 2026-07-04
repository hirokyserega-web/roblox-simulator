local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local UpgradeConfig = require(ReplicatedStorage.Shared.config.UpgradeConfig)
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local isHolding = false
local activeGhost = nil
local progress = 0
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isHolding = true
		local target = mouse.Target
		if target and target:GetAttribute("GhostId") then
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local dist = (char.HumanoidRootPart.Position - target.Position).Magnitude
				if dist <= GameConfig.TrapRange then
					activeGhost = target
					progress = 0
					if _G.SetCaptureGhostName then _G.SetCaptureGhostName(target.Name) end
					if _G.UIManager then _G.UIManager.openWindow("Capture") end
				end
			end
		end
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isHolding = false
		activeGhost = nil
		if _G.UIManager then _G.UIManager.closeWindow() end
	end
end)
RunService.Heartbeat:Connect(function(dt)
	if not activeGhost or not isHolding then return end
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then 
		activeGhost = nil
		return 
	end
	local dist = (char.HumanoidRootPart.Position - activeGhost.Position).Magnitude
	if dist > GameConfig.TrapRange or not activeGhost.Parent then
		activeGhost = nil
		if _G.UIManager then _G.UIManager.closeWindow() end
		return
	end
	local level = player:GetAttribute("CaptureSpeedLvl") or 1
	local capTime = UpgradeConfig.CaptureSpeed.Levels[level].Value
	progress = math.min(1, progress + dt / capTime)
	if _G.SetCaptureProgress then _G.SetCaptureProgress(progress) end
	if progress >= 1 then
		local id = activeGhost:GetAttribute("GhostId")
		Remotes.getEvent("CaptureGhost"):FireServer(id)
		activeGhost = nil
		if _G.UIManager then _G.UIManager.closeWindow() end
	end
end)
