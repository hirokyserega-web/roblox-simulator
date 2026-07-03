-- Попап результата продажи призраков (SellPopup)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Theme = require(script.Parent.Parent.theme.Theme)
local UIManager = require(script.Parent.Parent.UIManager)

local player = Players.LocalPlayer
local sellCompletedEvent = Remotes.getEvent("SellCompleted")

local SellPopup = {}

local function playSound(soundId, vol)
	local s = Instance.new("Sound")
	s.SoundId = soundId
	s.Volume = vol or 0.6
	s.Parent = SoundService
	s:Play()
	game:GetService("Debris"):AddItem(s, 1.5)
end

local function spawnConfetti(parentFrame)
	-- Спавним случайные разноцветные конфетти, падающие вниз
	local colors = {
		Color3.fromRGB(241, 196, 15),
		Color3.fromRGB(46, 204, 113),
		Color3.fromRGB(52, 152, 219),
		Color3.fromRGB(231, 76, 60),
		Color3.fromRGB(155, 89, 182)
	}

	for i = 1, 15 do
		local bit = Instance.new("Frame")
		bit.Size = UDim2.new(0, math.random(6, 10), 0, math.random(6, 10))
		bit.Position = UDim2.new(math.random() * 0.8 + 0.1, 0, -0.05, 0)
		bit.BackgroundColor3 = colors[math.random(#colors)]
		bit.BorderSizePixel = 0
		bit.ZIndex = 300
		bit.Rotation = math.random(0, 360)
		bit.Parent = parentFrame

		local bitCorner = Instance.new("UICorner")
		bitCorner.CornerRadius = UDim.new(0.5, 0)
		bitCorner.Parent = bit

		-- Анимируем падение и вращение
		local fallTween = TweenService:Create(bit, TweenInfo.new(math.random(1.0, 2.0), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(bit.Position.X.Scale + (math.random() - 0.5) * 0.2, 0, 1.05, 0),
			Rotation = bit.Rotation + math.random(180, 540),
			BackgroundTransparency = 1
		})
		fallTween:Play()
		fallTween.Completed:Connect(function()
			bit:Destroy()
		end)
	end
end

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

local function showSellPopup(earnings: number, caughtGhosts: table)
	local screenGui = UIManager.getScreenGui()

	-- Контейнер попапа
	local frame = Instance.new("Frame")
	frame.Name = "SellPopupFrame"
	frame.Size = UDim2.new(0, 280, 0, 200)
	frame.Position = UDim2.new(0.5, -140, 0.45, -100)
	frame.BackgroundColor3 = Theme.Colors.Background
	frame.BorderSizePixel = 0
	frame.ZIndex = 250
	frame.ClipsDescendants = false
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Sizes.CornerRadius
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = Theme.Sizes.BorderWidth
	stroke.Color = Theme.Colors.Success
	stroke.Parent = frame

	-- Шапка
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 30)
	header.Position = UDim2.new(0, 0, 0, 12)
	header.BackgroundTransparency = 1
	header.Font = Theme.Fonts.Title
	header.TextSize = 14
	header.TextColor3 = Theme.Colors.TextSecondary
	header.Text = "УСПЕШНАЯ ПРОДАЖА"
	header.Parent = frame

	-- Начисленная валюта крупно
	local earnLabel = Instance.new("TextLabel")
	earnLabel.Size = UDim2.new(1, 0, 0, 45)
	earnLabel.Position = UDim2.new(0, 0, 0, 38)
	earnLabel.BackgroundTransparency = 1
	earnLabel.Font = Theme.Fonts.Title
	earnLabel.TextSize = 32
	earnLabel.TextColor3 = Theme.Colors.Success
	earnLabel.Text = string.format("+$%s 💰", formatNumber(earnings))
	earnLabel.Parent = frame

	-- Группируем проданных
	local counts = {}
	for _, rarity in ipairs(caughtGhosts) do
		counts[rarity] = (counts[rarity] or 0) + 1
	end

	-- Строка проданного списка
	local listContainer = Instance.new("Frame")
	listContainer.Size = UDim2.new(1, -20, 0, 60)
	listContainer.Position = UDim2.new(0, 10, 0, 85)
	listContainer.BackgroundTransparency = 1
	listContainer.Parent = frame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 4)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Parent = listContainer

	for rarity, count in pairs(counts) do
		local rLabel = Instance.new("TextLabel")
		rLabel.Size = UDim2.new(1, 0, 0, 16)
		rLabel.BackgroundTransparency = 1
		rLabel.Font = Theme.Fonts.Bold
		rLabel.TextSize = 12
		rLabel.TextColor3 = Theme.RarityColors[rarity] or Theme.Colors.Text
		rLabel.Text = string.format("%s: %d призраков", rarity:upper(), count)
		rLabel.Parent = listContainer
	end

	-- Звук монеток
	playSound(Theme.Sounds.Success, 0.5)

	-- Конфетти
	spawnConfetti(frame)

	-- Pop-in анимация масштаба
	frame.Size = UDim2.new(0, 0, 0, 0)
	frame.Position = UDim2.new(0.5, 0, 0.45, 0)
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(frame, tweenInfo, {
		Size = UDim2.new(0, 280, 0, 200),
		Position = UDim2.new(0.5, -140, 0.45, -100)
	}):Play()

	-- Авто-закрытие через 2.5 секунды
	task.delay(2.5, function()
		if frame and frame.Parent then
			local fadeTween = TweenService:Create(frame, TweenInfo.new(0.3), { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.45, 0) })
			fadeTween:Play()
			fadeTween.Completed:Connect(function()
				frame:Destroy()
			end)
		end
	end)
end

function SellPopup.init()
	sellCompletedEvent.OnClientEvent:Connect(showSellPopup)
end

SellPopup.init()

return SellPopup
