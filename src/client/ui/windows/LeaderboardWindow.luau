-- Candy Leaderboard Window (React version)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local function LeaderboardWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose

	local data, setData = React.useState({
		{ Rank = 1, Name = "HirosySerega", Score = 1000000 },
		{ Rank = 2, Name = "RoolMachine", Score = 500000 },
		{ Rank = 3, Name = "RobloxDev", Score = 250000 },
		{ Rank = 4, Name = "NoobHunter", Score = 75000 },
		{ Rank = 5, Name = "SpookyCatcher", Score = 35000 },
	})

	React.useEffect(function()
		-- Try to invoke remote server data
		task.spawn(function()
			pcall(function()
				local serverData = Remotes.getFunction("GetLeaderboardData"):InvokeServer()
				if serverData and #serverData > 0 then
					setData(serverData)
				end
			end)
		end)
	end, {visible})

	if not visible then return nil end

	local listChildren = {
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 8),
		})
	}

	for i, entry in ipairs(data) do
		local isTop3 = entry.Rank <= 3
		local rankIcon = "⭐"
		if entry.Rank == 1 then rankIcon = "🥇"
		elseif entry.Rank == 2 then rankIcon = "🥈"
		elseif entry.Rank == 3 then rankIcon = "🥉" end

		listChildren["Entry_" .. entry.Name] = React.createElement("Frame", {
			Size = UDim2.new(1, -16, 0, 50),
			BackgroundColor3 = isTop3 and Color3.fromHex("1B1D36") or Color3.fromHex("12142B"),
			BorderSizePixel = 0,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerButton,
			}),
			Stroke = React.createElement("UIStroke", {
				Color = isTop3 and Color3.fromHex("FFB300") or Theme.Colors.Stroke,
				Thickness = isTop3 and 2 or 1.5,
			}),

			-- Rank Label
			Rank = React.createElement("TextLabel", {
				Size = UDim2.new(0, 44, 1, 0),
				Position = UDim2.new(0, 10, 0, 0),
				BackgroundTransparency = 1,
				Text = string.format("%s #%d", rankIcon, entry.Rank),
				Font = Theme.Fonts.Main,
				TextColor3 = isTop3 and Color3.fromRGB(255, 215, 0) or Theme.Colors.Text,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),

			-- Player Name
			NameLabel = React.createElement("TextLabel", {
				Size = UDim2.new(0.4, 0, 1, 0),
				Position = UDim2.new(0, 80, 0, 0),
				BackgroundTransparency = 1,
				Text = entry.Name,
				Font = Theme.Fonts.Main,
				TextColor3 = Theme.Colors.Text,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),

			-- Score / Value
			ValueLabel = React.createElement("TextLabel", {
				Size = UDim2.new(0.35, 0, 1, 0),
				Position = UDim2.new(1, -15, 0, 0),
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Text = string.format("$ %s", tostring(entry.Score)),
				Font = Theme.Fonts.Main,
				TextColor3 = Color3.fromHex("00D250"),
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Right,
			})
		})
	end

	return React.createElement(Panel, {
		Title = "GLOBAL LEADERBOARD",
		Size = UDim2.new(0, 480, 0, 360),
		OnClose = onClose,
	}, {
		Scroll = React.createElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			CanvasSize = UDim2.new(0, 0, 0, 300),
			ScrollBarThickness = 6,
			ScrollBarImageColor3 = Theme.Colors.Stroke,
		}, listChildren)
	})
end

return LeaderboardWindow
