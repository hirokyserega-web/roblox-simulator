-- Candy Panel Component
local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Parent.theme.Theme)
local CurrencyChip = require(script.Parent.Parent.components.CurrencyChip)

local PanelFactory = {}

function PanelFactory.create(options)
	local size = options.Size or UDim2.new(0, 400, 0, 300)
	local position = options.Position or UDim2.new(0.5, 0, 0.5, 0)
	local anchorPoint = options.AnchorPoint or Vector2.new(0.5, 0.5)
	local title = options.Title or ""
	local parent = options.Parent
	local onClose = options.OnClose

	local panel = Instance.new("Frame")
	panel.Name = "CandyPanel_" .. tostring(title)
	panel.Size = size
	panel.Position = position
	panel.AnchorPoint = anchorPoint
	panel.BackgroundColor3 = Theme.Colors.Panel
	panel.BackgroundTransparency = 1 - (Theme.Colors.PanelOpacity or 0.9)
	panel.BorderSizePixel = 0
	panel.Parent = parent

	Instance.new("UICorner", panel).CornerRadius = Theme.Sizes.CornerPanel
	local stroke = Instance.new("UIStroke", panel)
	stroke.Color = Theme.Colors.Stroke
	stroke.Thickness = 3

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundTransparency = 1
	header.Parent = panel

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 1, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title:upper()
	titleLabel.Font = Theme.Fonts.Title
	titleLabel.TextSize = 28
	titleLabel.TextColor3 = Theme.Colors.Text
	titleLabel.Parent = header
	
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 32, 0, 32)
	closeBtn.Position = UDim2.new(1, -15, 0, 15)
	closeBtn.AnchorPoint = Vector2.new(1, 0)
	closeBtn.BackgroundColor3 = Theme.Colors.Red
	closeBtn.Text = "X"
	closeBtn.Font = Theme.Fonts.Bold
	closeBtn.TextColor3 = Theme.Colors.Text
	closeBtn.Parent = header
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
	
	closeBtn.MouseButton1Click:Connect(function()
		if onClose then onClose() else panel.Visible = false end
	end)

	local balanceChip = nil
	if options.ShowBalance then
		balanceChip = CurrencyChip.create({
			CurrencyType = "Money",
			Position = UDim2.new(0.5, -75, 0, 60),
			Parent = panel
		})
	end

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -20, 1, -80)
	content.Position = UDim2.new(0.5, 0, 0, 70)
	content.AnchorPoint = Vector2.new(0.5, 0)
	content.BackgroundTransparency = 1
	content.Parent = panel

	local api = {}
	api.Instance = panel
	api.Content = content
	
	function api.SetBalance(val)
		if balanceChip then balanceChip.SetValue(val) end
	end
	
	function api.Open()
		panel.Visible = true
	end
	
	function api.Close()
		panel.Visible = false
	end

	function api.Destroy()
		panel:Destroy()
	end

	return api
end

return PanelFactory
