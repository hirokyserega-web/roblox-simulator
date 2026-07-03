-- Менеджер клиентского интерфейса (UIManager)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Theme = require(script.Parent.theme.Theme)
local Toast = require(script.Parent.components.Toast)

local UIManager = {}
local screenGui = nil
local windows = {} -- Ключ: Name (string), Значение: Объект окна с методами .Open() и .Close()

-- Инициализация менеджера
local function init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	-- Создаем единый корневой ScreenGui для всего интерфейса
	screenGui = playerGui:FindFirstChild("MainGameHUD")
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "MainGameHUD"
		screenGui.IgnoreGuiInset = true
		screenGui.ResetOnSpawn = false
		screenGui.DisplayOrder = 100
		screenGui.Parent = playerGui
	end

	-- Скрываем стандартные элементы CoreGui (PlayerList, Backpack) для полной кастомизации
	local StarterGui = game:GetService("StarterGui")
	task.spawn(function()
		local retries = 0
		while retries < 10 do
			local success = pcall(function()
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
			end)
			if success then break end
			task.wait(0.5)
			retries = retries + 1
		end
	end)
	
	-- Инициализируем систему тостов
	Toast.init(screenGui)

	-- Регистрируем глобальный API для старых систем тостов (совместимость)
	_G.ShowNotification = function(text, type)
		UIManager.ShowToast(text, type or "Info")
	end

	-- Экспортируем UIManager глобально ДО загрузки окон (чтобы окна не создавали циклический require)
	_G.UIManager = UIManager

	-- Загружаем и инициализируем все модули окон и эффектов с помощью task.defer (для предотвращения циклических крашей при require)
	task.defer(function()
		require(script.Parent.windows.ShopWindow)
		require(script.Parent.windows.InventoryWindow)
		require(script.Parent.windows.SellPopup)
		require(script.Parent.windows.EggWindow)
		require(script.Parent.windows.LeaderboardWindow)
		require(script.Parent.windows.RebirthWindow)
		require(script.Parent.windows.DailyRewardsWindow)
		require(script.Parent.windows.CodesWindow)
		require(script.Parent.windows.SettingsWindow)
		require(script.Parent.windows.TeleportWindow)
		require(script.Parent.effects.ScreenEffects)
		print("[UI MANAGER] Все окна успешно загружены и зарегистрированы!")
	end)

	print("[UI MANAGER] Клиентский менеджер интерфейса успешно запущен!")
end

-- Получить корневой ScreenGui
function UIManager.getScreenGui(): ScreenGui
	return screenGui
end

-- Регистрация окна в общей системе
function UIManager.registerWindow(name: string, windowObj: table)
	windows[name] = windowObj
end

-- Открытие окна по имени с анимацией
function UIManager.openWindow(name: string)
	local win = windows[name]
	if win then
		win.Open()
	else
		warn("[UI MANAGER] Попытка открыть незарегистрированное окно: " .. name)
	end
end

-- Закрытие окна по имени с анимацией
function UIManager.closeWindow(name: string)
	local win = windows[name]
	if win then
		win.Close()
	end
end

-- Всплывающее тост-уведомление
function UIManager.ShowToast(text: string, notificationType: string?)
	Toast.show(text, notificationType)
end

init()

return UIManager
