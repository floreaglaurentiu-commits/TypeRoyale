-- TypingFeedback.lua
-- Handles dopamine feedback (Screen shakes, glowing, sounds)

local TypingFeedback = {}

function TypingFeedback.PlayCorrectHit(combo: number)
	-- In the full game, play a mechanical switch sound here
	-- scale pitch or intensity based on combo
	-- Example: SoundService:PlayLocalSound(switchSound)
end

function TypingFeedback.PlayMistake()
	-- Play error buzz
	-- Screen flash red (e.g. using a red frame overlay tween)
	-- Camera shake
end

function TypingFeedback.PlayCountdown()
	-- Play 3.. 2.. 1.. ticking sound
end

function TypingFeedback.PlayMatchStart()
	-- Play deep bass "GO" sound
end

function TypingFeedback.PlayVictory()
	-- Play epic win fanfare
end

return TypingFeedback
