-- Окно Лидерборда (LeaderboardWindow) - Премиум-редизайн под референс
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local Panel = require(script.Parent.Parent.components.Panel)
local UIManager = _G.UIManager

local player = Players.LocalPlayer
local getLeaderboardData = Remotes.getFunction("GetLeaderboardData")

local LeaderboardWindow = {}
local lbPanel = nil
local scrollingFrame = nil

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

local rankColors = {
	[1] = Color3.fromRGB(241, 196, 15), -- Золото
	[2] = Color3.fromRGB(189, 195, 199), -- Серебро
	[3] = Color3.fromRGB(211, 84, 0) -- Бронза
}

local function refreshLeaderboard()
	if not scrollingFrame then return end

	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local success, topRanks = pcall(function()
		return getLeaderboardData:InvokeServer()
	end)

	if not success or not topRanks then
		local errorLabel = Instance.new("TextLabel")
		errorLabel.Size = UDim2.new(1, 0, 0, 40)
		errorLabel.BackgroundTransparency = 1
		errorLabel.Font = Theme.Fonts.Body
		errorLabel.TextSize = 14
		errorLabel.TextColor3 = Theme.Colors.Error
		errorLabel.Text = "Не удалось загрузить таблицу рекордов."
		errorLabel.Parent = scrollingFrame
		return
	end

	for _, entry in ipairs(topRanks) do
		-- Красивая 3D-строка ряда таблицы рекордов
		local rowContainer = Instance.new("Frame")
		rowContainer.Name = "RowContainer_" .. entry.Rank
		rowContainer.Size = UDim2.new(1, -20, 0, 44)
		rowContainer.BackgroundTransparency = 1
		rowContainer.Parent = scrollingFrame

		local rowShadow = Instance.new("Frame")
		rowShadow.Name = "RowShadow"
		rowShadow.Size = UDim2.new(1, 0, 1, 0)
		rowShadow.BackgroundColor3 = Color3.fromRGB(15, 16, 25)
		rowShadow.BorderSizePixel = 0
		rowShadow.Parent = rowContainer

		local shadowCorner = Instance.new("UICorner")
		shadowCorner.CornerRadius = Theme.Sizes.CornerRadius
		shadowCorner.Parent = rowShadow

		local row = Instance.new("Frame")
		row.Name = "RowTop"
		row.Size = UDim2.new(1, 0, 1, -4)
		row.Position = UDim2.new(0, 0, 0, -4)
		
		-- Расцветка фона (игрок выделяется сочным неоново-фиолетовым тоном)
		local rowFrameColor = Theme.Colors.BackgroundSecondary
		if entry.Name == player.Name then
			rowFrameColor = Color3.fromRGB(45, 35, 75)
		end

		row.BackgroundColor3 = rowFrameColor
		row.BorderSizePixel = 0
		row.Parent = rowContainer

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = Theme.Sizes.CornerRadius
		rowCorner.Parent = row

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = Theme.Sizes.BorderWidth
		stroke.Color = (entry.Name == player.Name) and Theme.Colors.Neon or Theme.Colors.Stroke
		stroke.Parent = row

		local rColor = rankColors[entry.Rank] or Theme.Colors.Text

		-- Ранг / Место (с медалью для Топ-3)
		local rankLabel = Instance.new("TextLabel")
		rankLabel.Size = UDim2.new(0, 45, 1, 0)
		rankLabel.Position = UDim2.new(0, 12, 0, 0)
		rankLabel.BackgroundTransparency = 1
		rankLabel.Font = Theme.Fonts.Title
		rankLabel.TextSize = 16
		rankLabel.TextColor3 = rColor
		rankLabel.TextStrokeTransparency = 0.8
		rankLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
		
		local medalEmoji = ""
		if entry.Rank == 1 then medalEmoji = "🥇 "
		elseif entry.Rank == 2 then medalEmoji = "🥈 "
		elseif entry.Rank == 3 then medalEmoji = "🥉 "
		end
		
		rankLabel.Text = medalEmoji .. tostring(entry.Rank)
		rankLabel.TextXAlignment = Enum.TextXAlignment.Left
		rankLabel.Parent = row

		-- Имя игрока
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.5, -30, 1, 0)
		nameLabel.Position = UDim2.new(0, 65, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Theme.Fonts.Title
		nameLabel.TextSize = 14
		nameLabel.TextColor3 = (entry.Name == player.Name) and Theme.Colors.Neon or Theme.Colors.Text
		nameLabel.TextStrokeTransparency = 0.8
		nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Text = entry.Name
		nameLabel.Parent = row

		-- Счёт / Сумма денег
		local scoreLabel = Instance.new("TextLabel")
		scoreLabel.Size = UDim2.new(0.35, 0, 1, 0)
		scoreLabel.Position = UDim2.new(0.65, -12, 0, 0)
		scoreLabel.BackgroundTransparency = 1
		scoreLabel.Font = Theme.Fonts.Title
		scoreLabel.TextSize = 15
		scoreLabel.TextColor3 = Theme.Colors.Success
		scoreLabel.TextStrokeTransparency = 0.8
		scoreLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
		scoreLabel.TextXAlignment = Enum.TextXAlignment.Right
		scoreLabel.Text = "$" .. formatNumber(entry.Score)
		scoreLabel.Parent = row
	end

	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #topRanks * 52)
end

function LeaderboardWindow.init()
	local screenGui = UIManager.getScreenGui()

	lbPanel = Panel.create({
		Title = "ГЛОБАЛЬНЫЙ ТОП-10",
		Size = UDim2.new(0, 420, 0, 400),
		Position = UDim2.new(0.5, -210, 0.5, -200),
		Parent = screenGui,
		OnClose = function()
			lbPanel.Close()
		end
	})

	UIManager.registerWindow("Leaderboard", lbPanel)

	scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Size = UDim2.new(1, 0, 1, -15)
	scrollingFrame.Position = UDim2.new(0, 0, 0, 10)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.ScrollBarThickness = 6
	scrollingFrame.Parent = lbPanel.Content

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 12)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Parent = scrollingFrame

	local originalOpen = lbPanel.Open
	lbPanel.Open = function()
		originalOpen()
		refreshLeaderboard()
	end
end

LeaderboardWindow.init()

return LeaderboardWindow
