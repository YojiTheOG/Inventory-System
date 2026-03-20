--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer :: Player

-- [ DEPENDENCIES ] --
local PacketsModule = require(ReplicatedStorage.Shared.Modules.Packets.InventoryServicePackets)
local InventoryServiceUtils = require("./InventoryServiceUtils")
local InputController = require(ReplicatedStorage.Shared.Controllers.InputController)

local InventoryServiceClient = {}

type Item = InventoryServiceUtils.Item
type Inventory = InventoryServiceUtils.Inventory

type InventoryServiceClient = typeof(InventoryServiceClient) & {
	_saveInput: InputController.Input,
	_releaseInput: InputController.Input,

	inventory: Inventory,
}

function InventoryServiceClient.init(self: InventoryServiceClient)
	self._saveInput = InputController:GetAction("Inventory", "storeItem")
	self._releaseInput = InputController:GetAction("Inventory", "releaseItem")
	self.inventory = {}

	self:Start()
end

function InventoryServiceClient.Start(self: InventoryServiceClient)
	self:_initInput()
end

function InventoryServiceClient.getItemOnHand(self: InventoryServiceClient): Item?
	local char = player.Character
	if not char then return nil end
	local item = char:FindFirstChildOfClass("Tool")
	if not item then return nil end

	return item
end

function InventoryServiceClient.storeItem(self: InventoryServiceClient, item: Item)
	PacketsModule.packets.storeItem.send({
		InventoryItem = item,
	})
end

function InventoryServiceClient.releaseItem(self: InventoryServiceClient)
	PacketsModule.packets.releaseItem.send({

	})
end

function InventoryServiceClient._initInput(self: InventoryServiceClient)
	local saveInput = self._saveInput
	local releaseInput = self._releaseInput

	saveInput.Keyboard.KeyCode = Enum.KeyCode.Y
	releaseInput.Keyboard.KeyCode = Enum.KeyCode.K

	saveInput.Pressed:Connect(function()
		local item = self:getItemOnHand()
		if not item then return end

		self:storeItem(item)
	end)

	releaseInput.Pressed:Connect(function()
		self:releaseItem()
	end)
end

return InventoryServiceClient :: InventoryServiceClient
