-- MainMenuController.lua
-- Scaffolds the dual-screen First Time User Experience (FTUE) and Esports Dashboard Main Menu.
-- Designed with 100% responsiveness, glowing borders, custom vectors, and rich micro-animations.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ClientMatchController = require(script.Parent.Parent.Controllers.ClientMatchController)
local MatchUIController = require(script.Parent.MatchUIController)

local MainMenuController = {}
local screenGui
local ftueCanvas
local dashboardCanvas

local FTUE_BACKGROUND_IMAGE_ID = "rbxassetid://136934488898007"
local FTUE_MUSIC_ID = "rbxassetid://120763440929151"

-- Interactive premium hover and click sounds
local AUDIO_ASSETS = {
	Hover = "rbxassetid://9114223192",      -- Tactile click
	Click = "rbxassetid://9086154861",      -- Heavy ignition sound
	ModalOpen = "rbxassetid://9084370217"  -- Celebratory win sound
}

local function playLocalSound(assetId, volume)
	local sound = Instance.new("Sound")
	sound.SoundId = assetId
	sound.Volume = volume or 0.5
	sound.Parent = SoundService
	SoundService:PlayLocalSound(sound)
	task.spawn(function()
		task.wait(2)
		sound:Destroy()
	end)
end

-- Helper to apply dynamic interactive scale-up & glow hover effects
local function applyInteractiveFeedback(element, baseSize, scaleMultiplier, glowStroke, activeColor)
	local originalColor = glowStroke and glowStroke.Color or nil
	local originalThickness = glowStroke and glowStroke.Thickness or nil
	
	element.MouseEnter:Connect(function()
		playLocalSound(AUDIO_ASSETS.Hover, 0.3)
		TweenService:Create(element, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(baseSize.X.Scale * scaleMultiplier, baseSize.Y.Scale * scaleMultiplier)
		}):Play()
		
		if glowStroke and activeColor then
			TweenService:Create(glowStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Color = activeColor,
				Thickness = originalThickness * 1.5
			}):Play()
		end
	end)
	
	element.MouseLeave:Connect(function()
		TweenService:Create(element, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = baseSize
		}):Play()
		
		if glowStroke and originalColor then
			TweenService:Create(glowStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Color = originalColor,
				Thickness = originalThickness
			}):Play()
		end
	end)
end

