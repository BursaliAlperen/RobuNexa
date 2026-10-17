--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local RBXMAssetLoader = require(ServerScriptService:WaitForChild("RBXMAssetLoader"))
local MovesetManager = {}

local function ensureFolder(parent: Instance, name: string): Folder
	local folder = parent:FindFirstChild(name)
	if folder and folder:IsA("Folder") then return folder end
	if folder then folder:Destroy() end
	folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function makeTool(movesetName: string, skillName: string, source: Instance): Tool
	local tool = Instance.new("Tool")
	tool.Name = skillName
	tool.ToolTip = skillName
	tool.RequiresHandle = false
	tool.CanBeDropped = false
	tool:SetAttribute("Moveset", movesetName)
	tool:SetAttribute("SkillName", skillName)
	tool:SetAttribute("RBXMAsset", source:GetFullName())
	local cooldown = source:GetAttribute("Cooldown")
	tool:SetAttribute("Cooldown", typeof(cooldown) == "number" and cooldown or 1)
	local duration = source:GetAttribute("Duration")
	if typeof(duration) == "number" then tool:SetAttribute("Duration", duration) end
	return tool
end

function MovesetManager.Grant(player: Player, movesetName: string): boolean
	local asset = RBXMAssetLoader.GetMovesetAsset(movesetName)
	if not asset then return false end
	local backpack = player:WaitForChild("Backpack")
	local starterGear = player:WaitForChild("StarterGear")
	local skillRoot = asset:FindFirstChild("Skills") or asset

	for _, container in ipairs({ensureFolder(backpack, movesetName), ensureFolder(starterGear, movesetName)}) do
		for _, skill in ipairs(skillRoot:GetChildren()) do
			if skill:IsA("Folder") or skill:IsA("Model") then
				if not container:FindFirstChild(skill.Name) then
					makeTool(movesetName, skill.Name, skill).Parent = container
				end
			end
		end
	end
	player:SetAttribute("EquippedMoveset", movesetName)
	return true
end

function MovesetManager.Revoke(player: Player, movesetName: string)
	for _, container in ipairs({player:FindFirstChild("Backpack"), player:FindFirstChild("StarterGear")}) do
		if container then
			local folder = container:FindFirstChild(movesetName)
			if folder then folder:Destroy() end
		end
	end
	if player:GetAttribute("EquippedMoveset") == movesetName then
		player:SetAttribute("EquippedMoveset", nil)
	end
end

return MovesetManager
