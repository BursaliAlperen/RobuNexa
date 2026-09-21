--!strict
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local SkillController = require(ServerScriptService:WaitForChild("SkillController"))

local function bindPlayer(player: Player)
	local backpack = player:WaitForChild("Backpack")
	SkillController.BindContainer(backpack)
	player.CharacterAdded:Connect(function(character)
		SkillController.BindContainer(character)
	end)
	if player.Character then SkillController.BindContainer(player.Character) end
end

Players.PlayerAdded:Connect(bindPlayer)
for _, player in ipairs(Players:GetPlayers()) do task.defer(bindPlayer, player) end
print("[RobuNexa] RBXM moveset runtime ready.")
