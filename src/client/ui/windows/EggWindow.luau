-- EggWindow (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
local ItemCard = require(script.Parent.Parent.components.ItemCard)
local PetConfig = require(ReplicatedStorage.Shared.config.PetConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local EggOpenCutscene = require(script.Parent.EggOpenCutscene)

local equipPetEvent = Remotes.getEvent("EquipPet")
local hatchEggRequest = Remotes.getEvent("HatchEggRequest")
local eggHatchedEvent = Remotes.getEvent("EggHatched")

local function EggWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose
	local pets = props.Pets or {}

	local fastOpenEnabled, setFastOpenEnabled = React.useState(false)
	local currentSelectedEgg, setCurrentSelectedEgg = React.useState("CommonEgg")

	local currentSelectedEggRef = React.useRef("CommonEgg")
	local fastOpenEnabledRef = React.useRef(false)

	React.useEffect(function()
		currentSelectedEggRef.current = currentSelectedEgg
	end, {currentSelectedEgg})

	React.useEffect(function()
		fastOpenEnabledRef.current = fastOpenEnabled
	end, {fastOpenEnabled})

	React.useEffect(function()
		if not visible then return end
		local conn = eggHatchedEvent.OnClientEvent:Connect(function(chosenPets)
			EggOpenCutscene.play(chosenPets, currentSelectedEggRef.current, fastOpenEnabledRef.current)
		end)
		return function()
			conn:Disconnect()
		end
	end, {visible})

	if not visible then return nil end

	local totalBonus = 0
	local equippedCount = 0
	for _, pet in ipairs(pets) do
		local petInfo = PetConfig.Pets[pet.Type]
		if pet.Equipped and petInfo then
			totalBonus = totalBonus + (petInfo.Multiplier - 1.0)
			equippedCount = equippedCount + 1
		end
	end
	local finalMultiplier = 1.0 + totalBonus

	local eggButtonsList = { "CommonEgg", "SpookyEgg" }
	local shopItems = {
		FastOpenToggle = React.createElement(Button, {
			Text = fastOpenEnabled and "Быстрое открытие: ВКЛ" or "Быстрое открытие: ВЫКЛ",
			Color = fastOpenEnabled and Theme.Colors.Success or Theme.Colors.BackgroundSecondary,
			Size = UDim2.new(1, -10, 0, 30),
			Position = UDim2.new(0, 5, 0, 5),
			TextSize = 11,
			OnClick = function()
				setFastOpenEnabled(not fastOpenEnabled)
			end
		})
	}

	for idx, eggName in ipairs(eggButtonsList) do
		local config = PetConfig.Eggs[eggName]
		if config then
			local yPos = 45 + (idx - 1) * 115
			shopItems[eggName] = React.createElement("Frame", {
				Size = UDim2.new(1, -10, 0, 105),
				Position = UDim2.new(0, 5, 0, yPos),
				BackgroundColor3 = Theme.Colors.BackgroundSecondary,
				BorderSizePixel = 0,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = Theme.Sizes.CornerRadius,
				}),
				Stroke = React.createElement("UIStroke", {
					Thickness = 1,
					Color = Theme.Colors.Stroke,
				}),
				Title = React.createElement("TextLabel", {
					Size = UDim2.new(1, -12, 0, 24),
					Position = UDim2.new(0, 8, 0, 6),
					BackgroundTransparency = 1,
					Font = Theme.Fonts.Title,
					TextSize = 13,
					TextColor3 = config.Color,
					TextXAlignment = Enum.TextXAlignment.Left,
					Text = config.DisplayName,
				}),
				Buy1 = React.createElement(Button, {
					Text = string.format("Открыть x1 ($%d)", config.Cost),
					Color = Theme.Colors.Success,
					Size = UDim2.new(0.5, -10, 0, 36),
					Position = UDim2.new(0, 6, 1, -48),
					TextSize = 10,
					OnClick = function()
						setCurrentSelectedEgg(eggName)
						hatchEggRequest:FireServer(eggName, 1)
					end
				}),
				Buy3 = React.createElement(Button, {
					Text = string.format("Открыть x3 ($%d)", config.Cost * 3),
					Color = Theme.Colors.Accent,
					Size = UDim2.new(0.5, -10, 0, 36),
					Position = UDim2.new(0.5, 4, 1, -48),
					TextSize = 10,
					OnClick = function()
						setCurrentSelectedEgg(eggName)
						hatchEggRequest:FireServer(eggName, 3)
					end
				})
			})
		end
	end

	local petCards = {
		UIGridLayout = React.createElement("UIGridLayout", {
			CellSize = UDim2.new(0, 80, 0, 95),
			CellPadding = UDim2.new(0, 8, 0, 8),
		})
	}

	for _, pet in ipairs(pets) do
		local petInfo = PetConfig.Pets[pet.Type]
		if petInfo then
			petCards["Pet_" .. pet.Id] = React.createElement("Frame", {
				Size = UDim2.new(0, 80, 0, 95),
				BackgroundTransparency = 1,
			}, {
				Card = React.createElement(ItemCard, {
					Title = petInfo.DisplayName,
					Rarity = petInfo.Rarity,
					IconColor = petInfo.Color,
					Subtext = string.format("x%.1f монет", petInfo.Multiplier),
					Equipped = pet.Equipped,
					OnClick = function()
						equipPetEvent:FireServer(pet.Id)
					end
				})
			})
		end
	end

	return React.createElement(Panel, {
		Title = "ПИТОМЦЫ И ЯЙЦА",
		Size = UDim2.new(0, 520, 0, 360),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Visible = true,
		OnClose = onClose,
	}, {
		EggShop = React.createElement("Frame", {
			Size = UDim2.new(0, 220, 1, 0),
			BackgroundTransparency = 1,
		}, shopItems),

		Divider = React.createElement("Frame", {
			Size = UDim2.new(0, 2, 1, -10),
			Position = UDim2.new(0, 222, 0, 5),
			BackgroundColor3 = Theme.Colors.Stroke,
			BorderSizePixel = 0,
		}),

		RightSide = React.createElement("Frame", {
			Size = UDim2.new(1, -235, 1, 0),
			Position = UDim2.new(0, 235, 0, 0),
			BackgroundTransparency = 1,
		}, {
			MultiplierLabel = React.createElement("TextLabel", {
				Size = UDim2.new(1, -10, 0, 25),
				Position = UDim2.new(0, 5, 0, 5),
				BackgroundTransparency = 1,
				Font = Theme.Fonts.Bold,
				TextSize = 13,
				TextColor3 = Theme.Colors.Success,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = string.format("Бонус: x%.1f монет (Надето: %d / 3)", finalMultiplier, equippedCount),
			}),

			Scroll = React.createElement("ScrollingFrame", {
				Size = UDim2.new(1, 0, 1, -35),
				Position = UDim2.new(0, 0, 0, 35),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 6,
				CanvasSize = UDim2.new(0, 0, 0, math.ceil(#pets / 3) * 115),
			}, petCards)
		})
	})
end

return EggWindow

