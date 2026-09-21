-- Cosmic moveset - Roblox Studio version
-- Setup:
-- 1) Import CosmicG.rbxmx into Studio and put it in ReplicatedStorage.
-- 2) The imported model must contain CosmicRigs and Anims.
-- 3) Optional: import Cosmic.rbxmx as ReplicatedStorage/Cosmic and add BlackBody for the transformation.
-- 4) Replace COSMIC_AUDIO_ID with a Roblox audio asset ID you own/use.
-- 5) Put this LocalScript in StarterPlayerScripts.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local EasingStyleMap = {
    [Enum.PoseEasingStyle.Linear] = Enum.EasingStyle.Linear,
    [Enum.PoseEasingStyle.Constant] = Enum.EasingStyle.Linear,
    [Enum.PoseEasingStyle.Elastic] = Enum.EasingStyle.Elastic,
    [Enum.PoseEasingStyle.Cubic] = Enum.EasingStyle.Cubic,
    [Enum.PoseEasingStyle.CubicV2] = Enum.EasingStyle.Cubic,
    [Enum.PoseEasingStyle.Bounce] = Enum.EasingStyle.Bounce,
    [Enum.PoseEasingStyle.Sine] = Enum.EasingStyle.Sine,
    [Enum.PoseEasingStyle.Quint] = Enum.EasingStyle.Quint,
    [Enum.PoseEasingStyle.Back] = Enum.EasingStyle.Back,
}

local EasingDirectionMap = {
    [Enum.PoseEasingDirection.In] = Enum.EasingDirection.In,
    [Enum.PoseEasingDirection.Out] = Enum.EasingDirection.Out,
    [Enum.PoseEasingDirection.InOut] = Enum.EasingDirection.InOut,
}

local function PlayKeyframeSequence(model, keyframeSequence, speedMult)
    speedMult = speedMult or 1

    if not model or not model.Parent or not keyframeSequence then
        return nil
    end

    local keyframes = {}
    for _, kf in ipairs(keyframeSequence:GetKeyframes()) do
        table.insert(keyframes, {Time = kf.Time, KF = kf})
    end
    table.sort(keyframes, function(a, b)
        return a.Time < b.Time
    end)

    if #keyframes == 0 then
        return nil
    end

    local jointData = {}
    local motorMap = {}
    local boneMap = {}

    local function resolveJoint(pose)
        local name = pose.Name

        if motorMap[name] then
            return motorMap[name], "Motor6D"
        end
        if boneMap[name] then
            return boneMap[name], "Bone"
        end

        for _, v in ipairs(model:GetDescendants()) do
            if v:IsA("Motor6D") and v.Part1 and v.Part1.Name == name then
                motorMap[name] = v
                return v, "Motor6D"
            elseif v:IsA("Bone") and v.Name == name then
                boneMap[name] = v
                return v, "Bone"
            end
        end

        return nil, nil
    end

    for _, entry in ipairs(keyframes) do
        for _, pose in ipairs(entry.KF:GetDescendants()) do
            if pose:IsA("Pose") and pose.Weight > 0 then
                local joint, jointType = resolveJoint(pose)
                if joint then
                    jointData[pose.Name] = jointData[pose.Name] or {}
                    table.insert(jointData[pose.Name], {
                        time = entry.Time,
                        cframe = pose.CFrame,
                        style = pose.EasingStyle,
                        dir = pose.EasingDirection,
                        joint = joint,
                        jtype = jointType,
                    })
                end
            end
        end
    end

    local totalLength = keyframes[#keyframes].Time
    if totalLength <= 0 then
        totalLength = 0.001
    end

    local startTime = os.clock()
    local skipOffset = 0
    local isPlaying = true
    local connection

    connection = RunService.Heartbeat:Connect(function()
        if not isPlaying or not model.Parent then
            if connection then
                connection:Disconnect()
            end
            return
        end

        local elapsed = (os.clock() - startTime) * speedMult
        local timePos = (elapsed + skipOffset) % totalLength

        for _, poses in pairs(jointData) do
            if #poses > 0 then
                local lastPose = poses[1]
                local nextPose = poses[#poses]

                for i = 1, #poses - 1 do
                    if timePos >= poses[i].time and timePos < poses[i + 1].time then
                        lastPose = poses[i]
                        nextPose = poses[i + 1]
                        break
                    end
                end

                local alpha = 0
                if nextPose.time > lastPose.time then
                    alpha = math.clamp(
                        (timePos - lastPose.time) / (nextPose.time - lastPose.time),
                        0,
                        1
                    )
                end

                local easedAlpha = TweenService:GetValue(
                    alpha,
                    EasingStyleMap[nextPose.style] or Enum.EasingStyle.Linear,
                    EasingDirectionMap[nextPose.dir] or Enum.EasingDirection.InOut
                )

                local finalCF = lastPose.cframe:Lerp(nextPose.cframe, easedAlpha)

                if lastPose.joint and lastPose.joint.Parent then
                    lastPose.joint.Transform = finalCF
                end
            end
        end
    end)

    return {
        Length = totalLength,
        Stop = function()
            isPlaying = false
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end,
        AddSkip = function(seconds)
            skipOffset += seconds
        end,
        GetPlayedTime = function()
            return (os.clock() - startTime) * speedMult + skipOffset
        end,
    }
end

local function getSkillProfile(tool: Tool)
    local name = string.lower(tool:GetAttribute("AbilityName") or tool.Name or "cosmic")

    if string.find(name, "awakening", 1, true) then
        return {
            burst = 220,
            radius = 11,
            duration = 2.2,
            armSwing = 1.2,
            colorA = Color3.fromRGB(170, 70, 255),
            colorB = Color3.fromRGB(55, 220, 255),
        }
    elseif string.find(name, "impact", 1, true) then
        return {
            burst = 160,
            radius = 16,
            duration = 1.25,
            armSwing = 1.0,
            colorA = Color3.fromRGB(255, 90, 210),
            colorB = Color3.fromRGB(120, 70, 255),
        }
    elseif string.find(name, "burst", 1, true) then
        return {
            burst = 130,
            radius = 10,
            duration = 1.4,
            armSwing = 1.0,
            colorA = Color3.fromRGB(80, 210, 255),
            colorB = Color3.fromRGB(160, 80, 255),
        }
    end

    return {
        burst = 95,
        radius = 8,
        duration = 1.1,
        armSwing = 0.8,
        colorA = Color3.fromRGB(140, 90, 255),
        colorB = Color3.fromRGB(70, 220, 255),
    }
end

local function makeEmitter(parent: Instance, colorA: Color3, colorB: Color3, speed: NumberRange, lifetime: NumberRange, size: NumberSequence)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Rate = 0
    emitter.Lifetime = lifetime
    emitter.Speed = speed
    emitter.SpreadAngle = Vector2.new(360, 360)
    emitter.Rotation = NumberRange.new(0, 360)
    emitter.RotSpeed = NumberRange.new(-260, 260)
    emitter.LightEmission = 1
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Color = ColorSequence.new(colorA, colorB)
    emitter.Size = size
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.03),
        NumberSequenceKeypoint.new(0.65, 0.2),
        NumberSequenceKeypoint.new(1, 1),
    })
    emitter.Parent = parent
    return emitter
