-- Виджет детектора сигналов призраков (DetectorWidget)
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Theme = require(script.Parent.Parent.theme.Theme)

local DetectorWidget = {}

function DetectorWidget.create(options)
	local parent = options.Parent

	-- Контейнер
	local container = Instance.new("Frame")
	container.Name = "DetectorWidget"
	container.Size = UDim2.new(0, 150, 0, 70)
	container.Position = options.Position or UDim2.new(0, 20, 0.4, -90)
	container.BackgroundColor3 = Theme.Colors.Background
	container.BackgroundTransparency = 0.2
	container.BorderSizePixel = 0
	container.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Sizes.CornerRadius
	corner.Parent = container

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = Theme.Sizes.BorderWidth
	stroke.Color = Theme.Colors.Stroke
	stroke.Parent = container

	-- Иконка радара
	local radarIcon = Instance.new("TextLabel")
	radarIcon.Size = UDim2.new(0, 40, 0, 40)
	radarIcon.Position = UDim2.new(0, 8, 0, 8)
	radarIcon.BackgroundTransparency = 1
	radarIcon.Font = Theme.Fonts.Title
	radarIcon.TextSize = 22
	radarIcon.Text = "📡"
	radarIcon.Parent = container

	-- Шкала сигнала (5 полосок)
	local barsContainer = Instance.new("Frame")
	barsContainer.Size = UDim2.new(0, 80, 0, 24)
	barsContainer.Position = UDim2.new(0, 55, 0, 16)
	barsContainer.BackgroundTransparency = 1
	barsContainer.Parent = container

	local barLayout = Instance.new("UIListLayout")
	barLayout.FillDirection = Enum.FillDirection.Horizontal
	barLayout.Padding = UDim.new(0, 4)
	barLayout.SortOrder = Enum.SortOrder.LayoutOrder
	barLayout.Parent = barsContainer

	local signalBars = {}
	for i = 1, 5 do
		local bar = Instance.new("Frame")
		bar.Name = "Bar_" .. i
		bar.Size = UDim2.new(0, 11, 1, 0)
		bar.BackgroundColor3 = Theme.Colors.BackgroundSecondary
		bar.BorderSizePixel = 0
		bar.LayoutOrder = i
		bar.Parent = barsContainer

		local barCorner = Instance.new("UICorner")
		barCorner.CornerRadius = UDim.new(0, 3)
		barCorner.Parent = bar

		table.insert(signalBars, bar)
	end

	-- Подпись редкости
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -16, 0, 20)
	label.Position = UDim2.new(0, 8, 1, -22)
	label.BackgroundTransparency = 1
	label.Font = Theme.Fonts.Body
	label.TextSize = 10
	label.TextColor3 = Theme.Colors.TextSecondary
	label.Text = "СИГНАЛ: ОТСУТСТВУЕТ"
	label.Parent = container

	-- Состояние детектора
	local currentProgress = 0
	local isTicking = true
	local lastTickTime = 0

	local function playSound(soundId, vol)
		local s = Instance.new("Sound")
		s.SoundId = soundId
		s.Volume = vol or 0.3
		s.Parent = SoundService
		s:Play()
		game:GetService("Debris"):AddItem(s, 1.2)
	end

	-- Логика пиканья при обнаружении сигнала в отдельном потоке
	task.spawn(function()
		while isTicking do
			if currentProgress > 0.05 then
				local factor = currentProgress
				local rate = 0.15 + (1 - factor) * 0.8 -- частота кликов

				if tick() - lastTickTime >= rate then
					lastTickTime = tick()
					playSound("rbxassetid://9120619853", 0.25)

					-- Короткий импульс масштаба панели
					local origSize = UDim2.new(0, 150, 0, 70)
					local pulseSize = UDim2.new(0, 155, 0, 72)
					TweenService:Create(container, TweenInfo.new(0.08), {Size = pulseSize}):Play()
					task.delay(0.08, function()
						if container and container.Parent then
							TweenService:Create(container, TweenInfo.new(0.08), {Size = origSize}):Play()
						end
					end)
				end
			end
			task.wait(0.05)
		end
	end)

	local api = {}
	api.Instance = container

	-- Задать уровень сигнала (от 0 до 1)
	function api.SetSignal(progress: number)
		currentProgress = math.clamp(progress, 0, 1)

		if currentProgress <= 0.05 then
			-- Нет сигнала
			for _, bar in ipairs(signalBars) do
				bar.BackgroundColor3 = Theme.Colors.BackgroundSecondary
			end
			label.Text = "СИГНАЛ: ОТСУТСТВУЕТ"
			label.TextColor3 = Theme.Colors.TextSecondary
		else
			-- Отрисовка полосок по силе сигнала
			local litCount = math.clamp(math.ceil(currentProgress * 5), 1, 5)
			for i = 1, 5 do
				if i <= litCount then
					signalBars[i].BackgroundColor3 = Theme.Colors.Neon
				else
					signalBars[i].BackgroundColor3 = Theme.Colors.BackgroundSecondary
				end
			end
		end
	end

	-- Задать редкость призрака на табло
	function api.SetRarity(rarity: string)
		if currentProgress > 0.05 and rarity and rarity ~= "" then
			label.Text = "СИГНАЛ: " .. rarity:upper()
			label.TextColor3 = Theme.RarityColors[rarity] or Theme.Colors.Text
		end
	end

	function api.Destroy()
		isTicking = false
		container:Destroy()
	end

	return api
end

return DetectorWidget
