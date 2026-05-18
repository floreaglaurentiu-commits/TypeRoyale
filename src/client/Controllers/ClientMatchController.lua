-- ClientMatchController.lua
-- Central state machine for the client during a match.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = require(ReplicatedStorage.Shared.Networking.Events)
local TypingMath = require(ReplicatedStorage.Shared.Typing.Math)
local KeyboardHandler = require(script.Parent.Parent.Input.KeyboardHandler)
local TypingFeedback = require(script.Parent.Parent.Effects.TypingFeedback)
local TextBank = require(ReplicatedStorage.Shared.Typing.TextBank)
local GameConfig = require(ReplicatedStorage.Shared.Constants.GameConfig)

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
local maxCombo = 0
local startTime = 0
local isOfflineMatch = false
local mistakeIndices = {} -- Track which characters were mistakes

-- Expose UI hooks
ClientMatchController.OnUIUpdateRequired = nil -- Function (wpm, accuracy, combo)
ClientMatchController.OnTextProgressRequired = nil -- Function (typedString, remainingString, mistakes)
ClientMatchController.OnMatchEnded = nil -- Function (winnerName)
ClientMatchController.OnCountdown = nil -- Function (secondsRemaining)
ClientMatchController.OnOpponentProgress = nil -- Function (typedIndex, totalChars)
ClientMatchController.OnKeyTypedVisual = nil -- Function (char)

local function resetState()
	isInMatch = false
	currentTargetText = ""
	currentTypedIndex = 0
	totalKeystrokes = 0
	correctKeystrokes = 0
	combo = 0
	maxCombo = 0
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

function ClientMatchController.StartOfflineMatch(options: any)
	resetState()
	isOfflineMatch = true
	countdownActive = true
	
	local category = "Quotes"
	local difficulty = "Normal"
	local mode = "Duel"
	local botSpeed = "Medium"
	
	if type(options) == "table" then
		category = options.category or "Quotes"
		difficulty = options.difficulty or "Normal"
		mode = options.mode or "Duel"
		botSpeed = options.botSpeed or "Medium"
		currentTargetText = TextBank.GetRandomText(category, difficulty)
	elseif type(options) == "string" then
		currentTargetText = options
	else
		currentTargetText = TextBank.GetRandomText("Quotes", "Normal")
	end
	
	-- Store options on the controller
	ClientMatchController.practiceOptions = {
		mode = mode,
		botSpeed = botSpeed,
		category = category,
		difficulty = difficulty
	}
	
	-- Initial UI sync to render the text
	fireUIUpdate()
	
	-- Immersive Ticking Countdown
	local countdownDuration = GameConfig.Practice.CountdownDuration or 3
	for i = countdownDuration, 1, -1 do
		if ClientMatchController.OnCountdown then
			ClientMatchController.OnCountdown(i)
		end
		TypingFeedback.PlayCountdown()
		task.wait(1)
	end
	
	if ClientMatchController.OnCountdown then
		ClientMatchController.OnCountdown(0)
	end
	
	-- Match Start ignition
	countdownActive = false
	KeyboardHandler.Enable()
	isInMatch = true
	startTime = os.clock()
	TypingFeedback.PlayMatchStart()
	
	-- Trigger bot logic if in bot duel mode! (to be added in Phase 6)
	if mode == "Duel" then
		task.spawn(function()
			ClientMatchController.StartPracticeBot()
		end)
	end
	
	fireUIUpdate()
end

