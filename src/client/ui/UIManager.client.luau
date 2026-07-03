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

	-- Инициализируем систему тостов
	Toast.init(screenGui)

	-- Регистрируем глобальный API для старых систем тостов (совместимость)
	_G.ShowNotification = function(text, type)
		UIManager.ShowToast(text, type or "Info")
	end

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
