-- Сервис управления питомцами на сервере
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local PetConfig = require(ReplicatedStorage.Shared.config.PetConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CurrencyService = require(ServerScriptService.Server.CurrencyService)

local PetService = {}
local playerPets = {} -- Ключ: UserId, Значение: { { Id = GUID, Type = "Cat", Equipped = false }, ... }
local activePetModels = {} -- Ключ: UserId, Значение: Folder с 3D-моделями питомцев
local standsFolder = nil

-- Создание физического стенда для яйца
local function createEggStand(eggType: string)
	local config = PetConfig.Eggs[eggType]
	if not config then return end

	local standName = "EggStand_" .. eggType
	local stand = Workspace:FindFirstChild(standName)
	if not stand then
		stand = Instance.new("Folder")
		stand.Name = standName
		stand.Parent = standsFolder

		-- 1. Подставка (Педестал)
		local pedestal = Instance.new("Part")
		pedestal.Name = "Pedestal"
		
		-- Устанавливаем положение в зависимости от типа
		if eggType == "CommonEgg" then
			pedestal.Position = Vector3.new(-12, 1, -12)
		else
			pedestal.Position = Vector3.new(12, 1, -12)
		end
		
		pedestal.Size = Vector3.new(4, 2, 4)
		pedestal.Shape = Enum.PartType.Cylinder
		pedestal.Rotation = Vector3.new(90, 0, 0)
		pedestal.Anchored = true
		pedestal.Color = Color3.fromRGB(80, 80, 85)
		pedestal.Material = Enum.Material.Slate
		pedestal.Parent = stand

		-- 2. Физическое яйцо (Сфера)
		local eggPart = Instance.new("Part")
		eggPart.Name = "EggPart"
		eggPart.Position = pedestal.Position + Vector3.new(0, 2.0, 0)
		eggPart.Size = Vector3.new(3, 4, 3)
		eggPart.Shape = Enum.PartType.Ball
		eggPart.Anchored = true
		eggPart.CanCollide = true
		eggPart.Color = config.Color
		eggPart.Material = Enum.Material.Glass
		eggPart.Parent = stand

		-- 3. Добавим BillboardGui с 3D названием и ценой
		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = eggPart

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = string.format("%s\nЦена: $%d", config.DisplayName, config.Cost)
		label.TextColor3 = config.Color
		label.TextStrokeTransparency = 0
		label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		label.Font = Enum.Font.FredokaOne
		label.TextSize = 14
		label.Parent = billboard

		-- 4. Добавляем ProximityPrompt для хетчинга
		local prompt = Instance.new("ProximityPrompt")
		prompt.ObjectText = config.DisplayName
		prompt.ActionText = "Купить Яйцо"
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.MaxActivationDistance = 8
		prompt.RequiresLineOfSight = false
		prompt.Parent = eggPart

		prompt.Triggered:Connect(function(player)
			PetService.hatchEgg(player, eggType)
		end)
	end
end

-- Инициализация сервиса питомцев
function PetService.init()
	standsFolder = Workspace:FindFirstChild("EggStands")
	if not standsFolder then
		standsFolder = Instance.new("Folder")
		standsFolder.Name = "EggStands"
		standsFolder.Parent = Workspace
	end

	createEggStand("CommonEgg")
	createEggStand("SpookyEgg")

	local equipPetEvent = Remotes.getEvent("EquipPet")
	equipPetEvent.OnServerEvent:Connect(PetService.onEquipPetRequest)

	print("[PET SERVICE] Сервис питомцев запущен!")
end

-- Удаление 3D-моделей питомцев игрока
function PetService.clearFollowers(player: Player)
	local folder = activePetModels[player.UserId]
	if folder then
		folder:Destroy()
		activePetModels[player.UserId] = nil
	end

	-- Очищаем все аттачменты следования в HRP
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if hrp then
		for _, child in ipairs(hrp:GetChildren()) do
			if child.Name:sub(1, 14) == "PetAttachment_" then
				child:Destroy()
			end
		end
	end
end

-- Обновление/создание 3D-моделей питомцев с физикой
function PetService.updateFollowers(player: Player)
	PetService.clearFollowers(player)

	local character = player.Character
	if not character then return end
	local hrp = character:WaitForChild("HumanoidRootPart", 5)
	if not hrp then return end

	local pets = playerPets[player.UserId] or {}
	local equipped = {}
	for _, pet in ipairs(pets) do
		if pet.Equipped then
			table.insert(equipped, pet)
		end
	end

	if #equipped == 0 then return end

	-- Создаем корневую папку для питомцев игрока
	local folder = Instance.new("Folder")
	folder.Name = player.Name .. "_Pets"
	folder.Parent = Workspace
	activePetModels[player.UserId] = folder

	-- Задаем оффсеты следования в зависимости от количества
	local offsets = {}
	if #equipped == 1 then
		offsets = { Vector3.new(0, 2, 3.5) }
	elseif #equipped == 2 then
		offsets = { Vector3.new(-2, 2, 3), Vector3.new(2, 2, 3) }
	elseif #equipped == 3 then
		offsets = { Vector3.new(-2.5, 2, 3), Vector3.new(0, 2.5, 3.8), Vector3.new(2.5, 2, 3) }
	end

	for i, pet in ipairs(equipped) do
		local petInfo = PetConfig.Pets[pet.Type]
		if not petInfo then continue end

		local offset = offsets[i]

		-- Создаем Attachment на HRP игрока
		local attachHRP = Instance.new("Attachment")
		attachHRP.Name = "PetAttachment_" .. i
		attachHRP.Position = offset
		attachHRP.Parent = hrp

		-- Создаем саму деталь питомца (сфера)
		local petPart = Instance.new("Part")
		petPart.Name = "PetPart_" .. pet.Id
		petPart.Size = Vector3.new(1.2, 1.2, 1.2)
		petPart.Shape = Enum.PartType.Ball
		petPart.Color = petInfo.Color
		petPart.Material = (petInfo.Rarity == "Legendary") and Enum.Material.Neon or Enum.Material.SmoothPlastic
		petPart.CanCollide = false
		petPart.Anchored = false
		petPart.Position = hrp.Position + offset
		petPart.Parent = folder

		-- Attachment на самом питомце
		local attachPet = Instance.new("Attachment")
		attachPet.Parent = petPart

		-- Настраиваем плавное следование через AlignPosition (координаты)
		local alignPos = Instance.new("AlignPosition")
		alignPos.Attachment0 = attachPet
		alignPos.Attachment1 = attachHRP
		alignPos.MaxForce = 35000
		alignPos.Responsiveness = 15
		alignPos.Parent = petPart

		-- Настраиваем следование через AlignOrientation (поворот)
		local alignOri = Instance.new("AlignOrientation")
		alignOri.Attachment0 = attachPet
		alignOri.Attachment1 = attachHRP
		alignOri.MaxTorque = 35000
		alignOri.Responsiveness = 15
		alignOri.Parent = petPart

		-- Процедурные украшения (ушки, крылья, ножки, эффекты)
		if pet.Type == "Cat" or pet.Type == "Dog" or pet.Type == "Bunny" then
			local earSize = (pet.Type == "Bunny") and Vector3.new(0.2, 0.7, 0.2) or Vector3.new(0.25, 0.4, 0.25)
			local function addEar(side)
				local ear = Instance.new("WedgePart")
				ear.Size = earSize
				ear.Color = petInfo.Color
				ear.CanCollide = false
				ear.Anchored = false
				
				local sideOffset = (side == "L") and -0.35 or 0.35
				ear.CFrame = petPart.CFrame * CFrame.new(sideOffset, 0.6, -0.1) * CFrame.Angles(0, math.rad(90), 0)
				ear.Parent = folder

				local weld = Instance.new("WeldConstraint")
				weld.Part0 = petPart
				weld.Part1 = ear
				weld.Parent = ear
			end
			addEar("L")
			addEar("R")
		elseif pet.Type == "Bat" then
			-- Летучая мышь: добавляем крылышки
			local function addWing(side)
				local wing = Instance.new("Part")
				wing.Size = Vector3.new(0.1, 0.6, 0.8)
				wing.Color = petInfo.Color
				wing.CanCollide = false
				wing.Anchored = false
				
				local sideOffset = (side == "L") and -0.75 or 0.75
				wing.CFrame = petPart.CFrame * CFrame.new(sideOffset, 0, 0.1)
				wing.Parent = folder

				local weld = Instance.new("WeldConstraint")
				weld.Part0 = petPart
				weld.Part1 = wing
				weld.Parent = wing
			end
			addWing("L")
			addWing("R")
		elseif pet.Type == "Spider" then
			-- Паук: 8 ножек
			for leg = 1, 4 do
				local function addLeg(side)
					local legPart = Instance.new("Part")
					legPart.Size = Vector3.new(0.15, 0.5, 0.15)
					legPart.Color = petInfo.Color
					legPart.CanCollide = false
					legPart.Anchored = false
					
					local sideOff = (side == "L") and -0.6 or 0.6
					legPart.CFrame = petPart.CFrame * CFrame.new(sideOff, -0.4, (leg - 2.5) * 0.3)
					legPart.Parent = folder

					local weld = Instance.new("WeldConstraint")
					weld.Part0 = petPart
					weld.Part1 = legPart
					weld.Parent = legPart
				end
				addLeg("L")
				addLeg("R")
			end
		elseif pet.Type == "GhostPet" then
			-- Дух-помощник: Эффект свечения и партиклы
			local light = Instance.new("PointLight")
			light.Color = Color3.fromRGB(0, 229, 255)
			light.Range = 6
			light.Brightness = 2
			light.Parent = petPart

			local pe = Instance.new("ParticleEmitter")
			pe.Texture = "rbxassetid://244221447"
			pe.Size = NumberSequence.new(0.4)
			pe.Lifetime = NumberRange.new(0.5, 1.0)
			pe.Rate = 12
			pe.Speed = NumberRange.new(0.5, 1.5)
			pe.Parent = petPart
		end
	end
end

-- Настройка питомцев при входе игрока
function PetService.setupPlayer(player: Player, loadedPets: table?)
	playerPets[player.UserId] = loadedPets or {}
	
	-- Слушаем загрузку персонажа для создания 3D-моделей
	player.CharacterAdded:Connect(function(char)
		task.wait(1.5) -- Даем загрузиться физике
		PetService.updateFollowers(player)
	end)

	if player.Character then
		task.spawn(function()
			task.wait(1.5)
			PetService.updateFollowers(player)
		end)
	end

	-- Синхронизируем инвентарь с клиентом при входе
	task.wait(1)
	PetService.syncPets(player)
end

-- Синхронизация списка питомцев с клиентом
function PetService.syncPets(player: Player)
	local petsList = playerPets[player.UserId] or {}
	local updatePetsEvent = Remotes.getEvent("UpdatePets")
	updatePetsEvent:FireClient(player, petsList)
end

-- Покупка яйца (хетчинг)
function PetService.hatchEgg(player: Player, eggType: string)
	local config = PetConfig.Eggs[eggType]
	if not config then return end

	local cost = config.Cost
	local success = CurrencyService.spend(player, "Money", cost)

	if success then
		-- Выбираем случайного питомца
		local totalWeight = 0
		for _, item in ipairs(config.Chances) do
			totalWeight = totalWeight + item.Chance
		end

		local randomVal = math.random() * totalWeight
		local cumulativeWeight = 0
		local chosenPetType = "Cat"

		for _, item in ipairs(config.Chances) do
			cumulativeWeight = cumulativeWeight + item.Chance
			if randomVal <= cumulativeWeight then
				chosenPetType = item.PetType
				break
			end
		end

		local petInfo = PetConfig.Pets[chosenPetType]
		if not petInfo then return end

		-- Считаем количество уже экипированных питомцев
		local equippedCount = 0
		for _, p in ipairs(playerPets[player.UserId] or {}) do
			if p.Equipped then
				equippedCount = equippedCount + 1
			end
		end

		-- АВТО-ЭКИПИРОВКА: если есть свободный слот (экипировано меньше 3)
		local shouldAutoEquip = (equippedCount < 3)

		-- Создаем запись о питомце
		local newPet = {
			Id = HttpService:GenerateGUID(false),
			Type = chosenPetType,
			Equipped = shouldAutoEquip
		}

		table.insert(playerPets[player.UserId], newPet)
		PetService.syncPets(player)

		-- Если сработал авто-экип, обновляем 3D-модели в мире
		if shouldAutoEquip then
			PetService.updateFollowers(player)
		end

		-- Отправляем уведомление
		local notificationEvent = Remotes.getEvent("ShowNotification")
		local autoEquipMsg = shouldAutoEquip and " (Автоматически экипирован!)" or ""
		notificationEvent:FireClient(player, string.format("Вылупился питомец: %s (x%.1f монет)%s!", petInfo.DisplayName, petInfo.Multiplier, autoEquipMsg))
		print(string.format("[PET SERVICE] Игрок %s купил %s и выбил %s", player.Name, eggType, chosenPetType))
	else
		local notificationEvent = Remotes.getEvent("ShowNotification")
		notificationEvent:FireClient(player, "Недостаточно монет для покупки яйца!")
	end
end

-- Обработка запроса экипировки с клиента
function PetService.onEquipPetRequest(player: Player, petId: string)
	if type(petId) ~= "string" then return end
	PetService.equipPet(player, petId)
end

-- Переключение экипировки питомца
function PetService.equipPet(player: Player, petId: string)
	local pets = playerPets[player.UserId]
	if not pets then return end

	-- Ищем питомца
	local targetPet = nil
	local equippedCount = 0

	for _, pet in ipairs(pets) do
		if pet.Id == petId then
			targetPet = pet
		end
		if pet.Equipped then
			equippedCount = equippedCount + 1
		end
	end

	if not targetPet then return end

	local notificationEvent = Remotes.getEvent("ShowNotification")

	if targetPet.Equipped then
		-- Снимаем экипировку
		targetPet.Equipped = false
		notificationEvent:FireClient(player, "Питомец снят")
	else
		-- Одеваем экипировку (лимит 3 питомца)
		if equippedCount >= 3 then
			notificationEvent:FireClient(player, "Лимит экипировки превышен (макс. 3)!")
			return
		end
		targetPet.Equipped = true
		local petInfo = PetConfig.Pets[targetPet.Type]
		notificationEvent:FireClient(player, string.format("Экипирован питомец: %s", petInfo.DisplayName))
	end

	PetService.syncPets(player)
	
	-- Обновляем 3D-модели питомцев в мире
	PetService.updateFollowers(player)
end

-- Вычисление суммарного множителя для игрока (сложение бонусов: 1.0 + sum(multiplier - 1.0))
function PetService.getMultiplier(player: Player): number
	local pets = playerPets[player.UserId]
	if not pets then return 1.0 end

	local totalMultiplierBonus = 0
	for _, pet in ipairs(pets) do
		if pet.Equipped then
			local petInfo = PetConfig.Pets[pet.Type]
			if petInfo then
				totalMultiplierBonus = totalMultiplierBonus + (petInfo.Multiplier - 1.0)
			end
		end
	end

	return 1.0 + totalMultiplierBonus
end

-- Получить данные сохранения
function PetService.getSaveData(player: Player): table
	return playerPets[player.UserId] or {}
end

-- Прямое начисление питомца игроку (например, из промокодов или наград)
function PetService.awardPet(player: Player, petType: string)
	local petInfo = PetConfig.Pets[petType]
	if not petInfo then return end

	local equippedCount = 0
	for _, p in ipairs(playerPets[player.UserId] or {}) do
		if p.Equipped then
			equippedCount = equippedCount + 1
		end
	end

	local shouldAutoEquip = (equippedCount < 3)

	local newPet = {
		Id = HttpService:GenerateGUID(false),
		Type = petType,
		Equipped = shouldAutoEquip
	}

	if not playerPets[player.UserId] then
		playerPets[player.UserId] = {}
	end

	table.insert(playerPets[player.UserId], newPet)
	PetService.syncPets(player)

	if shouldAutoEquip then
		PetService.updateFollowers(player)
	end
	
	print(string.format("[PET SERVICE] Игроку %s напрямую выдан питомец: %s", player.Name, petType))
end

-- Очистка памяти при выходе
function PetService.removePlayer(player: Player)
	PetService.clearFollowers(player)
	playerPets[player.UserId] = nil
end

return PetService