-- Handle Keystrokes
KeyboardHandler.BindOnKeyPressed(function(char: string, _keycode: Enum.KeyCode)
	if not isInMatch then return end
	
	if ClientMatchController.OnKeyTypedVisual then
		ClientMatchController.OnKeyTypedVisual(char)
	end
	
	if char == "<BACKSPACE>" then
		-- Backspacing is disabled completely by design!
		return
	end
	
	-- Prevent typing past the end of the text
	if currentTypedIndex >= string.len(currentTargetText) then
		return
	end
	
	totalKeystrokes += 1
	
	local nextExpectedChar = string.sub(currentTargetText, currentTypedIndex + 1, currentTypedIndex + 1)
	
	if char == nextExpectedChar then
		correctKeystrokes += 1
		combo += 1
		if combo > maxCombo then
			maxCombo = combo
		end
		mistakeIndices[currentTypedIndex + 1] = nil
		TypingFeedback.PlayCorrectHit(combo)
	else
		combo = 0
		mistakeIndices[currentTypedIndex + 1] = true
		TypingFeedback.PlayMistake()
	end
	
	currentTypedIndex += 1
	
	-- Check win / completion
	if currentTypedIndex >= string.len(currentTargetText) then
		if isOfflineMatch then
			task.spawn(function()
				local success, err = pcall(function()
					endLocalMatch("Player")
				end)
				if not success then
					warn("[ClientMatchController] Error in endLocalMatch: " .. tostring(err))
				end
			end)
		else
			-- Send finish packet to server in multiplayer
			MatchProgressEvent:FireServer({
				correctCount = correctKeystrokes,
				totalKeystrokes = totalKeystrokes,
				isFinished = true
			})
			isInMatch = false
			KeyboardHandler.Disable()
		end
	else
		if not isOfflineMatch then
			-- Send progress occasionally (e.g. every 5 chars)
			if totalKeystrokes % 5 == 0 then
				MatchProgressEvent:FireServer({
					correctCount = correctKeystrokes,
					totalKeystrokes = totalKeystrokes,
					isFinished = false
				})
			end
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

function ClientMatchController.GetFinalStats()
	local timeElapsed = os.clock() - startTime
	local wpm = TypingMath.calculateWPM(correctKeystrokes, timeElapsed)
	local accuracy = TypingMath.calculateAccuracy(correctKeystrokes, totalKeystrokes)
	
	-- Calculate total mistake count
	local mistakeCount = 0
	for _, val in pairs(mistakeIndices) do
		if val then
			mistakeCount += 1
		end
	end
	
	return {
		wpm = wpm,
		accuracy = accuracy,
		maxCombo = maxCombo,
		totalKeystrokes = totalKeystrokes,
		mistakeCount = mistakeCount,
		duration = timeElapsed
	}
end

function ClientMatchController.RetryMatch()
	local prevOptions = ClientMatchController.practiceOptions
	local MatchUIController = require(script.Parent.Parent.UI.MatchUIController)
	MatchUIController.Unmount()
	MatchUIController.Mount()
	ClientMatchController.StartOfflineMatch(prevOptions)
end

function ClientMatchController.JoinQueue()
	Events.GetEvent("QueueJoin"):FireServer()
end

function ClientMatchController.StartPracticeBot()
	local options = ClientMatchController.practiceOptions or {}
	local speedName = options.botSpeed or "Medium"
	local botWPM = GameConfig.Practice.BotSpeeds[speedName] or 60
	
	-- Calculate base delay per character (5 characters = 1 word)
	local charsPerSecond = (botWPM * 5) / 60
	local baseDelay = 1 / charsPerSecond
	
	local botTypedIndex = 0
	local N = string.len(currentTargetText)
	
	while isInMatch and botTypedIndex < N do
		-- Add random human-like variance (e.g. +/- 20% of base delay)
		local variance = (math.random() - 0.5) * 0.4 * baseDelay
		local currentDelay = baseDelay + variance
		
		-- Check the current character being typed
		local nextChar = string.sub(currentTargetText, botTypedIndex + 1, botTypedIndex + 1)
		
		-- Spaces/punctuation introduce longer micro-pauses
		if nextChar == " " then
			currentDelay = currentDelay + math.random(0.08, 0.18)
		elseif nextChar:match("[%p]") then
			currentDelay = currentDelay + math.random(0.12, 0.22)
		end
		
		task.wait(currentDelay)
		
		if not isInMatch then break end
		
		botTypedIndex = botTypedIndex + 1
		
		-- Trigger opponent UI progress update hook
		if ClientMatchController.OnOpponentProgress then
			ClientMatchController.OnOpponentProgress(botTypedIndex, N)
		end
		
		-- Check if Bot won
		if botTypedIndex >= N then
			endLocalMatch("CyberBot")
			break
		end
	end
end

return ClientMatchController
