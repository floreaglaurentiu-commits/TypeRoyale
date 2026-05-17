-- ServerMain.server.lua
-- The entry point for the server.

-- Require services so they initialize their event listeners
local QueueService = require(script.Parent.Matchmaking.QueueService)
local MatchService = require(script.Parent.Services.MatchService)
local ServerTypingValidation = require(script.Parent.Validation.ServerTypingValidation)

print("TypeRoyale Server initialized.")
