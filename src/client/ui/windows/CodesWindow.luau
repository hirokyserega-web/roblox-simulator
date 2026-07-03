-- Окно ввода Промо-кодов (CodesWindow) - Премиум-редизайн под референс
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local Panel = require(script.Parent.Parent.components.Panel)
local UIManager = _G.UIManager

local player = Players.LocalPlayer
local redeemCodeEvent = Remotes.getEvent("RedeemCode")

local CodesWindow = {}
local codesPanel = nil
local textBox = nil
local submitBtnComp = nil

function CodesWindow.init()
	local screenGui = UIManager.getScreenGui()

	codesPanel = Panel.create({
		Title = "АКТИВАЦИЯ КОДОВ",
		Size = UDim2.new(0, 380, 0, 240),
		Position = UDim2.new(0.5, -190, 0.5, -120),
		Parent = screenGui,
		OnClose = function()
			codesPanel.Close()
		end
	})

	UIManager.registerWindow("Codes", codesPanel)

	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -20, 1, -20)
	container.Position = UDim2.new(0, 10, 0, 10)
	container.BackgroundTransparency = 1
	container.Parent = codesPanel.Content

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 14)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.Parent = container

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(1, -20, 0, 36)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Font = Theme.Fonts.Title
	infoLabel.TextSize = 13
	infoLabel.TextColor3 = Theme.Colors.TextSecondary
	infoLabel.TextWrapped = true
	infoLabel.Text = "Введите секретный код группы или соцсетей, чтобы получить ценные бонусы!"
	infoLabel.Parent = container

	-- Красивое поле ввода кода
	local textBoxBg = Instance.new("Frame")
	textBoxBg.Name = "TextBoxBg"
	textBoxBg.Size = UDim2.new(1, -20, 0, 44)
	textBoxBg.BackgroundColor3 = Theme.Colors.BackgroundSecondary
	textBoxBg.BorderSizePixel = 0
	textBoxBg.Parent = container

	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = Theme.Sizes.CornerRadius
	bgCorner.Parent = textBoxBg

	local bgStroke = Instance.new("UIStroke")
	bgStroke.Thickness = Theme.Sizes.BorderWidth
	bgStroke.Color = Theme.Colors.Stroke
	bgStroke.Parent = textBoxBg

	textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(1, -20, 1, 0)
	textBox.Position = UDim2.new(0, 10, 0, 0)
	textBox.BackgroundTransparency = 1
	textBox.Font = Theme.Fonts.Title
	textBox.TextSize = 16
	textBox.TextColor3 = Theme.Colors.Neon
	textBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 130)
	textBox.PlaceholderText = "ВВЕДИТЕ КОД..."
	textBox.Text = ""
	textBox.ClearTextOnFocus = true
	textBox.Parent = textBoxBg

	submitBtnComp = Button.create({
		Text = "АКТИВИРОВАТЬ",
		Color = Theme.Colors.Success,
		Size = UDim2.new(1, -20, 0, 46),
		Parent = container,
		OnClick = function()
			local code = textBox.Text
			if code ~= "" then
				redeemCodeEvent:FireServer(code)
				textBox.Text = ""
			else
				UIManager.ShowToast("Сначала введите код!", "Error")
			end
		end
	})
end

CodesWindow.init()

return CodesWindow
