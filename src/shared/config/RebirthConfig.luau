-- Конфигурация перерождений для Ghost Hunter Simulator
local RebirthConfig = {
	BaseCost = 100000, -- Базовая цена первого перерождения
	CostStep = 50000,   -- Шаг увеличения цены
	MultiplierPerRebirth = 0.5, -- +50% за rebirth

	-- Вычисление стоимости следующего перерождения
	getCost = function(currentRebirths: number): number
		return RebirthConfig.BaseCost + (currentRebirths * RebirthConfig.CostStep)
	end
}

return RebirthConfig
