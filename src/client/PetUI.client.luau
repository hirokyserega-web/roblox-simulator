-- Клиентский UI Питомцев и Яиц (Pet UI)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local PetConfig = require(ReplicatedStorage.Shared.config.PetConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

-- Подгрузка темы и компонентов UI Kit
local Theme = require(script.Parent.ui.theme.Theme)
local Button = require(script.Parent.ui.components.Button)
local Panel = require(script.Parent.ui.components.Panel)
local ItemCard = require(script.Parent.ui.components.ItemCard)
local UIManager = require(script.Parent.ui.UIManager)

local player = Players.LocalPlayer
local equipPetEvent = Remotes.getEvent("EquipPet")
local updatePetsEvent = Remotes.getEvent("UpdatePets")
local hatchEggRequest = Remotes.getEvent("HatchEggRequest")
local eggHatchedEvent = Remotes.getEvent("EggHatched")

local petsPanel = nil
local scrollFrame = nil
local multiplierLabel = nil
local eggShopFrame = nil

-- Состояния хетчинга
local fastOpenEnabled = false
local currentSelectedEgg = "CommonEgg"

-- Анимация воспроизведения звуков
local function playSound(soundId)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 0.6
	sound.Parent = game:GetService("SoundService")
	sound:Play()
	game:GetService("Debris"):AddItem(sound, 1.5)
end

-- ==========================================
-- ЭФФЕКТНАЯ АНИМАЦИЯ ХЕТЧИНГА (EGG HATCHING FX)
-- ==========================================
local function playHatchAnimation(chosenPets)
	local screenGui = UIManager.getScreenGui()

	-- 1. Полноэкранный оверлей затемнения
	local overlay = Instance.new("Frame")
	overlay.Name = "HatchOverlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.ZIndex = 200
	overlay.Parent = screenGui

	TweenService:Create(overlay, TweenInfo.new(0.3), { BackgroundTransparency = 0.5 }):Play()

	-- Если включено быстрое открытие, сразу рендерим карточки без тряски
	if fastOpenEnabled then
		-- Сразу показываем карточки
		local cardsFrame = Instance.new("Frame")
		cardsFrame.Size = UDim2.new(0, #chosenPets * 110, 0, 150)
		cardsFrame.Position = UDim2.new(0.5, -(#chosenPets * 110)/2, 0.5, -75)
		cardsFrame.BackgroundTransparency = 1
		cardsFrame.ZIndex = 201
		cardsFrame.Parent = overlay

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.Padding = UDim.new(0, 15)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.Parent = cardsFrame

		for _, petType in ipairs(chosenPets) do
			local petInfo = PetConfig.Pets[petType]
			if not petInfo then continue end

			local cardWrapper = Instance.new("Frame")
			cardWrapper.Size = UDim2.new(0, 95, 0, 115)
			cardWrapper.BackgroundTransparency = 1
			cardWrapper.Parent = cardsFrame

			local card = ItemCard.create({
				Title = petInfo.DisplayName,
				Rarity = petInfo.Rarity,
				IconColor = petInfo.Color,
				Subtext = string.format("x%.1f монет", petInfo.Multiplier),
				Parent = cardWrapper
			})
		end

		playSound(Theme.Sounds.Hatch)

		-- Кнопка закрытия
		local closeBtn = Button.create({
			Text = "ЗАКРЫТЬ",
			Color = Theme.Colors.Success,
			Size = UDim2.new(0, 120, 0, 40),
			Position = UDim2.new(0.5, -60, 0.85, 0),
			Parent = overlay,
			OnClick = function()
				overlay:Destroy()
			end
		})
		return
	end

	-- 2. Создаем гигантское 3D-яйцо
	local eggLabel = Instance.new("TextLabel")
	eggLabel.Name = "GiantEgg"
	eggLabel.Size = UDim2.new(0, 160, 0, 200)
	eggLabel.Position = UDim2.new(0.5, -80, 0.5, -100)
	eggLabel.BackgroundTransparency = 1
	eggLabel.Font = Theme.Fonts.Title
	eggLabel.TextSize = 120
	eggLabel.Text = "🥚"
	eggLabel.ZIndex = 202
	eggLabel.Parent = overlay

	-- Разукрашиваем яйцо под тип текущего выбранного
	local eggConf = PetConfig.Eggs[currentSelectedEgg]
	eggLabel.TextColor3 = eggConf.Color

	-- Анимация покачивания (тряски) яйца
	local shakeInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true)
	local function shake(rot)
		local t = TweenService:Create(eggLabel, shakeInfo, { Rotation = rot })
		t:Play()
		t.Completed:Wait()
	end

	playSound("rbxassetid://9120619853") -- Звук подготовки
	task.wait(0.2)
	shake(15)
	shake(-15)
	shake(10)
	shake(-10)
	shake(5)
	shake(0)

	-- 3. Вспышка экрана цвета редкости (выбираем максимальную из выпавших)
	local highestRarity = "Common"
	for _, petType in ipairs(chosenPets) do
		local pInfo = PetConfig.Pets[petType]
		if pInfo and pInfo.Rarity == "Legendary" then
			highestRarity = "Legendary"
		elseif pInfo and pInfo.Rarity == "Rare" and highestRarity ~= "Legendary" then
			highestRarity = "Rare"
		elseif pInfo and pInfo.Rarity == "Uncommon" and highestRarity == "Common" then
			highestRarity = "Uncommon"
		end
	end
	
	local flashColor = Theme.RarityColors[highestRarity] or Theme.Colors.Text

	local flash = Instance.new("Frame")
	flash.Size = UDim2.new(1, 0, 1, 0)
	flash.BackgroundColor3 = flashColor
	flash.BackgroundTransparency = 0
	flash.ZIndex = 205
	flash.Parent = overlay

	-- Взрываем яйцо
	eggLabel:Destroy()
	playSound(Theme.Sounds.Hatch)

	TweenService:Create(flash, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
	task.delay(0.4, function() flash:Destroy() end)

	-- 4. Плавное появление (Pop-in) карточек с питомцами
	local cardsFrame = Instance.new("Frame")
	cardsFrame.Size = UDim2.new(0, #chosenPets * 110, 0, 150)
	cardsFrame.Position = UDim2.new(0.5, -(#chosenPets * 110)/2, 0.5, -75)
	cardsFrame.BackgroundTransparency = 1
	cardsFrame.ZIndex = 201
	cardsFrame.Parent = overlay

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 15)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Parent = cardsFrame

	for _, petType in ipairs(chosenPets) do
		local petInfo = PetConfig.Pets[petType]
		if not petInfo then continue end

		local cardWrapper = Instance.new("Frame")
		cardWrapper.Size = UDim2.new(0, 95, 0, 115)
		cardWrapper.BackgroundTransparency = 1
		cardWrapper.Parent = cardsFrame

		-- Pop-in анимация масштаба карточки
		cardWrapper.Size = UDim2.new(0, 0, 0, 0)
		local card = ItemCard.create({
			Title = petInfo.DisplayName,
			Rarity = petInfo.Rarity,
			IconColor = petInfo.Color,
			Subtext = string.format("x%.1f монет", petInfo.Multiplier),
			Parent = cardWrapper
		})

		TweenService:Create(cardWrapper, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 95, 0, 115)
		}):Play()
	end

	-- Кнопка закрытия
	local closeBtn = Button.create({
		Text = "ОТЛИЧНО!",
		Color = Theme.Colors.Success,
		Size = UDim2.new(0, 140, 0, 44),
		Position = UDim2.new(0.5, -70, 0.85, 0),
		Parent = overlay,
		OnClick = function()
			overlay:Destroy()
		end
	})
end

-- Слушаем сигнал хетчинга с сервера для старта анимации
eggHatchedEvent.OnClientEvent:Connect(playHatchAnimation)

-- ==========================================
-- ОТРЕНДЕРИТЬ ИНВЕНТАРЬ ПИТОМЦЕВ
-- ==========================================
local function renderPetsUI(petsList)
	if not scrollFrame then return end

	-- Очищаем скролл
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local totalBonus = 0
	local equippedCount = 0

	for _, pet in ipairs(petsList) do
		local petInfo = PetConfig.Pets[pet.Type]
		if pet.Equipped and petInfo then
			totalBonus = totalBonus + (petInfo.Multiplier - 1.0)
			equippedCount = equippedCount + 1
		end
	end
	
	local finalMultiplier = 1.0 + totalBonus
	multiplierLabel.Text = string.format("Бонус: x%.1f монет (Надето: %d / 3)", finalMultiplier, equippedCount)

	-- Заполняем карточками через UI Kit фабрику
	for _, pet in ipairs(petsList) do
		local petInfo = PetConfig.Pets[pet.Type]
		if not petInfo then continue end

		-- Оборачиваем карточку в Frame для сетки
		local cardWrapper = Instance.new("Frame")
		cardWrapper.Size = UDim2.new(0, 90, 0, 105)
		cardWrapper.BackgroundTransparency = 1
		cardWrapper.Parent = scrollFrame

		local card = ItemCard.create({
			Title = petInfo.DisplayName,
			Rarity = petInfo.Rarity,
			IconColor = petInfo.Color,
			Subtext = string.format("x%.1f монет", petInfo.Multiplier),
			Equipped = pet.Equipped,
			Parent = cardWrapper,
			OnClick = function()
				equipPetEvent:FireServer(pet.Id)
			end
		})
	end

	local rows = math.ceil(#petsList / 3)
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, rows * 115)
end

-- ==========================================
-- ИНИЦИАЛИЗАЦИЯ ИНТЕРФЕЙСА ПИТОМЦЕВ И ЯИЦ
-- ==========================================
local function init()
	local screenGui = UIManager.getScreenGui()

	-- Создаем премиум-панель
	petsPanel = Panel.create({
		Title = "ПИТОМЦЫ И ЯЙЦА",
		Size = UDim2.new(0, 520, 0, 360),
		Position = UDim2.new(0.5, -260, 0.5, -180),
		Parent = screenGui,
		OnClose = function()
			petsPanel.Close()
		end
	})

	UIManager.registerWindow("Pets", petsPanel)

	-- ==========================================
	-- ЛЕВАЯ ЧАСТЬ: МАГАЗИН ЯИЦ (Egg Shop)
	-- ==========================================
	eggShopFrame = Instance.new("Frame")
	eggShopFrame.Name = "EggShop"
	eggShopFrame.Size = UDim2.new(0, 220, 1, 0)
	eggShopFrame.BackgroundTransparency = 1
	eggShopFrame.Parent = petsPanel.Content

	-- Переключатель быстрого открытия (Fast Hatch Toggle)
	local fastToggleBtn = Button.create({
		Text = "Быстрое открытие: ВЫКЛ",
		Color = Theme.Colors.BackgroundSecondary,
		Size = UDim2.new(1, -10, 0, 30),
		Position = UDim2.new(0, 5, 0, 5),
		TextSize = 11,
		Parent = eggShopFrame,
		OnClick = function()
			fastOpenEnabled = not fastOpenEnabled
			local text = fastOpenEnabled and "Быстрое открытие: ВКЛ" or "Быстрое открытие: ВЫКЛ"
			local color = fastOpenEnabled and Theme.Colors.Success or Theme.Colors.BackgroundSecondary
			-- Пересоздавать не нужно, просто меняем атрибуты
			local top = eggShopFrame:FindFirstChild("Button3D_Shadow")
			local btnTop = top and top:FindFirstChild("ButtonTop")
			if btnTop then
				btnTop.Text = text
				btnTop.BackgroundColor3 = color
			end
		end
	})

	-- Список кнопок яиц
	local eggButtonsList = { "CommonEgg", "SpookyEgg" }
	for idx, eggName in ipairs(eggButtonsList) do
		local config = PetConfig.Eggs[eggName]
		if not config then continue end

		local yPos = 45 + (idx - 1) * 115

		local eggCard = Instance.new("Frame")
		eggCard.Size = UDim2.new(1, -10, 0, 105)
		eggCard.Position = UDim2.new(0, 5, 0, yPos)
		eggCard.BackgroundColor3 = Theme.Colors.BackgroundSecondary
		eggCard.BorderSizePixel = 0
		eggCard.Parent = eggShopFrame

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = Theme.Sizes.CornerRadius
		cardCorner.Parent = eggCard

		local cardStroke = Instance.new("UIStroke")
		cardStroke.Thickness = 1
		cardStroke.Color = Theme.Colors.Stroke
		cardStroke.Parent = eggCard

		-- Текст названия яйца
		local eggTitle = Instance.new("TextLabel")
		eggTitle.Size = UDim2.new(1, -12, 0, 24)
		eggTitle.Position = UDim2.new(0, 8, 0, 6)
		eggTitle.BackgroundTransparency = 1
		eggTitle.Font = Theme.Fonts.Title
		eggTitle.TextSize = 13
		eggTitle.TextColor3 = config.Color
		eggTitle.TextXAlignment = Enum.TextXAlignment.Left
		eggTitle.Text = config.DisplayName
		eggTitle.Parent = eggCard

		-- Кнопка Купить x1
		local buy1Btn = Button.create({
			Text = string.format("Купить x1 ($%d)", config.Cost),
			Color = Theme.Colors.Success,
			Size = UDim2.new(0.5, -10, 0, 36),
			Position = UDim2.new(0, 6, 1, -48),
			TextSize = 10,
			Parent = eggCard,
			OnClick = function()
				currentSelectedEgg = eggName
				hatchEggRequest:FireServer(eggName, 1)
			end
		})

		-- Кнопка Купить x3 (Тройное открытие)
		local buy3Btn = Button.create({
			Text = string.format("Купить x3 ($%d)", config.Cost * 3),
			Color = Theme.Colors.Accent,
			Size = UDim2.new(0.5, -10, 0, 36),
			Position = UDim2.new(0.5, 4, 1, -48),
			TextSize = 10,
			Parent = eggCard,
			OnClick = function()
				currentSelectedEgg = eggName
				hatchEggRequest:FireServer(eggName, 3)
			end
		})
	end

	-- Разделительная черта
	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(0, 2, 1, -10)
	divider.Position = UDim2.new(0, 222, 0, 5)
	divider.BackgroundColor3 = Theme.Colors.Stroke
	divider.BorderSizePixel = 0
	divider.Parent = petsPanel.Content

	-- ==========================================
	-- ПРАВАЯ ЧАСТЬ: ИНВЕНТАРЬ ПИТОМЦЕВ (Inventory)
	-- ==========================================
	local rightFrame = Instance.new("Frame")
	rightFrame.Size = UDim2.new(1, -235, 1, 0)
	rightFrame.Position = UDim2.new(0, 235, 0, 0)
	rightFrame.BackgroundTransparency = 1
	rightFrame.Parent = petsPanel.Content

	-- Множитель денег
	multiplierLabel = Instance.new("TextLabel")
	multiplierLabel.Size = UDim2.new(1, -10, 0, 25)
	multiplierLabel.Position = UDim2.new(0, 5, 0, 5)
	multiplierLabel.BackgroundTransparency = 1
	multiplierLabel.Font = Theme.Fonts.Bold
	multiplierLabel.TextSize = 13
	multiplierLabel.TextColor3 = Theme.Colors.Success
	multiplierLabel.TextXAlignment = Enum.TextXAlignment.Left
	multiplierLabel.Text = "Бонус: x1.0 монет (Надето: 0 / 3)"
	multiplierLabel.Parent = rightFrame

	-- Скролл для сетки питомцев
	scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, 0, 1, -35)
	scrollFrame.Position = UDim2.new(0, 0, 0, 35)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = rightFrame

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 80, 0, 95)
	gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
	gridLayout.Parent = scrollFrame

	-- Слушаем обновление списка от сервера
	updatePetsEvent.OnClientEvent:Connect(function(petsList)
		renderPetsUI(petsList)
	end)
end

init()
print("[PET UI] Интерфейс питомцев и яиц успешно запущен!")
