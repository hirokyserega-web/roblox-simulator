-- Таблица редкостей привидений (Ghost Rarities) для Ghost Hunter Simulator
local GhostConfig = {
	Common = {
		Id = "Common",
		Name = "Обычный призрак",
		Color = Color3.fromRGB(150, 220, 255),
		SpawnChance = 50.0,
		BasePrice = 10,
		BehaviorType = "Passive"
	},
	Uncommon = {
		Id = "Uncommon",
		Name = "Необычный призрак",
		Color = Color3.fromRGB(150, 255, 150),
		SpawnChance = 30.0,
		BasePrice = 25,
		BehaviorType = "Passive"
	},
	Rare = {
		Id = "Rare",
		Name = "Редкий призрак",
		Color = Color3.fromRGB(220, 150, 255),
		SpawnChance = 13.9,
		BasePrice = 60,
		BehaviorType = "Fleeing"
	},
	Epic = {
		Id = "Epic",
		Name = "Эпический призрак",
		Color = Color3.fromRGB(255, 200, 50),
		SpawnChance = 5.0,
		BasePrice = 150,
		BehaviorType = "Fleeing"
	},
	Legendary = {
		Id = "Legendary",
		Name = "Легендарный призрак",
		Color = Color3.fromRGB(255, 80, 80),
		SpawnChance = 1.0,
		BasePrice = 400,
		BehaviorType = "Aggressive"
	},
	Secret = {
		Id = "Secret",
		Name = "Секретный призрак",
		Color = Color3.fromRGB(255, 255, 255),
		SpawnChance = 0.1,
		BasePrice = 1200,
		BehaviorType = "Aggressive"
	}
}

return GhostConfig
