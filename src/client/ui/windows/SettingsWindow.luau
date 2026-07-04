-- Candy Settings Window (React version)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local function SettingsWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose

	local player = Players.LocalPlayer
	local isMusicOn, setMusicOn = React.useState(function()
		return player:GetAttribute("MusicEnabled") ~= false
	end)
	local isSfxOn, setSfxOn = React.useState(function()
		return player:GetAttribute("SfxEnabled") ~= false
	end)

	if not visible then return nil end

	local function toggleMusic()
		local nextVal = not isMusicOn
		setMusicOn(nextVal)
		player:SetAttribute("MusicEnabled", nextVal)
		Remotes.getEvent("ToggleSetting"):FireServer("MusicEnabled", nextVal)
	end

	local function toggleSfx()
		local nextVal = not isSfxOn
		setSfxOn(nextVal)
		player:SetAttribute("SfxEnabled", nextVal)
		Remotes.getEvent("ToggleSetting"):FireServer("SfxEnabled", nextVal)
	end

	return React.createElement(Panel, {
		Title = "SETTINGS",
		Size = UDim2.new(0, 440, 0, 320),
		OnClose = onClose,
	}, {
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 16),
		}),

		-- Music Row
		MusicRow = React.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 60),
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
			Icon = React.createElement("TextLabel", {
				Size = UDim2.new(0, 40, 1, 0),
				Position = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Text = "🎵",
				TextSize = 22,
				Font = Theme.Fonts.Main,
			}),
			Label = React.createElement("TextLabel", {
				Size = UDim2.new(0.5, 0, 1, 0),
				Position = UDim2.new(0, 52, 0, 0),
				BackgroundTransparency = 1,
				Text = "GAME MUSIC",
				Font = Theme.Fonts.Main,
				TextColor3 = Theme.Colors.Text,
				TextSize = 18,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
			ToggleButton = React.createElement(Button, {
				Text = isMusicOn and "ON" or "OFF",
				Color = isMusicOn and Theme.Colors.Success or Theme.Colors.Error,
				Size = UDim2.new(0, 90, 0, 40),
				Position = UDim2.new(1, -102, 0.5, -20),
				OnClick = toggleMusic,
			})
		}),

		-- SFX Row
		SfxRow = React.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 60),
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
			Icon = React.createElement("TextLabel", {
				Size = UDim2.new(0, 40, 1, 0),
				Position = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Text = "🔊",
				TextSize = 22,
				Font = Theme.Fonts.Main,
			}),
			Label = React.createElement("TextLabel", {
				Size = UDim2.new(0.5, 0, 1, 0),
				Position = UDim2.new(0, 52, 0, 0),
				BackgroundTransparency = 1,
				Text = "SOUND EFFECTS",
				Font = Theme.Fonts.Main,
				TextColor3 = Theme.Colors.Text,
				TextSize = 18,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
			ToggleButton = React.createElement(Button, {
				Text = isSfxOn and "ON" or "OFF",
				Color = isSfxOn and Theme.Colors.Success or Theme.Colors.Error,
				Size = UDim2.new(0, 90, 0, 40),
				Position = UDim2.new(1, -102, 0.5, -20),
				OnClick = toggleSfx,
			})
		}),

		-- Redeem Code Invitation Button
		PromoRow = React.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 50),
			BackgroundTransparency = 1,
		}, {
			CodeBtn = React.createElement(Button, {
				Text = "💬 ENTER PROMO CODE",
				Color = Color3.fromRGB(0, 176, 255),
				Size = UDim2.new(1, 0, 1, 0),
				OnClick = function()
					if _G.UIManager then _G.UIManager.openWindow("Codes") end
				end
			})
		})
	})
end

return SettingsWindow
