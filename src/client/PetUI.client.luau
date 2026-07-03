-- Клиентский контроллер UI питомцев (Pet UI)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local PetConfig = require(ReplicatedStorage.Shared.config.PetConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Сетевые события
local equipPetEvent = Remotes.getEvent("EquipPet")
local updatePetsEvent = Remotes.getEvent("UpdatePets")

-- Ссылка на элементы UI
local screenGui = nil
local petFrame = nil
local scrollFrame = nil
local multiplierLabel = nil

-- Цвета редкостей
local rarityColors = {
	Common = Color3.fromRGB(189, 195, 199),     -- Светло-серый
	Uncommon = Color3.fromRGB(46, 204, 113),   -- Зеленый
	Rare = Color3.fromRGB(52, 152, 219),       -- Синий
	Legendary = Color3.fromRGB(241, 196, 15)   -- Золотой
}

-- Функция обновления всего интерфейса питомцев
local function renderPetsUI(petsList)
	if not scrollFrame then return end

	-- Очищаем старые элементы
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Подсчитываем общий множитель для отображения в UI
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
	multiplierLabel.Text = string.format("Общий множитель монет: x%.1f (Экипировано: %d/3)", finalMultiplier, equippedCount)

	-- Заполняем сетку
	for _, pet in ipairs(petsList) do
		local petInfo = PetConfig.Pets[pet.Type]
		if not petInfo then continue end

		local card = Instance.new("Frame")
		card.Name = "Pet_" .. pet.Id
		card.Size = UDim2.new(0, 90, 0, 105)
		card.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		card.BorderSizePixel = 0
		card.Parent = scrollFrame

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 8)
		cardCorner.Parent = card

		-- Подсветка рамки при экипировке
		local border = Instance.new("SelectionBox")
		border.Adornee = card
		border.LineThickness = 0.05
		if pet.Equipped then
			border.Color3 = Color3.fromRGB(46, 204, 113) -- Зеленая рамка (надет)
			card.BackgroundColor3 = Color3.fromRGB(30, 45, 35) -- Зеленоватый оттенок
		else
			border.Color3 = rarityColors[petInfo.Rarity] or Color3.fromRGB(100, 100, 100)
		end
		border.Parent = card

		-- Название питомца
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(1, 0, 0, 30)
		nameLabel.Position = UDim2.new(0, 0, 0, 8)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Enum.Font.FredokaOne
		nameLabel.TextSize = 13
		nameLabel.TextColor3 = rarityColors[petInfo.Rarity] or Color3.fromRGB(255, 255, 255)
		nameLabel.Text = petInfo.DisplayName
		nameLabel.Parent = card

		-- Иконка/Символ питомца (цветной круг по центру)
		local petSphere = Instance.new("Frame")
		petSphere.Name = "Icon"
		petSphere.Size = UDim2.new(0, 24, 0, 24)
		petSphere.Position = UDim2.new(0.5, -12, 0, 38)
		petSphere.BackgroundColor3 = petInfo.Color
		petSphere.BorderSizePixel = 0
		petSphere.Parent = card

		local sphereCorner = Instance.new("UICorner")
		sphereCorner.CornerRadius = UDim.new(1, 0) -- Делает круглым
		sphereCorner.Parent = petSphere

		-- Множитель
		local multLabel = Instance.new("TextLabel")
		multLabel.Name = "MultLabel"
		multLabel.Size = UDim2.new(1, 0, 0, 20)
		multLabel.Position = UDim2.new(0, 0, 1, -25)
		multLabel.BackgroundTransparency = 1
		multLabel.Font = Enum.Font.FredokaOne
		multLabel.TextSize = 11
		multLabel.TextColor3 = Color3.fromRGB(241, 196, 15) -- Золотой
		multLabel.Text = string.format("x%.1f Монет", petInfo.Multiplier)
		multLabel.Parent = card

		-- Кнопка клика на всю карточку для экипировки
		local clickBtn = Instance.new("TextButton")
		clickBtn.Name = "ClickButton"
		clickBtn.Size = UDim2.new(1, 0, 1, 0)
		clickBtn.BackgroundTransparency = 1
		clickBtn.Text = ""
		clickBtn.Parent = card

		clickBtn.MouseButton1Click:Connect(function()
			equipPetEvent:FireServer(pet.Id)
		end)
	end

	-- Настраиваем адаптивную высоту скролла
	local rows = math.ceil(#petsList / 3)
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, rows * 115)
end

