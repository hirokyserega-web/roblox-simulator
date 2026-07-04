-- UI Theme & Design System (Candy 3D / Toy-Like Style)
local Theme = {}

Theme.Colors = {
	Background = Color3.fromHex("0E0F1F"),
	BackgroundSecondary = Color3.fromHex("1B1D36"),
	Panel = Color3.fromHex("1D1F38"),
	PanelOpacity = 0.94,
	
	-- Vibrant Button Colors
	Success = Color3.fromHex("00D250"),      -- Green for GHOST VACUUM BUY button
	Error = Color3.fromHex("FF004B"),        -- Red for BACKPACK BUY NOT ENOUGH button
	Warning = Color3.fromHex("FFB300"),      -- Yellow/Gold for DETECTOR MAX button
	Info = Color3.fromHex("00B0FF"),         -- Blue for capture progress bar
	Accent = Color3.fromHex("8F00FF"),       -- Purple for Rebirth neon button
	
	Text = Color3.fromHex("FFFFFF"),
	TextSecondary = Color3.fromHex("A2A8C9"),
	Stroke = Color3.fromHex("2E325C"),
}

Theme.RarityColors = {
	Common = Color3.fromHex("9D9D9D"),
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
	Click = "rbxassetid://6042053626",      -- Beautiful bubble click sound
	Success = "rbxassetid://6042054215",    -- Catch success
	Upgrade = "rbxassetid://5153734005",    -- Buy upgrade chime
}

return Theme
