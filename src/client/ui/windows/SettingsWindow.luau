-- SettingsWindow (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
local UIManager = {
	ShowToast = function(...)
		if _G.UIManager then
			_G.UIManager.ShowToast(...)
		end
	end,
	openWindow = function(...)
		if _G.UIManager then
			_G.UIManager.openWindow(...)
		end
	end,
}


local settingsStates = {
	Music = true,
	Sounds = true,
	Particles = true
}

local function SettingsWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose

	local music, setMusic = React.useState(settingsStates.Music)
	local sounds, setSounds = React.useState(settingsStates.Sounds)
	local particles, setParticles = React.useState(settingsStates.Particles)

	if not visible then return nil end

	return React.createElement(Panel, {
		Title = "НАСТРОЙКИ ИГРЫ",
		Size = UDim2.new(0, 340, 0, 300),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Visible = true,
		OnClose = onClose,
	}, {
		Container = React.createElement("Frame", {
			Size = UDim2.new(1, -20, 1, -20),
			Position = UDim2.new(0, 10, 0, 10),
			BackgroundTransparency = 1,
		}, {
			ListLayout = React.createElement("UIListLayout", {
				Padding = UDim.new(0, 18),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			MusicToggle = React.createElement(Button, {
				Text = string.format("🎵 Музыка: %s", music and "ВКЛ" or "ВЫКЛ"),
				Color = music and Theme.Colors.Success or Theme.Colors.Error,
				Size = UDim2.new(1, -20, 0, 48),
				OnClick = function()
					local newVal = not music
					settingsStates.Music = newVal
					setMusic(newVal)
					UIManager.ShowToast("Настройка музыки изменена!", "Info")
				end
			}),

			SoundsToggle = React.createElement(Button, {
				Text = string.format("🔊 Звуки: %s", sounds and "ВКЛ" or "ВЫКЛ"),
				Color = sounds and Theme.Colors.Success or Theme.Colors.Error,
				Size = UDim2.new(1, -20, 0, 48),
				OnClick = function()
					local newVal = not sounds
					settingsStates.Sounds = newVal
					setSounds(newVal)
					UIManager.ShowToast("Настройка звуков изменена!", "Info")
				end
			}),

			ParticlesToggle = React.createElement(Button, {
				Text = string.format("✨ Частицы: %s", particles and "ВКЛ" or "ВЫКЛ"),
				Color = particles and Theme.Colors.Success or Theme.Colors.Error,
				Size = UDim2.new(1, -20, 0, 48),
				OnClick = function()
					local newVal = not particles
					settingsStates.Particles = newVal
					setParticles(newVal)
					UIManager.ShowToast("Настройка частиц изменена!", "Info")
				end
			})
		})
	})
end

return SettingsWindow

