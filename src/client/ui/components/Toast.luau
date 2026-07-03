-- Candy Toast (Notification) Component
local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Parent.theme.Theme)

local ToastFactory = {}

function ToastFactory.create(options)
	local text = options.Text or "Notification"
	local color = options.Color or Theme.Colors.Blue
	local parent = options.Parent

	local toast = Instance.new("Frame")
	toast.Name = "Toast"
	toast.Size = UDim2.new(0, 240, 0, 44)
	toast.Position = UDim2.new(0.5, 0, 0, -60) -- Start off-screen
	toast.AnchorPoint = Vector2.new(0.5, 0)
	toast.BackgroundColor3 = Theme.Colors.Background
	toast.BorderSizePixel = 0
	toast.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Sizes.CornerButton
	corner.Parent = toast

	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = Theme.Sizes.StrokeThickness
	stroke.Parent = toast

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 1, 0)
	label.Position = UDim2.new(0.5, 0, 0, 0)
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Theme.Fonts.Main
	label.TextColor3 = Theme.Colors.Text
	label.TextScaled = true
	label.Parent = toast

	local ts = Instance.new("UIStroke")
	ts.Color = Theme.Colors.Stroke
	ts.Thickness = 1
	ts.Parent = label

	-- Animation
	local ti = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(toast, ti, {Position = UDim2.new(0.5, 0, 0, 20)}):Play()

	task.delay(3, function()
		local tOut = TweenService:Create(toast, ti, {Position = UDim2.new(0.5, 0, 0, -60)})
		tOut:Play()
		tOut.Completed:Connect(function()
			toast:Destroy()
		end)
	end)

	return toast
end

return ToastFactory
