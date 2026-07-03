-- Клиентский контроллер детектора привидений
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local UpgradeConfig = require(ReplicatedStorage.Shared.config.UpgradeConfig)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Ссылка на папку со спавнящимися привидениями
local spawnedGhostsFolder = Workspace:WaitForChild("SpawnedGhosts", 15)

-- Переменные для элементов UI
local screenGui = nil
local progressFill = nil
local signalText = nil

-- Функция для программного создания интерфейса детектора
local function createDetectorUI()
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DetectorHUD"
	screenGui.ResetOnSpawn = false

	-- Главный контейнер в верхней части экрана
	local frame = Instance.new("Frame")
	frame.Name = "DetectorFrame"
	frame.Size = UDim2.new(0, 260, 0, 75)
	frame.Position = UDim2.new(0.5, -130, 0, 25)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	-- Заголовок детектора
	local title = Instance.new("TextLabel")
	title.Name = "TitleLabel"
	title.Size = UDim2.new(1, 0, 0, 20)
	title.Position = UDim2.new(0, 0, 0, 8)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.FredokaOne
	title.TextSize = 14
	title.TextColor3 = Color3.fromRGB(240, 240, 255)
	title.Text = "P.K.E. DETECTOR"
	title.Parent = frame

	-- Задний фон полосы прогресса (серая линия)
	local progressBg = Instance.new("Frame")
	progressBg.Name = "ProgressBackground"
	progressBg.Size = UDim2.new(1, -30, 0, 12)
	progressBg.Position = UDim2.new(0, 15, 0, 32)
	progressBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
	progressBg.BorderSizePixel = 0
	progressBg.Parent = frame

	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(0, 6)
	bgCorner.Parent = progressBg

	-- Заполняющая часть полосы прогресса (активный сигнал)
	progressFill = Instance.new("Frame")
	progressFill.Name = "ProgressFill"
	progressFill.Size = UDim2.new(0, 0, 1, 0)
	progressFill.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Изначально зеленый
	progressFill.BorderSizePixel = 0
	progressFill.Parent = progressBg

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 6)
	fillCorner.Parent = progressFill

	-- Текстовый индикатор расстояния / силы сигнала
	signalText = Instance.new("TextLabel")
	signalText.Name = "SignalText"
	signalText.Size = UDim2.new(1, 0, 0, 18)
	signalText.Position = UDim2.new(0, 0, 0, 48)
	signalText.BackgroundTransparency = 1
	signalText.Font = Enum.Font.SourceSansBold
	signalText.TextSize = 14
	signalText.TextColor3 = Color3.fromRGB(180, 180, 190)
	signalText.Text = "NO SIGNAL"
	signalText.Parent = frame

	screenGui.Parent = playerGui
end

-- Основной цикл обновления детектора
local function updateDetector()
	if not spawnedGhostsFolder then return end
	local character = player.Character
	if not character then
		if progressFill then
			progressFill.Size = UDim2.new(0, 0, 1, 0)
			signalText.Text = "NO SIGNAL"
		end
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local myPos = rootPart.Position
	local minDistance = math.huge
	local nearestGhost = nil

	-- Ищем ближайшего призрака в папке
	for _, ghost in ipairs(spawnedGhostsFolder:GetChildren()) do
		if ghost:IsA("BasePart") then
			local dist = (myPos - ghost.Position).Magnitude
			if dist < minDistance then
				minDistance = dist
				nearestGhost = ghost
			end
		end
	end

	-- Рассчитываем силу сигнала на основе уровня апгрейда
	local level = player:GetAttribute("DetectorRadiusLvl") or 1
	local detectorRadius = UpgradeConfig.DetectorRadius.Levels[level].Value

	local signalPercent = 0
	if nearestGhost and minDistance <= detectorRadius then
		signalPercent = (1 - (minDistance / detectorRadius)) * 100
	end

	-- Обновляем UI
	if signalPercent > 0 then
		-- Сглаженное движение полосы прогресса
		progressFill.Size = UDim2.new(signalPercent / 100, 0, 1, 0)
		signalText.Text = string.format("SIGNAL STRENGTH: %.1f%% (Dist: %.1f studs)", signalPercent, minDistance)
		
		-- Меняем цвет в зависимости от силы сигнала (Зеленый -> Желтый -> Красный)
		if signalPercent > 75 then
			progressFill.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Красный (очень близко)
		elseif signalPercent > 40 then
			progressFill.BackgroundColor3 = Color3.fromRGB(241, 196, 15) -- Желтый (близко)
		else
			progressFill.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Зеленый (на грани обнаружения)
		end
	else
		progressFill.Size = UDim2.new(0, 0, 1, 0)
		signalText.Text = "NO SIGNAL"
	end
end

-- Инициализация
createDetectorUI()
RunService.RenderStepped:Connect(updateDetector)

print("Detector client controller started")
