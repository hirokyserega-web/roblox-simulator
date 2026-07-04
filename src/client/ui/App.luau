-- Candy UI Root App Component (React version)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

-- UI Components
local HUD = require(script.Parent.hud.HUD)
local InventoryWindow = require(script.Parent.windows.InventoryWindow)
local ShopWindow = require(script.Parent.windows.ShopWindow)
local TeleportWindow = require(script.Parent.windows.TeleportWindow)
local RebirthWindow = require(script.Parent.windows.RebirthWindow)
local DailyRewardsWindow = require(script.Parent.windows.DailyRewardsWindow)
local CodesWindow = require(script.Parent.windows.CodesWindow)
local Toast = require(script.Parent.components.Toast)
local CaptureBar = require(script.Parent.hud.CaptureBar)

local function App()
	local activeWindow, setActiveWindow = React.useState(nil)
	local money, setMoney = React.useState(0)
	local crystals, setCrystals = React.useState(0)
	local bagCount, setBagCount = React.useState(0)
	local bagMax, setBagMax = React.useState(10)
	local rebirths, setRebirths = React.useState(0)
	local toast, setToast = React.useState(nil)

	React.useEffect(function()
		local player = Players.LocalPlayer
		
		local function refreshData()
			setMoney(player:GetAttribute("Money") or 0)
			setCrystals(player:GetAttribute("Crystals") or 0)
			setRebirths(player:GetAttribute("Rebirths") or 0)
		end
		
		refreshData()

		local conn = player.AttributeChanged:Connect(refreshData)

		local invConn = Remotes.getEvent("InventoryUpdate").OnClientEvent:Connect(function(inv)
			setBagCount(#inv.Ghosts)
			setBagMax(inv.MaxCapacity)
		end)
		
		local toastConn = Remotes.getEvent("ShowNotification").OnClientEvent:Connect(function(msg)
			setToast(msg)
			task.delay(3, function()
				setToast(nil)
			end)
		end)

		_G.UIManager = {
			openWindow = function(name) setActiveWindow(name) end,
			closeWindow = function() setActiveWindow(nil) end,
			showToast = function(msg) setToast(msg) end,
		}

		return function()
			conn:Disconnect()
			invConn:Disconnect()
			toastConn:Disconnect()
			_G.UIManager = nil
		end
	end, {})

	return React.createElement("ScreenGui", {
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		HUD = React.createElement(HUD, {
			Money = money,
			Crystals = crystals,
			BagCount = bagCount,
			BagMax = bagMax,
			OnMenuOpen = function(name) setActiveWindow(name) end,
		}),

		Windows = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible = activeWindow ~= nil,
			ZIndex = 100,
		}, {
			Inventory = React.createElement(InventoryWindow, {
				Visible = activeWindow == "Inventory",
				OnClose = function() setActiveWindow(nil) end,
			}),
			Shop = React.createElement(ShopWindow, {
				Visible = activeWindow == "Shop",
				OnClose = function() setActiveWindow(nil) end,
			}),
			Teleport = React.createElement(TeleportWindow, {
				Visible = activeWindow == "Teleport",
				OnClose = function() setActiveWindow(nil) end,
			}),
			Rebirth = React.createElement(RebirthWindow, {
				Visible = activeWindow == "Rebirth",
				Money = money,
				Rebirths = rebirths,
				OnClose = function() setActiveWindow(nil) end,
			}),
			Daily = React.createElement(DailyRewardsWindow, {
				Visible = activeWindow == "Daily",
				OnClose = function() setActiveWindow(nil) end,
			}),
			Codes = React.createElement(CodesWindow, {
				Visible = activeWindow == "Codes",
				OnClose = function() setActiveWindow(nil) end,
			}),
		}),

		CaptureUI = React.createElement(CaptureBar),

		ToastContainer = toast and React.createElement(Toast, {
			Text = toast,
			OnComplete = function() setToast(nil) end,
		}) or nil,
	})
end

return App
