-- Candy Detector Widget
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Theme = require(script.Parent.Parent.theme.Theme)

local DetectorWidget = {}

function DetectorWidget.create(options)
	local parent = options.Parent

	local container = Instance.new("Frame")
	container.Name = "DetectorWidget"
	container.Size = UDim2.new(0, 160, 0, 75)
	container.Position = options.Position or UDim2.new(0, 20, 0.4, -90)
	container.BackgroundColor3 = Theme.Colors.Panel
	container.BackgroundTransparency = 0.2
	container.BorderSizePixel = 0
	container.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Sizes.CornerPanel
	corner.Parent = container

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = Theme.Sizes.StrokeThickness
	stroke.Color = Theme.Colors.Stroke
	stroke.Parent = container

	-- Radar Icon
	local radarIcon = Instance.new("TextLabel")
	radarIcon.Size = UDim2.new(0, 40, 0, 40)
	radarIcon.Position = UDim2.new(0, 10, 0, 8)
	radarIcon.BackgroundTransparency = 1
	radarIcon.Font = Theme.Fonts.Title
	radarIcon.TextSize = 24
	radarIcon.Text = "📡"
	radarIcon.Parent = container

	-- Signal Bars Container
	local barsContainer = Instance.new("Frame")
	barsContainer.Size = UDim2.new(0, 80, 0, 24)
	barsContainer.Position = UDim2.new(0, 60, 0, 16)
	barsContainer.BackgroundTransparency = 1
	barsContainer.Parent = container

	local barLayout = Instance.new("UIListLayout")
	barLayout.FillDirection = Enum.FillDirection.Horizontal
	barLayout.Padding = UDim.new(0, 4)
	barLayout.SortOrder = Enum.SortOrder.LayoutOrder
	barLayout.Parent = barsContainer

	local signalBars = {}
	for i = 1, 5 do
		local bar = Instance.new("Frame")
		bar.Name = "Bar_" .. i
		bar.Size = UDim2.new(0, 12, 1, 0)
		bar.BackgroundColor3 = Theme.Colors.Background
		bar.BorderSizePixel = 0
		bar.LayoutOrder = i
		bar.Parent = barsContainer

		local barCorner = Instance.new("UICorner")
		barCorner.CornerRadius = UDim.new(0, 4)
		barCorner.Parent = bar
		
		table.insert(signalBars, bar)
	end

	-- Rarity / Status Label
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 22)
	label.Position = UDim2.new(0, 10, 1, -26)
	label.BackgroundTransparency = 1
	label.Font = Theme.Fonts.Main
	label.TextSize = 12
	label.TextColor3 = Theme.Colors.TextSecondary
	label.Text = "SIGNAL: NONE"
	label.Parent = container
	
	local ts = Instance.new("UIStroke")
	ts.Color = Theme.Colors.Stroke
	ts.Thickness = 0.8
	ts.Parent = label

	-- State management
	local currentProgress = 0
	local isTicking = true
	local lastTickTime = 0

	task.spawn(function()
		while isTicking do
			if currentProgress > 0.05 then
				local factor = currentProgress
				local rate = 0.15 + (1 - factor) * 0.8

				if tick() - lastTickTime >= rate then
					lastTickTime = tick()
					-- Sound trigger logic would go here
				end
			end
			task.wait(0.05)
		end
	end)

	local api = {}
	api.Instance = container

	function api.SetSignal(progress)
		currentProgress = math.clamp(progress, 0, 1)

		if currentProgress <= 0.05 then
			for _, bar in ipairs(signalBars) do
				bar.BackgroundColor3 = Theme.Colors.Background
			end
			label.Text = "SIGNAL: NONE"
			label.TextColor3 = Theme.Colors.TextSecondary
		else
			local litCount = math.ceil(currentProgress * 5)
			for i = 1, 5 do
				signalBars[i].BackgroundColor3 = (i <= litCount) and Theme.Colors.Blue or Theme.Colors.Background
			end
		end
	end

	function api.SetRarity(rarity)
		if currentProgress > 0.05 and rarity then
			label.Text = "SIGNAL: " .. rarity:upper()
			label.TextColor3 = Theme.RarityColors[rarity] or Theme.Colors.Text
		end
	end

	return api
end

return DetectorWidget
