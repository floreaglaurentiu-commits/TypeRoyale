-- Math.lua
-- Contains pure functions for calculating WPM, Accuracy, and other typing metrics.

local TypingMath = {}

--[[
	Calculates the current Words Per Minute (WPM).
	Standard definition: 5 characters = 1 word.
	
	@param totalCharactersTyped number - Total characters typed (including spaces).
	@param timeElapsedSeconds number - Total time spent typing in seconds.
	@return number - Current WPM.
]]
function TypingMath.calculateWPM(totalCharactersTyped: number, timeElapsedSeconds: number): number
	if timeElapsedSeconds <= 0 then return 0 end
	local words = totalCharactersTyped / 5
	local minutes = timeElapsedSeconds / 60
	return math.floor(words / minutes)
end

--[[
	Calculates typing accuracy as a percentage.
	
	@param correctCharacters number
	@param totalKeystrokes number
	@return number - Accuracy from 0.0 to 100.0
]]
function TypingMath.calculateAccuracy(correctCharacters: number, totalKeystrokes: number): number
	if totalKeystrokes <= 0 then return 100.0 end
	local accuracy = (correctCharacters / totalKeystrokes) * 100
	return math.clamp(math.floor(accuracy * 10) / 10, 0, 100) -- One decimal place
end

--[[
	Calculates the combo multiplier or bonus based on consecutive correct keystrokes.
	
	@param currentCombo number
	@return number - Combo multiplier.
]]
function TypingMath.getComboMultiplier(currentCombo: number): number
	if currentCombo >= 50 then return 2.0 end
	if currentCombo >= 20 then return 1.5 end
	if currentCombo >= 10 then return 1.2 end
	return 1.0
end

return TypingMath
