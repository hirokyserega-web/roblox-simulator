-- ShopWindow
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpgradeConfig = require(ReplicatedStorage.Shared.config.UpgradeConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local Panel = require(script.Parent.Parent.components.Panel)
local ProgressBar = require(script.Parent.Parent.components.ProgressBar)

local ShopWindow = {}
local shopPanel = nil
local upgradeItems = {}

local function updateRow(uType)
	local row = upgradeItems[uType]
	if not row then return end
	local player = Players.LocalPlayer
	local level = player:GetAttribute(uType .. "Lvl") or 1
	local conf = UpgradeConfig[uType]
	row.LevelLabel.Text = "Lvl " .. level .. " / " .. conf.MaxLevel
	row.Bar.SetProgress(level / conf.MaxLevel)
	if row.Btn then row.Btn.Destroy() end
	local isMax = level >= conf.MaxLevel
	local cost = not isMax and conf.Levels[level+1].Cost or 0
	local canBuy = player:GetAttribute("Money") >= cost
	row.Btn = Button.create({
		Text = isMax and "MAX" or "$" .. tostring(cost),
		Color = isMax and Theme.Colors.BackgroundSecondary or (canBuy and Theme.Colors.Success or Theme.Colors.Error),
		Size = UDim2.new(0, 100, 0, 40),
		Position = UDim2.new(1, -110, 0.5, -20),
		Parent = row.Frame,
		OnClick = function()
			if not isMax and canBuy then Remotes.getEvent("BuyUpgrade"):FireServer(uType) end
		end
	})
end

function ShopWindow.init(screenGui)
	shopPanel = Panel.create({ Title = "UPGRADE SHOP", Parent = screenGui, ShowBalance = true })
	local scroll = Instance.new("ScrollingFrame", shopPanel.Content)
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)
	for uType, conf in pairs(UpgradeConfig) do
		local f = Instance.new("Frame", scroll)
		f.Size = UDim2.new(1, 0, 0, 60)
		f.BackgroundColor3 = Theme.Colors.BackgroundSecondary
		Instance.new("UICorner", f).CornerRadius = Theme.Sizes.CornerRadius
		local l = Instance.new("TextLabel", f)
		l.Text = conf.DisplayName
		l.Position = UDim2.new(0, 10, 0, 5)
		l.Size = UDim2.new(0, 200, 0, 20)
		l.BackgroundTransparency = 1
		l.TextColor3 = Theme.Colors.Text
		l.Font = Theme.Fonts.Title
		l.TextXAlignment = Enum.TextXAlignment.Left
		local lvl = Instance.new("TextLabel", f)
		lvl.Position = UDim2.new(0, 10, 0, 25)
		lvl.Size = UDim2.new(0, 200, 0, 20)
		lvl.BackgroundTransparency = 1
		lvl.TextColor3 = Theme.Colors.TextSecondary
		lvl.Font = Theme.Fonts.Body
		lvl.TextXAlignment = Enum.TextXAlignment.Left
		local b = ProgressBar.create({ Size = UDim2.new(0, 150, 0, 5), Position = UDim2.new(0, 10, 0, 45), Parent = f })
		upgradeItems[uType] = { Frame = f, LevelLabel = lvl, Bar = b }
		updateRow(uType)
	end
	
	Players.LocalPlayer:GetAttributeChangedSignal("Money"):Connect(function()
		for k in pairs(upgradeItems) do updateRow(k) end
		shopPanel.SetBalance(Players.LocalPlayer:GetAttribute("Money") or 0)
	end)
	
	return ShopWindow
end

function ShopWindow.Open() shopPanel.Open() end
function ShopWindow.Close() shopPanel.Close() end

return ShopWindow
