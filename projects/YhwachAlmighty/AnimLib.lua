-- Studio-safe, Uhhhhhh-style keyframe reader/player.
-- Track.frombuffer accepts the raw binary .anim bytes as a string or buffer.
-- Track.frominstance accepts a Roblox KeyframeSequence.
-- No executor-only readfile/request/getcustomasset functions are used.
-- Local Motor6D.Transform edits are not guaranteed to replicate.

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local AnimLib = {}
AnimLib.__index = AnimLib
AnimLib.Track = {}

function AnimLib.Track.frombuffer(input)
	local buf
	if typeof(input) == "buffer" then buf = input
	elseif type(input) == "string" then buf = buffer.fromstring(input)
	else error("Track.frombuffer expects a string or buffer") end
	local cursor, size = 0, buffer.len(buf)
	local function need(n) assert(size - cursor >= n, "Invalid .anim: unexpected end of buffer") end
	local function str()
		need(2); local n = buffer.readu16(buf, cursor); cursor += 2
		need(n); local v = buffer.readstring(buf, cursor, n); cursor += n; return v
	end
	local function u32() need(4); local v = buffer.readu32(buf, cursor); cursor += 4; return v end
	local function f32() need(4); local v = buffer.readf32(buf, cursor); cursor += 4; return v end
	local track = { Name = str(), Time = 0, Keyframes = {} }
	local count = u32()
	assert(count > 0 and count <= 100000, "Invalid .anim: unreasonable keyframe count")
	for _ = 1, count do
		local t, nposes = f32(), u32()
		assert(nposes <= 10000, "Invalid .anim: unreasonable pose count")
		local frame = { Time = t, Poses = {} }
		track.Time = math.max(track.Time, t)
		for _ = 1, nposes do
			local name, weight, style, direction = str(), f32(), str(), str()
			local cf = CFrame.new(f32(),f32(),f32(),f32(),f32(),f32(),f32(),f32(),f32(),f32(),f32(),f32())
			table.insert(frame.Poses, {Name=name, Weight=weight, EasingStyle=style, EasingDirection=direction, CFrame=cf})
		end
		table.insert(track.Keyframes, frame)
	end
	assert(cursor == size, "Invalid .anim: unexpected trailing bytes")
	table.sort(track.Keyframes, function(a,b) return a.Time < b.Time end)
	return track
end

