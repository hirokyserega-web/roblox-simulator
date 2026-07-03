-- Новая клиентская система HUD в стиле Roblox-симуляторов
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- Подгрузка темы и компонентов UI Kit
local Theme = require(script.Parent.ui.theme.Theme)
local Button = require(script.Parent.ui.components.Button)
local ProgressBar = require(script.Parent.ui.components.ProgressBar)
local CurrencyChip = require(script.Parent.ui.components.CurrencyChip)
local UIManager = require(script.Parent.ui.UIManager)

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- HUD GUI
local hudGui = nil

-- Компоненты фишек валют
local moneyChip = nil
local crystalChip = nil

-- Компоненты сумки
local bagProgress = nil
local bagLabel = nil
local bagIconLabel = nil

-- Элементы детектора
local detectorPanel = nil
local signalBars = {}
local signalRarityLabel = nil

-- Переменные звука тиканья детектора
local lastTickTime = 0
local tickRate = 1 -- Частота тиков в секунду (динамическая)

-- Виньетка испуга
local vignette = nil

-- Вспомогательная функция для проигрывания звуков
local function playSound(soundId, volume)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume or 0.5
	sound.Parent = game:GetService("SoundService")
	sound:Play()
	game:GetService("Debris"):AddItem(sound, 1.5)
end

-- Вспышка экрана и виньетка при испуге/атаке
local function applyScareFX(scareType)
	-- Камера трясется
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	
	-- Добавляем Blur
	local blur = Lighting:FindFirstChild("ScareBlur")
	if not blur then
		blur = Instance.new("BlurEffect")
		blur.Name = "ScareBlur"
		blur.Size = 0
		blur.Parent = Lighting
	end
	blur.Size = 20
	TweenService:Create(blur, TweenInfo.new(1.0), {Size = 0}):Play()

	-- Проигрываем звук
	playSound("rbxassetid://134012243", 0.8) -- Зловещий смех

	-- Виньетка испуга
	if vignette then
		vignette.ImageColor3 = (scareType == "ATK") and Theme.Colors.Error or Theme.Colors.Warning
		vignette.ImageTransparency = 0
		TweenService:Create(vignette, TweenInfo.new(1.2), {ImageTransparency = 1}):Play()
	end

	-- Тряска камеры
	local intensity = (scareType == "ATK") and 1.5 or 0.6
	local duration = (scareType == "ATK") and 1.5 or 0.8
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

-- Обработка событий испуга
Remotes.getEvent("ScarePlayer").OnClientEvent:Connect(function(scareType)
	applyScareFX(scareType)
	if scareType == "ATK" then
		UIManager.ShowToast("ВАС АТАКОВАЛИ! Утерян 1 призрак из сумки!", "Error")
	else
		UIManager.ShowToast("БУ! Рядом бродит опасный призрак!", "Warning")
	end
end)

