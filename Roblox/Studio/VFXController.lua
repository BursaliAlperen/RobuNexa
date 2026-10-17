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

local function placeRelative(container: Instance, target: CFrame)
	local origin = findOrigin(container)
	if origin and origin.Parent and origin.Parent:IsA("BasePart") then
		origin.Parent.CFrame = target
		return
	end

	if container:IsA("Model") then
		container:PivotTo(target)
		return
	end

	if container:IsA("BasePart") then
		container.CFrame = target
		return
	end

	local anchor = container:FindFirstChildWhichIsA("BasePart", true)
	if not anchor then return end

	local delta = target * anchor.CFrame:Inverse()
	for _, item in ipairs(container:GetDescendants()) do
		if item:IsA("BasePart") then
			item.CFrame = delta * item.CFrame
		end
	end
end

function VFXController.AttachSkillAsset(asset: Instance, character: Model): (Instance?, {Instance})
	local root = getRoot(character)
	if not root then return nil, {} end

	local clone = asset:Clone()
	clone.Name = "RBXM_" .. asset.Name
	clone.Parent = character
	placeRelative(clone, root.CFrame)

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
