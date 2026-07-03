-- Конфигурация уровней улучшений для Ghost Hunter Simulator
local UpgradeConfig = {
	-- Вместимость рюкзака (Bag Capacity)
	BagCapacity = {
		DisplayName = "Вместимость сумки",
		Description = "Позволяет переносить больше призраков за раз.",
		MaxLevel = 5,
		Levels = {
			[1] = { Value = 10, Cost = 0 },
			[2] = { Value = 20, Cost = 150 },
			[3] = { Value = 45, Cost = 400 },
			[4] = { Value = 90, Cost = 1000 },
			[5] = { Value = 200, Cost = 2500 }
		}
	},

	-- Скорость бега (WalkSpeed)
	WalkSpeed = {
		DisplayName = "Скорость бега",
		Description = "Увеличивает скорость передвижения вашего персонажа.",
		MaxLevel = 5,
		Levels = {
			[1] = { Value = 16, Cost = 0 },
			[2] = { Value = 20, Cost = 100 },
			[3] = { Value = 24, Cost = 250 },
			[4] = { Value = 28, Cost = 600 },
			[5] = { Value = 32, Cost = 1500 }
		}
	},

	-- Радиус действия детектора (Detector Radius)
	DetectorRadius = {
		DisplayName = "Радиус детектора",
		Description = "Позволяет обнаруживать призраков на большем расстоянии.",
		MaxLevel = 5,
		Levels = {
			[1] = { Value = 50, Cost = 0 },
			[2] = { Value = 70, Cost = 120 },
			[3] = { Value = 95, Cost = 300 },
			[4] = { Value = 125, Cost = 700 },
			[5] = { Value = 160, Cost = 1800 }
		}
	},

	-- Скорость захвата ловушкой (Capture Speed - снижает время захвата призрака)
	CaptureSpeed = {
		DisplayName = "Сила ловушки",
		Description = "Сокращает время удерживания кнопки для ловли призрака.",
		MaxLevel = 5,
		Levels = {
			[1] = { Value = 2.0, Cost = 0 },   -- Время удержания 2 секунды
			[2] = { Value = 1.6, Cost = 150 }, -- 1.6 секунды
			[3] = { Value = 1.2, Cost = 350 }, -- 1.2 секунды
			[4] = { Value = 0.8, Cost = 800 }, -- 0.8 секунды
			[5] = { Value = 0.4, Cost = 2000 } -- 0.4 секунды
		}
	}
}

return UpgradeConfig
