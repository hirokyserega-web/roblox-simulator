-- Контроллер поимки привидений (Client Input & Catching)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local NetworkEvents = require(ReplicatedStorage.Shared.NetworkEvents)

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local catchGhostEvent = NetworkEvents.getEvent("CatchGhost")

-- Получаем доступ к папке с привидениями
local spawnedGhostsFolder = Workspace:WaitForChild("SpawnedGhosts", 15)

-- Функция создания красивого луча (лазера) от игрока к привидению
local function drawCatchLaser(character: Model, targetPart: Part)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart or not targetPart then return end

	-- Создаем временные точки прикрепления луча
	local attachmentPlayer = Instance.new("Attachment")
	attachmentPlayer.Name = "LaserAttachmentPlayer"
	attachmentPlayer.Parent = humanoidRootPart

	local attachmentGhost = Instance.new("Attachment")
	attachmentGhost.Name = "LaserAttachmentGhost"
	attachmentGhost.Parent = targetPart

	-- Создаем луч
	local beam = Instance.new("Beam")
	beam.Attachment0 = attachmentPlayer
	beam.Attachment1 = attachmentGhost
	
	-- Градиент цвета луча (от синего к голубому)
	beam.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 255, 255))
	})
	
	beam.Width0 = 0.4
	beam.Width1 = 0.1
	beam.FaceCamera = true
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.Texture = "rbxassetid://446111271" -- Дефолтная текстура луча
	beam.TextureSpeed = 3
	beam.Parent = humanoidRootPart

	-- Удаляем луч через 0.15 секунды
	task.delay(0.15, function()
		attachmentPlayer:Destroy()
		if attachmentGhost.Parent then
			attachmentGhost:Destroy()
		end
		beam:Destroy()
	end)
end

-- Обработка ввода (клик/нажатие)
local function onInputBegan(input: InputObject, processed: boolean)
	if processed then return end -- Игнорируем клики по интерфейсу (UI)
	
	local inputType = input.UserInputType
	if inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch then
		local character = player.Character
		if not character then return end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		-- Стреляем лучом из камеры по курсору
		local target = mouse.Target
		
		-- Проверяем, кликнули ли мы по привидению
		if target and spawnedGhostsFolder and target:IsDescendantOf(spawnedGhostsFolder) then
			-- Проверяем дистанцию до привидения
			local distance = (rootPart.Position - target.Position).Magnitude
			if distance <= GameConfig.Ghosts.CatchDistance then
				-- Визуальный эффект лазера
				drawCatchLaser(character, target)
				
				-- Отправляем запрос на сервер
				catchGhostEvent:FireServer(target)
			end
		end
	end
end

UserInputService.InputBegan:Connect(onInputBegan)
print("Контроллер поимки привидений успешно запущен!")
