-- Candy UI Root App Component (React version)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local React = require(ReplicatedStorage.Packages.React)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local Theme = require(script.Parent.theme.Theme)

local HUD = require(script.Parent.hud.HUD)

-- Импорт окон (Windows)
local ShopWindow = require(script.Parent.windows.ShopWindow)
local InventoryWindow = require(script.Parent.windows.InventoryWindow)
local RebirthWindow = require(script.Parent.windows.RebirthWindow)
local SettingsWindow = require(script.Parent.windows.SettingsWindow)
local CodesWindow = require(script.Parent.windows.CodesWindow)
local TeleportWindow = require(script.Parent.windows.TeleportWindow)
local LeaderboardWindow = require(script.Parent.windows.LeaderboardWindow)
local DailyRewardsWindow = require(script.Parent.windows.DailyRewardsWindow)
local EggWindow = require(script.Parent.windows.EggWindow)
local SellPopup = require(script.Parent.windows.SellPopup)

local player = Players.LocalPlayer

-- Вспомогательный компонент для уведомлений (ToastItem)
local function ToastItem(props)
	local text = props.Text or "Notification"
	local notificationType = props.Type or "Info"
	local onFinished = props.OnFinished

	local ref = React.useRef(nil)

	React.useEffect(function()
		local toast = ref.current
		if not toast then return end

		-- Smooth sliding spring-like entrance animation from top
		toast.Position = UDim2.new(0.5, 0, 0, -80)
		local ti = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local tIn = TweenService:Create(toast, ti, {Position = UDim2.new(0.5, 0, 0, 24)})
		tIn:Play()

		-- Fade out and slide back up
		local delayTask = task.delay(3.5, function()
			local tOut = TweenService:Create(toast, ti, {Position = UDim2.new(0.5, 0, 0, -80)})
			tOut:Play()
			local conn
			conn = tOut.Completed:Connect(function()
				conn:Disconnect()
				if onFinished then onFinished() end
			end)
		end)

		return function()
			task.cancel(delayTask)
		end
	end, {})

	local color = Theme.Colors.Info
	if notificationType == "Success" then color = Theme.Colors.Success
	elseif notificationType == "Error" then color = Theme.Colors.Error
	elseif notificationType == "Warning" then color = Theme.Colors.Warning end

	return React.createElement("Frame", {
		Name = "ToastNotification",
		ref = ref,
		Size = UDim2.new(0, 320, 0, 60),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromHex("12142B"), -- Juicy dark backing
		BorderSizePixel = 0,
		ZIndex = 500, -- Maximum ZIndex to sit on top of everything!
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = Theme.Sizes.CornerRadius,
		}),
		Stroke = React.createElement("UIStroke", {
			Color = color,
			Thickness = 3,
		}),
		
		-- Cute Bell/Notif emoji
		IconLabel = React.createElement("TextLabel", {
			Size = UDim2.new(0, 36, 1, 0),
			Position = UDim2.new(0, 12, 0, 0),
			BackgroundTransparency = 1,
			Text = "🔔",
			TextSize = 22,
			Font = Theme.Fonts.Main,
			ZIndex = 501,
		}),

		-- Text message
		Label = React.createElement("TextLabel", {
			Size = UDim2.new(1, -70, 1, 0),
			Position = UDim2.new(0, 52, 0, 0),
			BackgroundTransparency = 1,
			Text = text,
			Font = Theme.Fonts.Main,
			TextColor3 = Theme.Colors.Text,
			TextSize = 16,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 501,
		}, {
			Stroke = React.createElement("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 1.5,
			})
		}),

		-- Dynamic gloss top sweep for that juicy plastic bubble highlight
		GlossHighlight = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 0.5, 0),
			BackgroundTransparency = 0.92,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			ZIndex = 502,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerRadius,
			})
		})
	})
end

