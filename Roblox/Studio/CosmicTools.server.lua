--!strict
-- RobuNexa Cosmic tool distributor
-- Put this Script in ServerScriptService.
-- Creates the visible Cosmic ability tools for every player.
-- The client-side CosmicMoveset LocalScript handles activation/animation.

local Players = game:GetService("Players")

local TOOL_NAMES = {
	"Cosmic",
	"Cosmic Burst",
	"Cosmic Impact",
	"Cosmic Awakening",
}

local function makeTool(name: string): Tool
	local tool = Instance.new("Tool")
	tool.Name = name
	tool.ToolTip = name
	tool.RequiresHandle = false
	tool.CanBeDropped = false
	tool:SetAttribute("RobuNexaMoveset", "Cosmic")
	tool:SetAttribute("AbilityName", name)
	return tool
end

local function distribute(player: Player)
	local backpack = player:WaitForChild("Backpack")
	local starterGear = player:WaitForChild("StarterGear")

	for _, name in ipairs(TOOL_NAMES) do
		if not backpack:FindFirstChild(name) then
			makeTool(name).Parent = backpack
		end
		if not starterGear:FindFirstChild(name) then
			makeTool(name).Parent = starterGear
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	task.defer(distribute, player)
	player.CharacterAdded:Connect(function()
		task.defer(distribute, player)
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.defer(distribute, player)
end

print("[RobuNexa] Cosmic tools distributed.")
