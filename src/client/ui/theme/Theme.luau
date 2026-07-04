-- UI Theme & Design System (Candy 3D / Toy-Like Style)
local Theme = {}

Theme.Colors = {
	Background = Color3.fromHex("0E0F1F"),
	BackgroundSecondary = Color3.fromHex("1B1D36"),
	Panel = Color3.fromHex("1D1F38"),
	PanelOpacity = 0.94,
	
	-- Vibrant Button Colors - Lightened for better contrast
	Success = Color3.fromHex("00FF62"),      -- Brighter Green
	Error = Color3.fromHex("FF3B3B"),        -- Brighter Red
	Warning = Color3.fromHex("FFD700"),      -- Gold
	Info = Color3.fromHex("00D9FF"),         -- Brighter Blue
	Accent = Color3.fromHex("B347FF"),       -- Brighter Purple (Neon)
	
	Text = Color3.fromHex("FFFFFF"),
	TextSecondary = Color3.fromHex("D1D5F0"), -- Lighter TextSecondary
	Stroke = Color3.fromHex("3D4380"),       -- Lighter Stroke
}

Theme.RarityColors = {
	Common = Color3.fromHex("C4C4C4"),
	Uncommon = Color3.fromHex("3AE374"),
	Rare = Color3.fromHex("1790FF"),
	Epic = Color3.fromHex("9B51E0"),
	Legendary = Color3.fromHex("F2C94C")
}

Theme.Fonts = {
	Main = Enum.Font.FredokaOne,
	Bold = Enum.Font.FredokaOne,
	Title = Enum.Font.FredokaOne,
	Body = Enum.Font.FredokaOne,
}

Theme.Sizes = {
	CornerRadius = UDim.new(0, 16),
	CornerButton = UDim.new(0, 12),
	StrokeThickness = 3,
}

Theme.Sounds = {
	Click = "rbxassetid://6042053626",
	Success = "rbxassetid://6042054215",
	Upgrade = "rbxassetid://5153734005",
}

return Theme
