-- Mafia Boss moveset for RobuNexa / NAM.
-- Standalone cosmetic moveset: procedural R6/R15 poses, mobile-friendly controls,
-- local VFX, stance aura and safe cleanup. It does not control other accounts or
-- apply damage to other players. Custom animation/audio files can be added later.
local modules = {}
local function AddModule(m)
    table.insert(modules, m)
end

AddModule(function()
    local m = {}
    m.ModuleType = "MOVESET"
    m.Name = "Mafia Boss"
    m.InternalName = "MAFIABOSS"
    m.Description = "Mafia Boss: Idle, Boss Stance, Threaten, Call Backup, Execute, Intimidate and Victory."
    m.Assets = {}

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local Debris = game:GetService("Debris")

    local figure
    local actionName
    local actionUntil = 0
    local actionStarted = 0
    local savedTransforms = {}
    local poseMotors = {}
    local buttons = {}
    local connections = {}
    local effects = {}
    local panel
    local aura
    local lastMovementState = "Idle"
    local currentActionToken = 0
    local originalAutoRotate
    local humanoid
    local rootPart
    local destroyed = false

    local GOLD = Color3.fromRGB(224, 184, 94)
    local DARK = Color3.fromRGB(35, 29, 25)
    local RED = Color3.fromRGB(168, 36, 42)
    local CREAM = Color3.fromRGB(246, 226, 185)

    local function resolvePart(model, names)
        if not model then return nil end
        for _, name in ipairs(names) do
            local part = model:FindFirstChild(name, true)
            if part and part:IsA("BasePart") then return part end
        end
        for _, item in ipairs(model:GetDescendants()) do
            if item:IsA("BasePart") then return item end
        end
        return nil
    end

    local function refreshRig(model)
        figure = model
        humanoid = model and model:FindFirstChildOfClass("Humanoid")
        rootPart = resolvePart(model, {"HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "Head"})
        poseMotors = {}
        if model then
            for _, obj in ipairs(model:GetDescendants()) do
                if obj:IsA("Motor6D") then
                    local key = obj.Name
                    if not poseMotors[key] then poseMotors[key] = obj end
                    if obj.Part0 and obj.Part1 then
                        local p0, p1 = obj.Part0.Name, obj.Part1.Name
                        if p0 == "HumanoidRootPart" or p0 == "Torso" or p0 == "LowerTorso" then
                            if p1 == "Head" then poseMotors.Neck = poseMotors.Neck or obj end
                            if p1 == "Right Arm" or p1 == "RightUpperArm" then poseMotors.RightArm = poseMotors.RightArm or obj end
                            if p1 == "Left Arm" or p1 == "LeftUpperArm" then poseMotors.LeftArm = poseMotors.LeftArm or obj end
                            if p1 == "Right Leg" or p1 == "RightUpperLeg" then poseMotors.RightLeg = poseMotors.RightLeg or obj end
                            if p1 == "Left Leg" or p1 == "LeftUpperLeg" then poseMotors.LeftLeg = poseMotors.LeftLeg or obj end
                            if p1 == "Torso" or p1 == "UpperTorso" then poseMotors.RootMotor = poseMotors.RootMotor or obj end
                        end
                    end
                end
            end
        end
    end

    local function getMotor(key)
        local aliases = {
            RightArm = {"RightArm", "Right Shoulder", "RightShoulder", "RightShoulderRigAttachment"},
            LeftArm = {"LeftArm", "Left Shoulder", "LeftShoulder", "LeftShoulderRigAttachment"},
            Neck = {"Neck"},
            RootMotor = {"RootMotor", "Root", "RootJoint", "Waist"},
            RightLeg = {"RightLeg", "Right Hip", "RightHip"},
            LeftLeg = {"LeftLeg", "Left Hip", "LeftHip"},
        }
        if poseMotors[key] then return poseMotors[key] end
        for _, alias in ipairs(aliases[key] or {}) do
            if poseMotors[alias] then return poseMotors[alias] end
        end
        return nil
    end

    local function resetPose()
        for motor, transform in pairs(savedTransforms) do
            if motor and motor.Parent then
                pcall(function() motor.Transform = transform end)
            end
        end
        savedTransforms = {}
    end

    local function capturePose()
        savedTransforms = {}
        for _, motor in pairs(poseMotors) do
            if motor and motor.Parent then savedTransforms[motor] = motor.Transform end
        end
    end

    local function setTransform(key, cf)
        local motor = getMotor(key)
        if motor and motor.Parent then
            if savedTransforms[motor] == nil then savedTransforms[motor] = motor.Transform end
            motor.Transform = cf
        end
    end

    local function cleanupEffect(effect)
        if effect and effect.Parent then
            effects[effect] = nil
            effect:Destroy()
        end
    end

    local function clearEffects()
        for effect in pairs(effects) do
            if effect and effect.Parent then pcall(function() effect:Destroy() end) end
        end
        effects = {}
        if aura and aura.Parent then aura:Destroy() end
        aura = nil
    end

    local function makeBurst(color, size, lifetime, shape)
        if not rootPart or not rootPart.Parent then return end
        local part = Instance.new("Part")
        part.Name = "MafiaBossVFX"
        part.Shape = shape or Enum.PartType.Ball
        part.Size = Vector3.new(size, size, size)
        part.Material = Enum.Material.Neon
        part.Color = color
        part.Transparency = 0.18
        part.Anchored = true
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.CastShadow = false
        part.CFrame = rootPart.CFrame
        part.Parent = workspace
        effects[part] = true
        local tween = TweenService:Create(part, TweenInfo.new(lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(size * 2.8, size * 2.8, size * 2.8),
            Transparency = 1,
        })
        tween:Play()
        Debris:AddItem(part, lifetime + 0.15)
        task.delay(lifetime + 0.2, function() effects[part] = nil end)
    end

    local function makeRing(color, diameter, lifetime)
        if not rootPart or not rootPart.Parent then return end
        local ring = Instance.new("Part")
        ring.Name = "MafiaBossRingVFX"
        ring.Shape = Enum.PartType.Cylinder
        ring.Size = Vector3.new(0.12, 1, 1)
        ring.Material = Enum.Material.Neon
        ring.Color = color
        ring.Transparency = 0.12
        ring.Anchored = true
        ring.CanCollide = false
        ring.CanTouch = false
        ring.CanQuery = false
        ring.CastShadow = false
        ring.CFrame = CFrame.new(rootPart.Position - Vector3.new(0, 2.6, 0)) * CFrame.Angles(0, 0, math.rad(90))
        ring.Parent = workspace
        effects[ring] = true
        local tween = TweenService:Create(ring, TweenInfo.new(lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(0.12, diameter, diameter),
            Transparency = 1,
        })
        tween:Play()
        Debris:AddItem(ring, lifetime + 0.15)
        task.delay(lifetime + 0.2, function() effects[ring] = nil end)
    end

    local function setAura(enabled)
        if not enabled then
            if aura and aura.Parent then aura:Destroy() end
            aura = nil
            return
        end
        if not rootPart or not rootPart.Parent or (aura and aura.Parent) then return end
        local part = Instance.new("Part")
        part.Name = "MafiaBossAura"
        part.Shape = Enum.PartType.Ball
        part.Size = Vector3.new(5.5, 5.5, 5.5)
        part.Material = Enum.Material.ForceField
        part.Color = GOLD
        part.Transparency = 0.72
        part.Anchored = false
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.Massless = true
        part.CastShadow = false
        part.CFrame = rootPart.CFrame
        part.Parent = figure
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = rootPart
        weld.Part1 = part
        weld.Parent = part
        aura = part
    end

    local function notify(message)
        pcall(function() Util.Notify("Mafia Boss: " .. message) end)
    end

    local function stopAction(keepStance)
        currentActionToken += 1
        resetPose()
        if not keepStance then
            actionName = nil
            setAura(false)
        end
    end

    local function beginAction(name, duration)
        if not figure or not figure.Parent then
            notify("Reanimation karakteri hazır değil.")
            return
        end
        stopAction(false)
        refreshRig(figure)
        capturePose()
        actionName = name
        actionStarted = os.clock()
        actionUntil = actionStarted + (duration or 2.8)
        currentActionToken += 1
        local token = currentActionToken

        if name == "Boss Stance" then
            setAura(true)
            makeRing(GOLD, 3.5, 0.55)
            notify("Boss duruşu aktif.")
        elseif name == "Threaten" then
            makeBurst(RED, 1.3, 0.42)
            makeRing(RED, 3.2, 0.55)
        elseif name == "Call Backup" then
            makeBurst(GOLD, 1.1, 0.5)
            makeRing(GOLD, 4.2, 0.7)
            task.delay(0.16, function()
                if currentActionToken == token and rootPart and rootPart.Parent then
                    makeRing(CREAM, 5.2, 0.7)
                end
            end)
        elseif name == "Execute" then
            makeBurst(RED, 1.5, 0.3)
            makeRing(RED, 2.6, 0.38)
        elseif name == "Intimidate" then
            makeBurst(GOLD, 2.2, 0.75)
            makeRing(RED, 4.8, 0.8)
        elseif name == "Victory" then
            makeBurst(GOLD, 1.8, 0.6)
            makeRing(GOLD, 4.5, 0.7)
        end
    end

    local function applyPose()
        if not actionName then return end
        local t = os.clock() - actionStarted
        local wave = math.sin(t * 8) * 0.035

        if actionName ~= "Boss Stance" and os.clock() >= actionUntil then
            stopAction(false)
            return
        end

        if actionName == "Boss Stance" then
            setTransform("RightArm", CFrame.Angles(math.rad(-28), 0, math.rad(26)))
            setTransform("LeftArm", CFrame.Angles(math.rad(-18), 0, math.rad(-22)))
            setTransform("Neck", CFrame.Angles(math.rad(-5), math.rad(8), 0))
            setTransform("RootMotor", CFrame.Angles(0, math.rad(math.sin(t * 1.2) * 2), 0))
        elseif actionName == "Threaten" then
            setTransform("RightArm", CFrame.Angles(math.rad(-72) + wave, 0, math.rad(20)))
            setTransform("LeftArm", CFrame.Angles(math.rad(-18), 0, math.rad(-12)))
            setTransform("Neck", CFrame.Angles(math.rad(10), math.rad(-10), 0))
            setTransform("RootMotor", CFrame.Angles(math.rad(-4), 0, 0))
        elseif actionName == "Call Backup" then
            setTransform("RightArm", CFrame.Angles(math.rad(-108), 0, math.rad(8)))
            setTransform("LeftArm", CFrame.Angles(math.rad(-30), 0, math.rad(-18)))
            setTransform("Neck", CFrame.Angles(math.rad(-8), 0, 0))
            setTransform("RootMotor", CFrame.Angles(math.rad(-3), 0, 0))
        elseif actionName == "Execute" then
            local swing = math.sin(math.min(t / 0.32, 1) * math.pi)
            setTransform("RightArm", CFrame.Angles(math.rad(-110 + 75 * swing), 0, math.rad(5)))
            setTransform("LeftArm", CFrame.Angles(math.rad(18), 0, math.rad(-25)))
            setTransform("Neck", CFrame.Angles(math.rad(12), 0, 0))
            setTransform("RootMotor", CFrame.Angles(math.rad(-7 * swing), 0, 0))
        elseif actionName == "Intimidate" then
            setTransform("RightArm", CFrame.Angles(math.rad(-88), 0, math.rad(12)))
            setTransform("LeftArm", CFrame.Angles(math.rad(-88), 0, math.rad(-12)))
            setTransform("Neck", CFrame.Angles(math.rad(-8), math.rad(math.sin(t * 9) * 5), 0))
            setTransform("RootMotor", CFrame.Angles(math.rad(-2), 0, 0))
        elseif actionName == "Victory" then
            setTransform("RightArm", CFrame.Angles(math.rad(-150), 0, math.rad(8)))
            setTransform("LeftArm", CFrame.Angles(math.rad(-150), 0, math.rad(-8)))
            setTransform("Neck", CFrame.Angles(math.rad(-6), 0, 0))
        end
    end

    local function createButton(parent, name, order)
        local button = Instance.new("TextButton")
        button.Name = string.gsub(name, " ", "") .. "Button"
        button.LayoutOrder = order
        button.BackgroundColor3 = DARK
        button.BorderSizePixel = 0
        button.Font = Enum.Font.GothamSemibold
        button.Text = name
        button.TextColor3 = CREAM
        button.TextSize = 12
        button.TextWrapped = true
        button.AutoButtonColor = true
        button.Parent = parent
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = button
        local stroke = Instance.new("UIStroke")
        stroke.Color = GOLD
        stroke.Thickness = 1
        stroke.Transparency = 0.18
        stroke.Parent = button
        buttons[name] = button
        button.Activated:Connect(function()
            if name == "Boss Stance" and actionName == name then
                stopAction(false)
                notify("Boss duruşu kapatıldı.")
            else
                beginAction(name, name == "Boss Stance" and 999999 or (name == "Victory" and 2.4 or 2.8))
            end
        end)
    end

    m.Config = function(parent: GuiBase2d)
        if panel and panel.Parent then panel:Destroy() end
        panel = Instance.new("Frame")
        panel.Name = "MafiaBossControls"
        panel.BackgroundTransparency = 1
        panel.Size = UDim2.new(1, 0, 0, 166)
        panel.Parent = parent

        local title = Instance.new("TextLabel")
        title.Name = "MafiaBossTitle"
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, 0, 0, 24)
        title.Font = Enum.Font.GothamBold
        title.Text = "MAFIA BOSS  •  COSMETIC MOVES"
        title.TextColor3 = GOLD
        title.TextSize = 13
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = panel

        local scroll = Instance.new("ScrollingFrame")
        scroll.Name = "MafiaBossButtonList"
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.Position = UDim2.new(0, 0, 0, 27)
        scroll.Size = UDim2.new(1, 0, 0, 132)
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = GOLD
        scroll.Parent = panel

        local grid = Instance.new("UIGridLayout")
        grid.CellSize = UDim2.new(0, 112, 0, 38)
        grid.CellPadding = UDim2.new(0, 6, 0, 6)
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        grid.Parent = scroll

        local names = {"Boss Stance", "Threaten", "Call Backup", "Execute", "Intimidate", "Victory", "Stop Pose"}
        for index, name in ipairs(names) do
            if name == "Stop Pose" then
                local button = createButton
                local stop = Instance.new("TextButton")
                stop.Name = "StopPoseButton"
                stop.LayoutOrder = index
                stop.BackgroundColor3 = Color3.fromRGB(70, 37, 39)
                stop.BorderSizePixel = 0
                stop.Font = Enum.Font.GothamSemibold
                stop.Text = "Stop Pose"
                stop.TextColor3 = CREAM
                stop.TextSize = 12
                stop.Parent = scroll
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 8)
                corner.Parent = stop
                stop.Activated:Connect(function()
                    stopAction(false)
                    notify("Poz ve efektler temizlendi.")
                end)
            else
                createButton(scroll, name, index)
            end
        end
        grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, grid.AbsoluteContentSize.Y + 4)
        end)
    end

    m.Init = function(model: Model)
        destroyed = false
        resetPose()
        clearEffects()
        refreshRig(model)
        actionName = nil
        lastMovementState = "Idle"
        if humanoid then originalAutoRotate = humanoid.AutoRotate end
    end

    m.Update = function(dt: number, model: Model)
        if destroyed then return end
        if model and model ~= figure then
            resetPose()
            clearEffects()
            refreshRig(model)
            actionName = nil
        end
        if not figure or not figure.Parent then return end
        if rootPart and not rootPart.Parent then rootPart = resolvePart(figure, {"HumanoidRootPart", "Torso", "UpperTorso", "Head"}) end
        applyPose()
    end

    m.Destroy = function()
        destroyed = true
        resetPose()
        clearEffects()
        for _, connection in ipairs(connections) do
            pcall(function() connection:Disconnect() end)
        end
        connections = {}
        if humanoid and humanoid.Parent and originalAutoRotate ~= nil then
            pcall(function() humanoid.AutoRotate = originalAutoRotate end)
        end
        if panel and panel.Parent then panel:Destroy() end
        panel = nil
        figure = nil
        humanoid = nil
        rootPart = nil
        actionName = nil
        poseMotors = {}
        buttons = {}
    end

    return m
end)

return modules
