local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local KeyboardHandler = {}
local onKeyPressedCallback = nil
local isCapturing = false

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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
	task.defer(function()
		captureBox:CaptureFocus()
	end)
end

function KeyboardHandler.Disable()
	if not isCapturing then return end
	isCapturing = false
	captureBox:ReleaseFocus()
end

return KeyboardHandler