end

local function createShockwave(folder: Folder, position: Vector3, radius: number, color: Color3, duration: number)
    local ring = Instance.new("Part")
    ring.Name = "Shockwave"
    ring.Anchored = true
    ring.CanCollide = false
    ring.CanQuery = false
    ring.CanTouch = false
    ring.Shape = Enum.PartType.Cylinder
    ring.Material = Enum.Material.Neon
    ring.Color = color
    ring.Transparency = 0.08
    ring.Size = Vector3.new(0.16, 2, 2)
    ring.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
    ring.Parent = folder

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Cylinder
    mesh.Parent = ring

    local started = os.clock()
    task.spawn(function()
        while ring.Parent do
            local t = os.clock() - started
            local a = math.clamp(t / duration, 0, 1)
            ring.Size = Vector3.new(0.16, 2 + radius * a, 2 + radius * a)
            ring.Transparency = 0.08 + (0.92 * a)
            if a >= 1 then break end
            RunService.RenderStepped:Wait()
        end
        if ring.Parent then ring:Destroy() end
    end)
end

local function playVisibleSkillVFX(character: Model, tool: Tool)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return 0 end

    local profile = getSkillProfile(tool)
    local folder = Instance.new("Folder")
    folder.Name = "RobuNexa_SkillVFX"
    folder.Parent = workspace

    local attachment = Instance.new("Attachment")
    attachment.Parent = root

    local emitter = makeEmitter(
        attachment,
        profile.colorA,
        profile.colorB,
        NumberRange.new(16, 34),
        NumberRange.new(0.28, 0.72),
        NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1.35),
            NumberSequenceKeypoint.new(0.45, 0.8),
            NumberSequenceKeypoint.new(1, 0),
        })
    )

    emitter:Emit(profile.burst)

    local light = Instance.new("PointLight")
    light.Brightness = 7
    light.Range = profile.radius * 2.2
    light.Color = profile.colorA
    light.Parent = root

    createShockwave(folder, root.Position - Vector3.new(0, 2.7, 0), profile.radius, profile.colorA, profile.duration)

    local pulse = Instance.new("Part")
    pulse.Name = "CosmicCore"
    pulse.Shape = Enum.PartType.Ball
    pulse.Anchored = true
    pulse.CanCollide = false
    pulse.CanQuery = false
    pulse.CanTouch = false
    pulse.Material = Enum.Material.Neon
    pulse.Color = profile.colorB
    pulse.Transparency = 0.12
    pulse.Size = Vector3.new(1, 1, 1)
    pulse.CFrame = CFrame.new(root.Position)
    pulse.Parent = folder

    local started = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not root.Parent or not folder.Parent then
            conn:Disconnect()
            return
        end

        local t = os.clock() - started
        local a = math.clamp(t / profile.duration, 0, 1)
        pulse.CFrame = CFrame.new(root.Position + Vector3.new(0, math.sin(t * 7) * 0.35, 0))
        local s = 1 + (profile.radius * 0.45) * math.sin(math.min(t / profile.duration, 1) * math.pi)
        pulse.Size = Vector3.new(s, s, s)
        pulse.Transparency = 0.12 + 0.88 * a
        light.Brightness = 7 * (1 - a)

        if t >= profile.duration then
            conn:Disconnect()
            attachment:Destroy()
            light:Destroy()
            if pulse.Parent then pulse:Destroy() end
            if folder.Parent then folder:Destroy() end
        end
    end)

    return profile.duration
