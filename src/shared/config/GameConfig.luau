-- Общие настройки игры Ghost Hunter Simulator (Фаза 2)
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
}

return GameConfig
