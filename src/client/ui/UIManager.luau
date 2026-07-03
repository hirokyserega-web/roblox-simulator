-- UIManager
local Theme = require(script.Parent.theme.Theme)
local Toast = require(script.Parent.components.Toast)
local UIManager = {}
local screenGui = nil
local windows = {}

function UIManager.getScreenGui() return screenGui end
function UIManager.ShowToast(msg, type) Toast.show(msg, type) end

function UIManager.registerWindow(name, api)
	windows[name] = api
end

function UIManager.openWindow(name)
	if windows[name] then windows[name].Open() end
end

local function init()
	local player = game:GetService("Players").LocalPlayer
	local pg = player:WaitForChild("PlayerGui")
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GhostSimulatorUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = pg
	
	Toast.init(screenGui)
	_G.UIManager = UIManager
	
	task.spawn(function()
		local shop = require(script.Parent.windows.ShopWindow)
		UIManager.registerWindow("Shop", shop.init(screenGui))
		
		local inv = require(script.Parent.windows.InventoryWindow)
		UIManager.registerWindow("Inventory", inv.init(screenGui))
	end)
end

init()
return UIManager