-- Создание макета HUD
local function createHUD()
	hudGui = UIManager.getScreenGui()

	-- Виньетка для полноэкранных эффектов
	vignette = Instance.new("ImageLabel")
	vignette.Name = "ScareVignette"
	vignette.Size = UDim2.new(1, 0, 1, 0)
	vignette.BackgroundTransparency = 1
	vignette.Image = "rbxassetid://257069542" -- Текстура виньетки
	vignette.ImageColor3 = Theme.Colors.Error
	vignette.ImageTransparency = 1
	vignette.ZIndex = 0
	vignette.Parent = hudGui

	-- ==========================================
	-- ВЕРХНЯЯ ПАНЕЛЬ (Валюты, Rebirth, Настройки)
	-- ==========================================
	local topBar = Instance.new("Frame")
	topBar.Name = "TopHUD"
	topBar.Size = UDim2.new(1, 0, 0, 60)
	topBar.Position = UDim2.new(0, 0, 0, 10)
	topBar.BackgroundTransparency = 1
	topBar.Parent = hudGui

	-- Фишка монет
	moneyChip = CurrencyChip.create({
		CurrencyType = "Money",
		Size = UDim2.new(0, 150, 0, 40),
		Position = UDim2.new(0, 20, 0, 10),
		Parent = topBar
	})

	-- Фишка кристаллов (правее монет)
	crystalChip = CurrencyChip.create({
		CurrencyType = "Crystals",
		Size = UDim2.new(0, 130, 0, 40),
		Position = UDim2.new(0, 180, 0, 10),
		Parent = topBar
	})

	-- Кнопка Rebirth (Правая сторона)
	local rebirthBtn = Button.create({
		Text = "⚡ REBIRTH",
		Color = Theme.Colors.Accent,
		Size = UDim2.new(0, 110, 0, 40),
		Position = UDim2.new(1, -210, 0, 14),
		Parent = topBar,
		OnClick = function()
			UIManager.openWindow("Rebirth")
		end
	})

	-- Кнопка Настроек (Gear ⚙️)
	local settingsBtn = Button.create({
		Text = "⚙️",
		Color = Theme.Colors.BackgroundSecondary,
		Size = UDim2.new(0, 40, 0, 40),
		Position = UDim2.new(1, -70, 0, 14),
		TextSize = 18,
		Parent = topBar,
		OnClick = function()
			UIManager.openWindow("Settings")
		end
	})

	-- ==========================================
	-- ДЕТЕКТОР СИГНАЛА (Левая сторона)
	-- ==========================================
	detectorPanel = Instance.new("Frame")
	detectorPanel.Name = "DetectorPanel"
	detectorPanel.Size = UDim2.new(0, 150, 0, 70)
	detectorPanel.Position = UDim2.new(0, 20, 0.4, -90)
	detectorPanel.BackgroundColor3 = Theme.Colors.Background
	detectorPanel.BackgroundTransparency = 0.2
	detectorPanel.BorderSizePixel = 0
	detectorPanel.Parent = hudGui

	local detCorner = Instance.new("UICorner")
	detCorner.CornerRadius = Theme.Sizes.CornerRadius
	detCorner.Parent = detectorPanel

	local detStroke = Instance.new("UIStroke")
	detStroke.Thickness = Theme.Sizes.BorderWidth
	detStroke.Color = Theme.Colors.Stroke
	detStroke.Parent = detectorPanel

	local radarIcon = Instance.new("TextLabel")
	radarIcon.Size = UDim2.new(0, 40, 0, 40)
	radarIcon.Position = UDim2.new(0, 8, 0, 8)
	radarIcon.BackgroundTransparency = 1
	radarIcon.Font = Theme.Fonts.Title
	radarIcon.TextSize = 22
	radarIcon.Text = "📡"
	radarIcon.Parent = detectorPanel

	-- Шкала сигнала (5 полосок)
	local barsContainer = Instance.new("Frame")
	barsContainer.Size = UDim2.new(0, 80, 0, 24)
	barsContainer.Position = UDim2.new(0, 55, 0, 16)
	barsContainer.BackgroundTransparency = 1
	barsContainer.Parent = detectorPanel

	local barLayout = Instance.new("UIListLayout")
	barLayout.FillDirection = Enum.FillDirection.Horizontal
	barLayout.Padding = UDim.new(0, 4)
	barLayout.SortOrder = Enum.SortOrder.LayoutOrder
	barLayout.Parent = barsContainer

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

	-- Подпись предполагаемой редкости под шкалой
	signalRarityLabel = Instance.new("TextLabel")
	signalRarityLabel.Size = UDim2.new(1, -16, 0, 20)
	signalRarityLabel.Position = UDim2.new(0, 8, 1, -22)
	signalRarityLabel.BackgroundTransparency = 1
	signalRarityLabel.Font = Theme.Fonts.Body
	signalRarityLabel.TextSize = 10
	signalRarityLabel.TextColor3 = Theme.Colors.TextSecondary
	signalRarityLabel.Text = "СИГНАЛ: ОТСУТСТВУЕТ"
	signalRarityLabel.Parent = detectorPanel

	-- ==========================================
	-- СУМКА / РЮКЗАК (Правая сторона)
	-- ==========================================
	local bagPanel = Instance.new("Frame")
	bagPanel.Name = "BagPanel"
	bagPanel.Size = UDim2.new(0, 150, 0, 70)
	bagPanel.Position = UDim2.new(1, -170, 0.4, -90)
	bagPanel.BackgroundColor3 = Theme.Colors.Background
	bagPanel.BackgroundTransparency = 0.2
	bagPanel.BorderSizePixel = 0
	bagPanel.Parent = hudGui

	local bagCorner = Instance.new("UICorner")
	bagCorner.CornerRadius = Theme.Sizes.CornerRadius
	bagCorner.Parent = bagPanel

	local bagStroke = Instance.new("UIStroke")
	bagStroke.Thickness = Theme.Sizes.BorderWidth
	bagStroke.Color = Theme.Colors.Stroke
	bagStroke.Parent = bagPanel

	bagIconLabel = Instance.new("TextLabel")
	bagIconLabel.Size = UDim2.new(0, 40, 0, 40)
	bagIconLabel.Position = UDim2.new(0, 8, 0, 8)
	bagIconLabel.BackgroundTransparency = 1
	bagIconLabel.Font = Theme.Fonts.Title
	bagIconLabel.TextSize = 22
	bagIconLabel.Text = "🎒"
	bagIconLabel.Parent = bagPanel

	bagLabel = Instance.new("TextLabel")
	bagLabel.Size = UDim2.new(1, -55, 0, 30)
	bagLabel.Position = UDim2.new(0, 50, 0, 12)
	bagLabel.BackgroundTransparency = 1
	bagLabel.Font = Theme.Fonts.Bold
	bagLabel.TextSize = 14
	bagLabel.TextColor3 = Theme.Colors.Text
	bagLabel.Text = "0 / 10"
	bagLabel.Parent = bagPanel

	-- Прогресс-бар рюкзака
	bagProgress = ProgressBar.create({
		Size = UDim2.new(1, -16, 0, 10),
		Position = UDim2.new(0, 8, 1, -18),
		FillColor = Theme.Colors.Success,
		Parent = bagPanel
	})

	-- ==========================================
	-- НИЖНЯЯ ПАНЕЛЬ КНОПОК (Dock)
	-- ==========================================
	local dock = Instance.new("Frame")
	dock.Name = "Dock"
	dock.Size = UDim2.new(0, 640, 0, 60)
	dock.Position = UDim2.new(0.5, -320, 1, -80)
	dock.BackgroundTransparency = 1
	dock.Parent = hudGui

	local dockLayout = Instance.new("UIListLayout")
	dockLayout.FillDirection = Enum.FillDirection.Horizontal
	dockLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	dockLayout.Padding = UDim.new(0, 10)
	dockLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	dockLayout.Parent = dock

	-- Создаем иконки для Дока
	local dockButtons = {
		{ Name = "Shop", Text = "🛒 Магазин", Color = Theme.Colors.Accent },
		{ Name = "Inventory", Text = "🎒 Рюкзак", Color = Theme.Colors.Accent },
		{ Name = "Pets", Text = "👾 Питомцы", Color = Theme.Colors.Accent },
		{ Name = "Leaderboard", Text = "🏆 Топ", Color = Theme.Colors.Accent },
		{ Name = "Teleport", Text = "🗺️ Телепорт", Color = Theme.Colors.Accent },
		{ Name = "Rewards", Text = "🎁 Награды", Color = Theme.Colors.Warning }
	}

	for _, item in ipairs(dockButtons) do
		local btn = Button.create({
			Text = item.Text,
			Color = item.Color,
			Size = UDim2.new(0, 95, 0, 44),
			TextSize = 11,
			Parent = dock,
			OnClick = function()
				UIManager.openWindow(item.Name)
			end
		})
	end