function AnimLib.Track.frominstance(sequence)
	assert(typeof(sequence) == "Instance" and sequence:IsA("KeyframeSequence"), "Expected KeyframeSequence")
	local track = { Name=sequence.Name, Time=0, Loop=sequence.Loop, Keyframes={} }
	for _, keyframe in ipairs(sequence:GetKeyframes()) do
		local frame = { Time=keyframe.Time, Poses={} }
		track.Time = math.max(track.Time, keyframe.Time)
		for _, pose in ipairs(keyframe:GetDescendants()) do
			if pose:IsA("Pose") then
				table.insert(frame.Poses, {Name=pose.Name, Weight=pose.Weight, EasingStyle=pose.EasingStyle.Name, EasingDirection=pose.EasingDirection.Name, CFrame=pose.CFrame})
			end
		end
		table.insert(track.Keyframes, frame)
	end
	assert(#track.Keyframes > 0, "KeyframeSequence has no keyframes")
	table.sort(track.Keyframes, function(a,b) return a.Time < b.Time end)
	return track
end

local function buildPoseTracks(track)
	assert(type(track) == "table" and type(track.Keyframes) == "table" and #track.Keyframes > 0, "Invalid animation track")
	local result = {}
	for _, frame in ipairs(track.Keyframes) do
		for _, pose in ipairs(frame.Poses) do
			if (pose.Weight or 1) > 0 then
				local samples = result[pose.Name]
				if not samples then samples = {}; result[pose.Name] = samples end
				table.insert(samples, {Time=frame.Time, CFrame=pose.CFrame, Weight=pose.Weight or 1, EasingStyle=pose.EasingStyle, EasingDirection=pose.EasingDirection})
			end
		end
	end
	for _, samples in pairs(result) do table.sort(samples, function(a,b) return a.Time < b.Time end) end
	return result
end

local function easedAlpha(alpha, style, direction)
	alpha = math.clamp(alpha, 0, 1)
	if style == "Constant" then
		if direction == "In" then return 1 elseif direction == "Out" then return 0 end
		return alpha < 0.5 and 0 or 1
	end
	if style == "CubicV2" then style = "Cubic" end
	local okStyle, es = pcall(function() return Enum.EasingStyle[style or "Linear"] end)
	local okDirection, ed = pcall(function() return Enum.EasingDirection[direction or "InOut"] end)
	if not okStyle or not okDirection or not es or not ed then return alpha end
	local ok, value = pcall(function() return TweenService:GetValue(alpha, es, ed) end)
	return ok and value or alpha
end

function AnimLib.new()
	return setmetatable({_track=nil, _poseTracks={}, _connection=nil, _joints={}, _original={}, _elapsed=0, _speed=1, _looped=false, _playing=false, _destroyed=false}, AnimLib)
end

function AnimLib:LoadTrack(track, rig)
	assert(not self._destroyed, "Player destroyed")
	assert(typeof(rig) == "Instance" and rig:IsA("Model"), "Expected character Model")
	self:Stop()
	self._poseTracks = buildPoseTracks(track)
	self._joints, self._original = {}, {}
	for _, item in ipairs(rig:GetDescendants()) do
		if item:IsA("Motor6D") and item.Part0 and item.Part1 then
			-- Uhhhhhh keys joints by Part1.Name (e.g. "Right Arm").
			self._joints[item.Part1.Name] = item
			self._original[item.Part1.Name] = item.Transform
			if not self._joints[item.Name] then
				self._joints[item.Name] = item
				self._original[item.Name] = item.Transform
			end
		end
	end
	self._track = {Name=track.Name or "<unknown>", Length=math.max(tonumber(track.Time) or 0, 0.001)}
	self._elapsed = 0
	self._looped = track.Loop == true
	return self
end

function AnimLib:LoadSequence(sequence, rig)
	return self:LoadTrack(AnimLib.Track.frominstance(sequence), rig)
end

function AnimLib:LoadBuffer(rawBytes, rig)
	return self:LoadTrack(AnimLib.Track.frombuffer(rawBytes), rig)
end

function AnimLib:_step(t)
	for name, joint in pairs(self._joints) do
		if joint.Parent then
			local samples, cf = self._poseTracks[name], CFrame.identity
			if samples and #samples > 0 then
				local before, after
				for _, sample in ipairs(samples) do
					if sample.Time <= t then before = sample else after = sample; break end
				end
				if before and after then
					local span = after.Time - before.Time
					local alpha = span > 0 and (t-before.Time)/span or 1
					alpha = easedAlpha(alpha, before.EasingStyle, before.EasingDirection)
					cf = before.CFrame:Lerp(after.CFrame, alpha)
				elseif before then cf = before.CFrame
				elseif after then cf = after.CFrame end
			end
			joint.Transform = cf
		end
	end
end

function AnimLib:Play()
	if not self._track or self._destroyed then return false end
	if self._connection then self._connection:Disconnect() end
	self._elapsed, self._playing = 0, true
	local track = self._track
	self._connection = RunService.RenderStepped:Connect(function(dt)
		if not self._playing or self._track ~= track then return end
		self._elapsed += dt * self._speed
		local t = self._elapsed
		if t >= track.Length then
			if self._looped then t %= track.Length; self._elapsed = t
			else self:_step(track.Length); self:Stop(); return end
		end
		self:_step(t)
	end)
	self:_step(0)
	return true
end

function AnimLib:Stop()
	self._playing = false
	if self._connection then self._connection:Disconnect(); self._connection = nil end
	for name, joint in pairs(self._joints) do
		local original = self._original[name]
		if joint.Parent and original then joint.Transform = original end
	end
	return self
end
function AnimLib:SetSpeed(value) self._speed = math.clamp(tonumber(value) or 1, 0.05, 4); return self end
function AnimLib:SetLooped(value) self._looped = value == true; return self end
function AnimLib:IsPlaying() return self._playing end
function AnimLib:Destroy()
	self:Stop(); self._track = nil; table.clear(self._poseTracks); table.clear(self._joints); table.clear(self._original); self._destroyed = true
end
return AnimLib
