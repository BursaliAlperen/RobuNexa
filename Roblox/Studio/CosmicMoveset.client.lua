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

local function playFallbackVFX(character: Model, abilityName: string)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local folder = Instance.new("Folder")
    folder.Name = "RobuNexaRuntimeVFX"
    folder.Parent = workspace

    local attachment = Instance.new("Attachment")
    attachment.Parent = root

    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "AbilityParticles"
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Rate = 0
    emitter.Lifetime = NumberRange.new(0.25, 0.65)
    emitter.Speed = NumberRange.new(18, 34)
    emitter.SpreadAngle = Vector2.new(360, 360)
    emitter.Rotation = NumberRange.new(0, 360)
    emitter.RotSpeed = NumberRange.new(-240, 240)
    emitter.LightEmission = 1
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.4),
        NumberSequenceKeypoint.new(0.45, 0.8),
        NumberSequenceKeypoint.new(1, 0),
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.05),
        NumberSequenceKeypoint.new(0.7, 0.25),
        NumberSequenceKeypoint.new(1, 1),
    })
    emitter.Parent = attachment

    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.72
    highlight.OutlineTransparency = 0.15
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character

    local ring = Instance.new("Part")
    ring.Name = "Shockwave"
    ring.Anchored = true
    ring.CanCollide = false
    ring.CanQuery = false
    ring.CanTouch = false
    ring.Shape = Enum.PartType.Cylinder
    ring.Material = Enum.Material.Neon
    ring.Size = Vector3.new(0.18, 2, 2)
    ring.CFrame = root.CFrame * CFrame.Angles(0, 0, math.rad(90))
    ring.Transparency = 0.15
    ring.Parent = folder

    local ringMesh = Instance.new("SpecialMesh")
    ringMesh.MeshType = Enum.MeshType.Cylinder
    ringMesh.Parent = ring

    local burstCount = 80
    if string.find(string.lower(abilityName), "awakening") then
        burstCount = 150
    elseif string.find(string.lower(abilityName), "impact") then
        burstCount = 110
    elseif string.find(string.lower(abilityName), "burst") then
        burstCount = 95
    end

    emitter:Emit(burstCount)

    local start = os.clock()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not root.Parent or not ring.Parent then
            if connection then connection:Disconnect() end
            return
        end

        local t = os.clock() - start
        local a = math.clamp(t / 0.9, 0, 1)
        ring.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, 0, math.rad(90))
        ring.Size = Vector3.new(0.18, 2 + a * 24, 2 + a * 24)
        ring.Transparency = 0.15 + a * 0.85
        highlight.FillTransparency = 0.72 + a * 0.28

        if t >= 0.9 then
            connection:Disconnect()
            ring:Destroy()
            attachment:Destroy()
            highlight:Destroy()
            folder:Destroy()
        end
    end)

    return 0.9
end

local function playFallbackCharacterAnimation(character: Model, duration: number)
    local root = character:FindFirstChild("HumanoidRootPart")
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    local rightShoulder = torso and torso:FindFirstChild("Right Shoulder")
    local leftShoulder = torso and torso:FindFirstChild("Left Shoulder")
    if not root then return end

    local originalRoot = root.CFrame
    local originalRight = rightShoulder and rightShoulder.Transform
    local originalLeft = leftShoulder and leftShoulder.Transform

    local start = os.clock()
    while os.clock() - start < duration and character.Parent do
        local t = (os.clock() - start) / duration
        local pulse = math.sin(t * math.pi * 3)
        root.CFrame = originalRoot * CFrame.new(0, math.sin(t * math.pi) * 0.18, 0) * CFrame.Angles(0, t * math.pi * 2, pulse * 0.035)

        if rightShoulder then
            rightShoulder.Transform = originalRight * CFrame.Angles(-pulse * 0.7, 0, -0.25)
        end
        if leftShoulder then
            leftShoulder.Transform = originalLeft * CFrame.Angles(pulse * 0.7, 0, 0.25)
        end
        RunService.RenderStepped:Wait()
    end

    if root.Parent then root.CFrame = originalRoot end
    if rightShoulder and originalRight then rightShoulder.Transform = originalRight end
    if leftShoulder and originalLeft then leftShoulder.Transform = originalLeft end
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

