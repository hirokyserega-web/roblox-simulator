-- Конфигурация промокодов для Ghost Hunter Simulator
local PromoConfig = {
	GHOST2026 = {
		RewardType = "Money",
		Amount = 1000,
		DisplayName = "1,000 Монет"
	},
	SUPERPET = {
		RewardType = "Pet",
		PetType = "Bunny", -- Выдает зайца напрямую
		DisplayName = "Питомец Заяц (x1.5 монет)"
	},
	CRYSTALS = {
		RewardType = "Crystals",
		Amount = 50,
		DisplayName = "50 Кристаллов"
	}
}

return PromoConfig
