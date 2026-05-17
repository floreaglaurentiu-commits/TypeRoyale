-- ClientMain.client.lua
-- The entry point for the client. Initializes controllers and mounts the UI.

local MainMenuController = require(script.Parent.UI.MainMenuController)
local MatchUIController = require(script.Parent.UI.MatchUIController)
local ClientMatchController = require(script.Parent.Controllers.ClientMatchController)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = require(ReplicatedStorage.Shared.Networking.Events)
local MatchStartEvent = Events.GetEvent("MatchStart")

-- Mount the main menu on start
MainMenuController.Mount()

-- When match starts, unmount menu and mount match HUD
MatchStartEvent.OnClientEvent:Connect(function()
	MainMenuController.Unmount()
	MatchUIController.Mount()
end)

-- When match ends, clean up HUD and return to menu
-- We override the existing OnMatchEnded hook in ClientMatchController
-- to add the UI transitions.
local originalOnMatchEnded = ClientMatchController.OnMatchEnded
ClientMatchController.OnMatchEnded = function(winnerName)
	if originalOnMatchEnded then
		originalOnMatchEnded(winnerName)
	end
	
	-- Delay so player can see the winner text
	task.delay(3, function()
		MatchUIController.Unmount()
		MainMenuController.Mount()
	end)
end

print("TypeRoyale Client initialized.")
