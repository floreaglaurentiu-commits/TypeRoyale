-- TypingFeedback.lua
-- Handles premium visual effects, audio clicks, error vignettes, and camera shakes.

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local TypingFeedback = {}

-- Audio asset IDs for high-fidelity feedback
local AUDIO_ASSETS = {
	Tick = "rbxassetid://9086154674",      -- Ticking countdown
	Go = "rbxassetid://9086154861",        -- Heavy arcade "GO"
	Click = "rbxassetid://9114223192",     -- Tactile mechanical keyboard switch
	Error = "rbxassetid://9069509268",     -- Cyber buzz error sound
	Victory = "rbxassetid://9084370217"    -- Synth celebratory win chime
}

-- Play sound locally using SoundService
local function playSound(assetId, volume, pitch)
	local sound = Instance.new("Sound")
	sound.SoundId = assetId
	sound.Volume = volume or 0.5
	sound.PlaybackSpeed = pitch or 1.0
	sound.Parent = SoundService
	SoundService:PlayLocalSound(sound)
	
	-- Self cleanup
	task.spawn(function()
		task.wait(3)
		sound:Destroy()
	end)
end

-- Play glowing screen vignette overlay pulse
local function pulseVignette(color, duration, targetTransparency)
	local player = Players.LocalPlayer
	if not player then return end
	local playerGui = player:WaitForChild("PlayerGui")
	local hud = playerGui:FindFirstChild("TypeRoyaleMatchHUD")
	if not hud then return end
	
	local vignette = hud:FindFirstChild("VignetteOverlay")
	if not vignette then
		vignette = Instance.new("ImageLabel")
		vignette.Name = "VignetteOverlay"
		vignette.Size = UDim2.fromScale(1, 1)
		vignette.BackgroundTransparency = 1
		vignette.Image = "rbxassetid://6577317770" -- Premium circular vignette mask
		vignette.ZIndex = 1
		vignette.Parent = hud
	end
	
	vignette.ImageColor3 = color or Color3.fromRGB(0, 0, 0)
	vignette.ImageTransparency = 1
	
	local tweenIn = TweenService:Create(vignette, TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		ImageTransparency = targetTransparency or 0.4
	})
	local tweenOut = TweenService:Create(vignette, TweenInfo.new(duration or 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		ImageTransparency = 1
	})
	
	tweenIn:Play()
	tweenIn.Completed:Connect(function()
		tweenOut:Play()
	end)
end

-- Spring-like camera shake
local function cameraShake(intensity, duration)
	local camera = workspace.CurrentCamera
	local originalCFrame = camera.CFrame
	
	local startTime = os.clock()
	local shakeConn
	shakeConn = RunService.RenderStepped:Connect(function()
		local elapsed = os.clock() - startTime
		if elapsed >= (duration or 0.15) then
			shakeConn:Disconnect()
			camera.CFrame = originalCFrame
			return
		end
		
		local decay = 1 - (elapsed / (duration or 0.15))
		local offset = Vector3.new(
			(math.random() - 0.5) * intensity * decay,
			(math.random() - 0.5) * intensity * decay,
			0
		)
		camera.CFrame = originalCFrame * CFrame.new(offset)
	end)
end

-- Key Hit Success Feedback
function TypingFeedback.PlayCorrectHit(combo: number)
	-- Scale click pitch based on current combo to simulate momentum
	local pitch = 1.0 + math.clamp(combo * 0.005, 0, 0.25)
	playSound(AUDIO_ASSETS.Click, 0.45, pitch)
end

-- Key Hit Mistake Feedback
function TypingFeedback.PlayMistake()
	playSound(AUDIO_ASSETS.Error, 0.6, 1.0)
	pulseVignette(Color3.fromRGB(200, 0, 0), 0.35, 0.3) -- Flash red
	cameraShake(0.4, 0.15) -- Slight camera screen shake
end

-- Countdown ticks
function TypingFeedback.PlayCountdown()
	playSound(AUDIO_ASSETS.Tick, 0.65, 1.0)
	pulseVignette(Color3.fromRGB(0, 170, 255), 0.4, 0.6) -- Cyan vignette flash
	
	-- Camera micro zoom bump
	local camera = workspace.CurrentCamera
	local originalField = camera.FieldOfView
	camera.FieldOfView = originalField - 2
	TweenService:Create(camera, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		FieldOfView = originalField
	}):Play()
end

-- Match Start GO
function TypingFeedback.PlayMatchStart()
	playSound(AUDIO_ASSETS.Go, 0.8, 1.0)
	pulseVignette(Color3.fromRGB(255, 180, 0), 0.6, 0.45) -- Bright gold glow pulse
	cameraShake(0.6, 0.25)
end

-- Victory FANFARE
function TypingFeedback.PlayVictory()
	playSound(AUDIO_ASSETS.Victory, 0.8, 1.0)
	pulseVignette(Color3.fromRGB(0, 255, 150), 0.8, 0.4) -- Emerald win glow
end

return TypingFeedback
