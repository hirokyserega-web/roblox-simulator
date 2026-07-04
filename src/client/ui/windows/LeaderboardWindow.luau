-- LeaderboardWindow (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local getLeaderboardData = Remotes.getFunction("GetLeaderboardData")

local rankColors = {
	[1] = Color3.fromRGB(241, 196, 15),
	[2] = Color3.fromRGB(189, 195, 199),
	[3] = Color3.fromRGB(211, 84, 0)
}

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

local function LeaderboardWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose

	local player = game:GetService("Players").LocalPlayer
	local topRanks, setTopRanks = React.useState(nil)
	local hasError, setHasError = React.useState(false)

	React.useEffect(function()
		if not visible then return end

		setTopRanks(nil)
		setHasError(false)

		task.spawn(function()
			local success, data = pcall(function()
				return getLeaderboardData:InvokeServer()
			end)

			if success and data then
				setTopRanks(data)
			else
				setHasError(true)
			end
		end)
	end, {visible})

	if not visible then return nil end

	local rows = {
		ListLayout = React.createElement("UIListLayout", {
			Padding = UDim.new(0, 12),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		})
	}

	if hasError then
		rows.Error = React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundTransparency = 1,
			Font = Theme.Fonts.Body,
			TextSize = 14,
			TextColor3 = Theme.Colors.Error,
			Text = "Не удалось загрузить таблицу рекордов.",
		})
	elseif not topRanks then
		rows.Loading = React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundTransparency = 1,
			Font = Theme.Fonts.Body,
			TextSize = 14,
			TextColor3 = Theme.Colors.TextSecondary,
			Text = "Загрузка...",
		})
	else
		for _, entry in ipairs(topRanks) do
			local rank = entry.Rank
			local rColor = rankColors[rank] or Theme.Colors.Text
			local isMe = entry.Name == player.Name
			
			local rowFrameColor = isMe and Color3.fromRGB(45, 35, 75) or Theme.Colors.BackgroundSecondary
			local strokeColor = isMe and Theme.Colors.Neon or Theme.Colors.Stroke

			local medalEmoji = ""
			if rank == 1 then medalEmoji = "🥇 "
			elseif rank == 2 then medalEmoji = "🥈 "
			elseif rank == 3 then medalEmoji = "🥉 "
			end

			rows["Row_" .. rank] = React.createElement("Frame", {
				Size = UDim2.new(1, -20, 0, 44),
				BackgroundTransparency = 1,
				LayoutOrder = rank,
			}, {
				RowShadow = React.createElement("Frame", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = Color3.fromRGB(15, 16, 25),
					BorderSizePixel = 0,
				}, {
					Corner = React.createElement("UICorner", {
						CornerRadius = Theme.Sizes.CornerRadius,
					})
				}),

				RowTop = React.createElement("Frame", {
					Size = UDim2.new(1, 0, 1, -4),
					Position = UDim2.new(0, 0, 0, -4),
					BackgroundColor3 = rowFrameColor,
					BorderSizePixel = 0,
				}, {
					Corner = React.createElement("UICorner", {
						CornerRadius = Theme.Sizes.CornerRadius,
					}),
					Stroke = React.createElement("UIStroke", {
						Thickness = Theme.Sizes.BorderWidth or 2,
						Color = strokeColor,
					}),

					RankLabel = React.createElement("TextLabel", {
						Size = UDim2.new(0, 45, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						BackgroundTransparency = 1,
						Font = Theme.Fonts.Title,
						TextSize = 16,
						TextColor3 = rColor,
						TextStrokeTransparency = 0.8,
						TextStrokeColor3 = Color3.new(0, 0, 0),
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = medalEmoji .. tostring(rank),
					}),

					NameLabel = React.createElement("TextLabel", {
						Size = UDim2.new(0.5, -30, 1, 0),
						Position = UDim2.new(0, 65, 0, 0),
						BackgroundTransparency = 1,
						Font = Theme.Fonts.Title,
						TextSize = 14,
						TextColor3 = isMe and Theme.Colors.Neon or Theme.Colors.Text,
						TextStrokeTransparency = 0.8,
						TextStrokeColor3 = Color3.new(0, 0, 0),
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = entry.Name,
					}),

					ScoreLabel = React.createElement("TextLabel", {
						Size = UDim2.new(0.35, 0, 1, 0),
						Position = UDim2.new(0.65, -12, 0, 0),
						BackgroundTransparency = 1,
						Font = Theme.Fonts.Title,
						TextSize = 15,
						TextColor3 = Theme.Colors.Success,
						TextStrokeTransparency = 0.8,
						TextStrokeColor3 = Color3.new(0, 0, 0),
						TextXAlignment = Enum.TextXAlignment.Right,
						Text = "$" .. formatNumber(entry.Score),
					})
				})
			})
		end
	end

	return React.createElement(Panel, {
		Title = "ГЛОБАЛЬНЫЙ ТОП-10",
		Size = UDim2.new(0, 420, 0, 400),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Visible = true,
		OnClose = onClose,
	}, {
		Scroll = React.createElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, -15),
			Position = UDim2.new(0, 0, 0, 10),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 6,
			CanvasSize = UDim2.new(0, 0, 0, (topRanks and #topRanks or 0) * 52),
		}, rows)
	})
end

return LeaderboardWindow
