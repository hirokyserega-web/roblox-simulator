-- Менеджер зоны продажи (Sell Zone)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerStateManager = require(script.Parent.PlayerStateManager)

local SellManager = {}
local sellZone = nil
local debounces = {} -- Защита от дребезга (debounce) для каждого игрока

-- Инициализация зоны продажи
function SellManager.init(zonePart: Part)
	sellZone = zonePart
	
	-- Слушаем касание зоны продажи
	sellZone.Touched:Connect(SellManager.onZoneTouched)
	
	print("Зона продажи успешно инициализирована!")
end

-- Обработка касания зоны игроком
function SellManager.onZoneTouched(hit: Instance)
	local character = hit.Parent
	if not character then return end
	
	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end
	
	-- Защита от множественного срабатывания Touched
	if debounces[player.UserId] then return end
	debounces[player.UserId] = true
	
	-- Сбрасываем привидений и получаем их общую стоимость
	local count, value = PlayerStateManager.clearGhosts(player)
	
	if count > 0 then
		-- Начисляем деньги игроку
		PlayerStateManager.addStat(player, "Money", value)
		print(string.format("Игрок %s продал привидений: %d. Получено: %d Монет", player.Name, count, value))
		
		-- Небольшой визуальный эффект: кратковременное изменение цвета зоны при продаже
		local originalColor = sellZone.Color
		sellZone.Color = Color3.fromRGB(100, 255, 100) -- Зеленый при успехе
		task.delay(0.5, function()
			sellZone.Color = originalColor
		end)
	end
	
	-- Снимаем debounce через 1 секунду
	task.wait(1)
	debounces[player.UserId] = nil
end

return SellManager
