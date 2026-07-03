-- Эффекты испуга, атак призраков и глобальных событий (ScreenEffects)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Theme = require(script.Parent.Parent.theme.Theme)
local UIManager = require(script.Parent.Parent.UIManager)

local player = Players.LocalPlayer
local scareEvent = Remotes.getEvent("ScarePlayer")

local ScreenEffects = {}
local vignette = nil

local function playSound(soundId, vol)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = vol or 0.6
	sound.Parent = SoundService
	sound:Play()
	game:GetService("Debris"):AddItem(sound, 1.5)
end

local function applyBlurEffect(size, duration)
	local blur = Lighting:FindFirstChild("ScreenEffectsBlur")
	if not blur then
		blur = Instance.new("BlurEffect")
		blur.Name = "ScreenEffectsBlur"
		blur.Size = 0
		blur.Parent = Lighting
	end
	blur.Size = size
	TweenService:Create(blur, TweenInfo.new(duration), {Size = 0}):Play()
end

local function shakeCamera(duration, intensity)
	local char = player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local startTime = tick()
	task.spawn(function()
		while tick() - startTime < duration do
			if humanoid then
				humanoid.CameraOffset = Vector3.new(
					(math.random() - 0.5) * intensity,
					(math.random() - 0.5) * intensity,
					0
				)
			end
			task.wait()
		end
		if humanoid then
			humanoid.CameraOffset = Vector3.new(0, 0, 0)
		end
	end)
end

function ScreenEffects.scare()
	applyBlurEffect(16, 1.0)
	playSound("rbxassetid://134012243", 0.7)
	shakeCamera(0.8, 0.6)

	if vignette then
		vignette.ImageColor3 = Theme.Colors.Warning
		vignette.ImageTransparency = 0
		TweenService:Create(vignette, TweenInfo.new(1.0), {ImageTransparency = 1}):Play()
	end
	UIManager.ShowToast("БУ! Рядом опасный призрак!", "Warning")
end

function ScreenEffects.attack()
	applyBlurEffect(24, 1.5)
	playSound("rbxassetid://134012243", 0.8)
	shakeCamera(1.5, 1.4)

	if vignette then
		vignette.ImageColor3 = Theme.Colors.Error
		vignette.ImageTransparency = 0
		TweenService:Create(vignette, TweenInfo.new(1.4), {ImageTransparency = 1}):Play()
	end
	UIManager.ShowToast("ВАС АТАКОВАЛИ! Утерян 1 призрак из сумки!", "Error")
end

function ScreenEffects.init()
	local screenGui = UIManager.getScreenGui()

	-- Создаем оверлей виньетки
	vignette = Instance.new("ImageLabel")
	vignette.Name = "ScareVignette"
	vignette.Size = UDim2.new(1, 0, 1, 0)
	vignette.BackgroundTransparency = 1
	vignette.Image = "rbxassetid://257069542"
	vignette.ImageTransparency = 1
	vignette.ZIndex = 1
	vignette.Parent = screenGui

	-- Подключение Remote
	scareEvent.OnClientEvent:Connect(function(scareType)
		if scareType == "ATK" then
			ScreenEffects.attack()
		else
			ScreenEffects.scare()
		end
	end)
end

ScreenEffects.init()

return ScreenEffects
