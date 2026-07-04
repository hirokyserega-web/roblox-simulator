-- Клиентский контроллер барьеров локаций
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Папка с локациями
local locationsFolder = Workspace:WaitForChild("Locations", 30)
if not locationsFolder then
	task.spawn(function()
		while not locationsFolder do
			task.wait(0.5)
			locationsFolder = Workspace:FindFirstChild("Locations")
		end
	end)
end

-- Вспомогательная функция для плавного управления барьером (открытие/закрытие)
local function updateBarrierState(zoneName: string, isUnlocked: boolean)
	if not locationsFolder then return end
	local barrierName = "Barrier_" .. zoneName
	local barrier = locationsFolder:WaitForChild(barrierName, 5)
	if not barrier or not barrier:IsA("BasePart") then return end

	if isUnlocked then
		barrier.CanCollide = false
		local tweenInfo = TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(barrier, tweenInfo, {Transparency = 1})
		tween:Play()
		print("[LOCATION CLIENT] Локальный барьер открыт: " .. barrierName)
	else
		barrier.CanCollide = true
		local tweenInfo = TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(barrier, tweenInfo, {Transparency = 0.5})
		tween:Play()
		print("[LOCATION CLIENT] Локальный барьер закрыт: " .. barrierName)
	end
end

-- Настройка отслеживания разблокировок зон
local function setupLocationListeners()
	local function checkZone(zoneName: string)
		local attrName = "Unlocked_" .. zoneName
		local isUnlocked = player:GetAttribute(attrName) == true
		updateBarrierState(zoneName, isUnlocked)
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
		-- Ждем появление папки в фоновом режиме, чтобы не спамить ворнингами
		task.spawn(function()
			while not locationsFolder do
				task.wait(0.5)
				locationsFolder = Workspace:FindFirstChild("Locations")
			end
			setupLocationListeners()
			print("[LOCATION CLIENT] Контроллер барьеров успешно запущен!")
		end)
	else
		setupLocationListeners()
		print("[LOCATION CLIENT] Контроллер барьеров успешно запущен!")
	end
end

init()