end

local function playVisibleSkillAnimation(character: Model, duration: number, intensity: number)
    local root = character:FindFirstChild("HumanoidRootPart")
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    if not root or not torso then return end

    local rightShoulder = torso:FindFirstChild("RightShoulder") or torso:FindFirstChild("Right Shoulder")
    local leftShoulder = torso:FindFirstChild("LeftShoulder") or torso:FindFirstChild("Left Shoulder")
    local neck = torso:FindFirstChild("Neck")

    local originalCFrame = root.CFrame
    local originalRight = rightShoulder and rightShoulder.Transform
    local originalLeft = leftShoulder and leftShoulder.Transform
    local originalNeck = neck and neck.Transform

    local started = os.clock()
    while root.Parent and os.clock() - started < duration do
        local t = (os.clock() - started) / duration
        local wave = math.sin(t * math.pi * 4)
        local lift = math.sin(t * math.pi)

        root.CFrame = originalCFrame
            * CFrame.new(0, lift * 0.22 * intensity, 0)
            * CFrame.Angles(0, wave * 0.07 * intensity, wave * 0.04 * intensity)

        if rightShoulder and originalRight then
            rightShoulder.Transform = originalRight
                * CFrame.Angles(-wave * 0.85 * intensity - lift * 0.55 * intensity, 0, -0.2 * intensity)
        end
        if leftShoulder and originalLeft then
            leftShoulder.Transform = originalLeft
                * CFrame.Angles(wave * 0.85 * intensity + lift * 0.55 * intensity, 0, 0.2 * intensity)
        end
        if neck and originalNeck then
            neck.Transform = originalNeck * CFrame.Angles(0, wave * 0.08 * intensity, 0)
        end

        RunService.RenderStepped:Wait()
    end

    if root.Parent then root.CFrame = originalCFrame end
    if rightShoulder and originalRight then rightShoulder.Transform = originalRight end
    if leftShoulder and originalLeft then leftShoulder.Transform = originalLeft end
    if neck and originalNeck then neck.Transform = originalNeck end
end

local function playCameraShake(duration: number, magnitude: number)
    local started = os.clock()
    while os.clock() - started < duration do
        local t = os.clock() - started
        local falloff = 1 - math.clamp(t / duration, 0, 1)
        camera.CFrame = camera.CFrame
            * CFrame.new(
                (math.random() - 0.5) * magnitude * falloff,
                (math.random() - 0.5) * magnitude * falloff,
                0
            )
            * CFrame.Angles(
                0,
                0,
                (math.random() - 0.5) * math.rad(3) * falloff
            )
        RunService.RenderStepped:Wait()
    end
end

local function getCosmicAsset()
    local asset = ReplicatedStorage:FindFirstChild("CosmicG")
    if not asset then
        warn("[Cosmic] ReplicatedStorage/CosmicG is missing. Import CosmicG.rbxmx first.")
        return nil
    end
    return asset
end

local function createSkybox()
    local originalSky = Lighting:FindFirstChildOfClass("Sky")
    local sky = Instance.new("Sky")
    local id = "rbxassetid://7188341508"

    sky.SkyboxBk = id
    sky.SkyboxDn = id
    sky.SkyboxFt = id
    sky.SkyboxLf = id
    sky.SkyboxRt = id
    sky.SkyboxUp = id
    sky.Parent = Lighting

    task.delay(9, function()
        if sky.Parent then
            sky:Destroy()
        end

        if originalSky and originalSky.Parent == nil then
            originalSky.Parent = Lighting
        end

        local gui = Instance.new("ScreenGui")
        gui.IgnoreGuiInset = true
        gui.ResetOnSpawn = false
        gui.Parent = player:WaitForChild("PlayerGui")

        local frame = Instance.new("Frame")
        frame.Size = UDim2.fromScale(1, 1)
        frame.BackgroundColor3 = Color3.new(0, 0, 0)
        frame.BackgroundTransparency = 0
        frame.Parent = gui

        task.delay(2, function()
            if not frame.Parent then return end

            local tween = TweenService:Create(
                frame,
                TweenInfo.new(1),
                {BackgroundTransparency = 1}
            )
            tween:Play()
            tween.Completed:Connect(function()
                gui:Destroy()
            end)
        end)
    end)
