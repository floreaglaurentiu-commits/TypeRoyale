-- ClientMatchController.lua
-- Central state machine for the client during a match.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Events = require(ReplicatedStorage.Shared.Networking.Events)
local TypingMath = require(ReplicatedStorage.Shared.Typing.Math)
local KeyboardHandler = require(script.Parent.Parent.Input.KeyboardHandler)
local TypingFeedback = require(script.Parent.Parent.Effects.TypingFeedback)

local MatchStartEvent = Events.GetEvent("MatchStart")
local MatchProgressEvent = Events.GetEvent("MatchProgress")
local MatchEndEvent = Events.GetEvent("MatchEnd")

local ClientMatchController = {}

-- Match State
local isInMatch = false
local currentTargetText = ""
local currentTypedIndex = 0
local totalKeystrokes = 0
local correctKeystrokes = 0
local combo = 0
local startTime = 0

-- Expose UI hooks
ClientMatchController.OnUIUpdateRequired = nil -- Function (wpm, accuracy, combo)
ClientMatchController.OnTextProgressRequired = nil -- Function (typedString, remainingString)
ClientMatchController.OnMatchEnded = nil -- Function (winnerName)

local function resetState()
	isInMatch = false
	currentTargetText = ""
	currentTypedIndex = 0
	totalKeystrokes = 0
	correctKeystrokes = 0
	combo = 0
	startTime = 0
end

local function fireUIUpdate()
	if not ClientMatchController.OnUIUpdateRequired then return end
	if not ClientMatchController.OnTextProgressRequired then return end
	
	local timeElapsed = os.clock() - startTime
	local wpm = TypingMath.calculateWPM(correctKeystrokes, timeElapsed)
	local accuracy = TypingMath.calculateAccuracy(correctKeystrokes, totalKeystrokes)
	
	ClientMatchController.OnUIUpdateRequired(wpm, accuracy, combo)
	
	local typed = string.sub(currentTargetText, 1, currentTypedIndex)
	local remaining = string.sub(currentTargetText, currentTypedIndex + 1)
	ClientMatchController.OnTextProgressRequired(typed, remaining)
end

-- Handle Keystrokes
KeyboardHandler.BindOnKeyPressed(function(char: string, keycode: Enum.KeyCode)
	if not isInMatch then return end
	
	totalKeystrokes += 1
	
	local nextExpectedChar = string.sub(currentTargetText, currentTypedIndex + 1, currentTypedIndex + 1)
	
	-- Very naive case-insensitive check for MVP
	if string.lower(char) == string.lower(nextExpectedChar) then
		currentTypedIndex += 1
		correctKeystrokes += 1
		combo += 1
		TypingFeedback.PlayCorrectHit(combo)
		
		-- Check win
		if currentTypedIndex >= string.len(currentTargetText) then
			-- Send finish packet
			MatchProgressEvent:FireServer({
				correctCount = correctKeystrokes,
				totalKeystrokes = totalKeystrokes,
				isFinished = true
			})
			isInMatch = false
		else
			-- Send progress occasionally (e.g. every 5 chars)
			if correctKeystrokes % 5 == 0 then
				MatchProgressEvent:FireServer({
					correctCount = correctKeystrokes,
					totalKeystrokes = totalKeystrokes,
					isFinished = false
				})
			end
		end
		
	else
		-- Mistake
		combo = 0
		TypingFeedback.PlayMistake()
	end
	
	fireUIUpdate()
end)

-- Network Listeners
MatchStartEvent.OnClientEvent:Connect(function(data)
	-- data.text, data.opponent
	resetState()
	currentTargetText = data.text
	isInMatch = true
	startTime = os.clock()
	TypingFeedback.PlayMatchStart()
	
	fireUIUpdate()
end)

MatchEndEvent.OnClientEvent:Connect(function(data)
	isInMatch = false
	TypingFeedback.PlayVictory()
	if ClientMatchController.OnMatchEnded then
		ClientMatchController.OnMatchEnded(data.winner)
	end
end)

MatchProgressEvent.OnClientEvent:Connect(function(data)
	-- Opponent progress received (update opponent UI bar)
	-- data.correctCount, data.totalKeystrokes
end)

function ClientMatchController.JoinQueue()
	Events.GetEvent("QueueJoin"):FireServer()
end

return ClientMatchController
