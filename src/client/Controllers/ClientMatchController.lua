-- ClientMatchController.lua
-- Central state machine for the client during a match.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
local isOfflineMatch = false
local mistakeIndices = {} -- Track which characters were mistakes

-- Expose UI hooks
ClientMatchController.OnUIUpdateRequired = nil -- Function (wpm, accuracy, combo)
ClientMatchController.OnTextProgressRequired = nil -- Function (typedString, remainingString, mistakes)
ClientMatchController.OnMatchEnded = nil -- Function (winnerName)
ClientMatchController.OnCountdown = nil -- Function (secondsRemaining)

local function resetState()
	isInMatch = false
	currentTargetText = ""
	currentTypedIndex = 0
	totalKeystrokes = 0
	correctKeystrokes = 0
	combo = 0
	startTime = 0
	isOfflineMatch = false
	mistakeIndices = {}
end

local function endLocalMatch(winnerName)
	isInMatch = false
	isOfflineMatch = false
	KeyboardHandler.Disable()
	TypingFeedback.PlayVictory()
	if ClientMatchController.OnMatchEnded then
		ClientMatchController.OnMatchEnded(winnerName)
	end
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
	ClientMatchController.OnTextProgressRequired(typed, remaining, mistakeIndices)
end

function ClientMatchController.StartOfflineMatch(targetText: string)
	resetState()
	currentTargetText = targetText
	isOfflineMatch = true
	countdownActive = true
	
	-- Countdown before match starts
	for i = 2, 1, -1 do
		if ClientMatchController.OnCountdown then
			ClientMatchController.OnCountdown(i)
		end
		task.wait(1)
	end
	
	-- Now start the actual match
	KeyboardHandler.Enable()
	isInMatch = true
	startTime = os.clock()
	TypingFeedback.PlayMatchStart()
	fireUIUpdate()
end

-- Handle Keystrokes
KeyboardHandler.BindOnKeyPressed(function(char: string, _keycode: Enum.KeyCode)
	if not isInMatch then return end
	
	if char == "<BACKSPACE>" then
		if currentTypedIndex > 0 then
			mistakeIndices[currentTypedIndex] = nil
			currentTypedIndex -= 1
			fireUIUpdate()
		end
		return
	end
	
	-- Prevent typing past the end of the text unless they backspace
	if currentTypedIndex >= string.len(currentTargetText) then
		return
	end
	
	totalKeystrokes += 1
	
	local nextExpectedChar = string.sub(currentTargetText, currentTypedIndex + 1, currentTypedIndex + 1)
	
	if char == nextExpectedChar then
		correctKeystrokes += 1
		combo += 1
		mistakeIndices[currentTypedIndex + 1] = nil
		TypingFeedback.PlayCorrectHit(combo)
	else
		combo = 0
		mistakeIndices[currentTypedIndex + 1] = true
		TypingFeedback.PlayMistake()
	end
	
	currentTypedIndex += 1
	
	-- Check win
	if currentTypedIndex >= string.len(currentTargetText) then
		if isOfflineMatch then
			endLocalMatch("You")
		else
			-- Send finish packet
			MatchProgressEvent:FireServer({
				correctCount = correctKeystrokes,
				totalKeystrokes = totalKeystrokes,
				isFinished = true
			})
			isInMatch = false
			KeyboardHandler.Disable()
		end
	else
		-- Send progress occasionally (e.g. every 5 chars)
		if totalKeystrokes % 5 == 0 then
			MatchProgressEvent:FireServer({
				correctCount = correctKeystrokes,
				totalKeystrokes = totalKeystrokes,
				isFinished = false
			})
		end
	end
	
	fireUIUpdate()
end)

-- Network Listeners
MatchStartEvent.OnClientEvent:Connect(function(data)
	-- data.text, data.opponent
	resetState()
	currentTargetText = data.text
	KeyboardHandler.Enable()
	isInMatch = true
	startTime = os.clock()
	TypingFeedback.PlayMatchStart()
	
	fireUIUpdate()
end)

MatchEndEvent.OnClientEvent:Connect(function(data)
	isInMatch = false
	KeyboardHandler.Disable()
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
