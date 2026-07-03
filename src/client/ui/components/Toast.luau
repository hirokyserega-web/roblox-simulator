-- Candy Toast (Notification) System
local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Parent.theme.Theme)

local Toast = {}
local container = nil

function Toast.init(parent)
	container = parent
end

function Toast.show(text, notificationType)
	if not container then return end
	
	local color = Theme.Colors.Info
	if notificationType == "Success" then color = Theme.Colors.Success
	elseif notificationType == "Error" then color = Theme.Colors.Error
	elseif notificationType == "Warning" then color = Theme.Colors.Warning end
	
	local toast = Instance.new("Frame")
	toast.Name = "ToastNotification"
	toast.Size = UDim2.new(0, 300, 0, 50)
	toast.Position = UDim2.new(0.5, 0, 0, -60)
	toast.AnchorPoint = Vector2.new(0.5, 0)
	toast.BackgroundColor3 = Theme.Colors.Background
	toast.BorderSizePixel = 0
	toast.Parent = container

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
	label.TextSize = 18
	label.TextWrapped = true
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
end

-- Factory method for direct creation if needed
function Toast.create(options)
	Toast.show(options.Text or "Notification", options.Type or "Info")
	return nil -- Toast manages its own lifecycle
end

return Toast
