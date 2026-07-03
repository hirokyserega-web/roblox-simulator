-- Сервис ежедневных наград на сервере
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DailyConfig = require(ReplicatedStorage.Shared.config.DailyConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CurrencyService = require(ServerScriptService.Server.CurrencyService)

local DailyRewardService = {}
local playerDailyStatus = {} -- Ключ: UserId, Значение: { LastClaimed = Timestamp, ConsecutiveDays = 0..7 }

-- Инициализация
function DailyRewardService.init()
	local claimDailyEvent = Remotes.getEvent("ClaimDaily")
	claimDailyEvent.OnServerEvent:Connect(DailyRewardService.onClaimRequest)
	
	print("[DAILY SERVICE] Сервис ежедневных наград запущен!")
end

-- Настройка при входе игрока
function DailyRewardService.setupPlayer(player: Player, loadedStatus: table?)
	local userId = player.UserId
	
	local status = loadedStatus or { LastClaimed = 0, ConsecutiveDays = 0 }
	playerDailyStatus[userId] = status

	-- Реплицируем состояние через атрибуты
	player:SetAttribute("DailyStreak", status.ConsecutiveDays)
	player:SetAttribute("DailyCooldown", status.LastClaimed + 64800) -- Доступно через 18 часов (64800 сек)
end

-- Обработка запроса клейма
function DailyRewardService.onClaimRequest(player: Player)
	local userId = player.UserId
	local status = playerDailyStatus[userId]
	if not status then return end

	local now = os.time()
	local timeSinceClaim = now - status.LastClaimed
	local COOLDOWN_TIME = 64800 -- 18 часов в секундах
	local RESET_TIME = 129600 -- 36 часов в секундах

	local notificationEvent = Remotes.getEvent("ShowNotification")

	-- 1. Проверка кулдауна
	if timeSinceClaim < COOLDOWN_TIME then
		local timeLeft = COOLDOWN_TIME - timeSinceClaim
		local hours = math.floor(timeLeft / 3600)
		local mins = math.floor((timeLeft % 3600) / 60)
		notificationEvent:FireClient(player, string.format("Награда недоступна! Попробуйте через %d ч. %d м.", hours, mins))
		return
	end

	-- 2. Определение дня серии (streak)
	local nextStreak = 1

	if status.LastClaimed == 0 then
		-- Самый первый клейм
		nextStreak = 1
	elseif timeSinceClaim <= RESET_TIME then
		-- Забрал вовремя (серия продолжается)
		nextStreak = (status.ConsecutiveDays % 7) + 1
	else
		-- Серия сброшена (прошло больше 36 часов)
		nextStreak = 1
	end

	-- 3. Выдача награды
	local config = DailyConfig[nextStreak]
	if not config then return end

	if config.RewardType == "Money" then
		CurrencyService.add(player, "Money", config.Amount)
	elseif config.RewardType == "Crystals" then
		CurrencyService.add(player, "Crystals", config.Amount)
	end

	-- Обновляем статус
	status.LastClaimed = now
	status.ConsecutiveDays = nextStreak

	-- Синхронизируем атрибуты для UI клиента
	player:SetAttribute("DailyStreak", nextStreak)
	player:SetAttribute("DailyCooldown", now + COOLDOWN_TIME)

	-- Отправляем уведомление
	notificationEvent:FireClient(player, string.format("Получена награда за День %d: %s!", nextStreak, config.DisplayName))
	print(string.format("[DAILY SERVICE] Игрок %s получил ежедневную награду за день %d", player.Name, nextStreak))
end

-- Данные для сохранения
function DailyRewardService.getSaveData(player: Player): table
	return playerDailyStatus[player.UserId] or { LastClaimed = 0, ConsecutiveDays = 0 }
end

-- Очистка при выходе
function DailyRewardService.removePlayer(player: Player)
	playerDailyStatus[player.UserId] = nil
end

return DailyRewardService
