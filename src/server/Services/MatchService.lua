-- MatchService.lua
-- Orchestrates active 1v1 typing matches.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = require(ReplicatedStorage.Shared.Networking.Events)
local Validation = require(script.Parent.Parent.Validation.ServerTypingValidation)

local MatchStartEvent = Events.GetEvent("MatchStart")
local MatchProgressEvent = Events.GetEvent("MatchProgress")
local MatchEndEvent = Events.GetEvent("MatchEnd")

local MatchService = {}
local activeMatches = {} -- matchId -> { player1, player2, startTime, status }

local matchCounter = 0

function MatchService.StartMatch(player1: Player, player2: Player)
	matchCounter += 1
	local matchId = "Match_" .. matchCounter
	
	activeMatches[matchId] = {
		id = matchId,
		p1 = player1,
		p2 = player2,
		status = "Starting",
		startTime = os.clock()
	}
	
	Validation.InitializePlayer(player1)
	Validation.InitializePlayer(player2)
	
	-- Sample text for Phase 1. Later, this should come from TextBank.
	local matchText = "In the midst of chaos, there is also opportunity."
	
	-- Notify clients
	MatchStartEvent:FireClient(player1, { opponent = player2.Name, text = matchText })
	MatchStartEvent:FireClient(player2, { opponent = player1.Name, text = matchText })
	
	activeMatches[matchId].status = "InProgress"
end

function MatchService.EndMatch(matchId: string, winner: Player?)
	local match = activeMatches[matchId]
	if not match then return end
	
	match.status = "Ended"
	Validation.ClearPlayer(match.p1)
	Validation.ClearPlayer(match.p2)
	
	MatchEndEvent:FireClient(match.p1, { winner = winner and winner.Name or "Draw" })
	MatchEndEvent:FireClient(match.p2, { winner = winner and winner.Name or "Draw" })
	
	activeMatches[matchId] = nil
end

-- Handle progress updates
MatchProgressEvent.OnServerEvent:Connect(function(player: Player, progressData: any)
	-- progressData expected: { correctCount = number, totalKeystrokes = number, isFinished = boolean }
	local match = nil
	local opponent = nil
	
	-- Find player's match (O(n) for now, can optimize later)
	for _, m in pairs(activeMatches) do
		if m.p1 == player then
			match = m
			opponent = m.p2
			break
		elseif m.p2 == player then
			match = m
			opponent = m.p1
			break
		end
	end
	
	if not match then return end
	
	-- Validate progress
	local isValid = Validation.ValidateProgress(player, progressData.correctCount, progressData.totalKeystrokes)
	
	if isValid then
		-- Broadcast to opponent
		MatchProgressEvent:FireClient(opponent, { 
			correctCount = progressData.correctCount,
			totalKeystrokes = progressData.totalKeystrokes 
		})
		
		-- Check for win condition
		if progressData.isFinished then
			MatchService.EndMatch(match.id, player)
		end
	else
		-- If cheating detected, automatically lose the match
		MatchService.EndMatch(match.id, opponent)
	end
end)

return MatchService