end

-- Обработка событий баланса
local function connectAttributes()
	local function updateMoney()
		local money = player:GetAttribute("Money") or 0
		moneyChip.SetValue(money)
	end
	
	local function updateCrystals()
		local crystals = player:GetAttribute("Crystals") or 0
		crystalChip.SetValue(crystals)
	end

	player:GetAttributeChangedSignal("Money"):Connect(updateMoney)
	player:GetAttributeChangedSignal("Crystals"):Connect(updateCrystals)

	updateMoney()
	updateCrystals()
end

-- Подписка на обновление инвентаря рюкзака
Remotes.getEvent("InventoryUpdate").OnClientEvent:Connect(function(inventory)
	if not bagProgress then return end
	if inventory and inventory.Ghosts then
		local count = #inventory.Ghosts
		local maxCap = inventory.MaxCapacity
		
		bagLabel.Text = string.format("%d / %d", count, maxCap)
		bagProgress.SetProgress(count / maxCap)

		-- При заполнении меняем цвета
		if count >= maxCap then
			bagProgress.SetColor(Theme.Colors.Warning)
			bagLabel.TextColor3 = Theme.Colors.Warning
			bagIconLabel.Text = "🚨"
			UIManager.ShowToast("Сумка полна! Продайте призраков на Черном Рынке!", "Warning")
		else
			bagProgress.SetColor(Theme.Colors.Success)
			bagLabel.TextColor3 = Theme.Colors.Text
			bagIconLabel.Text = "🎒"
		end
	end
end)