-- Создание интерфейса
local function createCompanionsUI()
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PetsHUD"
	screenGui.ResetOnSpawn = false

	-- Кнопка открытия инвентаря питомцев
	local petsBtn = Instance.new("TextButton")
	petsBtn.Name = "PetsButton"
	petsBtn.Size = UDim2.new(0, 80, 0, 45)
	petsBtn.Position = UDim2.new(0, 20, 0.45, 55) -- Под кнопкой магазина SHOP
	petsBtn.BackgroundColor3 = Color3.fromRGB(155, 89, 182) -- Красивый фиолетовый
	petsBtn.BorderSizePixel = 0
	petsBtn.Font = Enum.Font.FredokaOne
	petsBtn.TextSize = 16
	petsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	petsBtn.Text = "PETS"
	petsBtn.Parent = screenGui

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = petsBtn

	-- Главный фрейм питомцев
	petFrame = Instance.new("Frame")
	petFrame.Name = "PetsFrame"
	petFrame.Size = UDim2.new(0, 420, 0, 350)
	petFrame.Position = UDim2.new(0.5, -210, 0.5, -175)
	petFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	petFrame.BackgroundTransparency = 0.15
	petFrame.BorderSizePixel = 0
	petFrame.Visible = false
	petFrame.Parent = screenGui

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 12)
	frameCorner.Parent = petFrame

	-- Заголовок
	local title = Instance.new("TextLabel")
	title.Name = "TitleLabel"
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Position = UDim2.new(0, 0, 0, 10)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.FredokaOne
	title.TextSize = 20
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Text = "ИНВЕНТАРЬ ПИТОМЦЕВ"
	title.Parent = petFrame

	-- Суммарный множитель
	multiplierLabel = Instance.new("TextLabel")
	multiplierLabel.Name = "MultiplierLabel"
	multiplierLabel.Size = UDim2.new(1, 0, 0, 20)
	multiplierLabel.Position = UDim2.new(0, 0, 0, 50)
	multiplierLabel.BackgroundTransparency = 1
	multiplierLabel.Font = Enum.Font.SourceSansBold
	multiplierLabel.TextSize = 14
	multiplierLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
	multiplierLabel.Text = "Общий множитель монет: x1.0 (Экипировано: 0/3)"
	multiplierLabel.Parent = petFrame

	-- Кнопка закрытия
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -40, 0, 10)
	closeBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
	closeBtn.BorderSizePixel = 0
	closeBtn.Font = Enum.Font.FredokaOne
	closeBtn.TextSize = 14
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Text = "X"
	closeBtn.Parent = petFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeBtn

	-- Скролл для сетки питомцев
	scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "PetsScroll"
	scrollFrame.Size = UDim2.new(1, -30, 1, -95)
	scrollFrame.Position = UDim2.new(0, 15, 0, 80)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = petFrame

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 110, 0, 110)
	gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
	gridLayout.Parent = scrollFrame

	-- Логика кнопок открыть/закрыть
	petsBtn.MouseButton1Click:Connect(function()
		petFrame.Visible = not petFrame.Visible
	end)

	closeBtn.MouseButton1Click:Connect(function()
		petFrame.Visible = false
	end)

	screenGui.Parent = playerGui
end

-- Инициализация и подписка на события
local function init()
	createCompanionsUI()

	-- Получаем обновления инвентаря от сервера
	updatePetsEvent.OnClientEvent:Connect(function(petsList)
		renderPetsUI(petsList)
	end)
end

init()
print("PetsUI client controller started")