function MainMenuController.Mount()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Disable Roblox topbar, chat window, and core HUDs for premium, full-screen immersion
	local StarterGui = game:GetService("StarterGui")
	task.spawn(function()
		local success = false
		for i = 1, 10 do
			local ok = pcall(function()
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
			end)
			if ok then
				success = true
				break
			end
			task.wait(0.2)
		end
	end)
	
	-- Clear pre-existing menu HUD elements
	if playerGui:FindFirstChild("TypeRoyaleMenu") then
		playerGui.TypeRoyaleMenu:Destroy()
	end
	
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TypeRoyaleMenu"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	
	-- Global space-navy backdrop canvas frame
	local globalBackdrop = Instance.new("Frame")
	globalBackdrop.Name = "GlobalBackdrop"
	globalBackdrop.Size = UDim2.fromScale(1, 1)
	globalBackdrop.BackgroundColor3 = Color3.fromRGB(8, 8, 15) -- Ultra deep navy darkspace
	globalBackdrop.BorderSizePixel = 0
	globalBackdrop.Parent = screenGui
	
	-- Ambient background lighting decoration (subtle cyan/purple corner glow vignetting)
	local purpleGlow = Instance.new("ImageLabel")
	purpleGlow.Size = UDim2.fromScale(0.5, 0.8)
	purpleGlow.Position = UDim2.fromScale(-0.1, -0.1)
	purpleGlow.Image = "rbxassetid://13476313155" -- soft radial glow asset
	purpleGlow.ImageColor3 = Color3.fromRGB(138, 43, 226)
	purpleGlow.ImageTransparency = 0.85
	purpleGlow.BackgroundTransparency = 1
	purpleGlow.Parent = globalBackdrop
	
	local goldGlow = purpleGlow:Clone()
	goldGlow.Position = UDim2.fromScale(0.6, 0.3)
	goldGlow.ImageColor3 = Color3.fromRGB(255, 170, 0)
	goldGlow.Parent = globalBackdrop
	
	-------------------------------------------------------------
	-- SCREEN 1: FTUE SPLASH CANVAS (Ref. FTUEscreen.jpeg)
	-------------------------------------------------------------
	ftueCanvas = Instance.new("CanvasGroup")
	ftueCanvas.Name = "FTUECanvas"
	ftueCanvas.Size = UDim2.fromScale(1, 1)
	ftueCanvas.BackgroundTransparency = 1
	ftueCanvas.ZIndex = 2
	ftueCanvas.Parent = globalBackdrop
	
	-- Fullscreen FTUE background image (Ref. FTUE1080x1920.png)
	local ftueBackground = Instance.new("ImageLabel")
	ftueBackground.Name = "FTUEBackground"
	ftueBackground.Size = UDim2.fromScale(1, 1)
	ftueBackground.Position = UDim2.fromScale(0, 0)
	ftueBackground.Image = FTUE_BACKGROUND_IMAGE_ID
	ftueBackground.ScaleType = Enum.ScaleType.Crop
	ftueBackground.BackgroundTransparency = 1
	ftueBackground.ZIndex = 1
	ftueBackground.Parent = ftueCanvas
	
	-- Central "PLAY NOW" Button — styled exactly after FTUEscreen.jpeg
	-- Wide pill shape, deep dark-purple fill, vivid violet glow border, bold white text
	local playNowBtn = Instance.new("TextButton")
	playNowBtn.Name = "PlayNowButton"
	-- Wide pill aspect ratio: ~3.5:1 width-to-height, anchored dead center
	local playNowSize = UDim2.fromScale(0.26, 0.075)
	playNowBtn.Size = playNowSize
	playNowBtn.Position = UDim2.fromScale(0.37, 0.62) -- vertically centered on the image
	playNowBtn.AnchorPoint = Vector2.new(0, 0)
	playNowBtn.BackgroundColor3 = Color3.fromRGB(52, 20, 90)  -- Deep rich dark violet (matches ref)
	playNowBtn.BorderSizePixel = 0
	playNowBtn.Text = "PLAY NOW"
	playNowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	playNowBtn.Font = Enum.Font.GothamBlack
	playNowBtn.TextScaled = true
	playNowBtn.ZIndex = 3

	-- Fully rounded pill corners (CornerRadius 0.5 = perfect pill)
	local pCorner = Instance.new("UICorner")
	pCorner.CornerRadius = UDim.new(0.5, 0)
	pCorner.Parent = playNowBtn

	-- Vivid violet glow border matching the reference image
	local pStroke = Instance.new("UIStroke")
	pStroke.Color = Color3.fromRGB(160, 60, 255) -- bright violet
	pStroke.Thickness = 3
	pStroke.Parent = playNowBtn

	playNowBtn.Parent = ftueCanvas
	applyInteractiveFeedback(playNowBtn, playNowSize, 1.06, pStroke, Color3.fromRGB(200, 120, 255))

	-- FTUE ambient looping soundtrack
	local ftueMusic = Instance.new("Sound")
	ftueMusic.Name = "FTUEMusic"
	ftueMusic.SoundId = FTUE_MUSIC_ID
	ftueMusic.Volume = 0.7
	ftueMusic.Looped = true
	ftueMusic.RollOffMaxDistance = 0
	ftueMusic.Parent = SoundService
	SoundService:PlayLocalSound(ftueMusic)
	
	-------------------------------------------------------------
	-- SCREEN 2: MAIN MENU DASHBOARD CANVAS (Ref. MenuUI.jpeg)
	-------------------------------------------------------------
	dashboardCanvas = Instance.new("CanvasGroup")
	dashboardCanvas.Name = "DashboardCanvas"
	dashboardCanvas.Size = UDim2.fromScale(1, 1)
	dashboardCanvas.BackgroundTransparency = 1
	dashboardCanvas.ZIndex = 1
	dashboardCanvas.GroupTransparency = 1 -- Hidden initially!
	dashboardCanvas.Parent = globalBackdrop
	
	-- 2.1 Left Sidebar Navigation Panel
	local sidebar = Instance.new("Frame")
	sidebar.Name = "LeftSidebar"
	sidebar.Size = UDim2.fromScale(0.15, 0.96)
	sidebar.Position = UDim2.fromScale(0.015, 0.02)
	sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
	sidebar.BackgroundTransparency = 0.4
	sidebar.Parent = dashboardCanvas
	
	local sbCorner = Instance.new("UICorner")
	sbCorner.CornerRadius = UDim.new(0, 16)
	sbCorner.Parent = sidebar
	
	local sbStroke = Instance.new("UIStroke")
	sbStroke.Color = Color3.fromRGB(35, 35, 55)
	sbStroke.Thickness = 1.5
	sbStroke.Parent = sidebar
	
	-- Sidebar Logo title header
	local sbLogo = Instance.new("TextLabel")
	sbLogo.Size = UDim2.fromScale(0.9, 0.06)
	sbLogo.Position = UDim2.fromScale(0.05, 0.03)
	sbLogo.BackgroundTransparency = 1
	sbLogo.Text = "⚡ TYPE ROYALE"
	sbLogo.TextColor3 = Color3.fromRGB(255, 200, 0)
	sbLogo.Font = Enum.Font.GothamBlack
	sbLogo.TextScaled = true
	sbLogo.Parent = sidebar
	
	-- Navigation Vertical Scroll List
	local navScroll = Instance.new("ScrollingFrame")
	navScroll.Size = UDim2.fromScale(0.9, 0.76)
	navScroll.Position = UDim2.fromScale(0.05, 0.11)
	navScroll.BackgroundTransparency = 1
	navScroll.BorderSizePixel = 0
	navScroll.CanvasSize = UDim2.fromScale(0, 1.1)
	navScroll.ScrollBarThickness = 2
	navScroll.Parent = sidebar
	
	local navLayout = Instance.new("UIListLayout")
	navLayout.Padding = UDim.new(0.012, 0)
	navLayout.Parent = navScroll
	
	local function createNavBtn(name, isHighlighted)
		local btn = Instance.new("TextButton")
		local btnSize = UDim2.fromScale(1, 0.075)
		btn.Size = btnSize
		btn.BackgroundColor3 = isHighlighted and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(20, 20, 30)
		btn.BackgroundTransparency = isHighlighted and 0.2 or 0.5
		btn.Text = "   " .. name
		btn.TextColor3 = isHighlighted and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 185)
		btn.Font = Enum.Font.GothamBold
		btn.TextScaled = true
		btn.TextXAlignment = Enum.TextXAlignment.Left
		
		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 8)
		bCorner.Parent = btn
		
		local bStroke = Instance.new("UIStroke")
		bStroke.Color = isHighlighted and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 55)
		bStroke.Thickness = 1
		bStroke.Parent = btn
		
		btn.Parent = navScroll
		applyInteractiveFeedback(btn, btnSize, 1.04, bStroke, Color3.fromRGB(0, 255, 255))
		return btn
	end
	
	createNavBtn("HOME", true)
	createNavBtn("PLAY MATCH", false)
	createNavBtn("RANKED 1V1", false)
	createNavBtn("PRACTICE ARENA", false)
	createNavBtn("CUSTOM MODE", false)
	createNavBtn("EMOTES SHOP", false)
	createNavBtn("KEYBOARD SKINS", false)
	createNavBtn("PLAYER PROFILE", false)
	createNavBtn("LEADERBOARD", false)
	
	-- Sidebar Bottom Icons
	local sbBottomRow = Instance.new("Frame")
	sbBottomRow.Size = UDim2.fromScale(0.9, 0.06)
	sbBottomRow.Position = UDim2.fromScale(0.05, 0.89)
	sbBottomRow.BackgroundTransparency = 1
	sbBottomRow.Parent = sidebar
	
	local sbRowLayout = Instance.new("UIListLayout")
	sbRowLayout.FillDirection = Enum.FillDirection.Horizontal
	sbRowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	sbRowLayout.Padding = UDim.new(0.12, 0)
	sbRowLayout.Parent = sbBottomRow
	
	local function createSbIcon(symbol, color)
		local icon = Instance.new("TextButton")
		local iconSize = UDim2.fromScale(0.24, 1)
		icon.Size = iconSize
		icon.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
		icon.Text = symbol
		icon.TextColor3 = color
		icon.TextScaled = true
		icon.Font = Enum.Font.GothamBlack
		
		local iCorner = Instance.new("UICorner")
		iCorner.CornerRadius = UDim.new(1, 0)
		iCorner.Parent = icon
		
		icon.Parent = sbBottomRow
		applyInteractiveFeedback(icon, iconSize, 1.15, nil, nil)
	end
	
	createSbIcon("💬", Color3.fromRGB(88, 101, 242)) -- Discord Blue
	createSbIcon("👥", Color3.fromRGB(0, 255, 120)) -- Friends green
	createSbIcon("🚪", Color3.fromRGB(255, 50, 50))  -- Exit red
	
	-- 2.2 Top Header (Season Pass & Currencies)
	local topHeader = Instance.new("Frame")
	topHeader.Size = UDim2.fromScale(0.63, 0.09)
	topHeader.Position = UDim2.fromScale(0.18, 0.02)
	topHeader.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
	topHeader.BackgroundTransparency = 0.4
	topHeader.Parent = dashboardCanvas
	
	local thCorner = Instance.new("UICorner")
	thCorner.CornerRadius = UDim.new(0, 14)
	thCorner.Parent = topHeader
	
	local thStroke = Instance.new("UIStroke")
	thStroke.Color = Color3.fromRGB(35, 35, 55)
	thStroke.Thickness = 1.5
	thStroke.Parent = topHeader
	
	-- Season Pass level display
	local passLogo = Instance.new("TextLabel")
	passLogo.Size = UDim2.fromScale(0.32, 0.6)
	passLogo.Position = UDim2.fromScale(0.02, 0.2)
	passLogo.BackgroundTransparency = 1
	passLogo.Text = "👑 SEASON 1 PASS (Level 23)"
	passLogo.TextColor3 = Color3.fromRGB(255, 255, 255)
	passLogo.Font = Enum.Font.GothamBold
	passLogo.TextScaled = true
	passLogo.TextXAlignment = Enum.TextXAlignment.Left
	passLogo.Parent = topHeader
	
	-- Gold coins display
	local goldSlot = Instance.new("Frame")
	goldSlot.Size = UDim2.fromScale(0.16, 0.7)
	goldSlot.Position = UDim2.fromScale(0.55, 0.15)
	goldSlot.BackgroundColor3 = Color3.fromRGB(25, 20, 15)
	goldSlot.Parent = topHeader
	
	local gsCorner = Instance.new("UICorner")
	gsCorner.CornerRadius = UDim.new(0, 8)
	gsCorner.Parent = goldSlot
	
	local gsLabel = Instance.new("TextLabel")
	gsLabel.Size = UDim2.fromScale(0.9, 0.7)
	gsLabel.Position = UDim2.fromScale(0.05, 0.15)
	gsLabel.BackgroundTransparency = 1
	gsLabel.Text = "🪙 12,450"
	gsLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
	gsLabel.Font = Enum.Font.GothamBold
	gsLabel.TextScaled = true
	gsLabel.Parent = goldSlot
	
	-- Purple Gems display
	local gemSlot = Instance.new("Frame")
	gemSlot.Size = UDim2.fromScale(0.14, 0.7)
	gemSlot.Position = UDim2.fromScale(0.73, 0.15)
	gemSlot.BackgroundColor3 = Color3.fromRGB(25, 15, 35)
	gemSlot.Parent = topHeader
	
	local gemCorner = Instance.new("UICorner")
	gemCorner.CornerRadius = UDim.new(0, 8)
	gemCorner.Parent = gemSlot
	
	local gemLabel = Instance.new("TextLabel")
	gemLabel.Size = UDim2.fromScale(0.9, 0.7)
	gemLabel.Position = UDim2.fromScale(0.05, 0.15)
	gemLabel.BackgroundTransparency = 1
	gemLabel.Text = "💎 1,270"
	gemLabel.TextColor3 = Color3.fromRGB(200, 100, 255)
	gemLabel.Font = Enum.Font.GothamBold
	gemLabel.TextScaled = true
	gemLabel.Parent = gemSlot
	
	-- Utility gears/bell buttons
	local utilRow = Instance.new("Frame")
	utilRow.Size = UDim2.fromScale(0.08, 0.7)
	utilRow.Position = UDim2.fromScale(0.90, 0.15)
	utilRow.BackgroundTransparency = 1
	utilRow.Parent = topHeader
	
	local utilLayout = Instance.new("UIListLayout")
	utilLayout.FillDirection = Enum.FillDirection.Horizontal
	utilLayout.Padding = UDim.new(0.2, 0)
	utilLayout.Parent = utilRow
	
	local function createUtilIcon(sym)
		local icon = Instance.new("TextButton")
		icon.Size = UDim2.fromScale(0.4, 1)
		icon.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
		icon.Text = sym
		icon.TextScaled = true
		
		local ic = Instance.new("UICorner")
		ic.CornerRadius = UDim.new(0, 6)
		ic.Parent = icon
		
		icon.Parent = utilRow
		applyInteractiveFeedback(icon, UDim2.fromScale(0.4, 1), 1.15, nil, nil)
	end
	
	createUtilIcon("🔔")
	createUtilIcon("⚙️")
	
	-- 2.3 MAIN CENTER MODES GRID (Choose Your Mode)
	local centerGrid = Instance.new("Frame")
	centerGrid.Size = UDim2.fromScale(0.63, 0.64)
	centerGrid.Position = UDim2.fromScale(0.18, 0.13)
	centerGrid.BackgroundTransparency = 1
	centerGrid.Parent = dashboardCanvas
	
	-- 1v1 Ranked Big Card (Left side)
	local rankedCard = Instance.new("Frame")
	local rcSize = UDim2.fromScale(0.48, 1)
	rankedCard.Size = rcSize
	rankedCard.Position = UDim2.fromScale(0, 0)
	rankedCard.BackgroundColor3 = Color3.fromRGB(15, 12, 28)
	rankedCard.BackgroundTransparency = 0.2
	rankedCard.Parent = centerGrid
	
	local rcCardCorner = Instance.new("UICorner")
	rcCardCorner.CornerRadius = UDim.new(0, 16)
	rcCardCorner.Parent = rankedCard
	
	local rcCardStroke = Instance.new("UIStroke")
	rcCardStroke.Color = Color3.fromRGB(138, 43, 226)
	rcCardStroke.Thickness = 2.5
	rcCardStroke.Parent = rankedCard
	applyInteractiveFeedback(rankedCard, rcSize, 1.02, rcCardStroke, Color3.fromRGB(0, 255, 255))
	
	-- Character neon graphic placeholder inside ranked card
	local rAvatarFrame = Instance.new("Frame")
	rAvatarFrame.Size = UDim2.fromScale(0.9, 0.44)
	rAvatarFrame.Position = UDim2.fromScale(0.05, 0.05)
	rAvatarFrame.BackgroundColor3 = Color3.fromRGB(22, 18, 38)
	rAvatarFrame.Parent = rankedCard
	
	local ravCorner = Instance.new("UICorner")
	ravCorner.CornerRadius = UDim.new(0, 10)
	ravCorner.Parent = rAvatarFrame
	
	local ravImage = Instance.new("ImageLabel")
	ravImage.Size = UDim2.fromScale(1, 1)
	ravImage.Image = "rbxassetid://13476313155" -- matching character avatar glow
	ravImage.ImageColor3 = Color3.fromRGB(138, 43, 226)
	ravImage.BackgroundTransparency = 1
	ravImage.Parent = rAvatarFrame
	
	local ravSwordText = Instance.new("TextLabel")
	ravSwordText.Size = UDim2.fromScale(0.5, 0.5)
	ravSwordText.Position = UDim2.fromScale(0.25, 0.25)
	ravSwordText.BackgroundTransparency = 1
	ravSwordText.Text = "⚔️"
	ravSwordText.TextScaled = true
	ravSwordText.Parent = rAvatarFrame
	
	local rcTitle = Instance.new("TextLabel")
	rcTitle.Size = UDim2.fromScale(0.9, 0.07)
	rcTitle.Position = UDim2.fromScale(0.05, 0.52)
	rcTitle.BackgroundTransparency = 1
	rcTitle.Text = "1V1 RANKED DUEL"
	rcTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	rcTitle.Font = Enum.Font.GothamBlack
	rcTitle.TextScaled = true
	rcTitle.TextXAlignment = Enum.TextXAlignment.Left
	rcTitle.Parent = rankedCard
	
	local rcDesc = Instance.new("TextLabel")
	rcDesc.Size = UDim2.fromScale(0.9, 0.12)
	rcDesc.Position = UDim2.fromScale(0.05, 0.6)
	rcDesc.BackgroundTransparency = 1
	rcDesc.Text = "Climb the rankings, defeat real-time opponents and prove you are the ultimate keycap speedmaster."
	rcDesc.TextColor3 = Color3.fromRGB(150, 150, 175)
	rcDesc.Font = Enum.Font.GothamMedium
	rcDesc.TextScaled = true
	rcDesc.TextWrapped = true
	rcDesc.TextXAlignment = Enum.TextXAlignment.Left
	rcDesc.Parent = rankedCard
	
	local rcTierLbl = Instance.new("TextLabel")
	rcTierLbl.Size = UDim2.fromScale(0.9, 0.065)
	rcTierLbl.Position = UDim2.fromScale(0.05, 0.74)
	rcTierLbl.BackgroundTransparency = 1
	rcTierLbl.Text = "🏆 CURRENT TIER: DIAMOND II"
	rcTierLbl.TextColor3 = Color3.fromRGB(0, 255, 150)
	rcTierLbl.Font = Enum.Font.GothamBold
	rcTierLbl.TextScaled = true
	rcTierLbl.TextXAlignment = Enum.TextXAlignment.Left
	rcTierLbl.Parent = rankedCard
	
	-- Large purple Ranked play button (connects to competitive queue search)
	local rcPlayBtn = Instance.new("TextButton")
	rcPlayBtn.Name = "PlayRankedButton"
	local rcPlaySize = UDim2.fromScale(0.9, 0.11)
	rcPlayBtn.Size = rcPlaySize
	rcPlayBtn.Position = UDim2.fromScale(0.05, 0.84)
	rcPlayBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
	rcPlayBtn.Text = "PLAY COMPETITIVE"
	rcPlayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	rcPlayBtn.Font = Enum.Font.GothamBlack
	rcPlayBtn.TextScaled = true
	
	local rcpCorner = Instance.new("UICorner")
	rcpCorner.CornerRadius = UDim.new(0, 8)
	rcpCorner.Parent = rcPlayBtn
	
	rcPlayBtn.Parent = rankedCard
	applyInteractiveFeedback(rcPlayBtn, rcPlaySize, 1.04, nil, nil)
	
	rcPlayBtn.MouseButton1Click:Connect(function()
		rcPlayBtn.Text = "SEARCHING QUEUE..."
		rcPlayBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		ClientMatchController.JoinQueue()
	end)
	
	-- Right column Stack for other game modes
	local modeStack = Instance.new("Frame")
	modeStack.Size = UDim2.fromScale(0.48, 1)
	modeStack.Position = UDim2.fromScale(0.52, 0)
	modeStack.BackgroundTransparency = 1
	modeStack.Parent = centerGrid
	
	local stackLayout = Instance.new("UIListLayout")
	stackLayout.Padding = UDim.new(0.038, 0)
	stackLayout.Parent = modeStack
	
	local function createStackModeCard(title, desc, symbol, strokeColor, activeThemeColor)
		local card = Instance.new("Frame")
		local cardSize = UDim2.fromScale(1, 0.30)
		card.Size = cardSize
		card.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
		card.BackgroundTransparency = 0.4
		
		local cCorner = Instance.new("UICorner")
		cCorner.CornerRadius = UDim.new(0, 14)
		cCorner.Parent = card
		
		local cStroke = Instance.new("UIStroke")
		cStroke.Color = strokeColor
		cStroke.Thickness = 1.5
		cStroke.Parent = card
		
		local iconLbl = Instance.new("TextLabel")
		iconLbl.Size = UDim2.fromScale(0.18, 0.7)
		iconLbl.Position = UDim2.fromScale(0.04, 0.15)
		iconLbl.BackgroundTransparency = 1
		iconLbl.Text = symbol
		iconLbl.TextScaled = true
		iconLbl.Parent = card
		
		local tLbl = Instance.new("TextLabel")
		tLbl.Size = UDim2.fromScale(0.45, 0.28)
		tLbl.Position = UDim2.fromScale(0.24, 0.16)
		tLbl.BackgroundTransparency = 1
		tLbl.Text = title
		tLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		tLbl.Font = Enum.Font.GothamBold
		tLbl.TextScaled = true
		tLbl.TextXAlignment = Enum.TextXAlignment.Left
		tLbl.Parent = card
		
		local dLbl = Instance.new("TextLabel")
		dLbl.Size = UDim2.fromScale(0.48, 0.4)
		dLbl.Position = UDim2.fromScale(0.24, 0.46)
		dLbl.BackgroundTransparency = 1
		dLbl.Text = desc
		dLbl.TextColor3 = Color3.fromRGB(140, 140, 160)
		dLbl.Font = Enum.Font.GothamMedium
		dLbl.TextScaled = true
		dLbl.TextWrapped = true
		dLbl.TextXAlignment = Enum.TextXAlignment.Left
		dLbl.Parent = card
		
		-- Small premium Play / Create button inside stack card
		local actionBtn = Instance.new("TextButton")
		local abSize = UDim2.fromScale(0.22, 0.4)
		actionBtn.Size = abSize
		actionBtn.Position = UDim2.fromScale(0.74, 0.3)
		actionBtn.BackgroundColor3 = activeThemeColor
		actionBtn.Text = (title == "CUSTOM ROOM") and "CREATE" or "PLAY"
		actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		actionBtn.Font = Enum.Font.GothamBlack
		actionBtn.TextScaled = true
		
		local abCorner = Instance.new("UICorner")
		abCorner.CornerRadius = UDim.new(0, 8)
		abCorner.Parent = actionBtn
		
		actionBtn.Parent = card
		applyInteractiveFeedback(actionBtn, abSize, 1.08, nil, nil)
		
		card.Parent = modeStack
		applyInteractiveFeedback(card, cardSize, 1.02, cStroke, Color3.fromRGB(255, 255, 255))
		
		return actionBtn
	end
	
	local brPlayBtn = createStackModeCard("BATTLE ROYALE", "8 typers enter. 1 keyboard champion survives.", "👥", Color3.fromRGB(255, 170, 0), Color3.fromRGB(255, 160, 0))
	local practicePlayBtn = createStackModeCard("PRACTICE ARENA", "Improve accuracy, test bots, analyze speed milestones.", "⚡", Color3.fromRGB(0, 255, 150), Color3.fromRGB(0, 170, 255))
	local customCreateBtn = createStackModeCard("CUSTOM ROOM", "Scaffold custom rooms and type against friends.", "🏠", Color3.fromRGB(150, 150, 170), Color3.fromRGB(0, 200, 100))
	
	-- 2.4 Right Side Panel (Profile, Challenges & Friends)
	local rightPanel = Instance.new("Frame")
	rightPanel.Name = "RightSidePanel"
	rightPanel.Size = UDim2.fromScale(0.16, 0.96)
	rightPanel.Position = UDim2.fromScale(0.825, 0.02)
	rightPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
	rightPanel.BackgroundTransparency = 0.4
	rightPanel.Parent = dashboardCanvas
	
	local rpCorner = Instance.new("UICorner")
	rpCorner.CornerRadius = UDim.new(0, 16)
	rpCorner.Parent = rightPanel
	
	local rpStroke = Instance.new("UIStroke")
	rpStroke.Color = Color3.fromRGB(35, 35, 55)
	rpStroke.Thickness = 1.5
	rpStroke.Parent = rightPanel
	
	-- Profile overview card
	local profileBox = Instance.new("Frame")
	profileBox.Size = UDim2.fromScale(0.9, 0.16)
	profileBox.Position = UDim2.fromScale(0.05, 0.03)
	profileBox.BackgroundTransparency = 1
	profileBox.Parent = rightPanel
	
	local pAvatar = Instance.new("ImageLabel")
	pAvatar.Size = UDim2.fromScale(0.3, 0.6)
	pAvatar.Position = UDim2.fromScale(0.05, 0.2)
	pAvatar.Image = "rbxassetid://13476313437" -- circular gold frame character
	pAvatar.BackgroundTransparency = 1
	pAvatar.Parent = profileBox
	
	local pCorner = Instance.new("UICorner")
	pCorner.CornerRadius = UDim.new(1, 0)
	pCorner.Parent = pAvatar
	
	local pName = Instance.new("TextLabel")
	pName.Size = UDim2.fromScale(0.55, 0.3)
	pName.Position = UDim2.fromScale(0.4, 0.2)
	pName.BackgroundTransparency = 1
	pName.Text = "Zenox ✏️"
	pName.TextColor3 = Color3.fromRGB(255, 255, 255)
	pName.Font = Enum.Font.GothamBold
	pName.TextScaled = true
	pName.TextXAlignment = Enum.TextXAlignment.Left
	pName.Parent = profileBox
	
	local pLevel = Instance.new("TextLabel")
	pLevel.Size = UDim2.fromScale(0.55, 0.25)
	pLevel.Position = UDim2.fromScale(0.4, 0.55)
	pLevel.BackgroundTransparency = 1
	pLevel.Text = "Level 23 Typer"
	pLevel.TextColor3 = Color3.fromRGB(150, 120, 220)
	pLevel.Font = Enum.Font.GothamSemibold
	pLevel.TextScaled = true
	pLevel.TextXAlignment = Enum.TextXAlignment.Left
	pLevel.Parent = profileBox
	
	-- Active Rank progress
	local rpRankBox = Instance.new("Frame")
	rpRankBox.Size = UDim2.fromScale(0.9, 0.12)
	rpRankBox.Position = UDim2.fromScale(0.05, 0.20)
	rpRankBox.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
	rpRankBox.Parent = rightPanel
	
	local rprCorner = Instance.new("UICorner")
	rprCorner.CornerRadius = UDim.new(0, 10)
	rprCorner.Parent = rpRankBox
	
	local rpBadgeIcon = Instance.new("TextLabel")
	rpBadgeIcon.Size = UDim2.fromScale(0.18, 0.6)
	rpBadgeIcon.Position = UDim2.fromScale(0.04, 0.2)
	rpBadgeIcon.BackgroundTransparency = 1
	rpBadgeIcon.Text = "💎"
	rpBadgeIcon.TextScaled = true
	rpBadgeIcon.Parent = rpRankBox
	
	local rpRankName = Instance.new("TextLabel")
	rpRankName.Size = UDim2.fromScale(0.7, 0.35)
	rpRankName.Position = UDim2.fromScale(0.24, 0.18)
	rpRankName.BackgroundTransparency = 1
	rpRankName.Text = "DIAMOND II"
	rpRankName.TextColor3 = Color3.fromRGB(255, 255, 255)
	rpRankName.Font = Enum.Font.GothamBold
	rpRankName.TextScaled = true
	rpRankName.TextXAlignment = Enum.TextXAlignment.Left
	rpRankName.Parent = rpRankBox
	
	local rpPointsBarBg = Instance.new("Frame")
	rpPointsBarBg.Size = UDim2.fromScale(0.7, 0.16)
	rpPointsBarBg.Position = UDim2.fromScale(0.24, 0.62)
	rpPointsBarBg.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
	rpPointsBarBg.BorderSizePixel = 0
	rpPointsBarBg.Parent = rpRankBox
	
	local rpPointsBarFill = Instance.new("Frame")
	rpPointsBarFill.Size = UDim2.fromScale(0.64, 1) -- 64 / 100 RP
	rpPointsBarFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
	rpPointsBarFill.BorderSizePixel = 0
	rpPointsBarFill.Parent = rpPointsBarBg
	
	-- Daily Challenges List Header
	local chalHeader = Instance.new("TextLabel")
	chalHeader.Size = UDim2.fromScale(0.9, 0.035)
	chalHeader.Position = UDim2.fromScale(0.05, 0.34)
	chalHeader.BackgroundTransparency = 1
	chalHeader.Text = "⚡ DAILY CHALLENGES"
	chalHeader.TextColor3 = Color3.fromRGB(255, 170, 0)
	chalHeader.Font = Enum.Font.GothamBold
	chalHeader.TextScaled = true
	chalHeader.TextXAlignment = Enum.TextXAlignment.Left
	chalHeader.Parent = rightPanel
	
	-- Challenges Container List
	local chList = Instance.new("Frame")
	chList.Size = UDim2.fromScale(0.9, 0.35)
	chList.Position = UDim2.fromScale(0.05, 0.39)
	chList.BackgroundTransparency = 1
	chList.Parent = rightPanel
	
	local chLayout = Instance.new("UIListLayout")
	chLayout.Padding = UDim.new(0.035, 0)
	chLayout.Parent = chList
	
	local function createDailyChallengeCard(desc, progressStr, isComplete)
		local card = Instance.new("Frame")
		card.Size = UDim2.fromScale(1, 0.28)
		card.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
		card.BackgroundTransparency = 0.5
		
		local cc = Instance.new("UICorner")
		cc.CornerRadius = UDim.new(0, 8)
		cc.Parent = card
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(0.9, 0.4)
		label.Position = UDim2.fromScale(0.05, 0.12)
		label.BackgroundTransparency = 1
		label.Text = desc
		label.TextColor3 = isComplete and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 220)
		label.Font = Enum.Font.GothamSemibold
		label.TextScaled = true
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = card
		
		local prog = Instance.new("TextLabel")
		prog.Size = UDim2.fromScale(0.9, 0.32)
		prog.Position = UDim2.fromScale(0.05, 0.55)
		prog.BackgroundTransparency = 1
		prog.Text = isComplete and "COMPLETED ✔️" or ("Progress: " .. progressStr)
		prog.TextColor3 = isComplete and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(150, 150, 160)
		prog.Font = Enum.Font.GothamMedium
		prog.TextScaled = true
		prog.TextXAlignment = Enum.TextXAlignment.Left
		prog.Parent = card
		
		card.Parent = chList
	end
	
	createDailyChallengeCard("Win 3 Matches", "2/3 Duel Matches", false)
	createDailyChallengeCard("Hit 98% Accuracy", "98.5% Record", true)
	createDailyChallengeCard("Type 1,200 Words", "750/1,200 Words", false)
	
	-- Online Friends List
	local friendsHeader = Instance.new("TextLabel")
	friendsHeader.Size = UDim2.fromScale(0.9, 0.035)
	friendsHeader.Position = UDim2.fromScale(0.05, 0.76)
	friendsHeader.BackgroundTransparency = 1
	friendsHeader.Text = "👥 FRIENDS ONLINE (5)"
	friendsHeader.TextColor3 = Color3.fromRGB(0, 255, 255)
	friendsHeader.Font = Enum.Font.GothamBold
	friendsHeader.TextScaled = true
	friendsHeader.TextXAlignment = Enum.TextXAlignment.Left
	friendsHeader.Parent = rightPanel
	
	local fList = Instance.new("Frame")
	fList.Size = UDim2.fromScale(0.9, 0.14)
	fList.Position = UDim2.fromScale(0.05, 0.81)
	fList.BackgroundTransparency = 1
	fList.Parent = rightPanel
	
	local fLayout = Instance.new("UIListLayout")
	fLayout.Padding = UDim.new(0.08, 0)
	fLayout.Parent = fList
	
	local function createFriendRow(name, status, isJoinable)
		local row = Instance.new("Frame")
		row.Size = UDim2.fromScale(1, 0.42)
		row.BackgroundTransparency = 1
		
		local avatar = Instance.new("TextLabel")
		avatar.Size = UDim2.fromScale(0.18, 0.9)
		avatar.Position = UDim2.fromScale(0, 0.05)
		avatar.BackgroundTransparency = 1
		avatar.Text = "👤"
		avatar.TextScaled = true
		avatar.Parent = row
		
		local labelContainer = Instance.new("Frame")
		labelContainer.Size = UDim2.fromScale(0.55, 0.9)
		labelContainer.Position = UDim2.fromScale(0.20, 0.05)
		labelContainer.BackgroundTransparency = 1
		labelContainer.Parent = row
		
		local nLbl = Instance.new("TextLabel")
		nLbl.Size = UDim2.fromScale(1, 0.5)
		nLbl.BackgroundTransparency = 1
		nLbl.Text = name
		nLbl.TextColor3 = Color3.fromRGB(230, 230, 250)
		nLbl.Font = Enum.Font.GothamBold
		nLbl.TextScaled = true
		nLbl.TextXAlignment = Enum.TextXAlignment.Left
		nLbl.Parent = labelContainer
		
		local sLbl = Instance.new("TextLabel")
		sLbl.Size = UDim2.fromScale(1, 0.4)
		sLbl.Position = UDim2.fromScale(0, 0.5)
		sLbl.BackgroundTransparency = 1
		sLbl.Text = status
		sLbl.TextColor3 = Color3.fromRGB(0, 255, 120)
		sLbl.Font = Enum.Font.GothamMedium
		sLbl.TextScaled = true
		sLbl.TextXAlignment = Enum.TextXAlignment.Left
		sLbl.Parent = labelContainer
		
		if isJoinable then
			local joinBtn = Instance.new("TextButton")
			joinBtn.Size = UDim2.fromScale(0.22, 0.8)
			joinBtn.Position = UDim2.fromScale(0.78, 0.1)
			joinBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
			joinBtn.Text = "JOIN"
			joinBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
			joinBtn.Font = Enum.Font.GothamBlack
			joinBtn.TextScaled = true
			
			local jc = Instance.new("UICorner")
			jc.CornerRadius = UDim.new(0, 5)
			jc.Parent = joinBtn
			
			joinBtn.Parent = row
			applyInteractiveFeedback(joinBtn, UDim2.fromScale(0.22, 0.8), 1.1, nil, nil)
		end
		
		row.Parent = fList
	end
	
	createFriendRow("RapidKiller", "In Lobby", true)
	createFriendRow("TypeMaster", "In Practice", false)
	
	-- 2.5 Bottom Showcase Row (Latest News, Keyboard Skin, Popular lists)
	local bottomShowcase = Instance.new("Frame")
	bottomShowcase.Size = UDim2.fromScale(0.63, 0.15)
	bottomShowcase.Position = UDim2.fromScale(0.18, 0.83)
	bottomShowcase.BackgroundTransparency = 1
	bottomShowcase.Parent = dashboardCanvas
	
	local bsLayout = Instance.new("UIListLayout")
	bsLayout.FillDirection = Enum.FillDirection.Horizontal
	bsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	bsLayout.Padding = UDim.new(0.038, 0)
	bsLayout.Parent = bottomShowcase
	
	local function createShowcasePanel(title, sub, symbol, strokeColor, widthScale)
		local panel = Instance.new("Frame")
		local panelSize = UDim2.fromScale(widthScale, 1)
		panel.Size = panelSize
		panel.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
		panel.BackgroundTransparency = 0.4
		
		local pc = Instance.new("UICorner")
		pc.CornerRadius = UDim.new(0, 14)
		pc.Parent = panel
		
		local ps = Instance.new("UIStroke")
		ps.Color = strokeColor
		ps.Thickness = 1.2
		ps.Parent = panel
		
		local symLbl = Instance.new("TextLabel")
		symLbl.Size = UDim2.fromScale(0.2, 0.6)
		symLbl.Position = UDim2.fromScale(0.04, 0.2)
		symLbl.BackgroundTransparency = 1
		symLbl.Text = symbol
		symLbl.TextScaled = true
		symLbl.Parent = panel
		
		local titleLbl = Instance.new("TextLabel")
		titleLbl.Size = UDim2.fromScale(0.7, 0.3)
		titleLbl.Position = UDim2.fromScale(0.26, 0.2)
		titleLbl.BackgroundTransparency = 1
		titleLbl.Text = title
		titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		titleLbl.Font = Enum.Font.GothamBold
		titleLbl.TextScaled = true
		titleLbl.TextXAlignment = Enum.TextXAlignment.Left
		titleLbl.Parent = panel
		
		local subLbl = Instance.new("TextLabel")
		subLbl.Size = UDim2.fromScale(0.7, 0.3)
		subLbl.Position = UDim2.fromScale(0.26, 0.5)
		subLbl.BackgroundTransparency = 1
		subLbl.Text = sub
		subLbl.TextColor3 = Color3.fromRGB(150, 150, 170)
		subLbl.Font = Enum.Font.GothamMedium
		subLbl.TextScaled = true
		subLbl.TextXAlignment = Enum.TextXAlignment.Left
		subLbl.Parent = panel
		
		panel.Parent = bottomShowcase
		applyInteractiveFeedback(panel, panelSize, 1.02, ps, Color3.fromRGB(255, 255, 255))
	end
	
	createShowcasePanel("LATEST SEASON 1 NEWS", "Become a typewriter legend now!", "📰", Color3.fromRGB(138, 43, 226), 0.48)
	createShowcasePanel("KEYBOARD STORE", "Unlock Neon Pulse skin!", "⌨️", Color3.fromRGB(0, 255, 150), 0.48)
	
	-------------------------------------------------------------
	-- STAGE 3: TRANSITIONAL SEQUENCE (FTUE -> DASHBOARD)
	-------------------------------------------------------------
	playNowBtn.MouseButton1Click:Connect(function()
		-- Stop FTUE ambient music immediately
		local music = SoundService:FindFirstChild("FTUEMusic")
		if music then
			TweenService:Create(music, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Volume = 0
			}):Play()
			task.delay(0.5, function()
				music:Stop()
				music:Destroy()
			end)
		end

		playLocalSound(AUDIO_ASSETS.Click, 0.8)
		
		-- Smooth, premium fade-out and fade-in canvas transition!
		TweenService:Create(ftueCanvas, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			GroupTransparency = 1
		}):Play()
		
		task.delay(0.25, function()
			ftueCanvas.ZIndex = 1
			dashboardCanvas.ZIndex = 2
			
			TweenService:Create(dashboardCanvas, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				GroupTransparency = 0
			}):Play()
		end)
	end)
	
	-------------------------------------------------------------
	-- STAGE 4: INTERACTIVE PRACTICE MODAL BINDINGS
	-------------------------------------------------------------
	practicePlayBtn.MouseButton1Click:Connect(function()
		playLocalSound(AUDIO_ASSETS.ModalOpen, 0.6)
		
		-- Scaffolds glassmorphic options modal centered over the dashboard
		if globalBackdrop:FindFirstChild("PracticeModal") then return end
		
		local modal = Instance.new("Frame")
		modal.Name = "PracticeModal"
		modal.Size = UDim2.fromScale(0.6, 0.72)
		modal.Position = UDim2.fromScale(0.2, 0.14)
		modal.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
		modal.BorderSizePixel = 0
		modal.ZIndex = 10
		
		local modalCorner = Instance.new("UICorner")
		modalCorner.CornerRadius = UDim.new(0, 16)
		modalCorner.Parent = modal
		
		local modalStroke = Instance.new("UIStroke")
		modalStroke.Color = Color3.fromRGB(0, 170, 255) -- Cyan glow outline
		modalStroke.Thickness = 2
		modalStroke.Parent = modal
		
		-- Modal Title
		local modalTitle = Instance.new("TextLabel")
		modalTitle.Size = UDim2.fromScale(0.8, 0.08)
		modalTitle.Position = UDim2.fromScale(0.1, 0.04)
		modalTitle.BackgroundTransparency = 1
		modalTitle.Text = "PRACTICE ARENA OPTIONS"
		modalTitle.TextColor3 = Color3.fromRGB(255, 200, 0) -- Gold accent
		modalTitle.Font = Enum.Font.GothamBlack
		modalTitle.TextScaled = true
		modalTitle.ZIndex = 11
		modalTitle.Parent = modal
		
		-- Option State selection
		local selectedMode = "Duel"
		local selectedSpeed = "Medium"
		local selectedCategory = "Quotes"
		local selectedDifficulty = "Normal"
		
		-- Helper function to style active/inactive buttons
		local function setButtonState(btn, isActive, activeColor)
			if isActive then
				btn.BackgroundColor3 = activeColor or Color3.fromRGB(138, 43, 226)
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
				btn:FindFirstChild("UIStroke").Color = Color3.fromRGB(255, 255, 255)
			else
				btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
				btn.TextColor3 = Color3.fromRGB(150, 150, 170)
				btn:FindFirstChild("UIStroke").Color = Color3.fromRGB(50, 50, 60)
			end
		end
		
		-- Helper to make option row headers
		local function makeHeader(text, positionY)
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.fromScale(0.3, 0.05)
			lbl.Position = UDim2.fromScale(0.05, positionY)
			lbl.BackgroundTransparency = 1
			lbl.Text = text
			lbl.TextColor3 = Color3.fromRGB(0, 255, 255) -- Cyan header
			lbl.Font = Enum.Font.GothamBold
			lbl.TextScaled = true
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.ZIndex = 11
			lbl.Parent = modal
			return lbl
		end
		
		-- Helper to create rounded option buttons
		local function makeOptionButton(text, size, position, activeColor)
			local btn = Instance.new("TextButton")
			btn.Size = size
			btn.Position = position
			btn.Text = text
			btn.Font = Enum.Font.GothamBold
			btn.TextScaled = true
			btn.ZIndex = 11
			
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = btn
			
			local stroke = Instance.new("UIStroke")
			stroke.Thickness = 1.5
			stroke.Parent = btn
			
			btn.Parent = modal
			return btn
		end
		
		-- Row 1: MODE (Zen vs Bot Duel)
		makeHeader("GAME PLAY MODE:", 0.16)
		local zenBtn = makeOptionButton("ZEN PRACTICE", UDim2.fromScale(0.26, 0.07), UDim2.fromScale(0.38, 0.15), Color3.fromRGB(0, 200, 100))
		local duelBtn = makeOptionButton("BOT DUEL", UDim2.fromScale(0.26, 0.07), UDim2.fromScale(0.66, 0.15), Color3.fromRGB(138, 43, 226))
		
		-- Row 2: BOT SPEED (only active for Bot Duel)
		local speedHeader = makeHeader("BOT SPEED (WPM):", 0.28)
		local speedButtons = {}
		local speeds = { "Easy", "Medium", "Hard", "Insane" }
		for i, speedName in ipairs(speeds) do
			local xPos = 0.38 + (i - 1) * 0.14
			local btn = makeOptionButton(speedName, UDim2.fromScale(0.12, 0.07), UDim2.fromScale(xPos, 0.27), Color3.fromRGB(255, 100, 0))
			speedButtons[speedName] = btn
			
			btn.MouseButton1Click:Connect(function()
				if selectedMode ~= "Duel" then return end
				selectedSpeed = speedName
				for sName, sBtn in pairs(speedButtons) do
					setButtonState(sBtn, sName == selectedSpeed, Color3.fromRGB(255, 100, 0))
				end
			end)
		end
		
		local function updateModeUI()
			setButtonState(zenBtn, selectedMode == "Zen", Color3.fromRGB(0, 200, 100))
			setButtonState(duelBtn, selectedMode == "Duel", Color3.fromRGB(138, 43, 226))
			
			local opacity = selectedMode == "Duel" and 1 or 0.3
			speedHeader.TextTransparency = 1 - opacity
			for sName, sBtn in pairs(speedButtons) do
				sBtn.BackgroundTransparency = 1 - opacity
				sBtn.TextTransparency = 1 - opacity
				sBtn:FindFirstChild("UIStroke").Transparency = 1 - opacity
				setButtonState(sBtn, selectedMode == "Duel" and sName == selectedSpeed, Color3.fromRGB(255, 100, 0))
			end
		end
		
		zenBtn.MouseButton1Click:Connect(function()
			selectedMode = "Zen"
			updateModeUI()
		end)
		
		duelBtn.MouseButton1Click:Connect(function()
			selectedMode = "Duel"
			updateModeUI()
		end)
		
		-- Row 3: CATEGORY (Quotes, Words, Meme)
		makeHeader("TEXT CONTENT:", 0.40)
		local catButtons = {}
		local categories = { "Quotes", "Words", "Meme" }
		for i, catName in ipairs(categories) do
			local xPos = 0.38 + (i - 1) * 0.18
			local btn = makeOptionButton(catName == "Words" and "COMMON WORDS" or catName:upper(), UDim2.fromScale(0.16, 0.07), UDim2.fromScale(xPos, 0.39), Color3.fromRGB(0, 170, 255))
			catButtons[catName] = btn
			
			btn.MouseButton1Click:Connect(function()
				selectedCategory = catName
				for cName, cBtn in pairs(catButtons) do
					setButtonState(cBtn, cName == selectedCategory, Color3.fromRGB(0, 170, 255))
				end
			end)
		end
		
		-- Row 4: DIFFICULTY (Normal, Hard)
		makeHeader("TEXT DIFFICULTY:", 0.52)
		local diffButtons = {}
		local difficulties = { "Normal", "Hard" }
		for i, diffName in ipairs(difficulties) do
			local xPos = 0.38 + (i - 1) * 0.20
			local btn = makeOptionButton(diffName:upper(), UDim2.fromScale(0.18, 0.07), UDim2.fromScale(xPos, 0.51), Color3.fromRGB(255, 200, 0))
			diffButtons[diffName] = btn
			
			btn.MouseButton1Click:Connect(function()
				selectedDifficulty = diffName
				for dName, dBtn in pairs(diffButtons) do
					setButtonState(dBtn, dName == selectedDifficulty, Color3.fromRGB(255, 200, 0))
				end
			end)
		end
		
		-- Initialize Option Button Styles
		updateModeUI()
		for cName, cBtn in pairs(catButtons) do
			setButtonState(cBtn, cName == selectedCategory, Color3.fromRGB(0, 170, 255))
		end
		for dName, dBtn in pairs(diffButtons) do
			setButtonState(dBtn, dName == selectedDifficulty, Color3.fromRGB(255, 200, 0))
		end
		
		-- Cancel Button
		local cancelBtn = makeOptionButton("CANCEL", UDim2.fromScale(0.3, 0.08), UDim2.fromScale(0.15, 0.78), Color3.fromRGB(150, 0, 0))
		setButtonState(cancelBtn, true, Color3.fromRGB(150, 0, 0))
		cancelBtn.MouseButton1Click:Connect(function()
			modal:Destroy()
		end)
		
		-- Start Button
		local startBtn = makeOptionButton("START GAME", UDim2.fromScale(0.36, 0.08), UDim2.fromScale(0.5, 0.78), Color3.fromRGB(0, 200, 100))
		setButtonState(startBtn, true, Color3.fromRGB(0, 200, 100))
		startBtn.MouseButton1Click:Connect(function()
			modal:Destroy()
			
			-- Unmount main menu assets and load HUD
			MainMenuController.Unmount()
			MatchUIController.Mount()
			
			ClientMatchController.StartOfflineMatch({
				mode = selectedMode,
				botSpeed = selectedSpeed,
				category = selectedCategory,
				difficulty = selectedDifficulty
			})
		end)
		
		modal.Parent = globalBackdrop
	end)
	
	screenGui.Parent = playerGui
end

function MainMenuController.Unmount()
	if screenGui then
		screenGui:Destroy()
		screenGui = nil
	end
end

return MainMenuController
