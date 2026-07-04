-- Катсцена открытия яйца (EggOpenCutscene)
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Theme = require(script.Parent.Parent.theme.Theme)
local ItemCard = require(script.Parent.Parent.components.ItemCard)
local UIManager = _G.UIManager
local PetConfig = require(game:GetService("ReplicatedStorage").Shared.config.PetConfig)

local EggOpenCutscene = {}

local function playSound(soundId, vol)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = vol or 0.6
	sound.Parent = SoundService
	sound:Play()
	game:GetService("Debris"):AddItem(sound, 1.5)
end

function EggOpenCutscene.play(chosenPets, currentSelectedEgg, fastOpenEnabled)
	local screenGui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("GhostSimulatorUI")

	-- Полноэкранный оверлей затемнения
	local overlay = Instance.new("Frame")
	overlay.Name = "HatchOverlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.ZIndex = 200
	overlay.Parent = screenGui

	TweenService:Create(overlay, TweenInfo.new(0.3), { BackgroundTransparency = 0.5 }):Play()

	-- Быстрое открытие
	if fastOpenEnabled then
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

		playSound(Theme.Sounds.Hatch, 0.6)

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

	-- Гигантское яйцо
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

	local eggConf = PetConfig.Eggs[currentSelectedEgg]
	if eggConf then
		eggLabel.TextColor3 = eggConf.Color
	end

	-- Тряска яйца
	local shakeInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true)
	local function shake(rot)
		local t = TweenService:Create(eggLabel, shakeInfo, { Rotation = rot })
		t:Play()
		t.Completed:Wait()
	end

	playSound("rbxassetid://9120619853", 0.4)
	task.wait(0.2)
	shake(15)
	shake(-15)
	shake(10)
	shake(-10)
	shake(5)
	shake(0)

	-- Выбор цвета высшей редкости для вспышки
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

	-- Если Legendary / Secret - запускаем лучи света!
	if highestRarity == "Legendary" or highestRarity == "Secret" then
		task.spawn(function()
			for r = 1, 8 do
				local ray = Instance.new("Frame")
				ray.Size = UDim2.new(0, 4, 0, 100)
				ray.Position = UDim2.new(0.5, -2, 0.5, -50)
				ray.BackgroundColor3 = flashColor
				ray.BorderSizePixel = 0
				ray.ZIndex = 201
				ray.Rotation = (r - 1) * 45
				ray.Parent = overlay

				TweenService:Create(ray, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, 8, 0, 300),
					Position = UDim2.new(0.5, -4, 0.5, -150),
					BackgroundTransparency = 1
				}):Play()
			end
		end)
	end

	local flash = Instance.new("Frame")
	flash.Size = UDim2.new(1, 0, 1, 0)
	flash.BackgroundColor3 = flashColor
	flash.BackgroundTransparency = 0
	flash.ZIndex = 205
	flash.Parent = overlay

	eggLabel:Destroy()
	playSound(Theme.Sounds.Hatch, 0.7)

	TweenService:Create(flash, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
	task.delay(0.4, function() flash:Destroy() end)

	-- Рендеринг выпавших карточек
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
		cardWrapper.Size = UDim2.new(0, 0, 0, 0)
		cardWrapper.BackgroundTransparency = 1
		cardWrapper.Parent = cardsFrame

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

return EggOpenCutscene
