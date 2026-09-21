--!strict
local VFXController = {}

local function getRoot(character: Model): BasePart?
	return character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function findOrigin(container: Instance): Attachment?
	for _, name in ipairs({"Origin", "Root", "VFXOrigin", "Center"}) do
		local item = container:FindFirstChild(name, true)
		if item and item:IsA("Attachment") then return item end
	end
	return nil
end

function VFXController.AttachSkillAsset(asset: Instance, character: Model): (Instance?, {Instance})
	local root = getRoot(character)
	if not root then return nil, {} end

	local clone = asset:Clone()
	clone.Name = "RBXM_" .. asset.Name
	clone.Parent = character

	local origin = findOrigin(clone)
	if origin and origin.Parent and origin.Parent:IsA("BasePart") then
		origin.Parent.CFrame = root.CFrame
	elseif clone:IsA("Model") then
		clone:PivotTo(root.CFrame)
	elseif clone:IsA("BasePart") then
		clone.CFrame = root.CFrame
	end

	local runtimeObjects = {}
	for _, item in ipairs(clone:GetDescendants()) do
		if item:IsA("ParticleEmitter") or item:IsA("Beam") or item:IsA("Trail") or item:IsA("Sound") or item:IsA("Light") then
			table.insert(runtimeObjects, item)
		end
	end

	for _, item in ipairs(runtimeObjects) do
		if item:IsA("ParticleEmitter") or item:IsA("Beam") or item:IsA("Trail") or item:IsA("Light") then
			item.Enabled = true
		elseif item:IsA("Sound") then
			item:Play()
		end
	end

	return clone, runtimeObjects
end

function VFXController.Cleanup(instance: Instance?)
	if instance and instance.Parent then instance:Destroy() end
end

return VFXController
