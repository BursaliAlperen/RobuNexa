--!strict
local AnimationController = {}

local function getAnimator(character: Model): Animator?
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil end
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	return animator
end

local function findAnimation(asset: Instance): Animation?
	for _, item in ipairs(asset:GetDescendants()) do
		if item:IsA("Animation") and item.AnimationId ~= "" then return item end
	end
	return nil
end

function AnimationController.Play(asset: Instance, character: Model): (() -> ())?
	local animator = getAnimator(character)
	if not animator then return nil end

	local animation = findAnimation(asset)
	if animation then
		local ok, track = pcall(function()
			local t = animator:LoadAnimation(animation)
			t:Play(0.05, 1, 1)
			return t
		end)
		if ok and track then
			return function()
				pcall(function() track:Stop(0.08) end)
				pcall(function() track:Destroy() end)
			end
		end
	end

	local sequence = asset:FindFirstChildWhichIsA("KeyframeSequence", true)
	if sequence then
		warn("[RobuNexa] KeyframeSequence present but no playable AnimationId: " .. sequence:GetFullName())
	end
	return nil
end

return AnimationController
