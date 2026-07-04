-- Candy Capture Bar Overlay (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local ProgressBar = require(script.Parent.Parent.components.ProgressBar)

local function CaptureBar(props)
	local visible = props.Visible
	local ghostName = props.GhostName or "GHOST"
	local rarity = props.GhostRarity or "Common"
	local progress = props.Progress or 0
	local shakeTrigger = props.ShakeTrigger or 0

	local containerRef = React.useRef(nil)
	local canvasGroupRef = React.useRef(nil)
	
	local isActuallyVisible, setActuallyVisible = React.useState(visible)

	React.useEffect(function()
		local canvasGroup = canvasGroupRef.current
		if not canvasGroup then return end

		if visible then
			setActuallyVisible(true)
			canvasGroup.GroupTransparency = 1
			TweenService:Create(canvasGroup, TweenInfo.new(0.3), {GroupTransparency = 0}):Play()
		else
			local tween = TweenService:Create(canvasGroup, TweenInfo.new(0.2), {GroupTransparency = 1})
			tween:Play()
			local conn
			conn = tween.Completed:Connect(function()
				setActuallyVisible(false)
				conn:Disconnect()
			end)
		end
	end, {visible})

	React.useEffect(function()
		local container = containerRef.current
		if shakeTrigger > 0 and container then
			task.spawn(function()
				local origPos = container.Position
				for i = 1, 4 do
					container.Position = origPos + UDim2.new(0, math.random(-5, 5), 0, math.random(-5, 5))
					task.wait(0.05)
				end
				container.Position = origPos
			end)
		end
	end, {shakeTrigger})

	if not isActuallyVisible then return nil end

	return React.createElement("CanvasGroup", {
		Name = "CaptureOverlay",
		ref = canvasGroupRef,
		Size = UDim2.new(0, 350, 0, 100),
		Position = UDim2.new(0.5, 0, 0.2, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
	}, {
		Container = React.createElement("Frame", {
			Name = "Container",
			ref = containerRef,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
		}, {
			Main = React.createElement("Frame", {
				Name = "Main",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = Theme.Colors.Panel,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = Theme.Sizes.CornerRadius,
				}),
				Stroke = React.createElement("UIStroke", {
					Color = Theme.Colors.Stroke,
					Thickness = 3,
				}),
				GhostNameLabel = React.createElement("TextLabel", {
					Name = "GhostName",
					Size = UDim2.new(1, 0, 0, 40),
					BackgroundTransparency = 1,
					Text = string.upper(ghostName),
					Font = Theme.Fonts.Title,
					TextColor3 = Theme.RarityColors[rarity] or Theme.Colors.Text,
					TextSize = 24,
				}),
				Bar = React.createElement(ProgressBar, {
					Size = UDim2.new(1, -40, 0, 30),
					Position = UDim2.new(0.5, 0, 1, -35),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Progress = progress,
					Color = Theme.Colors.Info,
				})
			})
		})
	})
end

return CaptureBar

