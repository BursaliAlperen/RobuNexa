-- AnimLib.lua
-- Studio-safe local KeyframeSequence player inspired by file-driven keyframe animation.
-- Input: a Roblox KeyframeSequence instance (not a raw GitHub .anim file).
-- This module writes Motor6D.Transform locally; it does not bypass Roblox permissions
-- and local pose changes are not guaranteed to replicate to other clients.

local RunService = game:GetService("RunService")

local AnimLib = {}
AnimLib.__index = AnimLib

local function easingAlpha(alpha, style, direction)
	alpha = math.clamp(alpha, 0, 1)
	if style == Enum.PoseEasingStyle.Constant then
		return direction == Enum.PoseEasingDirection.In and 0 or 1
	elseif style == Enum.PoseEasingStyle.Linear then
		return alpha
	elseif style == Enum.PoseEasingStyle.Cubic then
		if direction == Enum.PoseEasingDirection.In then return alpha ^ 3 end
		if direction == Enum.PoseEasingDirection.Out then return 1 - (1 - alpha) ^ 3 end
		if alpha < 0.5 then return 4 * alpha ^ 3 end
		return 1 - ((-2 * alpha + 2) ^ 3) / 2
	elseif style == Enum.PoseEasingStyle.Elastic then
		if alpha == 0 or alpha == 1 then return alpha end
		local c4 = (2 * math.pi) / 3
		if direction == Enum.PoseEasingDirection.In then
			return -(2 ^ (10 * alpha - 10)) * math.sin((alpha * 10 - 10.75) * c4)
		elseif direction == Enum.PoseEasingDirection.Out then
			return (2 ^ (-10 * alpha)) * math.sin((alpha * 10 - 0.75) * c4) + 1
		end
		if alpha < 0.5 then
			return -((2 ^ (20 * alpha - 10)) * math.sin((20 * alpha - 11.125) * (2 * math.pi) / 4.5)) / 2
		end
		return ((2 ^ (-20 * alpha + 10)) * math.sin((20 * alpha - 11.125) * (2 * math.pi) / 4.5)) / 2 + 1
	elseif style == Enum.PoseEasingStyle.Bounce then
		local function outBounce(x)
			local n1, d1 = 7.5625, 2.75
			if x < 1 / d1 then return n1 * x * x end
			if x < 2 / d1 then x -= 1.5 / d1; return n1 * x * x + 0.75 end
			if x < 2.5 / d1 then x -= 2.25 / d1; return n1 * x * x + 0.9375 end
			x -= 2.625 / d1
			return n1 * x * x + 0.984375
		end
		if direction == Enum.PoseEasingDirection.In then return 1 - outBounce(1 - alpha) end
		if direction == Enum.PoseEasingDirection.InOut then
			if alpha < 0.5 then return (1 - outBounce(1 - 2 * alpha)) / 2 end
			return (1 + outBounce(2 * alpha - 1)) / 2
		end
		return outBounce(alpha)
	end
	return alpha
end

local function collectPose(pose, output)
	output[pose.Name] = {
		CFrame = pose.CFrame,
		EasingStyle = pose.EasingStyle,
		EasingDirection = pose.EasingDirection,
		Weight = pose.Weight,
	}
	for _, child in ipairs(pose:GetChildren()) do
		if child:IsA("Pose") then collectPose(child, output) end
	end
end

local function makeFrames(sequence)
	local frames = {}
	for _, keyframe in ipairs(sequence:GetKeyframes()) do
		local poses = {}
		for _, child in ipairs(keyframe:GetPoses()) do collectPose(child, poses) end
		table.insert(frames, { Time = keyframe.Time, Poses = poses })
	end
	table.sort(frames, function(a, b) return a.Time < b.Time end)
	return frames
end

function AnimLib.new()
	return setmetatable({
		_track = nil,
		_connection = nil,
		_joints = {},
		_elapsed = 0,
		_speed = 1,
		_looped = false,
		_playing = false,
		_weight = 1,
		_destroyed = false,
	}, AnimLib)
