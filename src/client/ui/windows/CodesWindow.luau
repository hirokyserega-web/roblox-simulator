-- Candy Codes Window (React version)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local function CodesWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose

	local text, setText = React.useState("")
	local status, setStatus = React.useState("Enter a code to claim awesome rewards!")

	if not visible then return nil end

	local function submitCode()
		if text == "" then return end
		Remotes.getEvent("RedeemCode"):FireServer(text)
		setText("")
		setStatus("Redeeming...")
		
		-- Custom temporary status feedback
		task.delay(1.5, function()
			setStatus("Code already redeemed or invalid!")
		end)
	end

	return React.createElement(Panel, {
		Title = "PROMO CODES",
		Size = UDim2.new(0, 440, 0, 320),
		OnClose = onClose,
	}, {
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 16),
		}),

		StatusLabel = React.createElement("TextLabel", {
			Size = UDim2.new(1, -20, 0, 40),
			BackgroundTransparency = 1,
			Text = status,
			Font = Theme.Fonts.Main,
			TextColor3 = Theme.Colors.TextSecondary,
			TextSize = 16,
			TextWrapped = true,
		}, {
			Stroke = React.createElement("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 1.2,
			})
		}),

		-- TextBox Container Row
		TextBoxRow = React.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 52),
			BackgroundColor3 = Color3.fromHex("12142B"),
			BorderSizePixel = 0,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerButton,
			}),
			Stroke = React.createElement("UIStroke", {
				Color = Theme.Colors.Stroke,
				Thickness = 2.5,
			}),
			Input = React.createElement("TextBox", {
				Size = UDim2.new(1, -20, 1, 0),
				Position = UDim2.new(0, 10, 0, 0),
				BackgroundTransparency = 1,
				Text = text,
				PlaceholderText = "TYPE CODE HERE...",
				PlaceholderColor3 = Color3.fromRGB(100, 110, 150),
				TextColor3 = Theme.Colors.Text,
				Font = Theme.Fonts.Main,
				TextSize = 18,
				ClearTextOnFocus = false,
				
				[React.Change.Text] = function(rbx)
					setText(rbx.Text)
				end,
			})
		}),

		-- Submit Button Row
		SubmitRow = React.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 50),
			BackgroundTransparency = 1,
		}, {
			Button = React.createElement(Button, {
				Text = "CLAIM REWARD 🎁",
				Color = Theme.Colors.Success,
				Size = UDim2.new(1, 0, 1, 0),
				OnClick = submitCode,
			})
		})
	})
end

return CodesWindow
