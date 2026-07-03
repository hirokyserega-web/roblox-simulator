-- Контроллер пользовательского интерфейса (Client HUD)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local NetworkEvents = require(ReplicatedStorage.Shared.NetworkEvents)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Ссылка на RemoteEvent ребитха
local requestRebirthEvent = NetworkEvents.getEvent("RequestRebirth")

-- Вспомогательная функция для форматирования чисел с запятыми (например, 1,000)
local function formatNumber(value: number): string
	local formatted = tostring(value)
	while true do  
		local k
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

-- Функция расчета стоимости следующего ребитха (дублирует формулу сервера)
local function getRebirthCost(rebirths: number): number
	return math.floor(GameConfig.Rebirth.BaseCost * math.pow(GameConfig.Rebirth.CostMultiplier, rebirths))
end

-- Функция создания UI
local function createHUD()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GhostHunterHUD"
	screenGui.ResetOnSpawn = false
	
	-- Основная панель
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 320, 0, 130)
	mainFrame.Position = UDim2.new(0.5, -160, 1, -150)
	mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	mainFrame.BackgroundTransparency = 0.15
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainFrame
	
	-- Градиент для красоты
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 45)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 25))
	})
	gradient.Parent = mainFrame

	-- Текст вместимости рюкзака
	local backpackLabel = Instance.new("TextLabel")
	backpackLabel.Name = "BackpackLabel"
	backpackLabel.Size = UDim2.new(1, -20, 0, 30)
	backpackLabel.Position = UDim2.new(0, 10, 0, 10)
	backpackLabel.BackgroundTransparency = 1
	backpackLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
	backpackLabel.Font = Enum.Font.FredokaOne
	backpackLabel.TextSize = 16
	backpackLabel.TextXAlignment = Enum.TextXAlignment.Left
	backpackLabel.Text = "Backpack: Loading..."
	backpackLabel.Parent = mainFrame

	-- Текст стоимости ребитха
	local rebirthLabel = Instance.new("TextLabel")
	rebirthLabel.Name = "RebirthLabel"
	rebirthLabel.Size = UDim2.new(1, -20, 0, 25)
	rebirthLabel.Position = UDim2.new(0, 10, 0, 40)
	rebirthLabel.BackgroundTransparency = 1
	rebirthLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	rebirthLabel.Font = Enum.Font.SourceSansBold
	rebirthLabel.TextSize = 15
	rebirthLabel.TextXAlignment = Enum.TextXAlignment.Left
	rebirthLabel.Text = "Next Rebirth: Loading..."
	rebirthLabel.Parent = mainFrame

	-- Кнопка покупки ребитха
	local rebirthBtn = Instance.new("TextButton")
	rebirthBtn.Name = "RebirthButton"
	rebirthBtn.Size = UDim2.new(1, -20, 0, 40)
	rebirthBtn.Position = UDim2.new(0, 10, 0, 75)
	rebirthBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Emerald Green
	rebirthBtn.BorderSizePixel = 0
	rebirthBtn.Font = Enum.Font.FredokaOne
	rebirthBtn.TextSize = 16
	rebirthBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	rebirthBtn.Text = "REBIRTH"
	rebirthBtn.Parent = mainFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = rebirthBtn
	
	-- Эффект наведения на кнопку
	rebirthBtn.MouseEnter:Connect(function()
		rebirthBtn.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
	end)
	rebirthBtn.MouseLeave:Connect(function()
		rebirthBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
	end)

	-- Подключение логики нажатия кнопки
	rebirthBtn.MouseButton1Click:Connect(function()
		requestRebirthEvent:FireServer()
	end)

	screenGui.Parent = playerGui
	return backpackLabel, rebirthLabel, rebirthBtn
end

-- Функция обновления HUD
local function startHUDController()
	local backpackLabel, rebirthLabel, rebirthBtn = createHUD()
	
	local leaderstats = player:WaitForChild("leaderstats", 15)
	local moneyVal = leaderstats and leaderstats:WaitForChild("Money", 5)
	local rebirthsVal = leaderstats and leaderstats:WaitForChild("Rebirths", 5)

	local function updateUI()
		local count = player:GetAttribute("GhostsCount") or 0
		local maxCap = player:GetAttribute("MaxCapacity") or GameConfig.InitialStats.MaxCapacity
		local value = player:GetAttribute("BackpackValue") or 0
		
		backpackLabel.Text = string.format("Backpack: %d/%d (%s Coins)", count, maxCap, formatNumber(value))
		
		local rebirths = rebirthsVal and rebirthsVal.Value or 0
		local cost = getRebirthCost(rebirths)
		rebirthLabel.Text = string.format("Rebirth Cost: %s Coins", formatNumber(cost))
		
		-- Делаем кнопку полупрозрачной, если не хватает денег
		local currentMoney = moneyVal and moneyVal.Value or 0
		if currentMoney >= cost then
			rebirthBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
			rebirthBtn.AutoButtonColor = true
		else
			rebirthBtn.BackgroundColor3 = Color3.fromRGB(127, 140, 141) -- Серый
			rebirthBtn.AutoButtonColor = false
		end
	end

	-- Подписываемся на изменения атрибутов и параметров
	player:GetAttributeChangedSignal("GhostsCount"):Connect(updateUI)
	player:GetAttributeChangedSignal("MaxCapacity"):Connect(updateUI)
	player:GetAttributeChangedSignal("BackpackValue"):Connect(updateUI)
	
	if moneyVal then moneyVal.Changed:Connect(updateUI) end
	if rebirthsVal then rebirthsVal.Changed:Connect(updateUI) end
	
	-- Первоначальный апдейт
	updateUI()
end

task.spawn(startHUDController)
