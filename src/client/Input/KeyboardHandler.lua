-- KeyboardHandler.lua
-- Listens to UserInputService and fires events when the user types characters.

local UserInputService = game:GetService("UserInputService")

local KeyboardHandler = {}
local onKeyPressedCallback = nil

-- Letters, numbers, and basic punctuation
local function isValidCharacter(keycode: Enum.KeyCode): string?
	local keyString = UserInputService:GetStringForKeyCode(keycode)
	if keyString and keyString ~= "" then
		-- In a real scenario, we'd handle shift states (uppercase, special chars).
		-- For this MVP, we assume basic lowercase or space matching.
		return keyString
	end
	
	if keycode == Enum.KeyCode.Space then
		return " "
	end
	
	return nil
end

function KeyboardHandler.BindOnKeyPressed(callback)
	onKeyPressedCallback = callback
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	-- Don't process if user is chatting or clicking UI
	if gameProcessedEvent then return end
	
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if onKeyPressedCallback then
			local char = isValidCharacter(input.KeyCode)
			if char then
				-- We might need UserInputService:GetKeysPressed() for Shift detection later
				-- For now, pass the lowercase string or space
				onKeyPressedCallback(char, input.KeyCode)
			end
		end
	end
end)

return KeyboardHandler
