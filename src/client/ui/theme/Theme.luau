-- UI Theme & Design System (Candy 3D Style) for Ghost Hunter Simulator
local Theme = {
	-- Color Palette (from Concept)
	Colors = {
		Background = Color3.fromHex("12131F"),      -- Main backdrop
		Panel = Color3.fromHex("232544"),           -- Panel background
		PanelOpacity = 0.92,
		
		Green = Color3.fromHex("3AE374"),           -- BUY / Money / Success
		Red = Color3.fromHex("FF3F4B"),             -- Close / Not enough / Error
		Yellow = Color3.fromHex("FFC048"),          -- MAX / Trophies / Warning
		Purple = Color3.fromHex("7B2FF7"),          -- Rebirth / Pets / Accent
		Blue = Color3.fromHex("00E5FF"),            -- Capture / Rare / Neon
		Orange = Color3.fromHex("FF8A3D"),          -- Shop
		
		Text = Color3.fromHex("FFFFFF"),            -- Main white text
		Stroke = Color3.fromHex("14141E"),          -- Dark stroke for text/UI
	},

	-- Rarity Colors
	RarityColors = {
		Common = Color3.fromHex("C9CCD6"),
		Uncommon = Color3.fromHex("3AE374"),
		Rare = Color3.fromHex("00E5FF"),
		Epic = Color3.fromHex("B24BF3"),
		Legendary = Color3.fromHex("FF9F1C"),
		Secret = Color3.fromHex("7B2FF7")
	},

	-- Typography
	Fonts = {
		Main = Enum.Font.GothamBlack,
		Secondary = Enum.Font.FredokaOne,
	},

	-- Design Parameters
	Sizes = {
		CornerButton = UDim.new(0, 14),
		CornerPanel = UDim.new(0, 20),
		CornerPill = UDim.new(1, 0),
		StrokeThickness = 2,
		TextStrokeThickness = 1.5,
		ButtonDepth = 4,
	},

	-- Sounds
	Sounds = {
		Click = "rbxassetid://8214392737",
		Success = "rbxassetid://2865227271",
		Error = "rbxassetid://2865227447",
		Hatch = "rbxassetid://9086152341"
	}
}

return Theme
