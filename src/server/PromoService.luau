-- Сервис активации промокодов на сервере
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PromoConfig = require(ReplicatedStorage.Shared.config.PromoConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CurrencyService = require(ServerScriptService.Server.CurrencyService)
local PetService = require(ServerScriptService.Server.PetService)

local PromoService = {}
local playerClaimedCodes = {} -- Ключ: UserId, Значение: { [CodeString] = true }

-- Инициализация сервиса
function PromoService.init()
	local redeemCodeEvent = Remotes.getEvent("RedeemCode")
	redeemCodeEvent.OnServerEvent:Connect(PromoService.onRedeemRequest)
	
	print("[PROMO SERVICE] Сервис промокодов запущен!")
end

-- Настройка кодов при входе игрока
function PromoService.setupPlayer(player: Player, loadedClaimedCodes: table?)
	playerClaimedCodes[player.UserId] = loadedClaimedCodes or {}
end

-- Обработка запроса на активацию промокода
function PromoService.onRedeemRequest(player: Player, codeStr: string)
	if type(codeStr) ~= "string" then return end
	
	local userId = player.UserId
	local claimedCodes = playerClaimedCodes[userId]
	if not claimedCodes then return end

	-- Переводим в верхний регистр для регистронезависимости
	local cleanCode = string.upper(string.gsub(codeStr, "%s+", ""))
	local config = PromoConfig[cleanCode]

	local notificationEvent = Remotes.getEvent("ShowNotification")

	-- 1. Валидация существования кода
	if not config then
		notificationEvent:FireClient(player, "Неверный промокод!")
		return
	end

	-- 2. Валидация повторного использования
	if claimedCodes[cleanCode] == true then
		notificationEvent:FireClient(player, "Промокод уже активирован!")
		return
	end

	-- 3. Выдача наград
	if config.RewardType == "Money" then
		CurrencyService.add(player, "Money", config.Amount)
	elseif config.RewardType == "Crystals" then
		CurrencyService.add(player, "Crystals", config.Amount)
	elseif config.RewardType == "Pet" then
		PetService.awardPet(player, config.PetType)
	end

	-- Помечаем код как активированный
	claimedCodes[cleanCode] = true

	-- Отправляем уведомление об успехе
	notificationEvent:FireClient(player, string.format("Код активирован! Получено: %s", config.DisplayName))
	print(string.format("[PROMO SERVICE] Игрок %s успешно активировал промокод %s", player.Name, cleanCode))
end

-- Данные для сохранения
function PromoService.getSaveData(player: Player): table
	return playerClaimedCodes[player.UserId] or {}
end

-- Очистка памяти при выходе
function PromoService.removePlayer(player: Player)
	playerClaimedCodes[player.UserId] = nil
end

return PromoService
