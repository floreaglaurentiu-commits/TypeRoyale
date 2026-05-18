-- GameConfig.lua
-- Centralized configuration for TypeRoyale

local GameConfig = {}

GameConfig.Match = {
	COUNTDOWN_DURATION = 3, -- Seconds before match starts
	MAX_MATCH_DURATION = 120, -- Seconds before match times out
}

GameConfig.Ranks = {
	{ name = "Bronze", minRP = 0 },
	{ name = "Silver", minRP = 500 },
	{ name = "Gold", minRP = 1000 },
	{ name = "Platinum", minRP = 1500 },
	{ name = "Diamond", minRP = 2000 },
	{ name = "Royale", minRP = 2500 }
}

GameConfig.AntiCheat = {
	MAX_REASONABLE_WPM = 350, -- Instantly flag if higher
	MIN_KEYSTROKE_INTERVAL_MS = 20, -- Instantly flag if keys are pressed faster than this
}

GameConfig.Practice = {
	BotSpeeds = { Easy = 30, Medium = 60, Hard = 90, Insane = 120 }, -- WPM target speeds
	CountdownDuration = 3,
	DefaultCategory = "Quotes",
	DefaultDifficulty = "Normal",
	BlockOnError = false, -- If true, player cannot type past a mistake without backspacing (Monkeytype style)
}

return GameConfig

