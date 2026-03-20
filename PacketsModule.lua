local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ByteNetMax = require(ReplicatedStorage.Packages.ByteNetMax)

return ByteNetMax.defineNamespace("InventoryService", function()
	return {
		packets = {
			storeItem = ByteNetMax.definePacket({
				value = ByteNetMax.struct({
					InventoryItem = ByteNetMax.inst,
				}),

			}),

			releaseItem = ByteNetMax.definePacket({
				value = ByteNetMax.struct({

				}),

			}),


		},

		queries = {

		},
	}
end)
