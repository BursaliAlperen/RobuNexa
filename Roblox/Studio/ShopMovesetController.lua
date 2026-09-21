--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local MovesetManager = require(ServerScriptService:WaitForChild("MovesetManager"))
local ShopMovesetController = {}

function ShopMovesetController.GrantPurchasedMoveset(player: Player, movesetName: string): boolean
	return MovesetManager.Grant(player, movesetName)
end

return ShopMovesetController