-- Основной корневой компонент App
local function App()
	local activeWindow, setActiveWindow = React.useState(nil)
	local toasts, setToasts = React.useState({})

	-- Балансы и статы игрока
	local money, setMoney = React.useState(player:GetAttribute("Money") or 0)
	local crystals, setCrystals = React.useState(player:GetAttribute("Crystals") or 0)
	local rebirths, setRebirths = React.useState(player:GetAttribute("Rebirths") or 0)
	local bagCount, setBagCount = React.useState(0)
	local bagMax, setBagMax = React.useState(10)
	local ghosts, setGhosts = React.useState({})
	local pets, setPets = React.useState({})
	local sellData, setSellData = React.useState(nil)

	-- Состояние детектора призраков
	local detectorSignal, setDetectorSignal = React.useState(0)
	local detectorRarity, setDetectorRarity = React.useState("NONE")

	-- Состояние шкалы захвата призрака
	local captureVisible, setCaptureVisible = React.useState(false)
	local captureGhostName, setCaptureGhostName = React.useState("GHOST")
	local captureGhostRarity, setCaptureGhostRarity = React.useState("Common")
	local captureProgress, setCaptureProgress = React.useState(0)
	local captureShakeTrigger, setCaptureShakeTrigger = React.useState(0)

	-- Мост-интеграция для UIManager
	React.useEffect(function()
		local UIManager = require(script.Parent.UIManager)
		UIManager._openWindowCallback = function(name)
			setActiveWindow(name)
		end
		UIManager._showToastCallback = function(text, toastType)
			setToasts(function(currentToasts)
				local newToasts = table.clone(currentToasts)
				table.insert(newToasts, {
					Id = HttpService:GenerateGUID(false),
					Text = text,
					Type = toastType,
				})
				return newToasts
			end)
		end

		return function()
			UIManager._openWindowCallback = nil
			UIManager._showToastCallback = nil
		end
	end, {})

	-- Подписки на атрибуты
	React.useEffect(function()
		local function updateMoney() setMoney(player:GetAttribute("Money") or 0) end
		local function updateCrystals() setCrystals(player:GetAttribute("Crystals") or 0) end
		local function updateRebirths() setRebirths(player:GetAttribute("Rebirths") or 0) end

		local c1 = player:GetAttributeChangedSignal("Money"):Connect(updateMoney)
		local c2 = player:GetAttributeChangedSignal("Crystals"):Connect(updateCrystals)
		local c3 = player:GetAttributeChangedSignal("Rebirths"):Connect(updateRebirths)

		updateMoney()
		updateCrystals()
		updateRebirths()

		return function()
			c1:Disconnect()
			c2:Disconnect()
			c3:Disconnect()
		end
	end, {})

	-- Подписка на обновление инвентаря
	React.useEffect(function()
		local conn = Remotes.getEvent("InventoryUpdate").OnClientEvent:Connect(function(inventory)
			if inventory then
				setBagCount(#inventory.Ghosts)
				setBagMax(inventory.MaxCapacity)
				setGhosts(inventory.Ghosts or {})
			end
		end)
		return function()
			conn:Disconnect()
		end
	end, {})

	-- Подписка на обновление питомцев
	React.useEffect(function()
		local conn = Remotes.getEvent("UpdatePets").OnClientEvent:Connect(function(petsList)
			setPets(petsList or {})
		end)
		return function()
			conn:Disconnect()
		end
	end, {})

	-- Подписка на завершение продажи
	React.useEffect(function()
		local conn = Remotes.getEvent("SellCompleted").OnClientEvent:Connect(function(earnings, caughtGhosts)
			setSellData({
				Earnings = earnings,
				Ghosts = caughtGhosts
			})
			-- Звук успеха
			task.spawn(function()
				local s = Instance.new("Sound")
				s.SoundId = Theme.Sounds.Success or "rbxassetid://9083893322"
				s.Volume = 0.5
				s.Parent = game:GetService("SoundService")
				s:Play()
				task.wait(1.5)
				s:Destroy()
			end)
			-- Авто-закрытие попапа
			task.delay(2.5, function()
				setSellData(nil)
			end)
		end)
		return function()
			conn:Disconnect()
		end
	end, {})

	-- Шкала захвата призрака
	React.useEffect(function()
		_G.ShowCapture = function(ghostInfo)
			setCaptureGhostName(ghostInfo.Name or "GHOST")
			setCaptureGhostRarity(ghostInfo.Rarity or "Common")
			setCaptureProgress(0)
			setCaptureVisible(true)
		end
		_G.SetCaptureProgress = function(v)
			setCaptureProgress(v)
		end
		_G.HideCapture = function()
			setCaptureVisible(false)
		end
		_G.ShakeCapture = function()
			setCaptureShakeTrigger(function(t) return t + 1 end)
		end

		return function()
			_G.ShowCapture = nil
			_G.SetCaptureProgress = nil
			_G.HideCapture = nil
			_G.ShakeCapture = nil
		end
	end, {})

	-- Цикл Детектора Сигналов
	React.useEffect(function()
		local localGhostsFolder = Workspace:WaitForChild("LocalGhosts", 15)

		local conn = RunService.Heartbeat:Connect(function()
			local character = player.Character
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			if not rootPart or not localGhostsFolder then return end

			local closestGhost = nil
			local minDistance = math.huge

			for _, ghost in ipairs(localGhostsFolder:GetChildren()) do
				if ghost:IsA("BasePart") then
					local distance = (rootPart.Position - ghost.Position).Magnitude
					if distance < minDistance then
						minDistance = distance
						closestGhost = ghost
					end
				end
			end

			local maxRange = player:GetAttribute("DetectorRadius") or GameConfig.DetectorRadius or 50

			if closestGhost and minDistance <= maxRange then
				local factor = 1 - (minDistance / maxRange)
				setDetectorSignal(factor)
				local rarity = closestGhost:GetAttribute("Rarity") or "Common"
				setDetectorRarity(rarity)
			else
				setDetectorSignal(0)
				setDetectorRarity("NONE")
			end
		end)

		return function()
			conn:Disconnect()
		end
	end, {})

	-- Генерация оверлеев тостов
	local toastElements = {}
	for _, toast in ipairs(toasts) do
		toastElements[toast.Id] = React.createElement(ToastItem, {
			Text = toast.Text,
			Type = toast.Type,
			OnFinished = function()
				setToasts(function(currentToasts)
					local newToasts = {}
					for _, t in ipairs(currentToasts) do
						if t.Id ~= toast.Id then
							table.insert(newToasts, t)
						end
					end
					return newToasts
				end)
			end
		})
	end

	return React.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		-- Игровой HUD
		Hud = React.createElement(HUD, {
			OpenWindow = function(name)
				setActiveWindow(function(current)
					if current == name then return nil else return name end
				end)
			end,
			PlayerStats = {
				Money = money,
				Crystals = crystals,
				BagCount = bagCount,
				BagMax = bagMax,
			},
			DetectorStats = {
				Signal = detectorSignal,
				Rarity = detectorRarity,
			},
			CaptureStats = {
				Visible = captureVisible,
				GhostName = captureGhostName,
				GhostRarity = captureGhostRarity,
				Progress = captureProgress,
				ShakeTrigger = captureShakeTrigger,
			}
		}),

		-- Уведомления (Toasts)
		ToastContainer = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ZIndex = 1000,
		}, toastElements),

		-- Попап успешной продажи
		SellOverlay = sellData and React.createElement(SellPopup, {
			Earnings = sellData.Earnings,
			Ghosts = sellData.Ghosts,
		}) or nil,

		-- Окна интерфейса (Windows Overlay)
		ActiveWindowOverlay = (function()
			if activeWindow == "Shop" then
				return React.createElement(ShopWindow, {
					Visible = true,
					OnClose = function() setActiveWindow(nil) end,
					Money = money,
				})
			elseif activeWindow == "Inventory" then
				return React.createElement(InventoryWindow, {
					Visible = true,
					OnClose = function() setActiveWindow(nil) end,
					Ghosts = ghosts,
				})
			elseif activeWindow == "Rebirth" then
				return React.createElement(RebirthWindow, {
					Visible = true,
					OnClose = function() setActiveWindow(nil) end,
					Money = money,
					Rebirths = rebirths,
				})
			elseif activeWindow == "Settings" then
				return React.createElement(SettingsWindow, {
					Visible = true,
					OnClose = function() setActiveWindow(nil) end,
				})
			elseif activeWindow == "Codes" then
				return React.createElement(CodesWindow, {
					Visible = true,
					OnClose = function() setActiveWindow(nil) end,
				})
			elseif activeWindow == "Teleport" then
				return React.createElement(TeleportWindow, {
					Visible = true,
					OnClose = function() setActiveWindow(nil) end,
					Money = money,
				})
			elseif activeWindow == "Leaderboard" then
				return React.createElement(LeaderboardWindow, {
					Visible = true,
					OnClose = function() setActiveWindow(nil) end,
				})
			elseif activeWindow == "Rewards" then
				return React.createElement(DailyRewardsWindow, {
					Visible = true,
					OnClose = function() setActiveWindow(nil) end,
				})
			elseif activeWindow == "Pets" then
				return React.createElement(EggWindow, {
					Visible = true,
					OnClose = function() setActiveWindow(nil) end,
					Pets = pets,
				})
			end
			return nil
		end)(),
	})
end

return App
