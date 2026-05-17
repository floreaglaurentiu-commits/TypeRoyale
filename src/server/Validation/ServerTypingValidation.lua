-- ServerTypingValidation.lua
-- Handles server-side validation to prevent obvious cheating (e.g., impossible WPM).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Constants.GameConfig)
local TypingMath = require(ReplicatedStorage.Shared.Typing.Math)

local Validation = {}

-- Store player typing states
local playerStates = {}

function Validation.InitializePlayer(player: Player)
	playerStates[player.UserId] = {
		startTime = os.clock(),
		lastKeystrokeTime = 0,
		keystrokeCount = 0,
		correctCount = 0
	}
end

function Validation.ClearPlayer(player: Player)
	playerStates[player.UserId] = nil
end

--[[
	Validates an incoming progress update from a client.
	Returns true if valid, false if flagged as cheating.
]]
function Validation.ValidateProgress(player: Player, correctCount: number, totalKeystrokes: number): boolean
	local state = playerStates[player.UserId]
	if not state then return false end
	
	local currentTime = os.clock()
	local timeElapsed = currentTime - state.startTime
	
	-- Calculate WPM based on reported correct keystrokes
	local currentWPM = TypingMath.calculateWPM(correctCount, timeElapsed)
	
	if currentWPM > GameConfig.AntiCheat.MAX_REASONABLE_WPM then
		warn(string.format("[AntiCheat] Player %s flagged for impossible WPM: %d", player.Name, currentWPM))
		return false
	end
	
	-- Simple interval check (preventing script-driven instant typing)
	if totalKeystrokes > state.keystrokeCount then
		local timeSinceLastKey = (currentTime - state.lastKeystrokeTime) * 1000 -- ms
		if timeSinceLastKey < GameConfig.AntiCheat.MIN_KEYSTROKE_INTERVAL_MS then
			warn(string.format("[AntiCheat] Player %s flagged for inhuman keystroke interval: %d ms", player.Name, timeSinceLastKey))
			-- Depending on strictness, we might return false here
		end
	end
	
	-- Update state
	state.lastKeystrokeTime = currentTime
	state.keystrokeCount = totalKeystrokes
	state.correctCount = correctCount
	
	return true
end

return Validation
