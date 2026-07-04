-- General settings for Ghost Hunter Simulator (Candy 3D Edition)
local GameConfig = {
	-- Starting parameters matching the prompt
	StartingMoney = 100000,
	StartingCrystals = 500,
	DefaultBagCapacity = 10,

	-- Ghost spawn settings
	SpawnInterval = 3,           -- Seconds between spawns
	MaxGhosts = 10,              -- Max ghosts on map

	-- Detector settings
	DetectorRadius = 50,         -- Base detector radius

	-- Trap / Capture settings
	TrapRange = 25,              -- Catch range
	SellMultiplier = 1.0,
	SellDistance = 50,           -- Maximum distance to sell

	-- Spawn Zone Settings
	SpawnZonePosition = Vector3.new(0, 5, 0),
	SpawnZoneSize = Vector3.new(10, 1, 10),

	-- Black Market Settings
	BlackMarketPosition = Vector3.new(50, 5, 0),
	BlackMarketSize = Vector3.new(8, 1, 8),
}

return GameConfig
