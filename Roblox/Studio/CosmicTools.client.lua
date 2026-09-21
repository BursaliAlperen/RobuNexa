--!strict
-- RobuNexa Cosmic tool controller.
-- Put this LocalScript in StarterPlayerScripts.
-- It binds the server-created Cosmic tools to the existing Cosmic moveset.

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function getMovesetModule()
	return script.Parent:FindFirstChild("CosmicMoveset")
end

local function bindTool(tool: Tool)
	if tool:GetAttribute("RobuNexaBound") then return end
	if tool:GetAttribute("RobuNexaMoveset") ~= "Cosmic" then return end

	tool:SetAttribute("RobuNexaBound", true)

	tool.Activated:Connect(function()
		-- The main CosmicMoveset script exposes activation through the shared
		-- player attribute. The controller remains intentionally lightweight.
		player:SetAttribute("CosmicRequestedAbility", tool:GetAttribute("AbilityName") or tool.Name)
	end)
end

local function scan(container: Instance)
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("Tool") then
			bindTool(child)
		end
	end
	container.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			bindTool(child)
		end
	end)
end

local backpack = player:WaitForChild("Backpack")
scan(backpack)

player.CharacterAdded:Connect(function(character)
	scan(character)
end)

if player.Character then
	scan(player.Character)
end
