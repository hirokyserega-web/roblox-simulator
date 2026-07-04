-- UIManager (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local App = require(script.Parent.App)

local UIManager = {}
UIManager._openWindowCallback = nil
UIManager._showToastCallback = nil

function UIManager.openWindow(name)
	if UIManager._openWindowCallback then
		UIManager._openWindowCallback(name)
	end
end

function UIManager.closeWindow()
	if UIManager._openWindowCallback then
		UIManager._openWindowCallback(nil)
	end
end

function UIManager.ShowToast(msg, type)
	if UIManager._showToastCallback then
		UIManager._showToastCallback(msg, type)
	end
end

-- Backward compatibility aliases/methods
local registeredWindows = {}
function UIManager.registerWindow(name, api)
	registeredWindows[name] = api
	return api
end

local function init()
	local player = Players.LocalPlayer
	local pg = player:WaitForChild("PlayerGui")
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GhostSimulatorUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = pg

	local root = ReactRoblox.createRoot(screenGui)
	root:render(React.createElement(App))

	_G.UIManager = UIManager
end

init()
return UIManager

