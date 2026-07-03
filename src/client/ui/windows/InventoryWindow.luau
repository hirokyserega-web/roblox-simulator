-- InventoryWindow
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local Panel = require(script.Parent.Parent.components.Panel)
local ItemCard = require(script.Parent.Parent.components.ItemCard)

local InventoryWindow = {}
local invPanel = nil

function InventoryWindow.init(screenGui)
	invPanel = Panel.create({ Title = "INVENTORY", Parent = screenGui })
	return InventoryWindow
end

function InventoryWindow.Open() invPanel.Open() end
function InventoryWindow.Close() invPanel.Close() end

return InventoryWindow
