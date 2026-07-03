-- Candy Item Card Component
local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Parent.theme.Theme)

local CardFactory = {}

function CardFactory.create(options)
	local title = options.Title or "ITEM"
	local rarity = options.Rarity or "Common"
	local subtext = options.Subtext or ""
	local iconColor = options.IconColor or Theme.Colors.Text
	local equipped = options.Equipped or false
	local parent = options.Parent

	local container = Instance.new("TextButton")
	container.Name = "Card_" .. title
	container.Size = UDim2.new(0, 95, 0, 110)
	container.BackgroundColor3 = Theme.Colors.Panel
	container.AutoButtonColor = false
	container.Text = ""
	container.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Sizes.CornerRadius
	corner.Parent = container

	local stroke = Instance.new("UIStroke")
	stroke.Color = equipped and Theme.Colors.Success or Theme.Colors.Stroke
	stroke.Thickness = equipped and 3 or 2
	stroke.Parent = container

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 20)
	titleLabel.Position = UDim2.new(0, 0, 0, 5)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.Font = Theme.Fonts.Bold
	titleLabel.TextSize = 12
	titleLabel.TextColor3 = Theme.RarityColors[rarity] or Theme.Colors.Text
	titleLabel.Parent = container

	local icon = Instance.new("Frame")
	icon.Size = UDim2.new(0, 40, 0, 40)
	icon.Position = UDim2.new(0.5, 0, 0.45, 0)
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.BackgroundColor3 = iconColor
	icon.Parent = container
	Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, 0, 0, 15)
	sub.Position = UDim2.new(0, 0, 1, -20)
	sub.BackgroundTransparency = 1
	sub.Text = subtext
	sub.Font = Theme.Fonts.Main
	sub.TextSize = 10
	sub.TextColor3 = Theme.Colors.TextSecondary
	sub.Parent = container

	if equipped then
		local eqLabel = Instance.new("TextLabel")
		eqLabel.Size = UDim2.new(1, 0, 0, 15)
		eqLabel.Position = UDim2.new(0, 0, 0, 20)
		eqLabel.BackgroundTransparency = 1
		eqLabel.Text = "EQUIPPED"
		eqLabel.Font = Theme.Fonts.Bold
		eqLabel.TextSize = 9
		eqLabel.TextColor3 = Theme.Colors.Success
		eqLabel.Parent = container
	end

	container.MouseButton1Click:Connect(function()
		if options.OnClick then options.OnClick() end
	end)

	return container
end

return CardFactory
