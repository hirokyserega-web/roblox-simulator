-- Окно ввода Промо-кодов (CodesWindow)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local Panel = require(script.Parent.Parent.components.Panel)
local UIManager = require(script.Parent.Parent.UIManager)

local player = Players.LocalPlayer
local redeemCodeEvent = Remotes.getEvent("RedeemCode")

local CodesWindow = {}
local codesPanel = nil

function CodesWindow.init()
	local screenGui = UIManager.getScreenGui()

	codesPanel = Panel.create({
		Title = "ПРОМОКОДЫ",
		Size = UDim2.new(0, 340, 0, 220),
		Position = UDim2.new(0.5, -170, 0.5, -110),
		Parent = screenGui,
		OnClose = function()
			codesPanel.Close()
		end
	})

	UIManager.registerWindow("Codes", codesPanel)

	local promoDesc = Instance.new("TextLabel")
	promoDesc.Size = UDim2.new(1, -40, 0, 40)
	promoDesc.Position = UDim2.new(0, 20, 0, 15)
	promoDesc.BackgroundTransparency = 1
	promoDesc.Font = Theme.Fonts.Body
	promoDesc.TextSize = 13
	promoDesc.TextColor3 = Theme.Colors.TextSecondary
	promoDesc.TextWrapped = true
	promoDesc.Text = "Введите действующий промокод, чтобы получить награду:"
	promoDesc.Parent = codesPanel.Content

	local codeBox = Instance.new("TextBox")
	codeBox.Name = "CodeTextBox"
	codeBox.Size = UDim2.new(0, 260, 0, 40)
	codeBox.Position = UDim2.new(0.5, -130, 0.35, 10)
	codeBox.BackgroundColor3 = Theme.Colors.BackgroundSecondary
	codeBox.BorderSizePixel = 0
	codeBox.Font = Theme.Fonts.Title
	codeBox.TextSize = 16
	codeBox.TextColor3 = Theme.Colors.Text
	codeBox.PlaceholderColor3 = Theme.Colors.TextSecondary
	codeBox.PlaceholderText = "ВВЕДИТЕ КОД..."
	codeBox.Text = ""
	codeBox.ClearTextOnFocus = false
	codeBox.Parent = codesPanel.Content

	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = Theme.Sizes.CornerRadius
	boxCorner.Parent = codeBox

	local boxStroke = Instance.new("UIStroke")
	boxStroke.Thickness = Theme.Sizes.BorderWidth - 1
	boxStroke.Color = Theme.Colors.Stroke
	boxStroke.Parent = codeBox

	local redeemButton = Button.create({
		Text = "АКТИВИРОВАТЬ",
		Color = Theme.Colors.Accent,
		Size = UDim2.new(0, 160, 0, 40),
		Position = UDim2.new(0.5, -80, 0.65, 15),
		Parent = codesPanel.Content,
		OnClick = function()
			local text = codeBox.Text
			if text ~= "" then
				redeemCodeEvent:FireServer(text)
				codeBox.Text = ""
				codesPanel.Close()
			else
				UIManager.ShowToast("Введите код перед отправкой!", "Warning")
			end
		end
	})
end

CodesWindow.init()

return CodesWindow
