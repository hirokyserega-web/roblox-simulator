-- Окно Лидерборда (LeaderboardWindow)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local Panel = require(script.Parent.Parent.components.Panel)
local UIManager = require(script.Parent.Parent.UIManager)

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
	[1] = Color3.fromRGB(241, 196, 15),
	[2] = Color3.fromRGB(189, 195, 199),
	[3] = Color3.fromRGB(211, 84, 0)
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
		local row = Instance.new("Frame")
		row.Name = "Row_" .. entry.Rank
		row.Size = UDim2.new(1, -10, 0, 36)
		local rowFrameColor = Theme.Colors.BackgroundSecondary
		
		if entry.Name == player.Name then
			rowFrameColor = Color3.fromRGB(40, 35, 55)
		end

		row.BackgroundColor3 = rowFrameColor
		row.BorderSizePixel = 0
		row.Parent = scrollingFrame

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = Theme.Sizes.CornerRadius
		rowCorner.Parent = row

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1
		stroke.Color = Theme.Colors.Stroke
		stroke.Parent = row

		local rColor = rankColors[entry.Rank] or Theme.Colors.Text

		local rankLabel = Instance.new("TextLabel")
		rankLabel.Size = UDim2.new(0, 30, 1, 0)
		rankLabel.Position = UDim2.new(0, 10, 0, 0)
		rankLabel.BackgroundTransparency = 1
		rankLabel.Font = Theme.Fonts.Title
		rankLabel.TextSize = 15
		rankLabel.TextColor3 = rColor
		rankLabel.Text = tostring(entry.Rank) .. "."
		rankLabel.Parent = row

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.6, -40, 1, 0)
		nameLabel.Position = UDim2.new(0, 45, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Theme.Fonts.Title
		nameLabel.TextSize = 14
		nameLabel.TextColor3 = (entry.Name == player.Name) and Theme.Colors.Neon or Theme.Colors.Text
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Text = entry.Name
		nameLabel.Parent = row

		local scoreLabel = Instance.new("TextLabel")
		scoreLabel.Size = UDim2.new(0.3, 0, 1, 0)
		scoreLabel.Position = UDim2.new(0.7, 0, 0, 0)
		scoreLabel.BackgroundTransparency = 1
		scoreLabel.Font = Theme.Fonts.Title
		scoreLabel.TextSize = 14
		scoreLabel.TextColor3 = Theme.Colors.Success
		scoreLabel.TextXAlignment = Enum.TextXAlignment.Right
		scoreLabel.Text = "$" .. formatNumber(entry.Score)
		scoreLabel.Parent = row
	end

	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #topRanks * 44)
end

function LeaderboardWindow.init()
	local screenGui = UIManager.getScreenGui()

	lbPanel = Panel.create({
		Title = "ГЛОБАЛЬНЫЙ ТОП-10",
		Size = UDim2.new(0, 360, 0, 350),
		Position = UDim2.new(0.5, -180, 0.5, -175),
		Parent = screenGui,
		OnClose = function()
			lbPanel.Close()
		end
	})

	UIManager.registerWindow("Leaderboard", lbPanel)

	scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Size = UDim2.new(1, 0, 1, -10)
	scrollingFrame.Position = UDim2.new(0, 0, 0, 5)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.ScrollBarThickness = 6
	scrollingFrame.Parent = lbPanel.Content

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 8)
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
