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
	local camera = workspace.CurrentCamera
	
	-- Hide and freeze player character
	if player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
		end
		
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
				part.Transparency = 1
			end
		end
	end
	
	-- Lock camera to center
	camera.CFrame = CFrame.new(0, 10, 15)
	camera.CameraType = Enum.CameraType.Fixed
	
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
	
	-- Countdown Timer (Above typing area)
	local countdownLabel = Instance.new("TextLabel")
	countdownLabel.Name = "CountdownLabel"
	countdownLabel.Size = UDim2.fromScale(0.3, 0.1)
	countdownLabel.Position = UDim2.fromScale(0.35, 0.2)
	countdownLabel.BackgroundTransparency = 1
	countdownLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
	countdownLabel.TextScaled = true
	countdownLabel.Font = Enum.Font.GothamBlack
	countdownLabel.Text = "5"
	countdownLabel.Parent = hud
	
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
	elements.countdownLabel = countdownLabel
	
	screenGui.Parent = playerGui
	
	-- Bind to controller
	ClientMatchController.OnUIUpdateRequired = function(wpm, accuracy, combo)
		wpmLabel.Text = "WPM: " .. tostring(wpm)
		accLabel.Text = "ACC: " .. tostring(accuracy) .. "%"
		comboLabel.Text = "COMBO: x" .. tostring(combo)
	end
	
	ClientMatchController.OnTextProgressRequired = function(typed, remaining, mistakeIndices)
		-- Build colored text with mistakes in red
		local typedWithColor = ""
		for i = 1, string.len(typed) do
			local char = string.sub(typed, i, i)
			if mistakeIndices and mistakeIndices[i] then
				typedWithColor = typedWithColor .. "<font color=\"#FF0000\">" .. char .. "</font>"
			else
				typedWithColor = typedWithColor .. "<font color=\"#8A2BE2\">" .. char .. "</font>"
			end
		end
		textDisplay.Text = typedWithColor .. remaining
	end
	
	ClientMatchController.OnCountdown = function(secondsRemaining)
		if secondsRemaining > 0 then
			countdownLabel.Text = tostring(secondsRemaining)
		else
			countdownLabel.Text = "GO!"
			task.wait(0.5)
			countdownLabel.Visible = false
		end
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
	
	-- Restore player character and movement
	local player = Players.LocalPlayer
	local camera = workspace.CurrentCamera
	
	if player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
		end
		
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = true
				part.Transparency = 0
			end
		end
	end
	
	-- Restore camera
	camera.CameraType = Enum.CameraType.Custom
end

return MatchUIController
