-- Клиентский UI Настроек (Settings UI)
local Players = game:GetService("Players")

-- Подгрузка темы и компонентов UI Kit
local Theme = require(script.Parent.ui.theme.Theme)
local Button = require(script.Parent.ui.components.Button)
local Panel = require(script.Parent.ui.components.Panel)
local UIManager = require(script.Parent.ui.UIManager)

local player = Players.LocalPlayer

local settingsPanel = nil
local musicToggle = nil
local soundsToggle = nil
local particlesToggle = nil

-- Состояния настроек
local settingsStates = {
	Music = true,
	Sounds = true,
	Particles = true
}

local function updateToggle(name: string, buttonComp: table)
	local state = settingsStates[name]
	local text = string.format("%s: %s", name == "Music" and "Музыка" or (name == "Sounds" and "Звуки" or "Частицы"), state and "ВКЛ" or "ВЫКЛ")
	local color = state and Theme.Colors.Success or Theme.Colors.Error
	
	-- Меняем визуальное состояние кнопки
	local top = buttonComp.Instance:FindFirstChild("ButtonTop")
	if top then
		top.Text = text
		top.BackgroundColor3 = color
	end
end

-- Инициализация
local function init()
	local screenGui = UIManager.getScreenGui()

	-- Создаем премиум-панель настроек
	settingsPanel = Panel.create({
		Title = "НАСТРОЙКИ ИГРЫ",
		Size = UDim2.new(0, 300, 0, 260),
		Position = UDim2.new(0.5, -150, 0.5, -130),
		Parent = screenGui,
		OnClose = function()
			settingsPanel.Close()
		end
	})

	UIManager.registerWindow("Settings", settingsPanel)

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 16)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.Parent = settingsPanel.Content

	-- Музыка
	musicToggle = Button.create({
		Text = "Музыка: ВКЛ",
		Color = Theme.Colors.Success,
		Size = UDim2.new(1, -40, 0, 42),
		Parent = settingsPanel.Content,
		OnClick = function()
			settingsStates.Music = not settingsStates.Music
			updateToggle("Music", musicToggle)
			UIManager.ShowToast("Настройка музыки изменена!", "Info")
		end
	})

	-- Звуки
	soundsToggle = Button.create({
		Text = "Звуки: ВКЛ",
		Color = Theme.Colors.Success,
		Size = UDim2.new(1, -40, 0, 42),
		Parent = settingsPanel.Content,
		OnClick = function()
			settingsStates.Sounds = not settingsStates.Sounds
			updateToggle("Sounds", soundsToggle)
			UIManager.ShowToast("Настройка звуков изменена!", "Info")
		end
	})

	-- Эффекты/частицы
	particlesToggle = Button.create({
		Text = "Частицы: ВКЛ",
		Color = Theme.Colors.Success,
		Size = UDim2.new(1, -40, 0, 42),
		Parent = settingsPanel.Content,
		OnClick = function()
			settingsStates.Particles = not settingsStates.Particles
			updateToggle("Particles", particlesToggle)
			UIManager.ShowToast("Настройка частиц изменена!", "Info")
		end
	})

	updateToggle("Music", musicToggle)
	updateToggle("Sounds", soundsToggle)
	updateToggle("Particles", particlesToggle)
end

init()
print("[SETTINGS UI] Интерфейс настроек успешно загружен!")
