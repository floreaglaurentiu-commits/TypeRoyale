-- TextBank.lua
-- Contains categorized libraries of texts and quotes for both offline and online matches.

local TextBank = {}

local texts = {
	Quotes = {
		Normal = {
			"In the midst of chaos, there is also opportunity.",
			"The quick brown fox jumps over the lazy dog.",
			"To be or not to be, that is the question.",
			"Focus is the key to mastering the keycap, type like the wind.",
			"Consistency beats speed when precision counts in the arena."
		},
		Hard = {
			"Esports is not just about reflexes; it is about absolute mental endurance under pressure.",
			"A champion is defined not by their peak speed, but by their rhythm and muscle consistency.",
			"Cyberpunk aesthetics merge neon light with dark corporate skyscrapers, defining a high-tech low-life era.",
			"The mechanical keyboard click clacks rhythmically, a symphony of focus reverberating in the quiet room."
		}
	},
	Words = {
		Normal = {
			"the quick brown fox jumps over the lazy dog typing test focus arena victory champion speed accuracy keyboard neon mechanical click gaming",
			"practice makes perfect and absolute consistency leads to high typing speed on any standard mechanical layout setup",
			"focus on your home row fingers and keep a steady breathing rhythm to avoid mistakes during intense match situations"
		},
		Hard = {
			"rhythm consistency precision mechanical keyboard switches linear tactile clicky actuation force keycap profile stabilized spacebar layout typing speedrun master",
			"cyberpunk digital interface neon blue glowing grids terminal latency ping packet loss network synchronization multiplayer competitive matchmaking queue"
		}
	},
	Meme = {
		Normal = {
			"gg wp ez clap no re click clack type like a beast lag is not an excuse git gud",
			"mom get the camera i just typed at three hundred words per minute in standard format"
		},
		Hard = {
			"wts mechanical keyboard brand new never used high speed actuation perfect for competitive ranked duels in type royale",
			"sheeesh that typing speed was absolutely cracked clean accuracy maximum combo multiplier unlocked"
		}
	}
}

--[[
	Retrieves a random text from the requested category and difficulty.
	Falls back gracefully if the category or difficulty is invalid.
]]
function TextBank.GetRandomText(category: string?, difficulty: string?): string
	category = category or "Quotes"
	difficulty = difficulty or "Normal"
	
	local catData = texts[category] or texts.Quotes
	local list = catData[difficulty] or catData.Normal or catData
	
	if #list == 0 then
		return "Default fallback typing text because database was empty."
	end
	
	local randomIndex = math.random(1, #list)
	local text = list[randomIndex]
	-- Strip all punctuation (like dots, commas, question marks, exclamation marks, colons, semicolons, dashes, etc.)
	text = text:gsub("[%p]", "")
	return text
end

return TextBank