end

function AnimLib:LoadSequence(sequence, rig)
	assert(not self._destroyed, "AnimLib player is destroyed")
	assert(typeof(sequence) == "Instance" and sequence:IsA("KeyframeSequence"), "LoadSequence expects a KeyframeSequence")
	assert(typeof(rig) == "Instance" and rig:IsA("Model"), "LoadSequence expects a character Model")
	self:Stop()
	local frames = makeFrames(sequence)
	assert(#frames > 0, "KeyframeSequence contains no keyframes")
	local joints = {}
	for _, descendant in ipairs(rig:GetDescendants()) do
		if descendant:IsA("Motor6D") then
			joints[descendant.Name] = descendant
		end
	end
	self._track = { Frames = frames, Length = math.max(frames[#frames].Time, 0.001), Rig = rig, Sequence = sequence }
	self._joints = joints
	self._elapsed = 0
	self._looped = sequence.Loop
	return self
end

function AnimLib:_poseAt(timePosition)
	local track = self._track
	if not track then return end
	local frames = track.Frames
	local left, right = frames[1], frames[#frames]
	for i = 1, #frames - 1 do
		if timePosition >= frames[i].Time and timePosition <= frames[i + 1].Time then
			left, right = frames[i], frames[i + 1]
			break
		elseif timePosition < frames[1].Time then
			left, right = frames[1], frames[1]
			break
		end
	end
	local span = right.Time - left.Time
	local alpha = span > 0 and (timePosition - left.Time) / span or 1
	local output = {}
	for jointName, rightPose in pairs(right.Poses) do
		local leftPose = left.Poses[jointName] or rightPose
		local eased = easingAlpha(alpha, leftPose.EasingStyle, leftPose.EasingDirection)
		local cf = leftPose.CFrame:Lerp(rightPose.CFrame, eased)
		local weight = math.clamp((leftPose.Weight or 1) + ((rightPose.Weight or 1) - (leftPose.Weight or 1)) * alpha, 0, 1)
		output[jointName] = CFrame.identity:Lerp(cf, weight)
	end
	for jointName, leftPose in pairs(left.Poses) do
		if output[jointName] == nil then
			output[jointName] = CFrame.identity:Lerp(leftPose.CFrame, math.clamp(leftPose.Weight or 1, 0, 1))
		end
	end
	for jointName, joint in pairs(self._joints) do
		if joint.Parent and output[jointName] then
			joint.Transform = output[jointName]
		end
	end
end

function AnimLib:Play(fadeTime)
	if not self._track or self._destroyed then return false end
	if self._connection then self._connection:Disconnect(); self._connection = nil end
	self._elapsed = 0
	self._playing = true
	local track = self._track
	local startTime = os.clock()
	self._connection = RunService:BindToRenderStep
		and nil or nil
	-- RenderStepped is available to LocalScripts and works without executor APIs.
	self._connection = RunService.RenderStepped:Connect(function(dt)
		if not self._playing or not self._track or self._track ~= track then return end
		self._elapsed += dt * self._speed
		local t = self._elapsed
		if t >= track.Length then
			if self._looped then
				t %= track.Length
				self._elapsed = t
			else
				t = track.Length
				self._playing = false
				if self._connection then self._connection:Disconnect(); self._connection = nil end
			end
		end
		self:_poseAt(t)
	end)
	self:_poseAt(0)
	return true
end

function AnimLib:Stop()
	self._playing = false
	if self._connection then self._connection:Disconnect(); self._connection = nil end
	return self
end

function AnimLib:SetSpeed(speed)
	self._speed = math.clamp(tonumber(speed) or 1, 0.05, 4)
	return self
end

function AnimLib:SetLooped(looped)
	self._looped = looped == true
	return self
end

function AnimLib:IsPlaying()
	return self._playing
end

function AnimLib:Destroy()
	self:Stop()
	self._track = nil
	table.clear(self._joints)
	self._destroyed = true
end

return AnimLib
