-- Configuration of upgrade levels for Ghost Hunter Simulator (Candy 3D Edition)
local UpgradeConfig = {
	-- Backpack Capacity
	BagCapacity = {
		DisplayName = "BACKPACK",
		Description = "Allows carrying more ghosts at once.",
		MaxLevel = 5,
		Levels = {
			[1] = { Value = 10, Cost = 0 },
			[2] = { Value = 10, Cost = 750 }, -- Level 2 -> Level 3 costs 750
			[3] = { Value = 25, Cost = 1500 },
			[4] = { Value = 50, Cost = 3000 },
			[5] = { Value = 100, Cost = 6000 }
		}
	},

	-- Detector range / radius
	DetectorRadius = {
		DisplayName = "DETECTOR",
		Description = "Detects ghosts from a further distance.",
		MaxLevel = 5,
		Levels = {
			[1] = { Value = 50, Cost = 0 },
			[2] = { Value = 70, Cost = 250 },
			[3] = { Value = 95, Cost = 500 },
			[4] = { Value = 125, Cost = 1000 },
			[5] = { Value = 160, Cost = 2000 } -- Level 5 is MAX
		}
	},

	-- Trap / Ghost Vacuum speed
	CaptureSpeed = {
		DisplayName = "GHOST VACUUM",
		Description = "Reduces the time required to capture a ghost.",
		MaxLevel = 5,
		Levels = {
			[1] = { Value = 2.0, Cost = 0 },
			[2] = { Value = 1.5, Cost = 500 },
			[3] = { Value = 1.0, Cost = 1000 }, -- Level 3 -> Level 4 costs 1000
			[4] = { Value = 0.6, Cost = 2000 },
			[5] = { Value = 0.3, Cost = 4000 }
		}
	}
}

return UpgradeConfig
