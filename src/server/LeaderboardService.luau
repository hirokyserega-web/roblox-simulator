-- Сервис глобального лидерборда по валюте на сервере
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)

local LeaderboardService = {}
local leaderboardDataStore = nil
local boardPart = nil
local listContainer = nil

-- Кэш имен игроков по их UserId для оптимизации сетевых запросов
local usernameCache = {}

-- Получить имя игрока по UserId из кэша или через API Roblox
local function getPlayerName(userId: number): string
	if usernameCache[userId] then
		return usernameCache[userId]
	end

	local name = "Player_" .. userId
	local success, err = pcall(function()
		name = Players:GetNameFromUserIdAsync(userId)
	end)

	if success then
		usernameCache[userId] = name
	else
		warn("[LEADERBOARD] Не удалось получить имя для UserId: " .. userId .. ", ошибка: " .. tostring(err))
	end

	return name
end

-- Вспомогательная функция форматирования чисел
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

-- Создание физического табло SurfaceGui в Workspace
local function createLeaderboardBoard()
	boardPart = Workspace:FindFirstChild("LeaderboardBoard")
	if not boardPart then
		boardPart = Instance.new("Part")
		boardPart.Name = "LeaderboardBoard"
		boardPart.Position = GameConfig.LeaderboardPosition
		boardPart.Size = GameConfig.LeaderboardSize
		boardPart.Anchored = true
		boardPart.Color = Color3.fromRGB(25, 25, 30)
		boardPart.Material = Enum.Material.SmoothPlastic
		boardPart.Parent = Workspace
		
		-- Добавим аккуратную рамку
		local selectionBox = Instance.new("SelectionBox")
		selectionBox.Adornee = boardPart
		selectionBox.Color3 = Color3.fromRGB(241, 196, 15) -- Золотая рамка
		selectionBox.LineThickness = 0.05
		selectionBox.Parent = boardPart
	end

	local surfaceGui = boardPart:FindFirstChild("LeaderboardGui")
	if not surfaceGui then
		surfaceGui = Instance.new("SurfaceGui")
		surfaceGui.Name = "LeaderboardGui"
		surfaceGui.Face = Enum.NormalId.Front
		surfaceGui.CanvasSize = Vector2.new(800, 600)
		surfaceGui.AlwaysOnTop = true
		surfaceGui.Parent = boardPart

		local mainFrame = Instance.new("Frame")
		mainFrame.Size = UDim2.new(1, 0, 1, 0)
		mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
		mainFrame.BorderSizePixel = 0
		mainFrame.Parent = surfaceGui

		-- Красивый градиент заднего фона
		local gradient = Instance.new("UIGradient")
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
		})
		gradient.Parent = mainFrame

		-- Шапка табло
		local title = Instance.new("TextLabel")
		title.Name = "Title"
		title.Size = UDim2.new(1, 0, 0, 80)
		title.Position = UDim2.new(0, 0, 0, 15)
		title.BackgroundTransparency = 1
		title.Font = Enum.Font.FredokaOne
		title.TextSize = 36
		title.TextColor3 = Color3.fromRGB(241, 196, 15) -- Золотой
		title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		title.TextStrokeTransparency = 0
		title.Text = "ГЛОБАЛЬНЫЙ ЛИДЕРБОРД (МОНЕТЫ)"
		title.Parent = mainFrame

		-- Контейнер для списка
		listContainer = Instance.new("Frame")
		listContainer.Name = "ListContainer"
		listContainer.Size = UDim2.new(1, -60, 1, -140)
		listContainer.Position = UDim2.new(0, 30, 0, 110)
		listContainer.BackgroundTransparency = 1
		listContainer.Parent = mainFrame

		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 8)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = listContainer

		-- Предварительно создаем 10 строк
		for i = 1, 10 do
			local rowFrame = Instance.new("Frame")
			rowFrame.Name = "Row_" .. i
			rowFrame.Size = UDim2.new(1, 0, 0, 38)
			rowFrame.BackgroundTransparency = 0.95
			rowFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			rowFrame.BorderSizePixel = 0
			rowFrame.LayoutOrder = i
			rowFrame.Parent = listContainer

			local rowCorner = Instance.new("UICorner")
			rowCorner.CornerRadius = UDim.new(0, 6)
			rowCorner.Parent = rowFrame

			-- Номер ранга
			local rankLabel = Instance.new("TextLabel")
			rankLabel.Name = "Rank"
			rankLabel.Size = UDim2.new(0.08, 0, 1, 0)
			rankLabel.Position = UDim2.new(0, 10, 0, 0)
			rankLabel.BackgroundTransparency = 1
			rankLabel.Font = Enum.Font.FredokaOne
			rankLabel.TextSize = 20
			rankLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			rankLabel.TextXAlignment = Enum.TextXAlignment.Left
			rankLabel.Text = tostring(i) .. "."
			rankLabel.Parent = rowFrame

			-- Имя игрока
			local nameLabel = Instance.new("TextLabel")
			nameLabel.Name = "Username"
			nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
			nameLabel.Position = UDim2.new(0.08, 10, 0, 0)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Font = Enum.Font.FredokaOne
			nameLabel.TextSize = 20
			nameLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.Text = "---"
			nameLabel.Parent = rowFrame

			-- Значение валюты
			local valueLabel = Instance.new("TextLabel")
			valueLabel.Name = "Value"
			valueLabel.Size = UDim2.new(0.3, 0, 1, 0)
			valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
			valueLabel.BackgroundTransparency = 1
			valueLabel.Font = Enum.Font.FredokaOne
			valueLabel.TextSize = 20
			valueLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
			valueLabel.TextXAlignment = Enum.TextXAlignment.Right
			valueLabel.Text = "$0"
			valueLabel.Parent = rowFrame

			-- Выделяем первые три ранга цветом
			if i == 1 then
				rankLabel.TextColor3 = Color3.fromRGB(241, 196, 15) -- Золото
				nameLabel.TextColor3 = Color3.fromRGB(241, 196, 15)
				rowFrame.BackgroundTransparency = 0.9
				rowFrame.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
			elseif i == 2 then
				rankLabel.TextColor3 = Color3.fromRGB(189, 195, 199) -- Серебро
				nameLabel.TextColor3 = Color3.fromRGB(189, 195, 199)
				rowFrame.BackgroundTransparency = 0.92
				rowFrame.BackgroundColor3 = Color3.fromRGB(189, 195, 199)
			elseif i == 3 then
				rankLabel.TextColor3 = Color3.fromRGB(211, 84, 0) -- Бронза
				nameLabel.TextColor3 = Color3.fromRGB(211, 84, 0)
				rowFrame.BackgroundTransparency = 0.94
				rowFrame.BackgroundColor3 = Color3.fromRGB(211, 84, 0)
			end
		end
	end
