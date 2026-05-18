-- MatchUIController.lua
-- Scaffolds the In-Game HUD and wires to ClientMatchController.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local ClientMatchController = require(script.Parent.Parent.Controllers.ClientMatchController)
local KeyboardHandler = require(script.Parent.Parent.Input.KeyboardHandler)
local TypingFeedback = require(script.Parent.Parent.Effects.TypingFeedback)

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
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui
	
	-- HUD Container
	local hud = Instance.new("Frame")
	hud.Size = UDim2.fromScale(1, 1)
	hud.BackgroundTransparency = 1
	hud.Parent = screenGui
	
	-- Full screen background gradient for cinematic immersive feeling
	local fullBg = Instance.new("Frame")
	fullBg.Size = UDim2.fromScale(1, 1)
	fullBg.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
	fullBg.BorderSizePixel = 0
	fullBg.ZIndex = 0
	
	local fullBgGradient = Instance.new("UIGradient")
	fullBgGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 8, 16)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 30))
	})
	fullBgGradient.Rotation = 45
	fullBgGradient.Parent = fullBg
	fullBg.Parent = hud

	-- Countdown Timer (Above typing area)
	local countdownLabel = Instance.new("TextLabel")
	countdownLabel.Name = "CountdownLabel"
	countdownLabel.Size = UDim2.fromScale(0.3, 0.12)
	countdownLabel.Position = UDim2.fromScale(0.35, 0.18)
	countdownLabel.BackgroundTransparency = 1
	countdownLabel.TextColor3 = Color3.fromRGB(255, 180, 0) -- Rich glowing orange
	countdownLabel.TextScaled = true
	countdownLabel.Font = Enum.Font.GothamBlack
	countdownLabel.Text = "3"
	countdownLabel.ZIndex = 3
	
	local countdownStroke = Instance.new("UIStroke")
	countdownStroke.Color = Color3.fromRGB(0, 0, 0)
	countdownStroke.Thickness = 3
	countdownStroke.Parent = countdownLabel
	countdownLabel.Parent = hud
	
	-- Typing Area (Center)
	local typingFrame = Instance.new("Frame")
	typingFrame.Size = UDim2.fromScale(0.6, 0.28)
	typingFrame.Position = UDim2.fromScale(0.2, 0.38)
	typingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	typingFrame.BackgroundTransparency = 0.1
	typingFrame.ZIndex = 2
	
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 16)
	uiCorner.Parent = typingFrame
	
	local typingStroke = Instance.new("UIStroke")
	typingStroke.Thickness = 2.5
	typingStroke.Parent = typingFrame

	-- Dual border stroke gradient: Purple left, Gold right
	local strokeGradient = Instance.new("UIGradient")
	strokeGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)), -- Neon Purple
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 170, 0))   -- Neon Gold
	})
	strokeGradient.Parent = typingStroke

	local typingGradient = Instance.new("UIGradient")
	typingGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 22)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 20, 45))
	})
	typingGradient.Rotation = 15
	typingGradient.Parent = typingFrame
	typingFrame.Parent = hud
	
	-- VERSUS HEADER (Top Center) - Inspired by Ranked 1v1 screen layout
	local versusHeader = Instance.new("Frame")
	versusHeader.Name = "VersusHeader"
	versusHeader.Size = UDim2.fromScale(1, 0.16)
	versusHeader.Position = UDim2.fromScale(0, 0.02)
	versusHeader.BackgroundTransparency = 1
	versusHeader.Parent = hud
	
	-- Center Container for Title, VS, and Pill Timer
	local centerContainer = Instance.new("Frame")
	centerContainer.Size = UDim2.fromScale(0.2, 1)
	centerContainer.Position = UDim2.fromScale(0.4, 0)
	centerContainer.BackgroundTransparency = 1
	centerContainer.Parent = versusHeader
	
	local titleLogo = Instance.new("TextLabel")
	titleLogo.Size = UDim2.fromScale(1, 0.25)
	titleLogo.Position = UDim2.fromScale(0, 0.05)
	titleLogo.Text = "👑 TYPEROYALE"
	titleLogo.Font = Enum.Font.GothamBlack
	titleLogo.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold Title
	titleLogo.TextScaled = true
	titleLogo.BackgroundTransparency = 1
	titleLogo.Parent = centerContainer
	
	local subtitleLogo = Instance.new("TextLabel")
	subtitleLogo.Size = UDim2.fromScale(1, 0.14)
	subtitleLogo.Position = UDim2.fromScale(0, 0.28)
	subtitleLogo.Text = "RANKED 1V1"
	subtitleLogo.Font = Enum.Font.GothamBold
	subtitleLogo.TextColor3 = Color3.fromRGB(150, 150, 180)
	subtitleLogo.TextScaled = true
	subtitleLogo.BackgroundTransparency = 1
	subtitleLogo.Parent = centerContainer
	
	local vsLabel = Instance.new("TextLabel")
	vsLabel.Size = UDim2.fromScale(1, 0.28)
	vsLabel.Position = UDim2.fromScale(0, 0.42)
	vsLabel.Text = "VS"
	vsLabel.Font = Enum.Font.GothamBlack
	vsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	vsLabel.TextScaled = true
	vsLabel.BackgroundTransparency = 1
	vsLabel.Parent = centerContainer
	
	local roundLabel = Instance.new("TextLabel")
	roundLabel.Size = UDim2.fromScale(1, 0.12)
	roundLabel.Position = UDim2.fromScale(0, 0.68)
	roundLabel.Text = "ROUND 1"
	roundLabel.Font = Enum.Font.GothamBold
	roundLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
	roundLabel.TextScaled = true
	roundLabel.BackgroundTransparency = 1
	roundLabel.Parent = centerContainer
	
	-- Timer Display Pill Box
	local timerBox = Instance.new("Frame")
	timerBox.Size = UDim2.fromScale(0.6, 0.18)
	timerBox.Position = UDim2.fromScale(0.2, 0.8)
	timerBox.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
	
	local tbCorner = Instance.new("UICorner")
	tbCorner.CornerRadius = UDim.new(0, 6)
	tbCorner.Parent = timerBox
	
	local tbStroke = Instance.new("UIStroke")
	tbStroke.Color = Color3.fromRGB(0, 170, 255) -- Cyan neon border
	tbStroke.Thickness = 1.5
	tbStroke.Parent = timerBox
	
	local timerLabel = Instance.new("TextLabel")
	timerLabel.Size = UDim2.fromScale(1, 0.8)
	timerLabel.Position = UDim2.fromScale(0, 0.1)
	timerLabel.Text = "0:00"
	timerLabel.Font = Enum.Font.GothamBold
	timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	timerLabel.TextScaled = true
	timerLabel.BackgroundTransparency = 1
	timerLabel.Parent = timerBox
	timerBox.Parent = centerContainer

	-- Left Competitor Panel (Player - Zenox)
	local leftCompetitor = Instance.new("Frame")
	leftCompetitor.Size = UDim2.fromScale(0.35, 1)
	leftCompetitor.Position = UDim2.fromScale(0.03, 0)
	leftCompetitor.BackgroundTransparency = 1
	leftCompetitor.Parent = versusHeader
	
	local leftAvatar = Instance.new("ImageLabel")
	leftAvatar.Size = UDim2.fromScale(0.24, 0.7)
	leftAvatar.Position = UDim2.fromScale(0, 0.1)
	leftAvatar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	leftAvatar.Image = "rbxassetid://13476313155" -- Roblox silhouette outline
	
	local laCorner = Instance.new("UICorner")
	laCorner.CornerRadius = UDim.new(0.5, 0)
	laCorner.Parent = leftAvatar
	
	local laStroke = Instance.new("UIStroke")
	laStroke.Color = Color3.fromRGB(138, 43, 226) -- Neon purple border
	laStroke.Thickness = 2.5
	laStroke.Parent = leftAvatar
	leftAvatar.Parent = leftCompetitor
	
	local leftUsername = Instance.new("TextLabel")
	leftUsername.Size = UDim2.fromScale(0.5, 0.2)
	leftUsername.Position = UDim2.fromScale(0.28, 0.15)
	leftUsername.Text = "Zenox"
	leftUsername.Font = Enum.Font.GothamBold
	leftUsername.TextColor3 = Color3.fromRGB(255, 255, 255)
	leftUsername.TextScaled = true
	leftUsername.TextXAlignment = Enum.TextXAlignment.Left
	leftUsername.BackgroundTransparency = 1
	leftUsername.Parent = leftCompetitor
	
	local leftRank = Instance.new("TextLabel")
	leftRank.Size = UDim2.fromScale(0.5, 0.14)
	leftRank.Position = UDim2.fromScale(0.28, 0.35)
	leftRank.Text = "💎 DIAMOND II"
	leftRank.Font = Enum.Font.GothamBold
	leftRank.TextColor3 = Color3.fromRGB(138, 43, 226)
	leftRank.TextScaled = true
	leftRank.TextXAlignment = Enum.TextXAlignment.Left
	leftRank.BackgroundTransparency = 1
	leftRank.Parent = leftCompetitor
	
	local leftBarBg = Instance.new("Frame")
	leftBarBg.Size = UDim2.fromScale(0.68, 0.15)
	leftBarBg.Position = UDim2.fromScale(0.28, 0.55)
	leftBarBg.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
	
	local lbBgCorner = Instance.new("UICorner")
	lbBgCorner.CornerRadius = UDim.new(0, 6)
	lbBgCorner.Parent = leftBarBg
	
	local lbBgStroke = Instance.new("UIStroke")
	lbBgStroke.Color = Color3.fromRGB(50, 40, 70)
	lbBgStroke.Thickness = 1
	lbBgStroke.Parent = leftBarBg
	
	local leftBarFill = Instance.new("Frame")
	leftBarFill.Size = UDim2.fromScale(0, 1)
	leftBarFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
	
	local lbfCorner = Instance.new("UICorner")
	lbfCorner.CornerRadius = UDim.new(0, 6)
	lbfCorner.Parent = leftBarFill
	
	local lbfGradient = Instance.new("UIGradient")
	lbfGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(186, 85, 211))
	})
	lbfGradient.Parent = leftBarFill
	leftBarFill.Parent = leftBarBg
	leftBarBg.Parent = leftCompetitor
	
	local leftPercent = Instance.new("TextLabel")
	leftPercent.Size = UDim2.fromScale(0.24, 0.4)
	leftPercent.Position = UDim2.fromScale(0.72, 0.15)
	leftPercent.Text = "0%"
	leftPercent.Font = Enum.Font.GothamBold
	leftPercent.TextColor3 = Color3.fromRGB(255, 255, 255)
	leftPercent.TextScaled = true
	leftPercent.TextXAlignment = Enum.TextXAlignment.Right
	leftPercent.BackgroundTransparency = 1
	leftPercent.Parent = leftCompetitor

	-- Right Competitor Panel (Bot - RapidKiller)
	local rightCompetitor = Instance.new("Frame")
	rightCompetitor.Size = UDim2.fromScale(0.35, 1)
	rightCompetitor.Position = UDim2.fromScale(0.62, 0)
	rightCompetitor.BackgroundTransparency = 1
	rightCompetitor.Parent = versusHeader
	
	local rightAvatar = Instance.new("ImageLabel")
	rightAvatar.Size = UDim2.fromScale(0.24, 0.7)
	rightAvatar.Position = UDim2.fromScale(0.76, 0.1)
	rightAvatar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	rightAvatar.Image = "rbxassetid://13476313155"
	
	local raCorner = Instance.new("UICorner")
	raCorner.CornerRadius = UDim.new(0.5, 0)
	raCorner.Parent = rightAvatar
	
	local raStroke = Instance.new("UIStroke")
	raStroke.Color = Color3.fromRGB(255, 170, 0) -- Neon gold border
	raStroke.Thickness = 2.5
	raStroke.Parent = rightAvatar
	rightAvatar.Parent = rightCompetitor
	
	local rightUsername = Instance.new("TextLabel")
	rightUsername.Size = UDim2.fromScale(0.5, 0.2)
	rightUsername.Position = UDim2.fromScale(0.22, 0.15)
	rightUsername.Text = "RapidKiller"
	rightUsername.Font = Enum.Font.GothamBold
	rightUsername.TextColor3 = Color3.fromRGB(255, 255, 255)
	rightUsername.TextScaled = true
	rightUsername.TextXAlignment = Enum.TextXAlignment.Right
	rightUsername.BackgroundTransparency = 1
	rightUsername.Parent = rightCompetitor
	
	local rightRank = Instance.new("TextLabel")
	rightRank.Size = UDim2.fromScale(0.5, 0.14)
	rightRank.Position = UDim2.fromScale(0.22, 0.35)
	rightRank.Text = "🏆 DIAMOND II"
	rightRank.Font = Enum.Font.GothamBold
	rightRank.TextColor3 = Color3.fromRGB(255, 170, 0)
	rightRank.TextScaled = true
	rightRank.TextXAlignment = Enum.TextXAlignment.Right
	rightRank.BackgroundTransparency = 1
	rightRank.Parent = rightCompetitor
	
	local rightBarBg = Instance.new("Frame")
	rightBarBg.Size = UDim2.fromScale(0.68, 0.15)
	rightBarBg.Position = UDim2.fromScale(0.04, 0.55)
	rightBarBg.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
	
	local rbBgCorner = Instance.new("UICorner")
	rbBgCorner.CornerRadius = UDim.new(0, 6)
	rbBgCorner.Parent = rightBarBg
	
	local rbBgStroke = Instance.new("UIStroke")
	rbBgStroke.Color = Color3.fromRGB(70, 50, 30)
	rbBgStroke.Thickness = 1
	rbBgStroke.Parent = rightBarBg
	
	local rightBarFill = Instance.new("Frame")
	rightBarFill.Size = UDim2.fromScale(0, 1)
	rightBarFill.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
	
	local rbfCorner = Instance.new("UICorner")
	rbfCorner.CornerRadius = UDim.new(0, 6)
	rbfCorner.Parent = rightBarFill
	
	local rbfGradient = Instance.new("UIGradient")
	rbfGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 140, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))
	})
	rbfGradient.Parent = rightBarFill
	rightBarFill.Parent = rightBarBg
	rightBarBg.Parent = rightCompetitor
	
	local rightPercent = Instance.new("TextLabel")
	rightPercent.Size = UDim2.fromScale(0.24, 0.4)
	rightPercent.Position = UDim2.fromScale(0.04, 0.15)
	rightPercent.Text = "0%"
	rightPercent.Font = Enum.Font.GothamBold
	rightPercent.TextColor3 = Color3.fromRGB(255, 255, 255)
	rightPercent.TextScaled = true
	rightPercent.TextXAlignment = Enum.TextXAlignment.Left
	rightPercent.BackgroundTransparency = 1
	rightPercent.Parent = rightCompetitor

	local practiceOptions = ClientMatchController.practiceOptions or {}
	if practiceOptions.mode == "Zen" then
		rightCompetitor.Visible = false
		leftUsername.Text = "Zenox (Zen)"
	end
	
	-- We need a RichText label to color the typed characters
	local textDisplay = Instance.new("TextLabel")
	textDisplay.Size = UDim2.fromScale(0.92, 0.88)
	textDisplay.Position = UDim2.fromScale(0.04, 0.06)
	textDisplay.BackgroundTransparency = 1
	textDisplay.TextColor3 = Color3.fromRGB(200, 200, 200)
	textDisplay.TextScaled = true
	textDisplay.Font = Enum.Font.Code -- Monospace is best for typing
	textDisplay.RichText = true
	textDisplay.TextXAlignment = Enum.TextXAlignment.Center
	textDisplay.TextYAlignment = Enum.TextYAlignment.Center
	textDisplay.ZIndex = 4
	textDisplay.Parent = typingFrame


	
	-- Stats Panel (Left Side) - Remodelled exactly like InGame.jpeg
	local statsFrame = Instance.new("Frame")
	statsFrame.Size = UDim2.fromScale(0.14, 0.32)
	statsFrame.Position = UDim2.fromScale(0.03, 0.3)
	statsFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
	statsFrame.BackgroundTransparency = 0.1
	statsFrame.ZIndex = 2
	
	local statsCorner = Instance.new("UICorner")
	statsCorner.CornerRadius = UDim.new(0, 12)
	statsCorner.Parent = statsFrame
	
	local statsStroke = Instance.new("UIStroke")
	statsStroke.Color = Color3.fromRGB(138, 43, 226) -- Glowing purple border
	statsStroke.Thickness = 1.5
	statsStroke.Parent = statsFrame

	local statsTitle = Instance.new("TextLabel")
	statsTitle.Size = UDim2.fromScale(0.9, 0.15)
	statsTitle.Position = UDim2.fromScale(0.05, 0.05)
	statsTitle.Text = "STATS"
	statsTitle.Font = Enum.Font.GothamBold
	statsTitle.TextColor3 = Color3.fromRGB(150, 150, 180)
	statsTitle.TextScaled = true
	statsTitle.BackgroundTransparency = 1
	statsTitle.Parent = statsFrame
	statsFrame.Parent = hud
	
	local wpmLabel = Instance.new("TextLabel")
	wpmLabel.Size = UDim2.fromScale(0.9, 0.16)
	wpmLabel.Position = UDim2.fromScale(0.05, 0.22)
	wpmLabel.BackgroundTransparency = 1
	wpmLabel.TextColor3 = Color3.fromRGB(0, 255, 255) -- Cyan
	wpmLabel.Font = Enum.Font.GothamBlack
	wpmLabel.TextScaled = true
	wpmLabel.Text = "WPM: 0"
	wpmLabel.ZIndex = 3
	wpmLabel.Parent = statsFrame
	
	local accLabel = wpmLabel:Clone()
	accLabel.Position = UDim2.fromScale(0.05, 0.4)
	accLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	accLabel.Text = "ACC: 100%"
	accLabel.Parent = statsFrame
	
	local comboLabel = wpmLabel:Clone()
	comboLabel.Position = UDim2.fromScale(0.05, 0.58)
	comboLabel.TextColor3 = Color3.fromRGB(255, 100, 255) -- Crimson-pink
	comboLabel.Text = "COMBO: x0"
	comboLabel.Parent = statsFrame
	
	local mistakesLabel = wpmLabel:Clone()
	mistakesLabel.Position = UDim2.fromScale(0.05, 0.76)
	mistakesLabel.TextColor3 = Color3.fromRGB(255, 50, 50) -- Red
	mistakesLabel.Text = "MISTAKES: 0"
	mistakesLabel.Parent = statsFrame
	
	-- BEST COMBO Card (separate lower panel)
	local bestComboCard = Instance.new("Frame")
	bestComboCard.Size = UDim2.fromScale(0.14, 0.1)
	bestComboCard.Position = UDim2.fromScale(0.03, 0.64)
	bestComboCard.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
	bestComboCard.BackgroundTransparency = 0.1
	bestComboCard.ZIndex = 2
	
	local bccCorner = Instance.new("UICorner")
	bccCorner.CornerRadius = UDim.new(0, 10)
	bccCorner.Parent = bestComboCard
	
	local bccStroke = Instance.new("UIStroke")
	bccStroke.Color = Color3.fromRGB(80, 50, 120)
	bccStroke.Thickness = 1
	bccStroke.Parent = bestComboCard
	
	local bccTitle = Instance.new("TextLabel")
	bccTitle.Size = UDim2.fromScale(0.9, 0.3)
	bccTitle.Position = UDim2.fromScale(0.05, 0.1)
	bccTitle.Text = "BEST COMBO"
	bccTitle.Font = Enum.Font.GothamBold
	bccTitle.TextColor3 = Color3.fromRGB(150, 150, 180)
	bccTitle.TextScaled = true
	bccTitle.BackgroundTransparency = 1
	bccTitle.Parent = bestComboCard
	
	local bestComboLabel = Instance.new("TextLabel")
	bestComboLabel.Size = UDim2.fromScale(0.9, 0.45)
	bestComboLabel.Position = UDim2.fromScale(0.05, 0.45)
	bestComboLabel.Text = "x0"
	bestComboLabel.Font = Enum.Font.GothamBlack
	bestComboLabel.TextColor3 = Color3.fromRGB(138, 43, 226) -- Glowing purple
	bestComboLabel.TextScaled = true
	bestComboLabel.BackgroundTransparency = 1
	bestComboLabel.Parent = bestComboCard
	bestComboCard.Parent = hud

	-- Right Info Panel (Ranked & Quests) - Symmetric Right columns
	local rightFrame = Instance.new("Frame")
	rightFrame.Size = UDim2.fromScale(0.14, 0.44)
	rightFrame.Position = UDim2.fromScale(0.83, 0.3)
	rightFrame.BackgroundTransparency = 1
	rightFrame.ZIndex = 2
	
	local rightLayout = Instance.new("UIListLayout")
	rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rightLayout.Padding = UDim.new(0, 10)
	rightLayout.Parent = rightFrame
	
	local rankedCard = Instance.new("Frame")
	rankedCard.Size = UDim2.fromScale(1, 0.5)
	rankedCard.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
	rankedCard.BackgroundTransparency = 0.1
	
	local rcCorner = Instance.new("UICorner")
	rcCorner.CornerRadius = UDim.new(0, 12)
	rcCorner.Parent = rankedCard
	
	local rcStroke = Instance.new("UIStroke")
	rcStroke.Color = Color3.fromRGB(138, 43, 226)
	rcStroke.Thickness = 1.5
	rcStroke.Parent = rankedCard
	
	local rcTitle = Instance.new("TextLabel")
	rcTitle.Size = UDim2.fromScale(0.9, 0.16)
	rcTitle.Position = UDim2.fromScale(0.05, 0.06)
	rcTitle.Text = "RANKED"
	rcTitle.Font = Enum.Font.GothamBold
	rcTitle.TextColor3 = Color3.fromRGB(150, 150, 180)
	rcTitle.TextScaled = true
	rcTitle.BackgroundTransparency = 1
	rcTitle.Parent = rankedCard
	
	local rcBadge = Instance.new("ImageLabel")
	rcBadge.Size = UDim2.fromScale(0.4, 0.44)
	rcBadge.Position = UDim2.fromScale(0.3, 0.22)
	rcBadge.Image = "rbxassetid://6031265977" -- Gem Badge
	rcBadge.BackgroundTransparency = 1
	rcBadge.Parent = rankedCard
	
	local rcName = Instance.new("TextLabel")
	rcName.Size = UDim2.fromScale(0.9, 0.12)
	rcName.Position = UDim2.fromScale(0.05, 0.68)
	rcName.Text = "DIAMOND II"
	rcName.Font = Enum.Font.GothamBold
	rcName.TextColor3 = Color3.fromRGB(255, 255, 255)
	rcName.TextScaled = true
	rcName.BackgroundTransparency = 1
	rcName.Parent = rankedCard
	
	local rcProgress = Instance.new("TextLabel")
	rcProgress.Size = UDim2.fromScale(0.9, 0.1)
	rcProgress.Position = UDim2.fromScale(0.05, 0.82)
	rcProgress.Text = "64/100 RP"
	rcProgress.Font = Enum.Font.GothamBold
	rcProgress.TextColor3 = Color3.fromRGB(138, 43, 226)
	rcProgress.TextScaled = true
	rcProgress.BackgroundTransparency = 1
	rcProgress.Parent = rankedCard
	rankedCard.Parent = rightFrame
	
	local questCard = Instance.new("Frame")
	questCard.Size = UDim2.fromScale(1, 0.46)
	questCard.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
	questCard.BackgroundTransparency = 0.1
	
	local qcCorner = Instance.new("UICorner")
	qcCorner.CornerRadius = UDim.new(0, 12)
	qcCorner.Parent = questCard
	
	local qcStroke = Instance.new("UIStroke")
	qcStroke.Color = Color3.fromRGB(255, 170, 0)
	qcStroke.Thickness = 1.5
	qcStroke.Parent = questCard
	
	local qcTitle = Instance.new("TextLabel")
	qcTitle.Size = UDim2.fromScale(0.9, 0.16)
	qcTitle.Position = UDim2.fromScale(0.05, 0.06)
	qcTitle.Text = "DAILY QUESTS"
	qcTitle.Font = Enum.Font.GothamBold
	qcTitle.TextColor3 = Color3.fromRGB(150, 150, 180)
	qcTitle.TextScaled = true
	qcTitle.BackgroundTransparency = 1
	qcTitle.Parent = questCard
	
	local function addQuestRow(name, progressStr, yPos, color)
		local qRow = Instance.new("TextLabel")
		qRow.Size = UDim2.fromScale(0.9, 0.16)
		qRow.Position = UDim2.fromScale(0.05, yPos)
		qRow.Text = name .. " (" .. progressStr .. ")"
		qRow.Font = Enum.Font.GothamBold
		qRow.TextColor3 = color or Color3.fromRGB(200, 200, 220)
		qRow.TextScaled = true
		qRow.TextXAlignment = Enum.TextXAlignment.Left
		qRow.BackgroundTransparency = 1
		qRow.Parent = questCard
	end
	
	addQuestRow("Win 3 matches", "2/3", 0.28, Color3.fromRGB(138, 43, 226))
	addQuestRow("Get 98% accuracy", "1/1 ✔", 0.5, Color3.fromRGB(0, 255, 150))
	addQuestRow("Type 1200 words", "750/1200", 0.72, Color3.fromRGB(255, 170, 0))
	questCard.Parent = rightFrame
	rightFrame.Parent = hud

	-- VIRTUAL KEYBOARD FRAME (Task 6.2 / Image polish) - Gorgeous interactive split glow keyboard
	local keyboardFrame = Instance.new("Frame")
	keyboardFrame.Name = "VirtualKeyboard"
	keyboardFrame.Size = UDim2.fromScale(0.52, 0.23)
	keyboardFrame.Position = UDim2.fromScale(0.24, 0.72)
	keyboardFrame.BackgroundTransparency = 1
	keyboardFrame.Parent = hud
	
	local keyRows = {
		{"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"},
		{"A", "S", "D", "F", "G", "H", "J", "K", "L"},
		{"Z", "X", "C", "V", "B", "N", "M"},
		{"SPACE"}
	}
	
	local keyFrames = {}
	
	for rowIndex, rowKeys in ipairs(keyRows) do
		local rowFrame = Instance.new("Frame")
		rowFrame.Size = UDim2.fromScale(1, 0.22)
		rowFrame.Position = UDim2.fromScale(0, (rowIndex - 1) * 0.25)
		rowFrame.BackgroundTransparency = 1
		rowFrame.Parent = keyboardFrame
		
		local numKeys = #rowKeys
		local keyWidth = 1 / 11
		local startX = (1 - (numKeys * keyWidth)) / 2
		
		if rowKeys[1] == "SPACE" then
			keyWidth = 0.5
			startX = 0.25
		end
		
		for keyIndex, keyChar in ipairs(rowKeys) do
			local keyBox = Instance.new("Frame")
			keyBox.Name = "Key_" .. keyChar
			keyBox.Size = UDim2.fromScale(keyWidth * 0.9, 0.9)
			keyBox.Position = UDim2.fromScale(startX + (keyIndex - 1) * keyWidth, 0.05)
			keyBox.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
			keyBox.BackgroundTransparency = 0.4
			
			local kbCorner = Instance.new("UICorner")
			kbCorner.CornerRadius = UDim.new(0, 4)
			kbCorner.Parent = keyBox
			
			local kbStroke = Instance.new("UIStroke")
			kbStroke.Thickness = 1
			local isLeftSide = (rowIndex <= 3 and keyIndex <= 5) or (rowKeys[1] == "SPACE")
			if isLeftSide then
				kbStroke.Color = Color3.fromRGB(80, 50, 120)
			else
				kbStroke.Color = Color3.fromRGB(120, 90, 40)
			end
			kbStroke.Parent = keyBox
			
			local keyLabel = Instance.new("TextLabel")
			keyLabel.Size = UDim2.fromScale(1, 0.8)
			keyLabel.Position = UDim2.fromScale(0, 0.1)
			keyLabel.Text = keyChar
			keyLabel.Font = Enum.Font.GothamBold
			keyLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
			keyLabel.TextScaled = true
			keyLabel.BackgroundTransparency = 1
			keyLabel.Parent = keyBox
			
			keyBox.Parent = rowFrame
			keyFrames[keyChar] = { box = keyBox, stroke = kbStroke, label = keyLabel, isLeftSide = isLeftSide }
		end
	end
	
	-- Save references
	elements.textDisplay = textDisplay
	elements.wpmLabel = wpmLabel
	elements.accLabel = accLabel
	elements.comboLabel = comboLabel
	elements.countdownLabel = countdownLabel
	elements.caretBox = nil
	
	screenGui.Parent = playerGui
	
	-- Bind to controller
	ClientMatchController.OnUIUpdateRequired = function(wpm, accuracy, combo)
		wpmLabel.Text = "WPM: " .. tostring(wpm)
		accLabel.Text = "ACC: " .. tostring(accuracy) .. "%"
		comboLabel.Text = "COMBO: x" .. tostring(combo)
		
		-- Count mistakes and best combo dynamically
		local stats = ClientMatchController.GetFinalStats()
		mistakesLabel.Text = "MISTAKES: " .. tostring(stats.mistakeCount)
		bestComboLabel.Text = "x" .. tostring(stats.maxCombo)
		
		-- Update live MM:SS match timer
		local minutes = math.floor(stats.duration / 60)
		local seconds = math.floor(stats.duration % 60)
		timerLabel.Text = string.format("%d:%02d", minutes, seconds)
		
		-- Subtle bounce effect on combo and WPM increase
		if combo > 0 then
			local originalSize = comboLabel.Size
			comboLabel.Size = UDim2.fromScale(wpmLabel.Size.X.Scale * 1.15, wpmLabel.Size.Y.Scale * 1.15)
			TweenService:Create(comboLabel, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = originalSize
			}):Play()
		end
	end
	
	ClientMatchController.OnOpponentProgress = function(botIndex, totalChars)
		local botProgress = totalChars > 0 and (botIndex / totalChars) or 0
		TweenService:Create(rightBarFill, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(botProgress, 1)
		}):Play()
		rightPercent.Text = tostring(math.floor(botProgress * 100)) .. "%"
	end
	
	ClientMatchController.OnKeyTypedVisual = function(keyName)
		local upperKey = string.upper(keyName)
		if upperKey == " " then upperKey = "SPACE" end
		
		local info = keyFrames[upperKey]
		if info then
			local flashColor = info.isLeftSide and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(255, 170, 0)
			local originalStrokeColor = info.stroke.Color
			
			info.box.BackgroundColor3 = flashColor
			info.box.BackgroundTransparency = 0.1
			info.stroke.Color = Color3.fromRGB(255, 255, 255)
			info.label.TextColor3 = Color3.fromRGB(255, 255, 255)
			
			task.delay(0.08, function()
				TweenService:Create(info.box, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundColor3 = Color3.fromRGB(15, 15, 25),
					BackgroundTransparency = 0.4
				}):Play()
				
				TweenService:Create(info.stroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Color = originalStrokeColor
				}):Play()
				
				TweenService:Create(info.label, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextColor3 = Color3.fromRGB(150, 150, 180)
				}):Play()
			end)
		end
	end
	
	ClientMatchController.OnTextProgressRequired = function(typed, remaining, mistakeIndices)
		-- Build colored text with mistakes in red
		local typedWithColor = ""
		for i = 1, string.len(typed) do
			local char = string.sub(typed, i, i)
			-- Escape special HTML tags for RichText compatibility if needed
			if char == "<" then char = "&lt;"
			elseif char == ">" then char = "&gt;"
			elseif char == "&" then char = "&amp;"
			end
			
			if mistakeIndices and mistakeIndices[i] then
				typedWithColor = typedWithColor .. "<font color=\"#FF0000\"><u>" .. char .. "</u></font>"
			else
				typedWithColor = typedWithColor .. "<font color=\"#8A2BE2\">" .. char .. "</font>"
			end
		end
		
		-- Safely escape remaining text as well
		local escapedRemaining = ""
		for i = 1, string.len(remaining) do
			local char = string.sub(remaining, i, i)
			if char == "<" then char = "&lt;"
			elseif char == ">" then char = "&gt;"
			elseif char == "&" then char = "&amp;"
			end
			escapedRemaining = escapedRemaining .. char
		end
		
		textDisplay.Text = typedWithColor .. escapedRemaining
		
		-- Update Caret Highlight Box (Task 2.4)
		local currentTypedIndex = string.len(typed)
		local currentTargetText = typed .. remaining
		local N = string.len(currentTargetText)
		
		-- Update Player Progress on head-to-head bar (Task 6.2)
		local progress = N > 0 and (currentTypedIndex / N) or 0
		TweenService:Create(leftBarFill, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(progress, 1)
		}):Play()
		leftPercent.Text = tostring(math.floor(progress * 100)) .. "%"
		

	end
	
	ClientMatchController.OnCountdown = function(secondsRemaining)
		countdownLabel.Visible = true
		if secondsRemaining > 0 then
			countdownLabel.Text = tostring(secondsRemaining)
		else
			countdownLabel.Text = "GO!"
			task.wait(0.5)
			countdownLabel.Visible = false
		end
	end
	
	ClientMatchController.OnMatchEnded = function(winnerName)
		local success, err = pcall(function()
			-- Clean up keyboard focus
			KeyboardHandler.Disable()
			
			-- Fetch final analytical stats from controller
			local stats = ClientMatchController.GetFinalStats()
			
			-- Cinematic Background Blur (Task 5 Polish)
			local Lighting = game:GetService("Lighting")
			local blur = Instance.new("BlurEffect")
			blur.Name = "ResultsBlur"
			blur.Size = 0
			blur.Parent = Lighting
			TweenService:Create(blur, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = 14
			}):Play()
			
			-- Create sleek dimmer background overlay
			local dimmer = Instance.new("Frame")
			dimmer.Name = "ResultsDimmer"
			dimmer.Size = UDim2.fromScale(1, 1)
			dimmer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			dimmer.BackgroundTransparency = 1
			dimmer.ZIndex = 19
			dimmer.Parent = screenGui
			
			TweenService:Create(dimmer, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.65
			}):Play()
			
			-- Create premium comparative results card frame (Esports double columns)
			local resultsModal = Instance.new("Frame")
			resultsModal.Name = "ResultsModal"
			resultsModal.Size = UDim2.fromScale(0.01, 0.01) -- start small for elastic scale intro
			resultsModal.Position = UDim2.fromScale(0.5, 0.5)
			resultsModal.AnchorPoint = Vector2.new(0.5, 0.5)
			resultsModal.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
			resultsModal.BorderSizePixel = 0
			resultsModal.ZIndex = 20
			resultsModal.Parent = screenGui -- Parented immediately!
			
			local modalCorner = Instance.new("UICorner")
			modalCorner.CornerRadius = UDim.new(0, 16)
			modalCorner.Parent = resultsModal
			
			local modalStroke = Instance.new("UIStroke")
			modalStroke.Thickness = 2.5
			modalStroke.Parent = resultsModal
			
			-- Spring Scale Intro Animation
			TweenService:Create(resultsModal, TweenInfo.new(0.65, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.fromScale(0.66, 0.74),
				Position = UDim2.fromScale(0.5, 0.5)
			}):Play()
		
		-- Title label
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.fromScale(0.8, 0.1)
		titleLabel.Position = UDim2.fromScale(0.1, 0.03)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Font = Enum.Font.GothamBlack
		titleLabel.TextScaled = true
		titleLabel.ZIndex = 21
		titleLabel.Parent = resultsModal
		
		local isWinner = (winnerName == "Player")
		if isWinner then
			titleLabel.Text = "VICTORY!"
			titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150) -- emerald green glow
			modalStroke.Color = Color3.fromRGB(0, 255, 150)
			TypingFeedback.PlayVictory()
			
			-- 2D Confetti Explosion (Dopamine Overload!)
			for i = 1, 45 do
				task.spawn(function()
					local p = Instance.new("Frame")
					p.Size = UDim2.fromOffset(math.random(6, 12), math.random(6, 12))
					p.Position = UDim2.fromScale(math.random(5, 95)/100, -0.05)
					p.BackgroundColor3 = Color3.fromHSV(math.random(), 0.8, 0.95)
					p.BorderSizePixel = 0
					p.ZIndex = 25
					p.Parent = screenGui
					
					local corner = Instance.new("UICorner")
					corner.CornerRadius = UDim.new(1, 0)
					corner.Parent = p
					
					local fallDuration = math.random(18, 32)/10
					local rotateTween = TweenService:Create(p, TweenInfo.new(fallDuration, Enum.EasingStyle.Linear), {
						Position = UDim2.fromScale(p.Position.X.Scale + (math.random(-15, 15)/100), 1.15),
						Rotation = math.random(360, 1080)
					})
					rotateTween:Play()
					
					task.wait(fallDuration - 0.5)
					TweenService:Create(p, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						BackgroundTransparency = 1
					}):Play()
					task.wait(0.5)
					p:Destroy()
				end)
			end
		else
			titleLabel.Text = "DEFEAT"
			titleLabel.TextColor3 = Color3.fromRGB(255, 50, 50) -- crimson red
			modalStroke.Color = Color3.fromRGB(255, 50, 50)
			TypingFeedback.PlayMistake()
		end
		
		-- Columns Container
		local columnsContainer = Instance.new("Frame")
		columnsContainer.Size = UDim2.fromScale(0.92, 0.52)
		columnsContainer.Position = UDim2.fromScale(0.04, 0.15)
		columnsContainer.BackgroundTransparency = 1
		columnsContainer.ZIndex = 21
		columnsContainer.Parent = resultsModal
		
		-- Helper to make comparative player columns
		local function createEsportsColumn(parent, headerText, isPlayer, themeColor, posScale)
			local col = Instance.new("Frame")
			col.Size = UDim2.fromScale(0.48, 1)
			col.Position = UDim2.fromScale(posScale, 0)
			col.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
			col.BackgroundTransparency = 0.3
			col.ZIndex = 21
			col.Parent = parent
			
			local colCorner = Instance.new("UICorner")
			colCorner.CornerRadius = UDim.new(0, 12)
			colCorner.Parent = col
			
			local colStroke = Instance.new("UIStroke")
			colStroke.Color = themeColor
			colStroke.Thickness = 1.5
			colStroke.Parent = col
			
			-- User Profile Frame
			local profileFrame = Instance.new("Frame")
			profileFrame.Size = UDim2.fromScale(0.9, 0.22)
			profileFrame.Position = UDim2.fromScale(0.05, 0.04)
			profileFrame.BackgroundTransparency = 1
			profileFrame.ZIndex = 22
			profileFrame.Parent = col
			
			local avatar = Instance.new("ImageLabel")
			avatar.Size = UDim2.fromScale(0.24, 0.85)
			avatar.Position = UDim2.fromScale(0.02, 0.08)
			avatar.Image = isPlayer and "rbxassetid://13476313155" or "rbxassetid://13476313437" -- Zenox vs RapidKiller
			avatar.BackgroundTransparency = 1
			avatar.ZIndex = 23
			avatar.Parent = profileFrame
			
			local avCorner = Instance.new("UICorner")
			avCorner.CornerRadius = UDim.new(1, 0)
			avCorner.Parent = avatar
			
			local avStroke = Instance.new("UIStroke")
			avStroke.Color = themeColor
			avStroke.Thickness = 2
			avStroke.Parent = avatar
			
			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.fromScale(0.68, 0.5)
			nameLabel.Position = UDim2.fromScale(0.3, 0.12)
			nameLabel.Text = headerText
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			nameLabel.TextScaled = true
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.BackgroundTransparency = 1
			nameLabel.ZIndex = 23
			nameLabel.Parent = profileFrame
			
			local rankLabel = Instance.new("TextLabel")
			rankLabel.Size = UDim2.fromScale(0.68, 0.35)
			rankLabel.Position = UDim2.fromScale(0.3, 0.58)
			rankLabel.Text = "DIAMOND II"
			rankLabel.Font = Enum.Font.GothamSemibold
			rankLabel.TextColor3 = isPlayer and Color3.fromRGB(150, 120, 220) or Color3.fromRGB(220, 180, 80)
			rankLabel.TextScaled = true
			rankLabel.TextXAlignment = Enum.TextXAlignment.Left
			rankLabel.BackgroundTransparency = 1
			rankLabel.ZIndex = 23
			rankLabel.Parent = profileFrame
			
			-- Stats Layout Stack inside column
			local statsStack = Instance.new("Frame")
			statsStack.Size = UDim2.fromScale(0.9, 0.68)
			statsStack.Position = UDim2.fromScale(0.05, 0.28)
			statsStack.BackgroundTransparency = 1
			statsStack.ZIndex = 22
			statsStack.Parent = col
			
			local stackLayout = Instance.new("UIListLayout")
			stackLayout.SortOrder = Enum.SortOrder.LayoutOrder
			stackLayout.Padding = UDim.new(0, 4)
			stackLayout.Parent = statsStack
			
			local function addColStat(name, finalVal, suffix, valColor)
				local statRow = Instance.new("Frame")
				statRow.Size = UDim2.fromScale(1, 0.17)
				statRow.BackgroundTransparency = 1
				statRow.ZIndex = 23
				statRow.Parent = statsStack
				
				local nLabel = Instance.new("TextLabel")
				nLabel.Size = UDim2.fromScale(0.55, 1)
				nLabel.Position = UDim2.fromScale(0.02, 0)
				nLabel.Text = name
				nLabel.Font = Enum.Font.GothamMedium
				nLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
				nLabel.TextScaled = true
				nLabel.TextXAlignment = Enum.TextXAlignment.Left
				nLabel.BackgroundTransparency = 1
				nLabel.ZIndex = 24
				nLabel.Parent = statRow
				
				local vLabel = Instance.new("TextLabel")
				vLabel.Size = UDim2.fromScale(0.4, 1)
				vLabel.Position = UDim2.fromScale(0.58, 0)
				vLabel.Text = "0" .. suffix -- start rolling from 0
				vLabel.Font = Enum.Font.GothamBlack
				vLabel.TextColor3 = valColor
				vLabel.TextScaled = true
				vLabel.TextXAlignment = Enum.TextXAlignment.Right
				vLabel.BackgroundTransparency = 1
				vLabel.ZIndex = 24
				vLabel.Parent = statRow
				
				-- Numerical roll up counter (Dopamine high)
				task.spawn(function()
					task.wait(0.3) -- stagger opening
					local steps = 22
					local rollDuration = 0.65
					local interval = rollDuration / steps
					for i = 1, steps do
						local current = math.floor((i / steps) * finalVal)
						vLabel.Text = tostring(current) .. suffix
						TypingFeedback.PlayCorrectHit(0)
						task.wait(interval)
					end
					vLabel.Text = tostring(finalVal) .. suffix
				end)
			end
			
			return addColStat
		end
		
		-- Setup Player stats
		local addPlayerStat = createEsportsColumn(columnsContainer, "Zenox (YOU)", true, Color3.fromRGB(0, 255, 150), 0)
		addPlayerStat("SPEED", stats.wpm, " WPM", Color3.fromRGB(0, 255, 255))
		addPlayerStat("ACCURACY", stats.accuracy, "%", Color3.fromRGB(255, 255, 255))
		addPlayerStat("MAX COMBO", stats.maxCombo, "x", Color3.fromRGB(255, 100, 255))
		addPlayerStat("KEYSTROKES", stats.totalKeystrokes, "", Color3.fromRGB(255, 200, 0))
		addPlayerStat("MISTAKES", stats.mistakeCount, "", Color3.fromRGB(255, 50, 50))
		
		-- Setup Simulated Bot stats dynamically based on chosen bot WPM difficulty
		local practiceOptions = ClientMatchController.practiceOptions or {}
		local speedName = practiceOptions.botSpeed or "Medium"
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local GameConfig = require(ReplicatedStorage.Shared.Constants.GameConfig)
		local baseBotWPM = GameConfig.Practice.BotSpeeds[speedName] or 60
		
		-- Generate highly realistic matched simulated stats for the bot column
		local botAccuracy = isWinner and math.random(84, 93) or math.random(96, 99)
		local botWPM = isWinner and math.floor(baseBotWPM * math.random(85, 96)/100) or math.floor(baseBotWPM * math.random(102, 115)/100)
		local botMaxCombo = math.floor(botWPM * (botAccuracy/100) * 0.3)
		local botKeystrokes = stats.totalKeystrokes
		local botMistakes = math.floor(botKeystrokes * (1 - (botAccuracy/100)))
		
		local addBotStat = createEsportsColumn(columnsContainer, "RapidKiller (BOT)", false, Color3.fromRGB(255, 100, 0), 0.52)
		addBotStat("SPEED", botWPM, " WPM", Color3.fromRGB(255, 200, 0))
		addBotStat("ACCURACY", botAccuracy, "%", Color3.fromRGB(255, 255, 255))
		addBotStat("MAX COMBO", botMaxCombo, "x", Color3.fromRGB(255, 120, 120))
		addBotStat("KEYSTROKES", botKeystrokes, "", Color3.fromRGB(200, 200, 200))
		addBotStat("MISTAKES", botMistakes, "", Color3.fromRGB(255, 50, 50))
		
		-- Center Rank Progress & RP Rewards Card (Task 10.4)
		local rankCard = Instance.new("Frame")
		rankCard.Size = UDim2.fromScale(0.92, 0.13)
		rankCard.Position = UDim2.fromScale(0.04, 0.69)
		rankCard.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
		rankCard.BackgroundTransparency = 0.5
		rankCard.ZIndex = 21
		rankCard.Parent = resultsModal
		
		local rcCorner = Instance.new("UICorner")
		rcCorner.CornerRadius = UDim.new(0, 10)
		rcCorner.Parent = rankCard
		
		local rcStroke = Instance.new("UIStroke")
		rcStroke.Color = Color3.fromRGB(138, 43, 226)
		rcStroke.Thickness = 1
		rcStroke.Parent = rankCard
		
		local rankIcon = Instance.new("ImageLabel")
		rankIcon.Size = UDim2.fromScale(0.08, 0.8)
		rankIcon.Position = UDim2.fromScale(0.03, 0.1)
		rankIcon.Image = "rbxassetid://13476313155" -- diamond badge
		rankIcon.BackgroundTransparency = 1
		rankIcon.ZIndex = 22
		rankIcon.Parent = rankCard
		
		local rankProgressTitle = Instance.new("TextLabel")
		rankProgressTitle.Size = UDim2.fromScale(0.2, 0.5)
		rankProgressTitle.Position = UDim2.fromScale(0.13, 0.25)
		rankProgressTitle.Text = "DIAMOND II"
		rankProgressTitle.Font = Enum.Font.GothamBold
		rankProgressTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
		rankProgressTitle.TextScaled = true
		rankProgressTitle.TextXAlignment = Enum.TextXAlignment.Left
		rankProgressTitle.BackgroundTransparency = 1
		rankProgressTitle.ZIndex = 22
		rankProgressTitle.Parent = rankCard
		
		-- Horizontal Progress Bar
		local barBg = Instance.new("Frame")
		barBg.Size = UDim2.fromScale(0.42, 0.3)
		barBg.Position = UDim2.fromScale(0.35, 0.35)
		barBg.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
		barBg.BorderSizePixel = 0
		barBg.ZIndex = 22
		barBg.Parent = rankCard
		
		local barCorner = Instance.new("UICorner")
		barCorner.CornerRadius = UDim.new(1, 0)
		barCorner.Parent = barBg
		
		local barFill = Instance.new("Frame")
		barFill.Size = UDim2.fromScale(0.64, 1) -- start at 64%
		barFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
		barFill.BorderSizePixel = 0
		barFill.ZIndex = 23
		barFill.Parent = barBg
		
		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(1, 0)
		fillCorner.Parent = barFill
		
		local fillGradient = Instance.new("UIGradient")
		fillGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))
		})
		fillGradient.Parent = barFill
		
		local barPercent = Instance.new("TextLabel")
		barPercent.Size = UDim2.fromScale(0.12, 0.5)
		barPercent.Position = UDim2.fromScale(0.79, 0.25)
		barPercent.Text = "64/100"
		barPercent.Font = Enum.Font.GothamBold
		barPercent.TextColor3 = Color3.fromRGB(255, 255, 255)
		barPercent.TextScaled = true
		barPercent.TextXAlignment = Enum.TextXAlignment.Left
		barPercent.BackgroundTransparency = 1
		barPercent.ZIndex = 22
		barPercent.Parent = rankCard
		
		-- Floating Reward RP Notification text
		local rpRewardLabel = Instance.new("TextLabel")
		rpRewardLabel.Size = UDim2.fromScale(0.16, 0.6)
		rpRewardLabel.Position = UDim2.fromScale(0.9, 0.2)
		rpRewardLabel.Text = isWinner and "+25 RP" or "-10 RP"
		rpRewardLabel.Font = Enum.Font.GothamBlack
		rpRewardLabel.TextColor3 = isWinner and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 80, 80)
		rpRewardLabel.TextScaled = true
		rpRewardLabel.BackgroundTransparency = 1
		rpRewardLabel.ZIndex = 22
		rpRewardLabel.Parent = rankCard
		
		-- Animate rating bar fill rewards on victory or loss! (Task 10.4)
		task.spawn(function()
			task.wait(1.0)
			local startRP = 64
			local gainedRP = isWinner and 25 or -10
			local endRP = startRP + gainedRP
			
			local barTween = TweenService:Create(barFill, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.fromScale(endRP / 100, 1)
			})
			barTween:Play()
			
			-- Count up rank points text
			local steps = 15
			for i = 1, steps do
				local curr = math.floor(startRP + (i / steps) * gainedRP)
				barPercent.Text = tostring(curr) .. "/100"
				task.wait(0.04)
			end
			barPercent.Text = tostring(endRP) .. "/100"
			
			-- Floater bounce
			rpRewardLabel:TweenPosition(UDim2.fromScale(0.9, -0.2), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.4, true)
		end)
		
		-- Button Container
		local btnFrame = Instance.new("Frame")
		btnFrame.Size = UDim2.fromScale(0.92, 0.08)
		btnFrame.Position = UDim2.fromScale(0.04, 0.86)
		btnFrame.BackgroundTransparency = 1
		btnFrame.ZIndex = 21
		btnFrame.Parent = resultsModal
		
		local function makeBtn(text, size, position, activeColor)
			local btn = Instance.new("TextButton")
			btn.Size = size
			btn.Position = position
			btn.Text = text
			btn.Font = Enum.Font.GothamBold
			btn.TextScaled = true
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.BackgroundColor3 = activeColor
			btn.ZIndex = 22
			
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = btn
			
			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(255, 255, 255)
			stroke.Thickness = 1
			stroke.Parent = btn
			
			btn.Parent = btnFrame
			return btn
		end
		
		local retryBtn = makeBtn("RETRY MATCH", UDim2.fromScale(0.46, 1), UDim2.fromScale(0, 0), Color3.fromRGB(0, 170, 255))
		local lobbyBtn = makeBtn("MAIN MENU", UDim2.fromScale(0.46, 1), UDim2.fromScale(0.54, 0), Color3.fromRGB(40, 40, 50))
		
		retryBtn.MouseButton1Click:Connect(function()
			local blur = game:GetService("Lighting"):FindFirstChild("ResultsBlur")
			if blur then blur:Destroy() end
			dimmer:Destroy()
			resultsModal:Destroy()
			ClientMatchController.RetryMatch()
		end)
		
		lobbyBtn.MouseButton1Click:Connect(function()
			local blur = game:GetService("Lighting"):FindFirstChild("ResultsBlur")
			if blur then blur:Destroy() end
			dimmer:Destroy()
			resultsModal:Destroy()
			local MainMenuController = require(script.Parent.MainMenuController)
			MatchUIController.Unmount()
			MainMenuController.Mount()
		end)
		end)
		if not success then
			warn("[MatchUIController] Critical error inside results modal generator: " .. tostring(err))
		end
	end
end

function MatchUIController.Unmount()
	local blur = game:GetService("Lighting"):FindFirstChild("ResultsBlur")
	if blur then blur:Destroy() end
	
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
