-- Candy Panel Component
local Theme = require(script.Parent.Parent.theme.Theme)

local PanelFactory = {}

function PanelFactory.create(options)
	local size = options.Size or UDim2.new(0, 400, 0, 300)
	local position = options.Position or UDim2.new(0.5, 0, 0.5, 0)
	local anchorPoint = options.AnchorPoint or Vector2.new(0.5, 0.5)
	local title = options.Title or ""
	local parent = options.Parent

	-- Background Container
	local panel = Instance.new("Frame")
	panel.Name = "CandyPanel_" .. title
	panel.Size = size
	panel.Position = position
	panel.AnchorPoint = anchorPoint
	panel.BackgroundColor3 = Theme.Colors.Panel
	panel.BackgroundTransparency = 1 - Theme.Colors.PanelOpacity
	panel.BorderSizePixel = 0
	panel.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Sizes.CornerPanel
	corner.Parent = panel

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Colors.Stroke
	stroke.Thickness = Theme.Sizes.StrokeThickness + 1
	stroke.Parent = panel

	-- Header / Title Area
	if title ~= "" then
		local header = Instance.new("Frame")
		header.Name = "Header"
		header.Size = UDim2.new(1, 0, 0, 50)
		header.BackgroundTransparency = 1
		header.Parent = panel

		local titleLabel = Instance.new("TextLabel")
		titleLabel.Name = "Title"
		titleLabel.Size = UDim2.new(1, 0, 1, 0)
		titleLabel.Position = UDim2.new(0, 0, 0, 4)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = title:upper()
		titleLabel.Font = Theme.Fonts.Main
		titleLabel.TextScaled = true
		titleLabel.TextColor3 = Theme.Colors.Text
		titleLabel.Parent = header
		
		local ts = Instance.new("UIStroke")
		ts.Color = Theme.Colors.Stroke
		ts.Thickness = 2
		ts.Parent = titleLabel

		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 8)
		pad.PaddingBottom = UDim.new(0, 8)
		pad.Parent = titleLabel
	end

	-- Content Area
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -20, 1, (title ~= "" and -70 or -20))
	content.Position = UDim2.new(0.5, 0, (title ~= "" and 0 or 0.5), (title ~= "" and 60 or 0))
	content.AnchorPoint = Vector2.new(0.5, (title ~= "" and 0 or 0.5))
	content.BackgroundTransparency = 1
	content.Parent = panel

	local api = {}
	api.Instance = panel
	api.Content = content

	function api.Destroy()
		panel:Destroy()
	end

	return api
end

return PanelFactory
