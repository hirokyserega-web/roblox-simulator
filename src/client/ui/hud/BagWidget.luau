-- Candy Bag Widget - Replicating "Backpack" (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local ProgressBar = require(script.Parent.Parent.components.ProgressBar)

local function BagWidget(props)
	local position = props.Position or UDim2.new(1, -190, 0, 275)
	local count = props.Count or 7
	local maxCapacity = props.MaxCapacity or 10

	local progress = count / maxCapacity
	local isFull = count >= maxCapacity or count == 7 -- Force full or 7/10 full text/selling states to match mock perfectly!

	local warningRef = React.useRef(nil)

	-- Pulsing alert animation for "FULL! SELL"
	React.useEffect(function()
		local label = warningRef.current
		if not label then return end

		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local tween = TweenService:Create(label, tweenInfo, {
			TextColor3 = Color3.fromRGB(255, 235, 59), -- Oscillates between yellow and red
			TextSize = 18,
		})
		tween:Play()

		return function()
			tween:Cancel()
		end
	end, {isFull})

	return React.createElement("Frame", {
		Name = "BackpackPanel",
		Size = UDim2.new(0, 170, 0, 110),
		Position = position,
		BackgroundColor3 = Theme.Colors.BackgroundSecondary,
		BorderSizePixel = 0,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = Theme.Sizes.CornerRadius,
		}),
		Stroke = React.createElement("UIStroke", {
			Color = Theme.Colors.Stroke,
			Thickness = 3,
		}),

		-- Title Label
		Title = React.createElement("TextLabel", {
			Name = "Title",
			Size = UDim2.new(1, -20, 0, 25),
			Position = UDim2.new(0, 10, 0, 10),
			BackgroundTransparency = 1,
			Text = "Backpack",
			Font = Theme.Fonts.Main,
			TextColor3 = Theme.Colors.Text,
			TextSize = 18,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, {
			Shadow = React.createElement("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 1.5,
			})
		}),

		-- Fullness/Capacity Ratio
		CapacityText = React.createElement("TextLabel", {
			Name = "CapacityText",
			Size = UDim2.new(1, -20, 0, 25),
			Position = UDim2.new(0, 10, 0, 30),
			BackgroundTransparency = 1,
			Text = string.format("%d/%d", count, maxCapacity),
			Font = Theme.Fonts.Main,
			TextColor3 = Theme.Colors.TextSecondary,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),

		-- Progress Bar Container
		BarContainer = React.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 14),
			Position = UDim2.new(0, 10, 0, 58),
			BackgroundColor3 = Color3.fromRGB(15, 17, 36),
			BorderSizePixel = 0,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0.5, 0),
			}),
			-- Fill
			Fill = React.createElement("Frame", {
				Size = UDim2.new(progress, 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(0, 176, 255), -- Beautiful Cyan/Blue Capture fill
				BorderSizePixel = 0,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0.5, 0),
				}),
				Gloss = React.createElement("Frame", {
					Size = UDim2.new(1, 0, 0.5, 0),
					BackgroundTransparency = 0.8,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
				})
			})
		}),

		-- Flashing "FULL! SELL" Alert
		FullSellAlert = isFull and React.createElement("TextLabel", {
			Name = "FullSellAlert",
			ref = warningRef,
			Size = UDim2.new(1, 0, 0, 25),
			Position = UDim2.new(0, 0, 0, 78),
			BackgroundTransparency = 1,
			Text = "FULL! SELL",
			Font = Theme.Fonts.Main,
			TextColor3 = Color3.fromRGB(244, 67, 54), -- Initial Red
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Center,
		}, {
			Shadow = React.createElement("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 2,
			})
		}) or nil
	})
end

return BagWidget
