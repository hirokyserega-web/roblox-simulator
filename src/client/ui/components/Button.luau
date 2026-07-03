-- Компонент сочной 3D-кнопки в стиле Roblox-симулятора
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.theme.Theme)

local ButtonFactory = {}

function ButtonFactory.create(options)
	local text = options.Text or "Кнопка"
	local color = options.Color or Theme.Colors.Accent
	local size = options.Size or UDim2.new(0, 120, 0, 44)
	local position = options.Position or UDim2.new(0, 0, 0, 0)
	local parent = options.Parent
	local onClick = options.OnClick

	-- 1. Тень кнопки (Нижняя часть 3D-эффекта)
	local shadowFrame = Instance.new("Frame")
	shadowFrame.Name = "Button3D_Shadow"
	shadowFrame.Size = size
	shadowFrame.Position = position
	
	-- Делаем цвет тени темнее оригинального
	local h, s, v = color:ToHSV()
	shadowFrame.BackgroundColor3 = Color3.fromHSV(h, s, math.clamp(v - 0.25, 0, 1))
	shadowFrame.BorderSizePixel = 0
	shadowFrame.Parent = parent

	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = options.CornerRadius or Theme.Sizes.CornerRadius
	shadowCorner.Parent = shadowFrame

	-- 2. Сама кнопка (Верхняя часть, которая нажимается)
	local button = Instance.new("TextButton")
	button.Name = "ButtonTop"
	button.Size = UDim2.new(1, 0, 1, -4) -- Оставляем 4px снизу для тени
	button.Position = UDim2.new(0, 0, 0, -4) -- Приподнята по умолчанию
	button.BackgroundColor3 = color
	button.BorderSizePixel = 0
	button.Font = Theme.Fonts.Button
	button.TextColor3 = Theme.Colors.Text
	button.TextSize = options.TextSize or 18
	button.Text = text
	button.TextStrokeTransparency = 0.5
	button.TextStrokeColor3 = Theme.Colors.Stroke
	button.Parent = shadowFrame

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = options.CornerRadius or Theme.Sizes.CornerRadius
	buttonCorner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = Theme.Sizes.BorderWidth
	stroke.Color = Theme.Colors.Stroke
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = button

	-- Легкий градиент
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 220))
	})
	gradient.Rotation = 90
	gradient.Parent = button

	-- Состояние активности кнопки
	local enabled = true

	-- Анимации наведения и нажатия
	local function playSound(soundId)
		local sound = Instance.new("Sound")
		sound.SoundId = soundId
		sound.Volume = 0.5
		sound.Parent = game:GetService("SoundService")
		sound:Play()
		game:GetService("Debris"):AddItem(sound, 1.5)
	end

	button.MouseEnter:Connect(function()
		if not enabled then return end
		-- Наведение: кнопка слегка приподнимается еще выше
		TweenService:Create(button, TweenInfo.new(0.15), {
			Position = UDim2.new(0, 0, 0, -6),
			BackgroundColor3 = Color3.fromHSV(h, s, math.clamp(v + 0.08, 0, 1))
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		if not enabled then return end
		-- Возврат в обычное состояние
		TweenService:Create(button, TweenInfo.new(0.15), {
			Position = UDim2.new(0, 0, 0, -4),
			BackgroundColor3 = color
		}):Play()
	end)

	button.MouseButton1Down:Connect(function()
		if not enabled then return end
		-- Нажатие: кнопка уходит вниз к уровню тени
		TweenService:Create(button, TweenInfo.new(0.08), {
			Position = UDim2.new(0, 0, 0, 0)
		}):Play()
	end)

	button.MouseButton1Up:Connect(function()
		if not enabled then return end
		-- Отжатие кнопки: возврат и запуск клика
		TweenService:Create(button, TweenInfo.new(0.1), {
			Position = UDim2.new(0, 0, 0, -4)
		}):Play()
		
		playSound(Theme.Sounds.Click)
		if onClick then
			onClick()
		end
	end)

	-- API для переключения активности кнопки
	local api = {}
	api.Instance = shadowFrame
	
	function api.SetEnabled(state: boolean)
		enabled = state
		if state then
			button.BackgroundColor3 = color
			button.TextColor3 = Theme.Colors.Text
			shadowFrame.BackgroundColor3 = Color3.fromHSV(h, s, math.clamp(v - 0.25, 0, 1))
			button.Position = UDim2.new(0, 0, 0, -4)
		else
			-- Выключенное состояние (Серая неактивная кнопка)
			button.BackgroundColor3 = Color3.fromRGB(110, 110, 115)
			button.TextColor3 = Color3.fromRGB(180, 180, 180)
			shadowFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 75)
			button.Position = UDim2.new(0, 0, 0, 0)
		end
	end

	function api.SetText(newText: string)
		button.Text = newText
	end

	function api.Destroy()
		shadowFrame:Destroy()
	end

	return api
end

return ButtonFactory
