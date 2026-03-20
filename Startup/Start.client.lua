--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local InputController = require(ReplicatedStorage.Shared.Controllers.InputController)
local InventoryServiceClient = require(ReplicatedStorage.Shared.Services.InventoryService.InventoryServiceClient)


InputController:init()
InventoryServiceClient:init()
