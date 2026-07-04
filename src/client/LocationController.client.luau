-- Клиентский контроллер барьеров локаций
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocationConfig = require(ReplicatedStorage.Shared.config.LocationConfig)
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

-- Вспомогательная функция для плавного управления барьером
local function updateBarrierState(zoneName: string, isUnlocked: boolean)
	if not locationsFolder then return end
	local barrierName = "Barrier_" .. zoneName
	local barrier = locationsFolder:FindFirstChild(barrierName)
	if not barrier or not barrier:IsA("BasePart") then return end

	if isUnlocked then
		barrier.CanCollide = false
		local tweenInfo = TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(barrier, tweenInfo, {Transparency = 1})
		tween:Play()
	else
		barrier.CanCollide = true
		local tweenInfo = TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(barrier, tweenInfo, {Transparency = 0.5})
		tween:Play()
	end
end

-- Настройка отслеживания разблокировок зон
local function setupLocationListeners()
	local function checkZone(zoneId: string)
		local attrName = "Zone_" .. zoneId
		local isUnlocked = (LocationConfig[zoneId].Cost == 0) or (player:GetAttribute(attrName) == true)
		updateBarrierState(zoneId, isUnlocked)
	end

	-- Динамически слушаем все зоны из конфига
	for zoneId, config in pairs(LocationConfig) do
		player:GetAttributeChangedSignal("Zone_" .. zoneId):Connect(function()
			checkZone(zoneId)
		end)
		-- Первоначальный чек
		checkZone(zoneId)
	end
end

-- Инициализация контроллера
local function init()
	task.spawn(function()
		if not locationsFolder then
			while not locationsFolder do
				task.wait(0.5)
				locationsFolder = Workspace:FindFirstChild("Locations")
			end
		end
		setupLocationListeners()
		print("[LOCATION CLIENT] Контроллер барьеров запущен динамически!")
	end)
end

init()
