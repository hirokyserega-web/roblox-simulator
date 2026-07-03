-- Клиентский контроллер барьеров локаций
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Папка с локациями
local locationsFolder = Workspace:WaitForChild("Locations", 15)

-- Вспомогательная функция для плавного исчезновения барьера
local function disableBarrier(barrierName: string)
	if not locationsFolder then return end
	local barrier = locationsFolder:WaitForChild(barrierName, 5)
	if not barrier or not barrier:IsA("BasePart") then return end

	-- Выключаем коллизию сразу
	barrier.CanCollide = false

	-- Плавно убираем видимость барьера (эффект силового поля растворяется)
	local tweenInfo = TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(barrier, tweenInfo, {Transparency = 1})
	tween:Play()
	
	print("[LOCATION CLIENT] Локальный барьер разблокирован: " .. barrierName)
end

-- Настройка отслеживания разблокировок зон
local function setupLocationListeners()
	local function checkZone(zoneName: string)
		local attrName = "Unlocked_" .. zoneName
		local isUnlocked = player:GetAttribute(attrName)
		
		if isUnlocked == true then
			disableBarrier("Barrier_" .. zoneName)
		end
	end

	-- Слушаем изменения статусов разблокировок
	player:GetAttributeChangedSignal("Unlocked_ForestArea"):Connect(function()
		checkZone("ForestArea")
	end)

	player:GetAttributeChangedSignal("Unlocked_MansionArea"):Connect(function()
		checkZone("MansionArea")
	end)

	-- Первоначальный чек при входе/спавне
	checkZone("ForestArea")
	checkZone("MansionArea")
end

-- Инициализация контроллера
local function init()
	if not locationsFolder then
		warn("[LOCATION CLIENT] Не найдена папка локаций в Workspace!")
		return
	end
	
	setupLocationListeners()
	print("[LOCATION CLIENT] Контроллер барьеров успешно запущен!")
end

init()
