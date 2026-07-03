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
	-- Создаем папку для стендов
	standsFolder = Workspace:FindFirstChild("EggStands")
	if not standsFolder then
		standsFolder = Instance.new("Folder")
		standsFolder.Name = "EggStands"
		standsFolder.Parent = Workspace
	end

	-- Создаем стенды
	createEggStand("CommonEgg")
	createEggStand("SpookyEgg")

	-- Подключаем обработку RemoteEvents
	local equipPetEvent = Remotes.getEvent("EquipPet")
	equipPetEvent.OnServerEvent:Connect(PetService.onEquipPetRequest)

	print("[PET SERVICE] Сервис питомцев запущен!")
end

-- Настройка питомцев при входе игрока
function PetService.setupPlayer(player: Player, loadedPets: table?)
	playerPets[player.UserId] = loadedPets or {}
	
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

		-- Создаем запись о питомце
		local newPet = {
			Id = HttpService:GenerateGUID(false),
			Type = chosenPetType,
			Equipped = false
		}

		table.insert(playerPets[player.UserId], newPet)
		PetService.syncPets(player)

		-- Отправляем уведомление
		local notificationEvent = Remotes.getEvent("ShowNotification")
		notificationEvent:FireClient(player, string.format("Вылупился питомец: %s (x%.1f монет)!", petInfo.DisplayName, petInfo.Multiplier))
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

-- Очистка памяти при выходе
function PetService.removePlayer(player: Player)
	playerUpgrades = nil
	playerPets[player.UserId] = nil
end

return PetService
