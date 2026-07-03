-- UI Тема и дизайн-система (Theme) для Ghost Hunter Simulator
local Theme = {
	-- Цветовая палитра
	Colors = {
		Background = Color3.fromHex("1A1B2E"),      -- Темный фон панелей
		BackgroundSecondary = Color3.fromHex("252641"), -- Карточки, вторичный фон
		Accent = Color3.fromHex("7B2FF7"),          -- Главный фиолетовый
		Neon = Color3.fromHex("00E5FF"),            -- Сигнал, подсветка, неон
		Success = Color3.fromHex("3AE374"),         -- Деньги, кнопки успеха
		Warning = Color3.fromHex("FFC048"),         -- Полная сумка, предупреждения
		Error = Color3.fromHex("FF3F6C"),           -- Недостаток монет, ошибки
		Text = Color3.fromHex("FFFFFF"),            -- Основной белый текст
		TextSecondary = Color3.fromHex("B8B9D6"),   -- Вторичный серый текст
		Stroke = Color3.fromHex("0D0E1A")           -- Темная обводка
	},

	-- Цвета редкостей
	RarityColors = {
		Common = Color3.fromHex("C9CCD6"),
		Uncommon = Color3.fromHex("3AE374"),
		Rare = Color3.fromHex("3A8DFF"),
		Epic = Color3.fromHex("B24BF3"),
		Legendary = Color3.fromHex("FF9F1C"),
		Secret = Color3.fromHex("00E5FF") -- Радужная анимированная подсветка
	},

	-- Типографика
	Fonts = {
		Title = Enum.Font.FredokaOne,
		Button = Enum.Font.FredokaOne,
		Body = Enum.Font.GothamMedium,
		Bold = Enum.Font.GothamBold
	},

	-- Общие параметры дизайна
	Sizes = {
		BorderWidth = 2,
		CornerRadius = UDim.new(0, 8),
		PanelCornerRadius = UDim.new(0, 16)
	},

	-- Звуки интерфейса (ID ассетов)
	Sounds = {
		Click = "rbxassetid://8214392737",
		Success = "rbxassetid://2865227271",
		Error = "rbxassetid://2865227447",
		Hatch = "rbxassetid://9086152341"
	}
}

return Theme
