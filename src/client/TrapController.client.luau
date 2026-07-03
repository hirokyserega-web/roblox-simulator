-- Клиентский контроллер ловушки (Client Input & Catching)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local UpgradeConfig = require(ReplicatedStorage.Shared.config.UpgradeConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

-- Подгрузка UIManager
local UIManager = require(script.Parent.ui.UIManager)

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Сетевые события
local captureGhostEvent = Remotes.getEvent("CaptureGhost")
local inventoryUpdateEvent = Remotes.getEvent("InventoryUpdate")

-- Локальное состояние рюкзака
local currentBagCount = 0
local maxBagCapacity = GameConfig.DefaultBagCapacity

-- Состояние захвата
local activeGhost = nil
local captureProgress = 0
local isHolding = false

-- Функция сброса захвата
local function resetCapture()
	activeGhost = nil
	captureProgress = 0
	if _G.HideCapture then
		_G.HideCapture()
	end
end

-- Всплывающее предупреждение через UIManager
local function triggerNotification(text: string, nType: string?)
	UIManager.ShowToast(text, nType or "Warning")
end

-- Создание прогресс-бара по центру-низу экрана
local function createProgressBar(ghostPart: Part)
	local rarity = ghostPart:GetAttribute("Rarity") or "Common"
	if _G.ShowCapture then
		_G.ShowCapture({ Rarity = rarity })
	end
end

-- Обработка нажатия кнопки мыши / тапа по экрану
local function onInputBegan(input: InputObject, processed: boolean)
	if processed then return end

	local inputType = input.UserInputType
	if inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch then
		isHolding = true
		
		local target = mouse.Target
		local localGhostsFolder = Workspace:FindFirstChild("LocalGhosts")
		
		if target and localGhostsFolder and target:IsDescendantOf(localGhostsFolder) then
			local character = player.Character
			if not character then return end
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if not rootPart then return end

			-- Валидация дистанции
			local distance = (rootPart.Position - target.Position).Magnitude
			if distance <= GameConfig.TrapRange then
				-- Валидация переполнения сумки
				if currentBagCount >= maxBagCapacity then
					triggerNotification("Сумка полна!")
					return
				end

				-- Начинаем поимку
				activeGhost = target
				captureProgress = 0
				createProgressBar(activeGhost)
			end
		end
	end
end

-- Обработка отпускания кнопки
local function onInputEnded(input: InputObject, processed: boolean)
	local inputType = input.UserInputType
	if inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch then
		isHolding = false
		resetCapture()
	end
end

-- Обновление каждый кадр
local function onHeartbeat(dt: number)
	if not activeGhost then return end

	local character = player.Character
	if not character or not isHolding then
		resetCapture()
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		resetCapture()
		return
	end

	-- Проверяем, не исчез ли призрак, не отошел ли игрок далеко и наведен ли прицел
	local distance = (rootPart.Position - activeGhost.Position).Magnitude
	if distance > GameConfig.TrapRange or not activeGhost.Parent or mouse.Target ~= activeGhost then
		resetCapture()
		return
	end

	-- Рассчитываем скорость захвата на основе уровня улучшения
	local level = player:GetAttribute("CaptureSpeedLvl") or 1
	local captureTime = UpgradeConfig.CaptureSpeed.Levels[level].Value

	-- Рассчитываем прогресс захвата
	captureProgress = captureProgress + dt / captureTime
	
	-- Визуализируем прогресс
	if _G.SetCaptureProgress then
		_G.SetCaptureProgress(captureProgress)
	end

	-- Успешный захват
	if captureProgress >= 1 then
		local ghostId = activeGhost:GetAttribute("GhostId")
		resetCapture()
		if ghostId then
			captureGhostEvent:FireServer(ghostId)
		end
	end
end

-- Подписка на обновление инвентаря для отслеживания лимита на клиенте
inventoryUpdateEvent.OnClientEvent:Connect(function(inventory)
	if inventory and inventory.Ghosts then
		currentBagCount = #inventory.Ghosts
		maxBagCapacity = inventory.MaxCapacity
	end
end)

-- Подключения событий ввода
UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)
RunService.Heartbeat:Connect(onHeartbeat)

print("TrapController initialized (Capture logic)")