end

local function getCharacter()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    return character, humanoid, root
end

local function stopDefaultAnimator(humanoid)
    for _, child in ipairs(humanoid:GetChildren()) do
        if child:IsA("Animator") then
            child:Destroy()
        end
    end
end

local function restoreAnimator(humanoid)
    if not humanoid:FindFirstChildOfClass("Animator") then
        Instance.new("Animator", humanoid)
    end
end

local function waitForAnimation(animator)
    if not animator then return end
    local started = os.clock()

    while os.clock() - started < (animator.Length + 5) do
        if animator:GetPlayedTime() >= animator.Length then
            break
        end
        task.wait(0.05)
    end

    animator:Stop()
end

local function runCosmic(abilityTool: Tool)
    local character, humanoid, root = getCharacter()
    local originalCameraType = camera.CameraType
    local originalCameraSubject = camera.CameraSubject

    local asset = getCosmicAsset()
    if not asset then return end

    -- The decoded repository asset is a hierarchy-only reconstruction. Its
    -- original Pose.CFrame / MeshId / ParticleEmitter property payload is not
    -- available, so trying to play those off-screen source rigs cannot show
    -- the intended result. Keep the player in place and render the skill VFX
    -- directly around the real character instead.
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = humanoid

    local profile = getSkillProfile(abilityTool)
    local duration = playVisibleSkillVFX(character, abilityTool)
    local intensity = math.clamp(profile.armSwing, 0.6, 1.4)

    task.spawn(function()
        playVisibleSkillAnimation(character, math.max(duration, 0.8), intensity)
    end)

    task.spawn(function()
        playCameraShake(math.min(duration, 0.65), 0.18 * intensity)
    end)

    -- Still attempt to use any valid decoded KeyframeSequence data that exists,
    -- but never move the player to the source asset's original world position.
    local rigs = asset:FindFirstChild("CosmicRigs")
    local anims = asset:FindFirstChild("Anims")
    local playerAnim = anims and anims:FindFirstChild("Player")
    if rigs and anims and playerAnim then
        local safeOk, safeErr = pcall(function()
            PlayKeyframeSequence(character, playerAnim, 1)
        end)
        if not safeOk then
            warn("[Cosmic] Optional decoded keyframe animation skipped: " .. tostring(safeErr))
        end
    end

    task.wait(duration)

    camera.CameraType = originalCameraType or Enum.CameraType.Custom
    camera.CameraSubject = originalCameraSubject or humanoid
end

local function bindCosmicTool(tool: Tool)
    if tool:GetAttribute("RobuNexaCosmicBound") then
        return
    end

    if tool:GetAttribute("RobuNexaMoveset") ~= "Cosmic" and tool.Name ~= "Cosmic" then
        return
    end

    tool.RequiresHandle = false
    tool.CanBeDropped = false
    tool:SetAttribute("RobuNexaCosmicBound", true)

    tool.Activated:Connect(function()
        if not tool.Enabled then
            return
        end

        tool.Enabled = false

        local ok, err = xpcall(function() runCosmic(tool) end, debug.traceback)
        if not ok then
            warn("[Cosmic] " .. err)

            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")

            if root then root.Anchored = false end
            if humanoid then restoreAnimator(humanoid) end
        end

        if tool.Parent then
            tool.Enabled = true
        end
    end)
end

local function scanForCosmicTools(container: Instance)
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Tool") then
            bindCosmicTool(child)
        end
    end

    container.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            bindCosmicTool(child)
        end
    end)
end

local backpack = player:WaitForChild("Backpack")
scanForCosmicTools(backpack)

player.CharacterAdded:Connect(function(character)
    scanForCosmicTools(character)
end)

if player.Character then
    scanForCosmicTools(player.Character)
end

-- Fallback: if the server distributor is not installed, always create
-- the primary Cosmic tool locally so the moveset remains usable.
if not backpack:FindFirstChild("Cosmic") then
    local tool = Instance.new("Tool")
    tool.Name = "Cosmic"
    tool.ToolTip = "Play Cosmic moveset"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    tool:SetAttribute("RobuNexaMoveset", "Cosmic")
    tool.Parent = backpack
end
