-- RebirthWindow (React version)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
local RebirthConfig = require(ReplicatedStorage.Shared.config.RebirthConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local UIManager = {
	ShowToast = function(...)
		if _G.UIManager then
			_G.UIManager.ShowToast(...)
		end
	end,
	openWindow = function(...)
		if _G.UIManager then
			_G.UIManager.openWindow(...)
		end
	end,
}


local requestRebirthEvent = Remotes.getEvent("RequestRebirth")

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

local function RebirthWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose
	local money = props.Money or 0
	local rebirths = props.Rebirths or 0

	local confirmOpen, setConfirmOpen = React.useState(false)

	if not visible then return nil end

	local cost = RebirthConfig.getCost(rebirths)
	local multiplier = 1.0 + (rebirths * RebirthConfig.MultiplierPerRebirth)
	local canAfford = money >= cost

	return React.createElement("Frame", {
		Name = "RebirthWindowContainer",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = props.ZIndex or 15,
	}, {
		MainPanel = React.createElement(Panel, {
			Title = "ПЕРЕРОЖДЕНИЯ",
			Size = UDim2.new(0, 380, 0, 310),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Visible = true,
			OnClose = onClose,
		}, {
			Container = React.createElement("Frame", {
				Size = UDim2.new(1, -20, 1, -20),
				Position = UDim2.new(0, 10, 0, 10),
				BackgroundTransparency = 1,
			}, {
				ListLayout = React.createElement("UIListLayout", {
					Padding = UDim.new(0, 10),
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),

				Description = React.createElement("TextLabel", {
					Size = UDim2.new(1, -20, 0, 45),
					BackgroundTransparency = 1,
					Font = Theme.Fonts.Title,
					TextSize = 12,
					TextColor3 = Theme.Colors.TextSecondary,
					TextWrapped = true,
					Text = "Сбросьте монеты и улучшения, чтобы получить колоссальный постоянный множитель монет!",
				}),

				StatsBox = React.createElement("Frame", {
					Size = UDim2.new(1, -20, 0, 120),
					BackgroundColor3 = Theme.Colors.BackgroundSecondary,
					BorderSizePixel = 0,
				}, {
					Corner = React.createElement("UICorner", {
						CornerRadius = Theme.Sizes.CornerRadius,
					}),
					Stroke = React.createElement("UIStroke", {
						Thickness = Theme.Sizes.BorderWidth or 2,
						Color = Theme.Colors.Stroke,
					}),

					RebirthsLabel = React.createElement("TextLabel", {
						Size = UDim2.new(1, -30, 0, 30),
						Position = UDim2.new(0, 15, 0, 12),
						BackgroundTransparency = 1,
						Font = Theme.Fonts.Title,
						TextSize = 13,
						TextColor3 = Theme.Colors.Text,
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = string.format("🔄 ТЕКУЩИЕ ПЕРЕРОЖДЕНИЯ: %d", rebirths),
					}),

					MultiplierLabel = React.createElement("TextLabel", {
						Size = UDim2.new(1, -30, 0, 30),
						Position = UDim2.new(0, 15, 0, 44),
						BackgroundTransparency = 1,
						Font = Theme.Fonts.Title,
						TextSize = 13,
						TextColor3 = Theme.Colors.Success,
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = string.format("✨ МНОЖИТЕЛЬ МОНЕТ: x%.1f", multiplier),
					}),

					CostLabel = React.createElement("TextLabel", {
						Size = UDim2.new(1, -30, 0, 30),
						Position = UDim2.new(0, 15, 0, 76),
						BackgroundTransparency = 1,
						Font = Theme.Fonts.Title,
						TextSize = 13,
						TextColor3 = Theme.Colors.Warning,
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = string.format("💵 СТОИМОСТЬ: $%s", formatNumber(cost)),
					}),
				}),

				ActionButton = React.createElement(Button, {
					Text = "СОВЕРШИТЬ ПЕРЕРОЖДЕНИЕ",
					Color = canAfford and Theme.Colors.Success or Theme.Colors.Error,
					Size = UDim2.new(1, -40, 0, 48),
					OnClick = function()
						if canAfford then
							setConfirmOpen(true)
						else
							UIManager.ShowToast(string.format("Недостаточно монет! Требуется: $%s", formatNumber(cost)), "Error")
						end
					end
				})
			})
		}),

		ConfirmModal = confirmOpen and React.createElement("Frame", {
			Size = UDim2.new(0, 260, 0, 140),
			Position = UDim2.new(0.5, -130, 0.5, -70),
			BackgroundColor3 = Theme.Colors.Background,
			ZIndex = 300,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerRadius,
			}),
			Stroke = React.createElement("UIStroke", {
				Thickness = Theme.Sizes.BorderWidth or 2,
				Color = Theme.Colors.Warning,
			}),
			TextLabel = React.createElement("TextLabel", {
				Size = UDim2.new(1, -20, 0, 50),
				Position = UDim2.new(0, 10, 0, 15),
				BackgroundTransparency = 1,
				Font = Theme.Fonts.Title,
				TextSize = 13,
				TextColor3 = Theme.Colors.Text,
				TextWrapped = true,
				Text = "ВНИМАНИЕ! Это сбросит ваши монеты и уровни улучшений!",
			}),
			YesBtn = React.createElement(Button, {
				Text = "ДА",
				Color = Theme.Colors.Success,
				Size = UDim2.new(0, 90, 0, 36),
				Position = UDim2.new(0.1, 0, 0.6, 10),
				OnClick = function()
					requestRebirthEvent:FireServer()
					setConfirmOpen(false)
					if onClose then onClose() end
				end
			}),
			NoBtn = React.createElement(Button, {
				Text = "ОТМЕНА",
				Color = Theme.Colors.Error,
				Size = UDim2.new(0, 90, 0, 36),
				Position = UDim2.new(0.55, 0, 0.6, 10),
				OnClick = function()
					setConfirmOpen(false)
				end
			})
		}) or nil
	})
end

return RebirthWindow

