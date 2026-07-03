-- Компонент диалоговой панели (Panel) в стиле Roblox-симулятора
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Button)

local PanelFactory = {}

function PanelFactory.create(options)
	local titleText = options.Title or "ОКНО"
	local size = options.Size or UDim2.new(0, 400, 0, 300)
	local position = options.Position or UDim2.new(0.5, -200, 0.5, -150)
	local parent = options.Parent
	local onClose = options.OnClose

	-- Основной контейнер окна
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "Panel_" .. titleText
	mainFrame.Size = size
	mainFrame.Position = position
	mainFrame.BackgroundColor3 = Theme.Colors.Background
	mainFrame.BackgroundTransparency = 0.1
	mainFrame.BorderSizePixel = 0
	mainFrame.Visible = false
	mainFrame.Parent = parent

	-- Закругление углов панели
	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = Theme.Sizes.PanelCornerRadius
	panelCorner.Parent = mainFrame

	-- Обводка рамки панели
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = Theme.Sizes.BorderWidth + 1
	stroke.Color = Theme.Colors.Stroke
	stroke.Parent = mainFrame

	-- Неоновый отблеск по контуру панели (UIGradient на обводку)
	local strokeGradient = Instance.new("UIGradient")
	strokeGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.Colors.Accent),
		ColorSequenceKeypoint.new(1, Theme.Colors.Neon)
	})
	strokeGradient.Rotation = 45
	strokeGradient.Parent = stroke

	-- Декоративная тень (Простой приглушенный черный фрейм сзади)
	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 0, 1, 0)
	shadow.Position = UDim2.new(0, 8, 0, 8) -- Смещение тени на 8 пикселей вниз-вправо
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 0.6
	shadow.ZIndex = mainFrame.ZIndex - 1
	shadow.BorderSizePixel = 0
	shadow.Parent = mainFrame

	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = Theme.Sizes.PanelCornerRadius
	shadowCorner.Parent = shadow

	-- Шапка окна (Header)
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 50)
	header.BackgroundColor3 = Theme.Colors.BackgroundSecondary
	header.BorderSizePixel = 0
	header.Parent = mainFrame

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = Theme.Sizes.PanelCornerRadius
	headerCorner.Parent = header

	-- Скрываем нижние закругления шапки, чтобы она сливалась с телом панели
	local clipFrame = Instance.new("Frame")
	clipFrame.Name = "ClipFrame"
	clipFrame.Size = UDim2.new(1, 0, 0, 10)
	clipFrame.Position = UDim2.new(0, 0, 1, -10)
	clipFrame.BackgroundColor3 = Theme.Colors.BackgroundSecondary
	clipFrame.BorderSizePixel = 0
	clipFrame.Parent = header

	-- Заголовок окна
	local label = Instance.new("TextLabel")
	label.Name = "TitleLabel"
	label.Size = UDim2.new(1, -100, 1, 0)
	label.Position = UDim2.new(0, 20, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Theme.Fonts.Title
	label.TextSize = 22
	label.TextColor3 = Theme.Colors.Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = titleText
	label.TextStrokeTransparency = 0.5
	label.TextStrokeColor3 = Theme.Colors.Stroke
	label.Parent = header

	-- Контейнер для содержимого (Content)
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -20, 1, -70)
	content.Position = UDim2.new(0, 10, 0, 60)
	content.BackgroundTransparency = 1
	content.Parent = mainFrame

	-- Кнопка закрытия окна (Крестик)
	local closeBtn = Button.create({
		Text = "✕",
		Color = Theme.Colors.Error,
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(1, -42, 0, 9),
		TextSize = 14,
		Parent = header,
		OnClick = function()
			if onClose then
				onClose()
			end
		end
	})

	-- API управления окном
	local api = {}
	api.Instance = mainFrame
	api.Content = content

	-- Плавное появление (scale 0.8 -> 1.0 + fade)
	function api.Open()
		mainFrame.Size = UDim2.new(0, size.X.Offset * 0.8, 0, size.Y.Offset * 0.8)
		mainFrame.Position = UDim2.new(0.5, -mainFrame.Size.X.Offset/2, 0.5, -mainFrame.Size.Y.Offset/2)
		mainFrame.BackgroundTransparency = 1
		shadow.BackgroundTransparency = 1
		header.BackgroundTransparency = 1
		label.TextTransparency = 1
		
		mainFrame.Visible = true

		TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = size,
			Position = position,
			BackgroundTransparency = 0.1
		}):Play()

		TweenService:Create(shadow, TweenInfo.new(0.3), { BackgroundTransparency = 0.6 }):Play()
		TweenService:Create(header, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play()
		TweenService:Create(label, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
	end

	-- Плавное скрытие
	function api.Close()
		local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, size.X.Offset * 0.8, 0, size.Y.Offset * 0.8),
			Position = UDim2.new(0.5, -size.X.Offset * 0.4, 0.5, -size.Y.Offset * 0.4),
			BackgroundTransparency = 1
		})
		
		TweenService:Create(shadow, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(header, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(label, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()

		closeTween:Play()
		closeTween.Completed:Connect(function()
			mainFrame.Visible = false
		end)
	end

	return api
end

return PanelFactory
