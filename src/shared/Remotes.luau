-- Модуль Remotes для централизованного управления сетевыми событиями
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = {}
local folderName = "Remotes"

-- Получить или создать папку Remotes
local function getRemotesFolder(): Folder
	local folder = ReplicatedStorage:FindFirstChild(folderName)
	if not folder then
		if RunService:IsServer() then
			folder = Instance.new("Folder")
			folder.Name = folderName
			folder.Parent = ReplicatedStorage
		else
			folder = ReplicatedStorage:WaitForChild(folderName, 3)
			if not folder then
				warn("Клиент не дождался создания папки Remotes в ReplicatedStorage!")
				return nil :: any
			end
		end
	end
	return folder
end

-- Получить или создать RemoteEvent
function Remotes.getEvent(name: string): RemoteEvent
	local folder = getRemotesFolder()
	local event = folder and folder:FindFirstChild(name)
	
	if not event then
		if RunService:IsServer() then
			if folder then
				event = Instance.new("RemoteEvent")
				event.Name = name
				event.Parent = folder
			end
		else
			if folder then
				event = folder:WaitForChild(name, 3)
			end
			if not event then
				warn("Клиент не дождался RemoteEvent: " .. name .. " - используя заглушку")
				local mock = {
					OnClientEvent = {
						Connect = function()
							return { Disconnect = function() end }
						end
					},
					Connect = function()
						return { Disconnect = function() end }
					end,
					FireServer = function() end,
				}
				return mock :: any
			end
		end
	end
	
	return event
end

-- Получить или создать RemoteFunction
function Remotes.getFunction(name: string): RemoteFunction
	local folder = getRemotesFolder()
	local func = folder and folder:FindFirstChild(name)
	
	if not func then
		if RunService:IsServer() then
			if folder then
				func = Instance.new("RemoteFunction")
				func.Name = name
				func.Parent = folder
			end
		else
			if folder then
				func = folder:WaitForChild(name, 3)
			end
			if not func then
				warn("Клиент не дождался RemoteFunction: " .. name .. " - используя заглушку")
				local mock = {
					InvokeServer = function()
						return nil
					end
				}
				return mock :: any
			end
		end
	end
	
	return func
end

return Remotes

