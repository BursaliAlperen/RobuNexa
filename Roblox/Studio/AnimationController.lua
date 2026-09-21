--!strict
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
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

local function playKeyframeSequence(sequence: KeyframeSequence, character: Model): (() -> ())?
	local frames = sequence:GetKeyframes()
	if #frames == 0 then return nil end
	table.sort(frames, function(a, b) return a.Time < b.Time end)

	local tracks = {}
	local function resolve(name: string)
		for _, item in ipairs(character:GetDescendants()) do
			if item:IsA("Motor6D") and item.Part1 and item.Part1.Name == name then
				return item
			end
			if item:IsA("Bone") and item.Name == name then
				return item
			end
		end
		return nil
	end

	for _, frame in ipairs(frames) do
		for _, pose in ipairs(frame:GetDescendants()) do
			if pose:IsA("Pose") and pose.Weight > 0 then
				local joint = resolve(pose.Name)
				if joint then
					tracks[pose.Name] = tracks[pose.Name] or {joint = joint, poses = {}}
					table.insert(tracks[pose.Name].poses, {
						time = frame.Time,
						cframe = pose.CFrame,
						style = pose.EasingStyle,
						direction = pose.EasingDirection,
					})
				end
			end
		end
	end

	local original = {}
	for _, track in pairs(tracks) do
		original[track.joint] = track.joint:IsA("Motor6D") and track.joint.Transform or track.joint.Transform
	end

	local length = math.max(frames[#frames].Time, 0.001)
	local started = os.clock()
	local connection
	local stopped = false

	local function stop()
		if stopped then return end
		stopped = true
		if connection then connection:Disconnect() end
		for joint, transform in pairs(original) do
			if joint.Parent then joint.Transform = transform end
		end
	end

	connection = RunService.Heartbeat:Connect(function()
		if not character.Parent then stop(); return end
		local t = math.min(os.clock() - started, length)

		for _, track in pairs(tracks) do
			local poses = track.poses
			local a = poses[1]
			local b = poses[#poses]
			for i = 1, #poses - 1 do
				if t >= poses[i].time and t <= poses[i + 1].time then
					a, b = poses[i], poses[i + 1]
					break
				end
			end

			local alpha = 0
			if b.time > a.time then
				alpha = math.clamp((t - a.time) / (b.time - a.time), 0, 1)
			end
			local style = b.style
			local direction = b.direction
			local ok, eased = pcall(function()
				return TweenService:GetValue(
					alpha,
					Enum.EasingStyle[style.Name] or Enum.EasingStyle.Linear,
					Enum.EasingDirection[direction.Name] or Enum.EasingDirection.InOut
				)
			end)
			if ok then alpha = eased end
			track.joint.Transform = a.cframe:Lerp(b.cframe, alpha)
		end

		if t >= length then stop() end
	end)

	return stop
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
		return playKeyframeSequence(sequence, character)
	end

	return nil
end

return AnimationController
