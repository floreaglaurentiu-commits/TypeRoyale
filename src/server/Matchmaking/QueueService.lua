-- QueueService.lua
-- Manages the matchmaking queue for 1v1 duels.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Events = require(ReplicatedStorage.Shared.Networking.Events)
local MatchService = require(script.Parent.Parent.Services.MatchService)

local QueueJoinEvent = Events.GetEvent("QueueJoin")
local QueueLeaveEvent = Events.GetEvent("QueueLeave")

local QueueService = {}
local matchQueue = {} -- Array of Players

local function updateQueue()
	if #matchQueue >= 2 then
		-- We have enough players for a 1v1
		local p1 = table.remove(matchQueue, 1)
		local p2 = table.remove(matchQueue, 1)
		
		-- Ensure both are still in the game
		if p1.Parent and p2.Parent then
			MatchService.StartMatch(p1, p2)
		else
			-- If someone left, put the remaining one back
			if p1.Parent then QueueService.JoinQueue(p1) end
			if p2.Parent then QueueService.JoinQueue(p2) end
		end
	end
end

function QueueService.JoinQueue(player: Player)
	-- Prevent duplicate entries
	if table.find(matchQueue, player) then return end
	
	table.insert(matchQueue, player)
	print(player.Name .. " joined the queue. Total: " .. #matchQueue)
	updateQueue()
end

function QueueService.LeaveQueue(player: Player)
	local index = table.find(matchQueue, player)
	if index then
		table.remove(matchQueue, index)
		print(player.Name .. " left the queue.")
	end
end

-- Listen to client events
QueueJoinEvent.OnServerEvent:Connect(QueueService.JoinQueue)
QueueLeaveEvent.OnServerEvent:Connect(QueueService.LeaveQueue)

-- Remove from queue if they leave the game
Players.PlayerRemoving:Connect(QueueService.LeaveQueue)

return QueueService
