-- Компонент диалоговой панели (Panel) в стиле Roblox-симулятора (Новый дизайн с обводками)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.theme.Theme)

local PanelFactory = {}

local player = Players.LocalPlayer

-- Форматирование чисел
local function formatNumber(value: number): string
	local formatted = tostring(value)
	while true do  
		local k
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

function PanelFactory.create(options)
	local titleText = options.Title or "ОКНО"
	local size = options.Size or UDim2.new(0, 420, 0, 340)
	local position = options.Position or UDim2.new(0.5, -210, 0.5, -170)
	local parent = options.Parent
	local onClose = options.OnClose
	local showBalance = options.ShowBalance ~= false -- По умолчанию показываем баланс в шапке

	-- Основной контейнер окна
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "Panel_" .. titleText
	mainFrame.Size = size
	mainFrame.Position = position
	mainFrame.BackgroundColor3 = Theme.Colors.Background
	mainFrame.BorderSizePixel = 0
	mainFrame.Visible = false
	mainFrame.Parent = parent

	-- Закругление углов панели
	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = Theme.Sizes.PanelCornerRadius
	panelCorner.Parent = mainFrame

	-- Обводка рамки панели (Толстая темная обводка как на скриншоте)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 4
	stroke.Color = Theme.Colors.Stroke
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = mainFrame

	-- Тень панели (Смещение вниз-вправо)
	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 0, 1, 0)
	shadow.Position = UDim2.new(0, 6, 0, 10)
	shadow.BackgroundColor3 = Color3.fromHex("06070B")
	shadow.BackgroundTransparency = 0.4
	shadow.ZIndex = mainFrame.ZIndex - 1
	shadow.BorderSizePixel = 0
	shadow.Parent = mainFrame

	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = Theme.Sizes.PanelCornerRadius
	shadowCorner.Parent = shadow

	-- Заголовок окна (Центрированный, заглавными буквами с толстой обводкой текста)
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 40)
	titleLabel.Position = UDim2.new(0, 0, 0, 15)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Theme.Fonts.Title
	titleLabel.TextSize = 24
	titleLabel.TextColor3 = Theme.Colors.Text
	titleLabel.Text = string.upper(titleText)
	titleLabel.TextStrokeTransparency = 0
	titleLabel.TextStrokeColor3 = Theme.Colors.Stroke
	titleLabel.Parent = mainFrame

	-- Баланс игрока под заголовком (Зеленая плашка)
	local balanceContainer = nil
	local balanceTextLabel = nil
	local balanceConnection = nil

	if showBalance then
		balanceContainer = Instance.new("Frame")
		balanceContainer.Name = "BalanceContainer"
		balanceContainer.Size = UDim2.new(0, 150, 0, 30)
		balanceContainer.Position = UDim2.new(0.5, -75, 0, 52)
		balanceContainer.BackgroundColor3 = Color3.fromHex("183d2a") -- Темно-зеленый
		balanceContainer.BorderSizePixel = 0
		balanceContainer.Parent = mainFrame

		local balCorner = Instance.new("UICorner")
		balCorner.CornerRadius = UDim.new(0, 15)
		balCorner.Parent = balanceContainer

		local balStroke = Instance.new("UIStroke")
		balStroke.Thickness = 2
		balStroke.Color = Theme.Colors.Stroke
		balStroke.Parent = balanceContainer

		-- Иконка наличных внутри баланса
		local cashIcon = Instance.new("ImageLabel")
		cashIcon.Name = "CashIcon"
		cashIcon.Size = UDim2.new(0, 20, 0, 20)
		cashIcon.Position = UDim2.new(0, 8, 0.5, -10)
		cashIcon.BackgroundTransparency = 1
		cashIcon.Image = "rbxassetid://10499147573" -- Иконка купюры/монеты
		cashIcon.Parent = balanceContainer

		-- Текст баланса
		balanceTextLabel = Instance.new("TextLabel")
		balanceTextLabel.Name = "BalanceTextLabel"
		balanceTextLabel.Size = UDim2.new(1, -36, 1, 0)
		balanceTextLabel.Position = UDim2.new(0, 32, 0, 0)
		balanceTextLabel.BackgroundTransparency = 1
		balanceTextLabel.Font = Theme.Fonts.Title
		balanceTextLabel.TextSize = 14
		balanceTextLabel.TextColor3 = Theme.Colors.Success
		balanceTextLabel.TextXAlignment = Enum.TextXAlignment.Center
		balanceTextLabel.Text = "0"
		balanceTextLabel.TextStrokeTransparency = 0
		balanceTextLabel.TextStrokeColor3 = Theme.Colors.Stroke
		balanceTextLabel.Parent = balanceContainer

		local function updateBalance()
			local money = player:GetAttribute("Money") or 0
			balanceTextLabel.Text = formatNumber(money)
		end
		balanceConnection = player:GetAttributeChangedSignal("Money"):Connect(updateBalance)
		updateBalance()
	end

	-- Контейнер для содержимого (Смещен ниже, чтобы не перекрывать заголовок)
	local contentYOffset = showBalance and 90 or 60
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -30, 1, -contentYOffset - 20)
	content.Position = UDim2.new(0, 15, 0, contentYOffset)
	content.BackgroundTransparency = 1
	content.Parent = mainFrame

	-- Кнопка закрытия (Сочный красный квадратик с белым крестиком как на скриншоте)
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 32, 0, 32)
	closeBtn.Position = UDim2.new(1, -45, 0, 15)
	closeBtn.BackgroundColor3 = Color3.fromHex("ff4a68")
	closeBtn.BorderSizePixel = 0
	closeBtn.Font = Theme.Fonts.Title
	closeBtn.TextSize = 16
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.Text = "✕"
	closeBtn.Parent = mainFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeBtn

	local closeStroke = Instance.new("UIStroke")
	closeStroke.Thickness = 3
	closeStroke.Color = Theme.Colors.Stroke
	closeStroke.Parent = closeBtn

	-- Анимация наведения на кнопку закрытия
	closeBtn.MouseEnter:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromHex("ff2b4e")
		}):Play()
	end)

	closeBtn.MouseLeave:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromHex("ff4a68")
		}):Play()
	end)

	closeBtn.MouseButton1Click:Connect(function()
		local sound = Instance.new("Sound")
		sound.SoundId = Theme.Sounds.Click
		sound.Volume = 0.5
		sound.Parent = game:GetService("SoundService")
		sound:Play()
		game:GetService("Debris"):AddItem(sound, 1.5)

		if onClose then
			onClose()
		end
	end)

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
		titleLabel.TextTransparency = 1
		closeBtn.BackgroundTransparency = 1
		closeBtn.TextTransparency = 1

		if balanceContainer then
			balanceContainer.BackgroundTransparency = 1
			balanceTextLabel.TextTransparency = 1
			balanceContainer.CashIcon.ImageTransparency = 1
		end
		
		mainFrame.Visible = true

		TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = size,
			Position = position,
			BackgroundTransparency = 0
		}):Play()

		TweenService:Create(shadow, TweenInfo.new(0.3), { BackgroundTransparency = 0.4 }):Play()
		TweenService:Create(titleLabel, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
		TweenService:Create(closeBtn, TweenInfo.new(0.3), { BackgroundTransparency = 0, TextTransparency = 0 }):Play()

		if balanceContainer then
			TweenService:Create(balanceContainer, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play()
			TweenService:Create(balanceTextLabel, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
			TweenService:Create(balanceContainer.CashIcon, TweenInfo.new(0.3), { ImageTransparency = 0 }):Play()
		end
	end

	-- Плавное скрытие
	function api.Close()
		local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, size.X.Offset * 0.8, 0, size.Y.Offset * 0.8),
			Position = UDim2.new(0.5, -size.X.Offset * 0.4, 0.5, -size.Y.Offset * 0.4),
			BackgroundTransparency = 1
		})
		
		TweenService:Create(shadow, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(titleLabel, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
		TweenService:Create(closeBtn, TweenInfo.new(0.2), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()

		if balanceContainer then
			TweenService:Create(balanceContainer, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(balanceTextLabel, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
			TweenService:Create(balanceContainer.CashIcon, TweenInfo.new(0.2), { ImageTransparency = 1 }):Play()
		end

		closeTween:Play()
		closeTween.Completed:Connect(function()
			mainFrame.Visible = false
			-- Сброс размеров к исходным
			mainFrame.Size = size
			mainFrame.Position = position
		end)
	end

	function api.Destroy()
		if balanceConnection then
			balanceConnection:Disconnect()
		end
		mainFrame:Destroy()
	end

	return api
end

return PanelFactory
