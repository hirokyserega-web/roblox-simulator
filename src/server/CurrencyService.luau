-- Сервис управления валютами игрока (Money, Crystals) на сервере
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)

local CurrencyService = {}
local balances = {} -- Ключ: UserId, Значение: { Money = X, Crystals = Y }

-- Инициализация лидерборда и валют при входе игрока
function CurrencyService.setupPlayer(player: Player)
	local userId = player.UserId
	
	-- Устанавливаем стартовый баланс
	balances[userId] = {
		Money = GameConfig.StartingMoney,
		Crystals = GameConfig.StartingCrystals
	}

	-- 1. Лидерборд для отображения в стандартной таблице игроков
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = balances[userId].Money
	money.Parent = leaderstats

	local crystals = Instance.new("IntValue")
	crystals.Name = "Crystals"
	crystals.Value = balances[userId].Crystals
	crystals.Parent = leaderstats

	-- 2. Дублируем баланс в атрибуты игрока для легкого доступа на клиенте
	player:SetAttribute("Money", balances[userId].Money)
	player:SetAttribute("Crystals", balances[userId].Crystals)

	print("[CURRENCY SERVICE] Инициализирован кошелек для игрока: " .. player.Name)
end

-- Получить текущий баланс валюты
function CurrencyService.get(player: Player, currencyType: string): number
	local userId = player.UserId
	if balances[userId] and balances[userId][currencyType] then
		return balances[userId][currencyType]
	end
	return 0
end

-- Начислить валюту игроку
function CurrencyService.add(player: Player, currencyType: string, amount: number)
	local userId = player.UserId
	if not balances[userId] then return end
	if balances[userId][currencyType] == nil then return end

	balances[userId][currencyType] = balances[userId][currencyType] + amount

	-- Синхронизация с Value в leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local statValue = leaderstats:FindFirstChild(currencyType)
		if statValue then
			statValue.Value = balances[userId][currencyType]
		end
	end

	-- Синхронизация с атрибутами
	player:SetAttribute(currencyType, balances[userId][currencyType])
	print(string.format("[CURRENCY SERVICE] Игроку %s добавлено %d %s. Новый баланс: %d", player.Name, amount, currencyType, balances[userId][currencyType]))
end

-- Потратить валюту игрока (возвращает true при успехе, false если недостаточно средств)
function CurrencyService.spend(player: Player, currencyType: string, amount: number): boolean
	local userId = player.UserId
	if not balances[userId] then return false end
	if balances[userId][currencyType] == nil then return false end

	if balances[userId][currencyType] >= amount then
		balances[userId][currencyType] = balances[userId][currencyType] - amount

		-- Синхронизация с leaderstats
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local statValue = leaderstats:FindFirstChild(currencyType)
			if statValue then
				statValue.Value = balances[userId][currencyType]
			end
		end

		-- Синхронизация с атрибутами
		player:SetAttribute(currencyType, balances[userId][currencyType])
		print(string.format("[CURRENCY SERVICE] Игрок %s потратил %d %s. Новый баланс: %d", player.Name, amount, currencyType, balances[userId][currencyType]))
		return true
	end

	return false
end

-- Удалить баланс при выходе игрока
function CurrencyService.removePlayer(player: Player)
	balances[player.UserId] = nil
end

return CurrencyService
