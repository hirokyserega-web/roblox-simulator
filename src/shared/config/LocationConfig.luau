-- Конфигурация локаций для Ghost Hunter Simulator
local LocationConfig = {
	StarterArea = {
		Id = "StarterArea",
		DisplayName = "Начальное кладбище",
		Cost = 0,
		Position = Vector3.new(0, 0.5, 0),
		Size = Vector3.new(60, 1, 60),
		AllowedGhosts = { "Common", "Uncommon" },
		MaxGhosts = 6
	},
	
	ForestArea = {
		Id = "ForestArea",
		DisplayName = "Заброшенный лес",
		Cost = 1000,
		Position = Vector3.new(0, 0.5, 120),
		Size = Vector3.new(60, 1, 60),
		AllowedGhosts = { "Uncommon", "Rare", "Epic" },
		MaxGhosts = 6,
		BarrierPosition = Vector3.new(0, 8, 60),
		BarrierSize = Vector3.new(60, 16, 1),
		SignPosition = Vector3.new(0, 3, 57)
	},
	
	MansionArea = {
		Id = "MansionArea",
		DisplayName = "Проклятый особняк",
		Cost = 5000,
		Position = Vector3.new(0, 0.5, 240),
		Size = Vector3.new(60, 1, 60),
		AllowedGhosts = { "Rare", "Epic", "Legendary", "Secret" },
		MaxGhosts = 6,
		BarrierPosition = Vector3.new(0, 8, 180),
		BarrierSize = Vector3.new(60, 16, 1),
		SignPosition = Vector3.new(0, 3, 177)
	}
}

return LocationConfig
