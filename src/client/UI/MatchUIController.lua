-- MatchUIController.lua
-- Scaffolds the In-Game HUD and wires to ClientMatchController.

local Players = game:GetService("Players")
local ClientMatchController = require(script.Parent.Parent.Controllers.ClientMatchController)

local MatchUIController = {}
local screenGui
local elements = {}

function MatchUIController.Mount()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	if playerGui:FindFirstChild("TypeRoyaleMatchHUD") then
		playerGui.TypeRoyaleMatchHUD:Destroy()
	end
	
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TypeRoyaleMatchHUD"
	screenGui.ResetOnSpawn = false
	
	-- HUD Container
	local hud = Instance.new("Frame")
	hud.Size = UDim2.fromScale(1, 1)
	hud.BackgroundTransparency = 1
	hud.Parent = screenGui
	
	-- Typing Area (Center)
	local typingFrame = Instance.new("Frame")
	typingFrame.Size = UDim2.fromScale(0.6, 0.3)
	typingFrame.Position = UDim2.fromScale(0.2, 0.4)
	typingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	typingFrame.BackgroundTransparency = 0.5
	
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 16)
	uiCorner.Parent = typingFrame
	typingFrame.Parent = hud
	
	-- We need a RichText label to color the typed characters
	local textDisplay = Instance.new("TextLabel")
	textDisplay.Size = UDim2.fromScale(0.9, 0.9)
	textDisplay.Position = UDim2.fromScale(0.05, 0.05)
	textDisplay.BackgroundTransparency = 1
	textDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
	textDisplay.TextScaled = true
	textDisplay.Font = Enum.Font.Code -- Monospace is best for typing
	textDisplay.RichText = true
	textDisplay.TextXAlignment = Enum.TextXAlignment.Center
	textDisplay.TextYAlignment = Enum.TextYAlignment.Center
	textDisplay.Parent = typingFrame
	
	-- Stats Panel (Left Side)
	local statsFrame = Instance.new("Frame")
	statsFrame.Size = UDim2.fromScale(0.15, 0.4)
	statsFrame.Position = UDim2.fromScale(0.02, 0.3)
	statsFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	
	local statsCorner = Instance.new("UICorner")
	statsCorner.CornerRadius = UDim.new(0, 12)
	statsCorner.Parent = statsFrame
	statsFrame.Parent = hud
	
	local wpmLabel = Instance.new("TextLabel")
	wpmLabel.Size = UDim2.fromScale(1, 0.25)
	wpmLabel.BackgroundTransparency = 1
	wpmLabel.TextColor3 = Color3.fromRGB(0, 255, 255) -- Cyan
	wpmLabel.Font = Enum.Font.GothamBold
	wpmLabel.TextScaled = true
	wpmLabel.Text = "WPM: 0"
	wpmLabel.Parent = statsFrame
	
	local accLabel = wpmLabel:Clone()
	accLabel.Position = UDim2.fromScale(0, 0.25)
	accLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	accLabel.Text = "ACC: 100%"
	accLabel.Parent = statsFrame
	
	local comboLabel = wpmLabel:Clone()
	comboLabel.Position = UDim2.fromScale(0, 0.5)
	comboLabel.TextColor3 = Color3.fromRGB(255, 100, 255) -- Neon Pink
	comboLabel.Text = "COMBO: x0"
	comboLabel.Parent = statsFrame
	
	-- Save references
	elements.textDisplay = textDisplay
	elements.wpmLabel = wpmLabel
	elements.accLabel = accLabel
	elements.comboLabel = comboLabel
	
	screenGui.Parent = playerGui
	
	-- Bind to controller
	ClientMatchController.OnUIUpdateRequired = function(wpm, accuracy, combo)
		wpmLabel.Text = "WPM: " .. tostring(wpm)
		accLabel.Text = "ACC: " .. tostring(accuracy) .. "%"
		comboLabel.Text = "COMBO: x" .. tostring(combo)
	end
	
	ClientMatchController.OnTextProgressRequired = function(typed, remaining)
		-- Using RichText to highlight typed portion (e.g. purple highlight)
		textDisplay.Text = string.format("<font color=\"#8A2BE2\">%s</font>%s", typed, remaining)
	end
	
	ClientMatchController.OnMatchEnded = function(winnerName)
		textDisplay.Text = "WINNER: " .. winnerName
		-- Return to menu logic after a delay can be added here
	end
end

function MatchUIController.Unmount()
	if screenGui then
		screenGui:Destroy()
		screenGui = nil
		elements = {}
	end
end

return MatchUIController
