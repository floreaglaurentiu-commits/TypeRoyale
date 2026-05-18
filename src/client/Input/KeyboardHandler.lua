local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local KeyboardHandler = {}
local onKeyPressedCallback = nil
local isCapturing = false

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local playerScripts = player:WaitForChild("PlayerScripts")

-- Safely get controls
local PlayerModule = require(playerScripts:WaitForChild("PlayerModule"))
local playerControls = PlayerModule:GetControls()

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TypeRoyale_InputCapture"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui


local captureBox = Instance.new("TextBox")
captureBox.Size = UDim2.fromScale(0, 0)
captureBox.Position = UDim2.fromScale(-1, -1)
captureBox.Text = ""
captureBox.ClearTextOnFocus = false
captureBox.BackgroundTransparency = 1
captureBox.TextTransparency = 1
captureBox.MultiLine = false
captureBox.Parent = screenGui

local isResetting = false

captureBox:GetPropertyChangedSignal("Text"):Connect(function()
	if not isCapturing or isResetting then return end
	
	local text = captureBox.Text
	if string.len(text) > 0 then
		isResetting = true
		
		if onKeyPressedCallback then
			for i = 1, string.len(text) do
				local char = string.sub(text, i, i)
				-- Ignore newlines if they somehow get through
				if char ~= "\n" and char ~= "\r" then
					onKeyPressedCallback(char, Enum.KeyCode.Unknown)
				end
			end
		end
		
		captureBox.Text = ""
		isResetting = false
	end
end)

-- Handle Backspace natively since TextBox text is cleared instantly
UserInputService.InputBegan:Connect(function(input, _gameProcessedEvent)
	if not isCapturing then return end
	
	if input.KeyCode == Enum.KeyCode.Backspace then
		if onKeyPressedCallback then
			onKeyPressedCallback("<BACKSPACE>", Enum.KeyCode.Backspace)
		end
	end
end)

-- Recapture focus on click/tap anywhere on the screen
UserInputService.InputBegan:Connect(function(input, _gameProcessedEvent)
	if not isCapturing then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		task.defer(function()
			if isCapturing and not captureBox:IsFocused() then
				captureBox:CaptureFocus()
			end
		end)
	end
end)

captureBox.FocusLost:Connect(function()
	if isCapturing then
		task.defer(function()
			captureBox:CaptureFocus()
		end)
	end
end)

function KeyboardHandler.BindOnKeyPressed(callback)
	onKeyPressedCallback = callback
end

function KeyboardHandler.Enable()
	if isCapturing then return end
	isCapturing = true
	captureBox.Text = ""
	
	-- Disable controls, chat, emotes
	pcall(function()
		playerControls:Disable()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	end)
	
	task.defer(function()
		captureBox:CaptureFocus()
	end)
end

function KeyboardHandler.Disable()
	if not isCapturing then return end
	isCapturing = false
	captureBox:ReleaseFocus()
	
	-- Enable controls back (but keep screens completely clean and immersive!)
	pcall(function()
		playerControls:Enable()
	end)
end

return KeyboardHandler

