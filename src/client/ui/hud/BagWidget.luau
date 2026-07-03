-- Виджет заполнения сумки (BagWidget)
local Theme = require(script.Parent.Parent.theme.Theme)
local ProgressBar = require(script.Parent.Parent.components.ProgressBar)

local BagWidget = {}

function BagWidget.create(options)
	local parent = options.Parent

	-- Корпус панели
	local container = Instance.new("Frame")
	container.Name = "BagWidget"
	container.Size = UDim2.new(0, 150, 0, 70)
	container.Position = options.Position or UDim2.new(1, -170, 0.4, -90)
	container.BackgroundColor3 = Theme.Colors.Background
	container.BackgroundTransparency = 0.2
	container.BorderSizePixel = 0
	container.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Sizes.CornerRadius
	corner.Parent = container

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = Theme.Sizes.BorderWidth
	stroke.Color = Theme.Colors.Stroke
	stroke.Parent = container

	-- Иконка рюкзака
	local bagIcon = Instance.new("TextLabel")
	bagIcon.Size = UDim2.new(0, 40, 0, 40)
	bagIcon.Position = UDim2.new(0, 8, 0, 8)
	bagIcon.BackgroundTransparency = 1
	bagIcon.Font = Theme.Fonts.Title
	bagIcon.TextSize = 22
	bagIcon.Text = "🎒"
	bagIcon.Parent = container

	-- Текст объема
	local countLabel = Instance.new("TextLabel")
	countLabel.Size = UDim2.new(1, -55, 0, 30)
	countLabel.Position = UDim2.new(0, 50, 0, 12)
	countLabel.BackgroundTransparency = 1
	countLabel.Font = Theme.Fonts.Bold
	countLabel.TextSize = 14
	countLabel.TextColor3 = Theme.Colors.Text
	countLabel.Text = "0 / 10"
	countLabel.Parent = container

	-- Прогресс-бар рюкзака
	local progress = ProgressBar.create({
		Size = UDim2.new(1, -16, 0, 10),
		Position = UDim2.new(0, 8, 1, -18),
		FillColor = Theme.Colors.Success,
		Parent = container
	})

	local api = {}
	api.Instance = container

	function api.Update(count: number, maxCapacity: number)
		countLabel.Text = string.format("%d / %d", count, maxCapacity)
		progress.SetProgress(count / maxCapacity)

		-- При полном рюкзаке меняем визуальное состояние
		if count >= maxCapacity then
			progress.SetColor(Theme.Colors.Warning)
			countLabel.TextColor3 = Theme.Colors.Warning
			bagIcon.Text = "🚨"
		else
			progress.SetColor(Theme.Colors.Success)
			countLabel.TextColor3 = Theme.Colors.Text
			bagIcon.Text = "🎒"
		end
	end

	function api.Destroy()
		progress.Destroy()
		container:Destroy()
	end

	return api
end

return BagWidget