local function runCosmic(abilityTool)
    local character, humanoid, root = getCharacter()
    local originalCFrame = root.CFrame
    local originalCameraType = camera.CameraType
    local originalCameraSubject = camera.CameraSubject

    local asset = getCosmicAsset()
    if not asset then return end

    local rigs = asset:FindFirstChild("CosmicRigs")
    local anims = asset:FindFirstChild("Anims")

    if not rigs or not anims then
        warn("[Cosmic] CosmicRigs or Anims is missing inside CosmicG.")
        return
    end

    local godRig = rigs:FindFirstChild("GOD")
    local sceneRig = rigs:FindFirstChild("SceneRig")

    local godAnim = anims:FindFirstChild("GOD")
    local sceneAnim = anims:FindFirstChild("SceneRig")
    local playerAnim = anims:FindFirstChild("Player")
    local playerTwoAnim = anims:FindFirstChild("PlayerTwo")

    local backgroundAnimations = {}
    local playerAnimation

    stopDefaultAnimator(humanoid)

    root.CFrame = CFrame.new(
        876.199097, 1882.01294, -397.585388,
        -0.565931678, 4.82408259e-17, 0.824452102,
        -5.49948317e-17, 1, 2.07622863e-17,
        -0.824452102, 3.35905705e-17, -0.565931678
    )
    root.Anchored = true

    createSkybox()

    -- Studio cannot use getcustomasset("Cosmic.mp3").
    -- Put your Roblox audio asset ID here if you want the sound.
    local COSMIC_AUDIO_ID = ""
    if COSMIC_AUDIO_ID ~= "" then
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. COSMIC_AUDIO_ID
        sound.Volume = 1
        sound.Parent = workspace
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end

    if godRig and godAnim then
        table.insert(backgroundAnimations, PlayKeyframeSequence(godRig, godAnim))
    end

    if sceneRig and sceneAnim then
        table.insert(backgroundAnimations, PlayKeyframeSequence(sceneRig, sceneAnim))
    end

    if playerAnim then
        playerAnimation = PlayKeyframeSequence(character, playerAnim)
    end

    -- The GitHub decoded manifest contains the instance hierarchy, but the
    -- original Pose.CFrame/particle property payload is not present. If that
    -- data is missing, run a deterministic local fallback so clicking a skill
    -- still produces animation + VFX instead of a silent activation.
    local abilityName = abilityTool and abilityTool:GetAttribute("AbilityName") or "Cosmic"
    local fallbackDuration = playFallbackVFX(character, abilityName) or 0.9
    task.spawn(function()
        playFallbackCharacterAnimation(character, math.max(fallbackDuration, 1.25))
    end)

    task.delay(8, function()
        for _, anim in ipairs(backgroundAnimations) do
            if anim then anim.AddSkip(8) end
        end
        if playerAnimation then
            playerAnimation.AddSkip(9.9)
        end
    end)

    waitForAnimation(playerAnimation)

    root.CFrame = originalCFrame
    task.wait(2.9)

    if playerTwoAnim then
        local playerAnimation2 = PlayKeyframeSequence(character, playerTwoAnim)

        if playerAnimation2 then
            playerAnimation2.AddSkip(27.8)
            waitForAnimation(playerAnimation2)
        end
    end

    root.Anchored = false
    root.CFrame = originalCFrame
    camera.CameraType = originalCameraType or Enum.CameraType.Custom
    camera.CameraSubject = originalCameraSubject or humanoid

    for _, anim in ipairs(backgroundAnimations) do
        if anim then anim.Stop() end
    end

    restoreAnimator(humanoid)
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
