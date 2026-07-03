-- Компонент тост-уведомлений (Toast) в стиле Roblox-симулятора с авто-стеком
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.theme.Theme)

local ToastManager = {}
local container = nil

-- Инициализация контейнера уведомлений
function ToastManager.init(parentScreenGui: ScreenGui)
	if container then return end

	container = Instance.new("Frame")
	container.Name = "ToastContainer"
	container.Size = UDim2.new(0, 260, 0.7, 0)
	container.Position = UDim2.new(1, -280, 0.1, 0)
	container.BackgroundTransparency = 1
	container.Parent = parentScreenGui

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 8)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = container
end

-- Воспроизведение звуков уведомлений
local function playSound(soundId)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 0.5
	sound.Parent = game:GetService("SoundService")
	sound:Play()
	game:GetService("Debris"):AddItem(sound, 1.5)
end

-- Показ всплывающего уведомления
function ToastManager.show(text: string, notificationType: string?)
	if not container then return end

	local notifType = notificationType or "Info" -- Info, Success, Warning, Error
	
	-- Цвета рамки в зависимости от типа
	local borderColor = Theme.Colors.Neon
	local soundId = Theme.Sounds.Click

	if notifType == "Success" then
		borderColor = Theme.Colors.Success
		soundId = Theme.Sounds.Success
	elseif notifType == "Warning" then
		borderColor = Theme.Colors.Warning
		soundId = Theme.Sounds.Error -- Использование стандартных звуков
	elseif notifType == "Error" then
		borderColor = Theme.Colors.Error
		soundId = Theme.Sounds.Error
	end

	-- 1. Сама плашка тоста
	local toast = Instance.new("Frame")
	toast.Name = "Toast"
	toast.Size = UDim2.new(1, 0, 0, 46)
	toast.BackgroundColor3 = Theme.Colors.Background
	toast.BackgroundTransparency = 1 -- Будем анимировать появление
	toast.BorderSizePixel = 0
	toast.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Sizes.CornerRadius
	corner.Parent = toast

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = Theme.Sizes.BorderWidth
	stroke.Color = borderColor
	stroke.Transparency = 1 -- Анимируем
	stroke.Parent = toast

	-- Иконка галочки / крестика
	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 30, 0, 30)
	icon.Position = UDim2.new(0, 6, 0.5, -15)
	icon.BackgroundTransparency = 1
	icon.Font = Theme.Fonts.Title
	icon.TextSize = 16
	
	local symbol = "📡"
	if notifType == "Success" then symbol = "✅"
	elseif notifType == "Error" then symbol = "❌"
	elseif notifType == "Warning" then symbol = "⚠️"
	end
	icon.Text = symbol
	icon.TextTransparency = 1
	icon.Parent = toast

	-- Текст сообщения
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, -48, 1, 0)
	label.Position = UDim2.new(0, 40, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Theme.Fonts.Body
	label.TextSize = 13
	label.TextColor3 = Theme.Colors.Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.Text = text
	label.TextTransparency = 1
	label.Parent = toast

	-- Звуковой эффект
	playSound(soundId)

	-- Анимация появления (Fade In)
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(toast, tweenInfo, { BackgroundTransparency = 0.15 }):Play()
	TweenService:Create(stroke, tweenInfo, { Transparency = 0 }):Play()
	TweenService:Create(icon, tweenInfo, { TextTransparency = 0 }):Play()
	TweenService:Create(label, tweenInfo, { TextTransparency = 0 }):Play()

	-- Авто-удаление через 3 секунды
	task.delay(3.0, function()
		if not toast or not toast.Parent then return end

		-- Анимация исчезновения (Fade Out)
		local fadeTween = TweenService:Create(toast, tweenInfo, { BackgroundTransparency = 1 })
		TweenService:Create(stroke, tweenInfo, { Transparency = 1 }):Play()
		TweenService:Create(icon, tweenInfo, { TextTransparency = 1 }):Play()
		TweenService:Create(label, tweenInfo, { TextTransparency = 1 }):Play()

		fadeTween:Play()
		fadeTween.Completed:Connect(function()
			toast:Destroy()
		end)
	end)
end

return ToastManager
