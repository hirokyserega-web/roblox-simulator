-- Общие настройки игры Ghost Hunter Simulator (Фаза 6)
local GameConfig = {
	-- Стартовые параметры игрока
	StartingMoney = 0,
	StartingCrystals = 0,
	DefaultBagCapacity = 10,

	-- Настройки спавна привидений
	SpawnInterval = 3,           -- Интервал спавна в секундах
	MaxGhosts = 10,              -- Максимальное количество привидений на карте

	-- Настройки детектора
	DetectorRadius = 50,         -- Радиус действия детектора в студах

	-- Настройки поимки ловушкой
	TrapRange = 20,              -- Радиус действия ловушки в студах
	CaptureTime = 2.0,           -- Время удерживания кнопки для полной поимки призрака (сек)

	-- Параметры тестовой карты
	SpawnZoneSize = Vector3.new(60, 1, 60),
	SpawnZonePosition = Vector3.new(0, 0.5, 0),

	-- Параметры черного рынка (Зоны продажи)
	BlackMarketPosition = Vector3.new(30, 0.5, 30),
	BlackMarketSize = Vector3.new(10, 1, 10),
	SellDistance = 15,           -- Максимально допустимая дистанция до зоны продажи

	-- Параметры глобального лидерборда
	LeaderboardPosition = Vector3.new(-25, 6, -25),
	LeaderboardSize = Vector3.new(16, 11, 1),
}

return GameConfig
