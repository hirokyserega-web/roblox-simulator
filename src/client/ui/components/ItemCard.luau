-- Компонент карточки предмета (ItemCard) в стиле Roblox-симулятора
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.theme.Theme)

local ItemCardFactory = {}

function ItemCardFactory.create(options)
	local size = options.Size or UDim2.new(0, 90, 0, 105)
	local position = options.Position or UDim2.new(0, 0, 0, 0)
	local rarity = options.Rarity or "Common"
	local parent = options.Parent
	local onClick = options.OnClick

	-- 1. Главный контейнер карточки
	local card = Instance.new("Frame")
	card.Name = "ItemCard_" .. (options.Title or "Item")
	card.Size = size
	card.Position = position
	card.BackgroundColor3 = Theme.Colors.BackgroundSecondary
	if options.Equipped then
		card.BackgroundColor3 = Color3.fromRGB(30, 45, 35) -- Зеленоватый оттенок для надетых
	end
	card.BorderSizePixel = 0
	card.Parent = parent

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = Theme.Sizes.CornerRadius
	cardCorner.Parent = card

	-- 2. Обводка (Stroke) по редкости
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = Theme.Sizes.BorderWidth
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = card

	-- Задаем цвет обводки на основе редкости
	local rColor = Theme.RarityColors[rarity] or Theme.RarityColors.Common
	stroke.Color = rColor

	-- Анимация для Secret (Радужная обводка)
	local connection = nil
	if rarity == "Secret" then
		local gradient = Instance.new("UIGradient")
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 127, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(75, 0, 130)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
		})
		gradient.Rotation = 0
		gradient.Parent = stroke

		-- Бесконечное вращение градиента
		connection = RunService.Heartbeat:Connect(function()
			gradient.Rotation = (gradient.Rotation + 2) % 360
		end)
	elseif options.Equipped then
		stroke.Color = Theme.Colors.Success -- Зеленая обводка для одетых питомцев
	end

	-- 3. Название предмета (Текст)
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, -10, 0, 24)
	titleLabel.Position = UDim2.new(0, 5, 0, 6)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Theme.Fonts.Title
	titleLabel.TextSize = 12
	titleLabel.TextColor3 = rColor
	titleLabel.Text = options.Title or "Предмет"
	titleLabel.TextStrokeTransparency = 0.5
	titleLabel.TextStrokeColor3 = Theme.Colors.Stroke
	titleLabel.Parent = card

	-- 4. Внутренний значок/декорация (Центральный элемент)
	local inner = Instance.new("Frame")
	inner.Name = "Icon"
	inner.Size = UDim2.new(0, 30, 0, 30)
	inner.Position = UDim2.new(0.5, -15, 0.5, -18)
	inner.BackgroundColor3 = options.IconColor or Theme.Colors.Accent
	inner.BorderSizePixel = 0
	inner.Parent = card

	local innerCorner = Instance.new("UICorner")
	innerCorner.CornerRadius = UDim.new(1, 0)
	innerCorner.Parent = inner

	-- 5. Подпись / Значение снизу
	local subLabel = Instance.new("TextLabel")
	subLabel.Name = "SubLabel"
	subLabel.Size = UDim2.new(1, -10, 0, 20)
	subLabel.Position = UDim2.new(0, 5, 1, -22)
	subLabel.BackgroundTransparency = 1
	subLabel.Font = Theme.Fonts.Title
	subLabel.TextSize = 11
	subLabel.TextColor3 = Color3.fromRGB(241, 196, 15) -- Золотой
	subLabel.Text = options.Subtext or ""
	subLabel.Parent = card

	-- Кнопка для кликов
	local button = Instance.new("TextButton")
	button.Name = "ClickButton"
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.Parent = card

	button.MouseButton1Click:Connect(function()
		-- Короткий эффект сжатия при клике
		local tween = TweenService:Create(card, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, size.X.Offset * 0.9, 0, size.Y.Offset * 0.9)
		})
		tween:Play()
		tween.Completed:Connect(function()
			TweenService:Create(card, TweenInfo.new(0.08), { Size = size }):Play()
			if onClick then
				onClick()
			end
		end)
	end)

	-- API управления
	local api = {}
	api.Instance = card

	function api.Destroy()
		if connection then
			connection:Disconnect()
		end
		card:Destroy()
	end

	return api
end

return ItemCardFactory