-- Слушатель логики Детектора Сигнала
local function startDetectorUpdateLoop()
	local localGhostsFolder = Workspace:WaitForChild("LocalGhosts", 15)
	
	RunService.Heartbeat:Connect(function()
		local character = player.Character
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		if not rootPart or not localGhostsFolder then return end

		-- Ищем ближайшего призрака
		local closestGhost = nil
		local minDistance = math.huge

		for _, ghost in ipairs(localGhostsFolder:GetChildren()) do
			if ghost:IsA("BasePart") then
				local distance = (rootPart.Position - ghost.Position).Magnitude
				if distance < minDistance then
					minDistance = distance
					closestGhost = ghost
				end
			end
		end

		local maxRange = player:GetAttribute("DetectorRadius") or GameConfig.DefaultDetectorRadius

		if closestGhost and minDistance <= maxRange then
			-- Расчет шкалы: чем ближе, тем больше полосок (от 1 до 5)
			local factor = 1 - (minDistance / maxRange) -- от 0 (далеко) до 1 (вплотную)
			local litBars = math.clamp(math.ceil(factor * 5), 1, 5)

			-- Подсвечиваем полоски
			for i = 1, 5 do
				if i <= litBars then
					signalBars[i].BackgroundColor3 = Theme.Colors.Neon
				else
					signalBars[i].BackgroundColor3 = Theme.Colors.BackgroundSecondary
				end
			end

			-- Подпись редкости
			local rarity = closestGhost:GetAttribute("Rarity") or "Common"
			signalRarityLabel.Text = "СИГНАЛ: " .. rarity:upper()
			signalRarityLabel.TextColor3 = Theme.RarityColors[rarity] or Theme.Colors.Text

			-- Звук пиканья: скорость увеличивается с приближением
			tickRate = 0.15 + (1 - factor) * 0.8 -- частота пиков в секундах

			if tick() - lastTickTime >= tickRate then
				lastTickTime = tick()
				playSound("rbxassetid://9120619853", 0.3) -- Звук детектора
				
				-- Пульсация детектора при сигнале
				local origSize = UDim2.new(0, 150, 0, 70)
				local pulseSize = UDim2.new(0, 155, 0, 72)
				TweenService:Create(detectorPanel, TweenInfo.new(0.08), {Size = pulseSize}):Play()
				task.delay(0.08, function()
					TweenService:Create(detectorPanel, TweenInfo.new(0.08), {Size = origSize}):Play()
				end)
			end
		else
			-- Сбрасываем детектор
			for i = 1, 5 do
				signalBars[i].BackgroundColor3 = Theme.Colors.BackgroundSecondary
			end
			signalRarityLabel.Text = "СИГНАЛ: ОТСУТСТВУЕТ"
			signalRarityLabel.TextColor3 = Theme.Colors.TextSecondary
		end
	end)
end

-- Запуск систем HUD
local function start()
	createHUD()
	connectAttributes()
	startDetectorUpdateLoop()
	
	-- Поддерживаем старый хук для показа оверлея
	_G.ShowNotification = function(text, nType)
		UIManager.ShowToast(text, nType or "Info")
	end
	
	print("[HUD] HUD-панели запущены на новой теме!")
end

start()
