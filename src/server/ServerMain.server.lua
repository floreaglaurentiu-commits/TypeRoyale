-- ServerMain.server.lua
-- The entry point for the server.

local Workspace = game:GetService("Workspace")

-- Create or update a centered test cube in Workspace for Rojo/Studio verification.
local cubeName = "RojoTestCube"
local devCube = Workspace:FindFirstChild(cubeName)

if not devCube then
    devCube = Instance.new("Part")
    devCube.Name = cubeName
    devCube.Parent = Workspace
end

devCube.Size = Vector3.new(4, 4, 4)
devCube.CFrame = CFrame.new(0, 2, 0)
devCube.Anchored = true
devCube.TopSurface = Enum.SurfaceType.Smooth
devCube.BottomSurface = Enum.SurfaceType.Smooth
devCube.Color = Color3.fromRGB(170, 0, 255)

-- Require services so they initialize their event listeners
local QueueService = require(script.Parent.Matchmaking.QueueService)
local MatchService = require(script.Parent.Services.MatchService)
local ServerTypingValidation = require(script.Parent.Validation.ServerTypingValidation)

print("TypeRoyale Server initialized.")
