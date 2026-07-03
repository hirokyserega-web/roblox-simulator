-- UI Theme & Design System (Candy 3D Style)
local Theme = {}
Theme.Colors = {
	Background = Color3.fromHex("12131F"),
	BackgroundSecondary = Color3.fromHex("232544"),
	Panel = Color3.fromHex("232544"),
	PanelOpacity = 0.92,
	Success = Color3.fromHex("3AE374"),
	Error = Color3.fromHex("FF3F4B"),
	Warning = Color3.fromHex("FFC048"),
	Info = Color3.fromHex("00E5FF"),
	Accent = Color3.fromHex("7B2FF7"),
	Text = Color3.fromHex("FFFFFF"),
	TextSecondary = Color3.fromHex("A0A0B8"),
	Stroke = Color3.fromHex("14141E"),
	White = Color3.new(1, 1, 1),
}
Theme.Fonts = {
	Main = Enum.Font.FredokaOne,
	Secondary = Enum.Font.GothamMedium,
	Title = Enum.Font.FredokaOne,
	Body = Enum.Font.GothamMedium,
}
Theme.Sizes = {
	CornerRadius = UDim.new(0, 12),
	CornerButton = UDim.new(0, 10),
	StrokeThickness = 2,
}
Theme.Sounds = {
	Click = "rbxassetid://8214392737",
	Success = "rbxassetid://6518811702",
	Error = "rbxassetid://9061140085",
}
Theme.RarityColors = {
	Common = Color3.fromHex("b2bec3"),
	Uncommon = Color3.fromHex("55efc4"),
	Rare = Color3.fromHex("74b9ff"),
	Epic = Color3.fromHex("a29bfe"),
	Legendary = Color3.fromHex("fdcb6e"),
	Mythical = Color3.fromHex("ff7675")
}
return Theme
