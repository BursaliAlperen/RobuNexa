-- RobuNexa shared moveset adapter
-- Location: Roblox/Studio/RobuNexa_MovesetCompatibility.lua
-- Use in an experience you own. For replicated NPC animations, call from a server Script.
-- For a player's own character, call from that player's LocalScript.
-- Add your own uploaded animation asset IDs to the moveset definitions.

local MovesetCompatibility = {}

local Players = game:GetService("Players")

local registeredMovesets = {}
local activeTracks = setmetatable({}, { __mode = "k" })

local function getHumanoidAndAnimator(target)
	if typeof(target) ~= "Instance" then
		return nil, nil, "Target must be a Model or character Model."
	end

	local model
	if target:IsA("Model") then
		model = target
	else
		model = target:FindFirstAncestorOfClass("Model")
	end

	if not model then
		return nil, nil, "No character Model found."
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil, nil, "Target Model has no Humanoid."
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local rigType = humanoid.RigType.Name
	return model, animator, nil, rigType
end

function MovesetCompatibility.RegisterMoveset(name, definition)
	assert(type(name) == "string" and name ~= "", "Moveset name is required.")
	assert(type(definition) == "table", "Moveset definition must be a table.")
	assert(type(definition.Animations) == "table", "Definition.Animations must be a table.")

	local normalized = {
		Animations = definition.Animations,
		RigTypes = definition.RigTypes or { R6 = true, R15 = true },
		Priority = definition.Priority or Enum.AnimationPriority.Action,
		LoopedActions = definition.LoopedActions or {},
	}
	registeredMovesets[name] = normalized
end

function MovesetCompatibility.GetAvailableMovesets(target)
	local model, _, err, rigType = getHumanoidAndAnimator(target)
	if not model then
		return {}, err
	end

	local available = {}
	for name, definition in pairs(registeredMovesets) do
		if definition.RigTypes[rigType] then
			table.insert(available, name)
		end
	end
	table.sort(available)
	return available
end

function MovesetCompatibility.Play(target, movesetName, actionName, fadeTime)
	local model, animator, err, rigType = getHumanoidAndAnimator(target)
	if not model then
		return false, err
	end

	local definition = registeredMovesets[movesetName]
	if not definition then
		return false, "Unknown moveset: " .. tostring(movesetName)
	end
	if not definition.RigTypes[rigType] then
		return false, movesetName .. " does not support " .. rigType .. "."
	end

	local animationId = definition.Animations[actionName]
	if type(animationId) ~= "string" or animationId == "" then
		return false, "No animation ID configured for " .. movesetName .. "." .. tostring(actionName)
	end

	local slotKey = movesetName .. ":" .. actionName
	activeTracks[model] = activeTracks[model] or {}
	local previous = activeTracks[model][slotKey]
	if previous then
		pcall(function()
			previous:Stop(fadeTime or 0.1)
			previous:Destroy()
		end)
		activeTracks[model][slotKey] = nil
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId:match("^rbxassetid://") and animationId
		or ("rbxassetid://" .. animationId)

	local ok, trackOrError = pcall(function()
		local track = animator:LoadAnimation(animation)
		track.Priority = definition.Priority
		track.Looped = definition.LoopedActions[actionName] == true
		track:Play(fadeTime or 0.1)
		return track
	end)
	animation:Destroy()

	if not ok then
		return false, "Could not load animation: " .. tostring(trackOrError)
	end

	activeTracks[model][slotKey] = trackOrError
	return true, trackOrError
end

function MovesetCompatibility.Stop(target, movesetName, actionName, fadeTime)
	local model = target
	if typeof(target) == "Instance" and not target:IsA("Model") then
		model = target:FindFirstAncestorOfClass("Model")
	end
	if not model or not activeTracks[model] then
		return false, "No active moveset tracks for target."
	end

	local prefix = movesetName and (movesetName .. ":") or nil
	for key, track in pairs(activeTracks[model]) do
		local matchesMoveset = not prefix or key:sub(1, #prefix) == prefix
		local matchesAction = not actionName or key == ((movesetName or key:match("^(.-):")) .. ":" .. actionName)
		if matchesMoveset and matchesAction then
			pcall(function()
				track:Stop(fadeTime or 0.1)
				track:Destroy()
			end)
			activeTracks[model][key] = nil
		end
	end
	return true
end

function MovesetCompatibility.IsPlayerCharacter(target)
	local model = target
	if typeof(target) == "Instance" and not target:IsA("Model") then
		model = target:FindFirstAncestorOfClass("Model")
	end
	return model ~= nil and Players:GetPlayerFromCharacter(model) ~= nil
end

return MovesetCompatibility
