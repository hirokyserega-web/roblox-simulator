-- Окно Питомцев и Яиц (EggWindow)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local PetConfig = require(ReplicatedStorage.Shared.config.PetConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local Panel = require(script.Parent.Parent.components.Panel)
local ItemCard = require(script.Parent.Parent.components.ItemCard)
local UIManager = _G.UIManager
local EggOpenCutscene = require(script.Parent.EggOpenCutscene)

local player = Players.LocalPlayer
local equipPetEvent = Remotes.getEvent("EquipPet")
local updatePetsEvent = Remotes.getEvent("UpdatePets")
local hatchEggRequest = Remotes.getEvent("HatchEggRequest")
local eggHatchedEvent = Remotes.getEvent("EggHatched")

local EggWindow = {}
local petsPanel = nil
local scrollFrame = nil
local multiplierLabel = nil
local eggShopFrame = nil

local fastOpenEnabled = false
local currentSelectedEgg = "CommonEgg"

local function renderPetsUI(petsList)
	if not scrollFrame then return end

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

	for _, pet in ipairs(petsList) do
		local petInfo = PetConfig.Pets[pet.Type]
		if not petInfo then continue end

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

function EggWindow.init()
	local screenGui = UIManager.getScreenGui()

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

	-- Левая колонка яиц
	eggShopFrame = Instance.new("Frame")
	eggShopFrame.Name = "EggShop"
	eggShopFrame.Size = UDim2.new(0, 220, 1, 0)
	eggShopFrame.BackgroundTransparency = 1
	eggShopFrame.Parent = petsPanel.Content

	-- Переключатель быстрого открытия
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
			
			local top = eggShopFrame:FindFirstChild("Button3D_Shadow")
			local btnTop = top and top:FindFirstChild("ButtonTop")
			if btnTop then
				btnTop.Text = text
				btnTop.BackgroundColor3 = color
			end
		end
	})

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

		local buy1Btn = Button.create({
			Text = string.format("Открыть x1 ($%d)", config.Cost),
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

		local buy3Btn = Button.create({
			Text = string.format("Открыть x3 ($%d)", config.Cost * 3),
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

	-- Разделитель
	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(0, 2, 1, -10)
	divider.Position = UDim2.new(0, 222, 0, 5)
	divider.BackgroundColor3 = Theme.Colors.Stroke
	divider.BorderSizePixel = 0
	divider.Parent = petsPanel.Content

	-- Правая инвентарь
	local rightFrame = Instance.new("Frame")
	rightFrame.Size = UDim2.new(1, -235, 1, 0)
	rightFrame.Position = UDim2.new(0, 235, 0, 0)
	rightFrame.BackgroundTransparency = 1
	rightFrame.Parent = petsPanel.Content

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

	updatePetsEvent.OnClientEvent:Connect(function(petsList)
		renderPetsUI(petsList)
	end)

	eggHatchedEvent.OnClientEvent:Connect(function(chosenPets)
		EggOpenCutscene.play(chosenPets, currentSelectedEgg, fastOpenEnabled)
	end)
end

EggWindow.init()

return EggWindow
