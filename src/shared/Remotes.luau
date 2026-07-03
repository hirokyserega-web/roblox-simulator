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
			folder = ReplicatedStorage:WaitForChild(folderName, 10)
			if not folder then
				error("Клиент не дождался создания папки Remotes в ReplicatedStorage!")
			end
		end
	end
	return folder
end

-- Получить или создать RemoteEvent
function Remotes.getEvent(name: string): RemoteEvent
	local folder = getRemotesFolder()
	local event = folder:FindFirstChild(name)
	
	if not event then
		if RunService:IsServer() then
			event = Instance.new("RemoteEvent")
			event.Name = name
			event.Parent = folder
		else
			event = folder:WaitForChild(name, 10)
			if not event then
				error("Клиент не дождался RemoteEvent: " .. name)
			end
		end
	end
	
	return event
end

-- Получить или создать RemoteFunction
function Remotes.getFunction(name: string): RemoteFunction
	local folder = getRemotesFolder()
	local func = folder:FindFirstChild(name)
	
	if not func then
		if RunService:IsServer() then
			func = Instance.new("RemoteFunction")
			func.Name = name
			func.Parent = folder
		else
			func = folder:WaitForChild(name, 10)
			if not func then
				error("Клиент не дождался RemoteFunction: " .. name)
			end
		end
	end
	
	return func
end

return Remotes
