--!strict
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local RBXMAssetLoader = require(ServerScriptService:WaitForChild("RBXMAssetLoader"))
local VFXController = require(ServerScriptService:WaitForChild("VFXController"))
local AnimationController = require(ServerScriptService:WaitForChild("AnimationController"))
local SkillController = {}
local active: {[Player]: {[string]: boolean}} = {}

local function finish(player: Player, key: string, tool: Tool, clone: Instance?, stopAnimation: (() -> ())?)
	if stopAnimation then
		stopAnimation()
	end
	VFXController.Cleanup(clone)
	if active[player] then active[player][key] = nil end
	if tool.Parent then tool.Enabled = true end
end

function SkillController.BindTool(tool: Tool)
	if tool:GetAttribute("RBXMControllerBound") then return end
	tool:SetAttribute("RBXMControllerBound", true)

	tool.Activated:Connect(function()
		local character = tool.Parent
		local player = character and Players:GetPlayerFromCharacter(character)
		if not player or not character:IsA("Model") then return end

		local moveset = tool:GetAttribute("Moveset")
		local skillName = tool:GetAttribute("SkillName")
		if typeof(moveset) ~= "string" or typeof(skillName) ~= "string" then
			warn("[RobuNexa] Tool missing Moveset/SkillName: " .. tool:GetFullName())
			return
		end

		active[player] = active[player] or {}
		local key = moveset .. ":" .. skillName
		if active[player][key] then return end
		active[player][key] = true
		tool.Enabled = false

		local asset = RBXMAssetLoader.GetSkillAsset(moveset, skillName)
		if not asset then
			finish(player, key, tool, nil, nil)
			return
		end

		local clone = VFXController.AttachSkillAsset(asset, character)
		local stopAnimation = AnimationController.Play(asset, character)
		local duration = clone and clone:GetAttribute("Duration")
		if typeof(duration) ~= "number" then duration = tool:GetAttribute("Duration") end
		if typeof(duration) ~= "number" then duration = 1 end

		task.delay(math.max(0, duration), function()
			finish(player, key, tool, clone, stopAnimation)
		end)

		local cooldown = tool:GetAttribute("Cooldown")
		task.delay(typeof(cooldown) == "number" and math.max(0, cooldown) or 1, function()
			if tool.Parent then tool.Enabled = true end
		end)
	end)
end

function SkillController.BindContainer(container: Instance)
	for _, item in ipairs(container:GetChildren()) do
		if item:IsA("Tool") then SkillController.BindTool(item) end
	end
	container.ChildAdded:Connect(function(item)
		if item:IsA("Tool") then SkillController.BindTool(item) end
	end)
end

return SkillController
