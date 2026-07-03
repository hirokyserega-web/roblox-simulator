-- Конфигурация баланса и настроек игры Ghost Hunter Simulator
local GameConfig = {}

-- Начальные характеристики игрока
GameConfig.InitialStats = {
	Money = 0,
	Crystals = 0,
	Rebirths = 0,
	MaxCapacity = 10, -- Стартовая вместимость рюкзака для привидений
}

-- Настройки перерождений (Rebirths)
GameConfig.Rebirth = {
	BaseCost = 1000,             -- Базовая стоимость первого ребитха в Монетах
	CostMultiplier = 1.5,        -- Коэффициент увеличения цены с каждым ребитхом
	CrystalsRewardBase = 10,     -- Кристаллов за ребитх
	CrystalsMultiplier = 1.2,    -- Коэффициент увеличения награды кристаллов за каждый ребитх
}

-- Настройки привидений
GameConfig.Ghosts = {
	SpawnInterval = 3,           -- Интервал спавна привидений в секундах
	MaxGhostsInZone = 15,        -- Лимит привидений на зоне
	CatchDistance = 25,          -- Максимальная дистанция поимки от игрока (в студах)
	Types = {
		Common = {
			Name = "Common Ghost",
			Color = Color3.fromRGB(150, 220, 255),
			Value = 10,               -- Сколько монет дает при продаже
			MaxHealth = 3,            -- Сколько кликов нужно для поимки
			Size = Vector3.new(2, 2, 2)
		},
		Rare = {
			Name = "Rare Ghost",
			Color = Color3.fromRGB(220, 150, 255),
			Value = 25,
			MaxHealth = 6,
			Size = Vector3.new(2.5, 2.5, 2.5)
		},
		Epic = {
			Name = "Epic Ghost",
			Color = Color3.fromRGB(255, 215, 0),
			Value = 75,
			MaxHealth = 12,
			Size = Vector3.new(3, 3, 3)
		}
	}
}

-- Настройки зон (для автоматической генерации тестовой арены)
GameConfig.Map = {
	SpawnZoneSize = Vector3.new(60, 1, 60),
	SpawnZonePosition = Vector3.new(0, 0.5, 0),
	SellZoneSize = Vector3.new(10, 1, 10),
	SellZonePosition = Vector3.new(40, 0.5, 40),
}

return GameConfig
