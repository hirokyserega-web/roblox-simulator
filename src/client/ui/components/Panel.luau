-- Candy Panel Component with Juicy Elastic Pop Anim (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local CurrencyChip = require(script.Parent.Parent.components.CurrencyChip)

local function Panel(props)
	local size = props.Size or UDim2.new(0, 480, 0, 360)
	local position = props.Position or UDim2.new(0.5, 0, 0.5, 0)
	local anchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5)
	local title = props.Title or ""
	local showBalance = props.ShowBalance or false
	local balanceValue = props.BalanceValue or 0
	local visible = props.Visible ~= false

	local scaleValRef = React.useRef(nil)

	-- Handle spring pop-in animation on mount / visibility change
	React.useEffect(function()
		if not visible then return end
		local scaleObj = scaleValRef.current
		if not scaleObj then return end

		-- Start very small to animate popping open
		scaleObj.Scale = 0.3
		
		local tweenInfo = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local tween = TweenService:Create(scaleObj, tweenInfo, { Scale = 1.0 })
		tween:Play()
	end, {visible})

	if not visible then return nil end

	-- Beautiful background overlay to isolate modals, resolving ZIndex issues and making it feel premium!
	return React.createElement("Frame", {
		Name = "ModalOverlay_" .. tostring(title),
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("060712"),
		BackgroundTransparency = 0.65, -- Dark blurred-like focus backdrop
		BorderSizePixel = 0,
		ZIndex = 100, -- Absolutely on top of standard HUD elements
	}, {
		-- Center Modal Panel
		WindowFrame = React.createElement("Frame", {
			Name = "WindowFrame",
			Size = size,
			Position = position,
			AnchorPoint = anchorPoint,
			BackgroundColor3 = Theme.Colors.Panel,
			BackgroundTransparency = 0.05, -- Thick opaque backing
			BorderSizePixel = 0,
			ZIndex = 101,
		}, {
			-- UIScale drives the beautiful elastic spring entrance animation
			Scale = React.createElement("UIScale", {
				ref = scaleValRef,
				Scale = 1.0,
			}),

			-- Thick neon glowing outline to make it pop!
			Stroke = React.createElement("UIStroke", {
				Color = Theme.Colors.Stroke,
				Thickness = 4,
			}),

			Corner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerRadius or UDim.new(0, 16),
			}),

			-- Title header bar
			Header = React.createElement("Frame", {
				Name = "Header",
				Size = UDim2.new(1, 0, 0, 65),
				BackgroundTransparency = 1,
				ZIndex = 102,
			}, {
				TitleLabel = React.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = title:upper(),
					Font = Theme.Fonts.Title,
					TextSize = 28,
					TextColor3 = Theme.Colors.Text,
					ZIndex = 103,
				}, {
					Shadow = React.createElement("UIStroke", {
						Color = Color3.fromRGB(0, 0, 0),
						Thickness = 2.5,
					})
				}),

				-- Modern Glossy Circular Close button
				CloseButton = React.createElement("TextButton", {
					Name = "CloseButton",
					Size = UDim2.new(0, 36, 0, 36),
					Position = UDim2.new(1, -15, 0.5, -18),
					BackgroundColor3 = Theme.Colors.Error or Color3.fromRGB(255, 63, 75),
					Text = "X",
					Font = Theme.Fonts.Bold,
					TextColor3 = Theme.Colors.Text,
					TextSize = 18,
					BorderSizePixel = 0,
					ZIndex = 104,

					[React.Event.Activated] = function()
						if props.OnClose then props.OnClose() end
					end,
				}, {
					Corner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0.5, 0), -- Circular
					}),
					Stroke = React.createElement("UIStroke", {
						Color = Theme.Colors.Stroke,
						Thickness = 2,
					})
				})
			}),

			-- Current money balance widget integrated inside shop panels
			BalanceChip = showBalance and React.createElement(CurrencyChip, {
				CurrencyType = "Money",
				Value = balanceValue,
				Position = UDim2.new(0.5, -110, 0, 68),
				Size = UDim2.new(0, 220, 0, 44),
			}) or nil,

			-- Inner main content box
			Content = React.createElement("Frame", {
				Name = "Content",
				Size = if showBalance then UDim2.new(1, -30, 1, -135) else UDim2.new(1, -30, 1, -85),
				Position = if showBalance then UDim2.new(0.5, 0, 0, 120) else UDim2.new(0.5, 0, 0, 70),
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				ZIndex = 105,
			}, props.children),

			-- Top visual gloss sweep overlay
			GlossHighlight = React.createElement("Frame", {
				Name = "GlossHighlight",
				Size = UDim2.new(1, 0, 0.5, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 0.94,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				ZIndex = 106,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = Theme.Sizes.CornerRadius or UDim.new(0, 16),
				})
			})
		})
	})
end

return Panel