end

-- Обновление лидерборда
function LeaderboardService.updateLeaderboard()
	if not leaderboardDataStore then return end

	-- 1. Сначала асинхронно записываем баланс всех онлайн игроков
	for _, player in ipairs(Players:GetPlayers()) do
		local money = player:GetAttribute("Money")
		if money then
			pcall(function()
				leaderboardDataStore:SetAsync(tostring(player.UserId), money)
			end)
		end
	end

	-- 2. Запрашиваем топ-10 записей (по убыванию)
	local success, pages = pcall(function()
		return leaderboardDataStore:GetSortedAsync(false, 10)
	end)

	if not success or not pages then
		warn("[LEADERBOARD] Не удалось загрузить отсортированные данные из OrderedDataStore.")
		return
	end

	local topData = pages:GetCurrentPage()

	-- 3. Рендерим полученные записи в SurfaceGui
	for i = 1, 10 do
		local rowFrame = listContainer:FindFirstChild("Row_" .. i)
		if not rowFrame then continue end

		local dataEntry = topData[i]
		if dataEntry then
			local userId = tonumber(dataEntry.key)
			local score = dataEntry.value
			local username = getPlayerName(userId)

			rowFrame.Username.Text = username
			rowFrame.Value.Text = "$" .. formatNumber(score)
			rowFrame.Visible = true
		else
			-- Скрываем или обнуляем лишние строки, если записей в БД меньше 10
			rowFrame.Username.Text = "---"
			rowFrame.Value.Text = "$0"
		end
	end

	print("[LEADERBOARD] Глобальный топ успешно обновлен!")
end

-- Инициализация сервиса
function LeaderboardService.init()
	local success, err = pcall(function()
		leaderboardDataStore = DataStoreService:GetOrderedDataStore("GlobalMoneyLeaderboard_v1")
	end)

	if not success then
		warn("[LEADERBOARD] OrderedDataStore не инициализирован. Доступ к API заблокирован? Ошибка: " .. tostring(err))
		return
	end

	-- Создаем физическое табло
	createLeaderboardBoard()

	-- Запускаем цикл периодического обновления (раз в 60 секунд)
	task.spawn(function()
		task.wait(5) -- Даем игре загрузиться перед первым вызовом
		while true do
			local ok, reason = pcall(LeaderboardService.updateLeaderboard)
			if not ok then
				warn("[LEADERBOARD] Исключение в цикле обновления: " .. tostring(reason))
			end
			task.wait(60)
		end
	end)

	print("[LEADERBOARD SERVICE] Сервис глобальной таблицы рекордов успешно запущен!")
end

return LeaderboardService
