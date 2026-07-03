-- Компонент плавного прогресс-бара (ProgressBar) в стиле Roblox-симулятора
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.theme.Theme)

local ProgressBarFactory = {}

function ProgressBarFactory.create(options)
	local size = options.Size or UDim2.new(1, 0, 0, 16)
	local position = options.Position or UDim2.new(0, 0, 0, 0)
	local fillColor = options.FillColor or Theme.Colors.Success
	local parent = options.Parent

	-- 1. Фоновая часть бара
	local bg = Instance.new("Frame")
	bg.Name = "ProgressBar_Background"
	bg.Size = size
	bg.Position = position
	bg.BackgroundColor3 = Theme.Colors.BackgroundSecondary
	bg.BackgroundTransparency = 0.4
	bg.BorderSizePixel = 0
	bg.Parent = parent

	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = Theme.Sizes.CornerRadius
	bgCorner.Parent = bg

	local bgStroke = Instance.new("UIStroke")
	bgStroke.Thickness = Theme.Sizes.BorderWidth - 1
	bgStroke.Color = Theme.Colors.Stroke
	bgStroke.Parent = bg

	-- 2. Заполняющая часть (Fill)
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = fillColor
	fill.BorderSizePixel = 0
	fill.Parent = bg

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = Theme.Sizes.CornerRadius
	fillCorner.Parent = fill

	-- Плавный градиент для объема заливки
	local fillGradient = Instance.new("UIGradient")
	fillGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 220))
	})
	fillGradient.Rotation = 90
	fillGradient.Parent = fill

	-- API управления
	local api = {}
	api.Instance = bg

	-- Установка уровня прогресса (от 0 до 1)
	function api.SetProgress(progress: number)
		local clampedProgress = math.clamp(progress, 0, 1)
		
		-- Анимируем изменение шкалы заполнения
		TweenService:Create(fill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(clampedProgress, 0, 1, 0)
		}):Play()
	end

	function api.SetColor(color: Color3)
		fill.BackgroundColor3 = color
	end

	function api.Destroy()
		bg:Destroy()
	end

	return api
end

return ProgressBarFactory
