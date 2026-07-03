-- Оверлей полоски захвата призрака (CaptureBar)
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Theme = require(script.Parent.Parent.theme.Theme)
local ProgressBar = require(script.Parent.Parent.components.ProgressBar)

local CaptureBar = {}

function CaptureBar.create(options)
	local parent = options.Parent

	-- Главный контейнер оверлея
	local container = Instance.new("Frame")
	container.Name = "CaptureOverlayFrame"
	container.Size = UDim2.new(0, 300, 0, 50)
	container.Position = UDim2.new(0.5, -150, 1, -145) -- Над док-панелью
	container.BackgroundColor3 = Theme.Colors.Background
	container.BackgroundTransparency = 0.2
	container.BorderSizePixel = 0
	container.Visible = false
	container.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Sizes.CornerRadius
	corner.Parent = container

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = Theme.Sizes.BorderWidth
	stroke.Color = Theme.Colors.Stroke
	stroke.Parent = container

	-- Иконка призрака
	local ghostIcon = Instance.new("TextLabel")
	ghostIcon.Size = UDim2.new(0, 30, 0, 30)
	ghostIcon.Position = UDim2.new(0, 8, 0.5, -15)
	ghostIcon.BackgroundTransparency = 1
	ghostIcon.Font = Theme.Fonts.Title
	ghostIcon.TextSize = 18
	ghostIcon.Text = "👻"
	ghostIcon.Parent = container

	local iconStroke = Instance.new("UIStroke")
	iconStroke.Thickness = 1
	iconStroke.Color = Theme.Colors.Success
	iconStroke.Parent = ghostIcon

	-- Подпись Удерживай!
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -55, 0, 18)
	title.Position = UDim2.new(0, 48, 0, 4)
	title.BackgroundTransparency = 1
	title.Font = Theme.Fonts.Title
	title.TextSize = 10
	title.TextColor3 = Theme.Colors.Text
	title.Text = "УДЕРЖИВАЙ КНОПКУ МЫШИ!"
	title.Parent = container

	-- Прогресс-бар заполнения
	local pBar = ProgressBar.create({
		Size = UDim2.new(1, -55, 0, 10),
		Position = UDim2.new(0, 48, 1, -20),
		FillColor = Theme.Colors.Success,
		Parent = container
	})

	local api = {}
	api.Instance = container

	local function playSound(soundId, vol)
		local s = Instance.new("Sound")
		s.SoundId = soundId
		s.Volume = vol or 0.5
		s.Parent = SoundService
		s:Play()
		game:GetService("Debris"):AddItem(s, 1.5)
	end

	-- Показать полоску захвата
	function api.Show(ghostInfo)
		local rarity = ghostInfo.Rarity or "Common"
		local rColor = Theme.RarityColors[rarity] or Theme.Colors.Success

		pBar.SetColor(rColor)
		iconStroke.Color = rColor
		pBar.SetProgress(0)

		container.Visible = true
	end

	-- Обновить прогресс заполнения
	function api.SetProgress(value: number)
		pBar.SetProgress(value)

		-- Вспышка на 100%
		if value >= 1 and container.Visible then
			task.spawn(function()
				local flash = Instance.new("Frame")
				flash.Size = UDim2.new(1, 0, 1, 0)
				flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				flash.ZIndex = 100
				flash.Parent = container

				playSound(Theme.Sounds.Success, 0.4)
				TweenService:Create(flash, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
				task.delay(0.35, function() flash:Destroy() end)
			end)
		end
	end

	-- Эффект дрожания / атаки (краснеет и трясется)
	function api.Shake()
		local origPos = UDim2.new(0.5, -150, 1, -145)
		local shakePos1 = UDim2.new(0.5, -145, 1, -145)
		local shakePos2 = UDim2.new(0.5, -155, 1, -145)

		task.spawn(function()
			stroke.Color = Theme.Colors.Error
			for i = 1, 4 do
				container.Position = (i % 2 == 0) and shakePos1 or shakePos2
				task.wait(0.04)
			end
			container.Position = origPos
			stroke.Color = Theme.Colors.Stroke
		end)
	end

	-- Скрыть
	function api.Hide()
		container.Visible = false
	end

	function api.Destroy()
		pBar.Destroy()
		container:Destroy()
	end

	return api
end

return CaptureBar
