-- MainMenuController.lua
-- Scaffolds the Main Menu UI and handles queue interaction.

local Players = game:GetService("Players")
local ClientMatchController = require(script.Parent.Parent.Controllers.ClientMatchController)

local MainMenuController = {}
local screenGui

function MainMenuController.Mount()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Destroy old if exists
	if playerGui:FindFirstChild("TypeRoyaleMenu") then
		playerGui.TypeRoyaleMenu:Destroy()
	end
	
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TypeRoyaleMenu"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	-- Main Background
	local background = Instance.new("Frame")
	background.Name = "Background"
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundColor3 = Color3.fromRGB(15, 15, 25) -- Deep Navy
	background.Parent = screenGui
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.fromScale(0.4, 0.1)
	title.Position = UDim2.fromScale(0.3, 0.1)
	title.BackgroundTransparency = 1
	title.Text = "TYPE ROYALE"
	title.TextColor3 = Color3.fromRGB(255, 200, 0) -- Gold/Neon Yellow
	title.TextScaled = true
	title.Font = Enum.Font.GothamBlack
	title.Parent = background
	
	-- Play Button
	local playButton = Instance.new("TextButton")
	playButton.Name = "PlayButton"
	playButton.Size = UDim2.fromScale(0.2, 0.08)
	playButton.Position = UDim2.fromScale(0.4, 0.5)
	playButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Neon Purple
	playButton.Text = "PLAY 1V1"
	playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	playButton.TextScaled = true
	playButton.Font = Enum.Font.GothamBold
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = playButton
	
	playButton.Parent = background
	
	-- Logic
	playButton.MouseButton1Click:Connect(function()
		playButton.Text = "SEARCHING..."
		playButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		ClientMatchController.JoinQueue()
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
