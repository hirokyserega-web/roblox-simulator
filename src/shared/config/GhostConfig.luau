-- Таблица редкостей и поведения привидений для Ghost Hunter Simulator
local GhostConfig = {
	Common = {
		Id = "Common",
		Name = "Обычный призрак",
		Color = Color3.fromRGB(150, 220, 255),
		SpawnChance = 50.0,
		BasePrice = 10,
		BehaviorType = "Passive",
		Speed = 0,
		ScareInterval = 15
	},
	Uncommon = {
		Id = "Uncommon",
		Name = "Необычный призрак",
		Color = Color3.fromRGB(150, 255, 150),
		SpawnChance = 30.0,
		BasePrice = 25,
		BehaviorType = "Passive",
		Speed = 0,
		ScareInterval = 12
	},
	Rare = {
		Id = "Rare",
		Name = "Редкий призрак",
		Color = Color3.fromRGB(220, 150, 255),
		SpawnChance = 13.9,
		BasePrice = 60,
		BehaviorType = "Fleeing",
		Speed = 8,
		FleeRange = 15,
		ScareInterval = 10
	},
	Epic = {
		Id = "Epic",
		Name = "Эпический призрак",
		Color = Color3.fromRGB(255, 200, 50),
		SpawnChance = 5.0,
		BasePrice = 150,
		BehaviorType = "Teleport",
		Speed = 10,
		TeleportInterval = 6,
		ScareInterval = 8
	},
	Legendary = {
		Id = "Legendary",
		Name = "Легендарный призрак",
		Color = Color3.fromRGB(255, 80, 80),
		SpawnChance = 1.0,
		BasePrice = 400,
		BehaviorType = "Aggressive",
		Speed = 12,
		AggroRange = 25,
		TeleportInterval = 8,
		ScareInterval = 6
	},
	Secret = {
		Id = "Secret",
		Name = "Секретный призрак",
		Color = Color3.fromRGB(255, 255, 255),
		SpawnChance = 0.1,
		BasePrice = 1200,
		BehaviorType = "Aggressive",
		Speed = 15,
		AggroRange = 35,
		TeleportInterval = 5,
		ScareInterval = 4
	}
}

return GhostConfig
