-- Конфигурация питомцев и яиц для Ghost Hunter Simulator
local PetConfig = {
	Eggs = {
		CommonEgg = {
			DisplayName = "Обычное яйцо",
			Cost = 500,
			Color = Color3.fromRGB(240, 240, 240),
			Chances = {
				{ PetType = "Cat", Chance = 50 },
				{ PetType = "Dog", Chance = 40 },
				{ PetType = "Bunny", Chance = 10 }
			}
		},
		SpookyEgg = {
			DisplayName = "Жуткое яйцо",
			Cost = 2500,
			Color = Color3.fromRGB(155, 89, 182), -- Фиолетовый
			Chances = {
				{ PetType = "Bat", Chance = 60 },
				{ PetType = "Spider", Chance = 35 },
				{ PetType = "GhostPet", Chance = 5 }
			}
		}
	},

	Pets = {
		Cat = {
			DisplayName = "Кот",
			Rarity = "Common",
			Color = Color3.fromRGB(200, 200, 200),
			Multiplier = 1.2
		},
		Dog = {
			DisplayName = "Собака",
			Rarity = "Common",
			Color = Color3.fromRGB(220, 160, 100),
			Multiplier = 1.2
		},
		Bunny = {
			DisplayName = "Заяц",
			Rarity = "Uncommon",
			Color = Color3.fromRGB(240, 240, 255),
			Multiplier = 1.5
		},
		Bat = {
			DisplayName = "Летучая мышь",
			Rarity = "Uncommon",
			Color = Color3.fromRGB(80, 80, 100),
			Multiplier = 1.8
		},
		Spider = {
			DisplayName = "Паук",
			Rarity = "Rare",
			Color = Color3.fromRGB(40, 40, 45),
			Multiplier = 2.5
		},
		GhostPet = {
			DisplayName = "Дух-помощник",
			Rarity = "Legendary",
			Color = Color3.fromRGB(150, 250, 255),
			Multiplier = 5.0
		}
	}
}

return PetConfig
