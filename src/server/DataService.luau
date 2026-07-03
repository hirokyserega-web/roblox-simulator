-- Сервис сохранения и загрузки прогресса игроков через DataStore
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local DataService = {}
local gameDataStore = nil

-- Инициализируем хранилище
local function getStore()
	if not gameDataStore then
		local success, err = pcall(function()
			gameDataStore = DataStoreService:GetDataStore("GhostHunterData_v1")
		end)
		if not success then
			warn("[DATA SERVICE] Ошибка инициализации DataStore: " .. tostring(err))
		end
	end
	return gameDataStore
end

-- Загрузка данных игрока (с ретраями и pcall)
function DataService.loadData(player: Player): table?
	local store = getStore()
	if not store then return nil end

	local key = "Player_" .. player.UserId
	local attempts = 3
	local success, result = false, nil

	for i = 1, attempts do
		success, result = pcall(function()
			return store:GetAsync(key)
		end)

		if success then
			break
		else
			warn(string.format("[DATA SERVICE] Ошибка загрузки для %s (Попытка %d/%d): %s", player.Name, i, attempts, tostring(result)))
			task.wait(1)
		end
	end

	if success then
		if result then
			print("[DATA SERVICE] Успешно загружены данные для " .. player.Name)
			return result
		else
			print("[DATA SERVICE] Сохранений для " .. player.Name .. " не найдено. Создаем новый прогресс.")
			return nil
		end
	else
		warn("[DATA SERVICE] Не удалось загрузить данные для " .. player.Name .. " после всех попыток.")
		return nil
	end
end

-- Сохранение данных игрока (считывает данные из атрибутов персонажа)
function DataService.saveData(player: Player)
	local store = getStore()
	if not store then return end

	-- Проверяем, загрузился ли игрок (чтобы не перезаписать данные дефолтами при ошибке входа)
	if not player:GetAttribute("Money") then 
		return -- Игрок еще не инициализировал кошелек, пропускаем
	end

	local key = "Player_" .. player.UserId
	
	-- Собираем актуальные данные из атрибутов игрока
	local dataToSave = {
		Money = player:GetAttribute("Money") or 0,
		Crystals = player:GetAttribute("Crystals") or 0,
		Upgrades = {
			BagCapacity = player:GetAttribute("BagCapacityLvl") or 1,
			WalkSpeed = player:GetAttribute("WalkSpeedLvl") or 1,
			DetectorRadius = player:GetAttribute("DetectorRadiusLvl") or 1,
			CaptureSpeed = player:GetAttribute("CaptureSpeedLvl") or 1
		},
		Locations = {
			ForestArea = player:GetAttribute("Unlocked_ForestArea") or false,
			MansionArea = player:GetAttribute("Unlocked_MansionArea") or false
		}
	}

	local attempts = 3
	local success, err = false, nil

	for i = 1, attempts do
		success, err = pcall(function()
			store:SetAsync(key, dataToSave)
		end)

		if success then
			print("[DATA SERVICE] Успешно сохранены данные для " .. player.Name)
			break
		else
			warn(string.format("[DATA SERVICE] Ошибка сохранения для %s (Попытка %d/%d): %s", player.Name, i, attempts, tostring(err)))
			task.wait(1)
		end
	end

	if not success then
		warn("[DATA SERVICE] Не удалось сохранить данные для " .. player.Name .. " после всех попыток.")
	end
end

-- Инициализация автосейва и BindToClose
function DataService.init()
	-- Цикл автосохранения каждые 300 секунд (5 минут)
	task.spawn(function()
		while true do
			task.wait(300)
			print("[DATA SERVICE] Запуск автосохранения всех игроков...")
			for _, player in ipairs(Players:GetPlayers()) do
				task.spawn(DataService.saveData, player)
			end
		end
	end)

	-- Защита от потери данных при закрытии сервера/выключении инстанса
	game:BindToClose(function()
		print("[DATA SERVICE] Сервер закрывается! Выполняем экстренное сохранение...")
		local activePlayers = Players:GetPlayers()
		local count = #activePlayers
		if count == 0 then return end

		local completed = 0
		for _, player in ipairs(activePlayers) do
			task.spawn(function()
				local ok, err = pcall(function()
					DataService.saveData(player)
				end)
				if not ok then
					warn("[DATA SERVICE] Исключение при закрытии для " .. player.Name .. ": " .. tostring(err))
				end
				completed = completed + 1
			end)
		end

		-- Ждем сохранения всех игроков (таймаут 5 секунд)
		local startTime = tick()
		while completed < count and (tick() - startTime) < 5 do
			task.wait(0.1)
		end
		print("[DATA SERVICE] Экстренное сохранение завершено.")
	end)

	print("[DATA SERVICE] Сервис сохранения запущен!")
end

return DataService
