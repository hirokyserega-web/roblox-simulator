-- CodesWindow (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
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


local redeemCodeEvent = Remotes.getEvent("RedeemCode")

local function CodesWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose

	local codeText, setCodeText = React.useState("")

	if not visible then return nil end

	return React.createElement(Panel, {
		Title = "АКТИВАЦИЯ КОДОВ",
		Size = UDim2.new(0, 380, 0, 240),
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
				Padding = UDim.new(0, 14),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			InfoLabel = React.createElement("TextLabel", {
				Size = UDim2.new(1, -20, 0, 36),
				BackgroundTransparency = 1,
				Font = Theme.Fonts.Title,
				TextSize = 13,
				TextColor3 = Theme.Colors.TextSecondary,
				TextWrapped = true,
				Text = "Введите секретный код группы или соцсетей, чтобы получить ценные бонусы!",
			}),

			TextBoxBg = React.createElement("Frame", {
				Name = "TextBoxBg",
				Size = UDim2.new(1, -20, 0, 44),
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

				Input = React.createElement("TextBox", {
					Size = UDim2.new(1, -20, 1, 0),
					Position = UDim2.new(0, 10, 0, 0),
					BackgroundTransparency = 1,
					Font = Theme.Fonts.Title,
					TextSize = 16,
					TextColor3 = Theme.Colors.Neon or Color3.fromRGB(0, 229, 255),
					PlaceholderColor3 = Color3.fromRGB(100, 100, 130),
					PlaceholderText = "ВВЕДИТЕ КОД...",
					Text = codeText,
					ClearTextOnFocus = true,

					[React.Change.Text] = function(rbx)
						setCodeText(rbx.Text)
					end
				})
			}),

			SubmitBtn = React.createElement(Button, {
				Text = "АКТИВИРОВАТЬ",
				Color = Theme.Colors.Success,
				Size = UDim2.new(1, -20, 0, 46),
				OnClick = function()
					if codeText ~= "" then
						redeemCodeEvent:FireServer(codeText)
						setCodeText("")
					else
						UIManager.ShowToast("Сначала введите код!", "Error")
					end
				end
			})
		})
	})
end

return CodesWindow

