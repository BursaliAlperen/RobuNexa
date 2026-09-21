--!strict
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RBXMAssetLoader = {}

local function findRoot(): Instance?
	for _, container in ipairs({ServerStorage, ReplicatedStorage}) do
		for _, name in ipairs({"RBXMAssets", "MovesetAssets"}) do
			local root = container:FindFirstChild(name)
			if root then return root end
		end
	end
	return nil
end

function RBXMAssetLoader.GetMovesetAsset(movesetName: string): Instance?
	local root = findRoot()
	if not root then
		warn("[RobuNexa] RBXM asset root missing: ServerStorage/RBXMAssets")
		return nil
	end
	local asset = root:FindFirstChild(movesetName)
	if not asset then
		warn("[RobuNexa] RBXM asset missing: " .. movesetName)
		return nil
	end
	return asset
end

function RBXMAssetLoader.GetSkillAsset(movesetName: string, skillName: string): Instance?
	local moveset = RBXMAssetLoader.GetMovesetAsset(movesetName)
	if not moveset then return nil end
	local skills = moveset:FindFirstChild("Skills")
	if skills and skills:FindFirstChild(skillName) then
		return skills:FindFirstChild(skillName)
	end
	local direct = moveset:FindFirstChild(skillName)
	if direct then return direct end
	for _, candidate in ipairs(moveset:GetDescendants()) do
		if candidate.Name == skillName and (candidate:IsA("Model") or candidate:IsA("Folder")) then
			return candidate
		end
	end
	warn(string.format("[RobuNexa] Skill asset missing: %s/%s", movesetName, skillName))
	return nil
end

function RBXMAssetLoader.ListSkills(movesetName: string): {string}
	local moveset = RBXMAssetLoader.GetMovesetAsset(movesetName)
	if not moveset then return {} end
	local source = moveset:FindFirstChild("Skills") or moveset
	local result = {}
	for _, child in ipairs(source:GetChildren()) do
		if child:IsA("Folder") or child:IsA("Model") then
			table.insert(result, child.Name)
		end
	end
	table.sort(result)
	return result
end

return RBXMAssetLoader
