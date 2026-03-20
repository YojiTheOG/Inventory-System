--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- [ DEPENDENCIES ] --
local PacketsModule = require(ReplicatedStorage.Shared.Modules.Packets.InventoryServicePackets)
local InventoryServiceUtils = require(ReplicatedStorage.Shared.Services.InventoryService.InventoryServiceUtils)
local Signal = require(ReplicatedStorage.Packages.Signal)

local InventoryServiceServer = {}

type Item = InventoryServiceUtils.Item
type Inventory = InventoryServiceUtils.Inventory

type InventoryServiceServer = typeof(InventoryServiceServer) & {
	_saveItemThrottles: { [number]: number },
	_releaseItemThrottles: { [number]: number },

	inventories: { [number]: Inventory },

	ItemAddedToInventory: Signal.Signal<Player, Item>,
}

function InventoryServiceServer.init(self: InventoryServiceServer)
	self.inventories = {}
	self._saveItemThrottles = {}
	self._releaseItemThrottles = {}

	self.ItemAddedToInventory = Signal.new()



	self:Start()
end

function InventoryServiceServer.Start(self: InventoryServiceServer)
	self:_initPlayers()
	self:_initNetwork()
end

function InventoryServiceServer.attemptStoreItem(self: InventoryServiceServer, player: Player, item: Item)
	local inventory = self.inventories[player.UserId]

	table.insert(inventory, item)

	item.Parent = nil

	self.ItemAddedToInventory:Fire(player, item)

	print(`stored item {item:GetFullName()}`)
	print(`{player.UserId}'s inventory: {inventory}`)

	print(#inventory)
end

function InventoryServiceServer.attemptReleaseItem(self: InventoryServiceServer, player: Player)
	local inventory = self.inventories[player.UserId]

	local index = #inventory
	local item = inventory[index]
	if not item then return end

	table.remove(inventory, index)

	item.Parent = player.Backpack

	print(#inventory)
end

function InventoryServiceServer._initNetwork(self: InventoryServiceServer)
	PacketsModule.packets.storeItem.listen(function(data, player)
		if not player then return end
		if not data then return end
		local item = data.InventoryItem

		if not item then return end
		if typeof(item) ~= "Instance" then return end
		if not item:IsA("Tool") then return end

		local lastTimeStored = self._saveItemThrottles[player.UserId]
		if lastTimeStored and workspace:GetServerTimeNow() - lastTimeStored < 0.2 then return end
		self._saveItemThrottles[player.UserId] = workspace:GetServerTimeNow()


		self:attemptStoreItem(player, item)
	end)

	PacketsModule.packets.releaseItem.listen(function(data, player)
		if not player then return end
		if not data then return end

		local lastTimeReleased = self._releaseItemThrottles[player.UserId]
		if lastTimeReleased and workspace:GetServerTimeNow() - lastTimeReleased < 0.2 then return end
		self._releaseItemThrottles[player.UserId] = workspace:GetServerTimeNow()


		self:attemptReleaseItem(player)
	end)
end

function InventoryServiceServer._initPlayers(self: InventoryServiceServer)
	Players.PlayerAdded:Connect(function(player)
		self.inventories[player.UserId] = {}

		self._saveItemThrottles[player.UserId] = 0
		self._releaseItemThrottles[player.UserId] = 0
	end)

	Players.PlayerRemoving:Connect(function(player)
		table.clear(self.inventories[player.UserId])
		self.inventories[player.UserId] = nil

		self._saveItemThrottles[player.UserId] = nil
		self._releaseItemThrottles[player.UserId] = nil
	end)
end

return InventoryServiceServer :: InventoryServiceServer
