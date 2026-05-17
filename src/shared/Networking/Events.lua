-- Events.lua
-- Centralized repository for all RemoteEvents in the game.
-- This module ensures Remotes are safely retrieved or created.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = {}
local isServer = RunService:IsServer()

local EVENT_FOLDER_NAME = "TypeRoyaleEvents"
local eventFolder

if isServer then
	eventFolder = ReplicatedStorage:FindFirstChild(EVENT_FOLDER_NAME)
	if not eventFolder then
		eventFolder = Instance.new("Folder")
		eventFolder.Name = EVENT_FOLDER_NAME
		eventFolder.Parent = ReplicatedStorage
	end
else
	eventFolder = ReplicatedStorage:WaitForChild(EVENT_FOLDER_NAME)
end

--[[
	Retrieves a RemoteEvent by name. Creates it if on the server and it doesn't exist.
	Yields on the client until the event exists.
]]
function Events.GetEvent(eventName: string): RemoteEvent
	if isServer then
		local remote = eventFolder:FindFirstChild(eventName)
		if not remote then
			remote = Instance.new("RemoteEvent")
			remote.Name = eventName
			remote.Parent = eventFolder
		end
		return remote
	else
		return eventFolder:WaitForChild(eventName)
	end
end

-- Define all events here for easy discovery
Events.List = {
	QueueJoin = "QueueJoin",
	QueueLeave = "QueueLeave",
	MatchFound = "MatchFound",
	MatchStart = "MatchStart",
	MatchProgress = "MatchProgress",
	MatchEnd = "MatchEnd"
}

return Events
