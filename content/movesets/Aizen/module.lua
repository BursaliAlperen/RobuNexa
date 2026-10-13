-- Aizen Sōsuke TYBW moveset for RobuNexa / NAM.
-- Accessory-based presentation: does not select or modify HatReanimator.
-- Asset IDs were checked where public catalog results were available; unknown IDs are
-- intentionally not treated as animation IDs. Add converted .anim files to content/animations/Aizen
-- and update animationFiles below when those files are available.
local modules = {}
local function AddModule(fn) table.insert(modules, fn) end

AddModule(function()
    local m = {}
    local Players = game:GetService("Players")
    local InsertService = game:GetService("InsertService")
    local TweenService = game:GetService("TweenService")

    m.ModuleType = "MOVESET"
    m.Name = "Aizen TYBW"
    m.Description = "Aizen Sōsuke TYBW: seated intro, automatic 100% awakening, accessory-based visuals."
    m.Assets = {}

    local ASSET_IDS = {
        Chair = 103501121910392,
        Goryutenmetsu = 114712538192357, -- Aizen Goryutenmetsu back accessory
        PurpleAura = 83002193396907,    -- Purple Sparkling Aura back accessory
        AizenHead = 96379261062372,     -- Aizen TYBW 3D head
        Unknown = 106080031550988,      -- type not verified; do not auto-equip
    }

    local animationFiles = {
        ChairIdle = "Aizen/ChairIdle.anim",
        StandUp = "Aizen/StandUp.anim",
        Idle = "Aizen/Idle.anim",
        Walk = "Aizen/Walk.anim",
        Awakening = "Aizen/Awakening.anim",
        -- Ability animations can be added here once supplied as .anim files.
    }

    local activeFigure, humanoid, root
    local activeAnimator, activeName, startedAt, activeDuration
    local awakened = false
    local awakening = false
    local charge = 0
    local CHARGE_PER_SECOND = 2.5 -- 40 seconds of active play to reach 100%
    local guiConnections = {}
    local hud, barFill, barLabel, awakenLabel
    local accessoryInstances = {}
    local chairModel
    local savedWalkSpeed
    local introStarted = false
    local actionLock = false

    local function notify(message)
        pcall(function() Util.Notify(message) end)
    end

    local function resolveRoot(model)
        return model and (model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChild("UpperTorso")
            or model:FindFirstChild("Torso")
            or model.PrimaryPart)
    end

    local function stopAnimation()
        activeAnimator, activeName, startedAt, activeDuration = nil, nil, nil, nil
        if activeFigure then
            for _, obj in ipairs(activeFigure:GetDescendants()) do
                if obj:IsA("Motor6D") then
                    pcall(function() obj.Transform = CFrame.identity end)
                end
            end
        end
    end

    local function playAnimation(name, looped)
        if not activeFigure then return false end
        local relativePath = animationFiles[name]
        if not relativePath then return false end
        local okPath, path = pcall(function() return AssetGetPathFromFilename(relativePath) end)
        if not okPath or not path then return false end
        local okTrack, track = pcall(function() return AnimLib.Track.fromfile(path) end)
        if not okTrack or not track or not track.Keyframes or #track.Keyframes == 0 then
            return false
        end
        stopAnimation()
        activeAnimator = AnimLib.Animator.new()
        activeAnimator.rig = activeFigure
        activeAnimator.track = track
        activeAnimator.looped = looped == true
        startedAt = os.clock()
        activeName = name
        activeDuration = tonumber(track.Length) or tonumber(track.Duration) or 3
        return true
    end

    local function updateBar()
        if barFill then
            TweenService:Create(barFill, TweenInfo.new(0.12), {
                Size = UDim2.new(math.clamp(charge / 100, 0, 1), 0, 1, 0)
            }):Play()
        end
        if barLabel then barLabel.Text = string.format("AWAKENING  %d%%", math.floor(charge)) end
        if awakenLabel then
            awakenLabel.Text = awakened and "AWAKENED" or (awakening and "AWAKENING..." or "TYBW")
        end
    end

    local function clearVisuals()
        for _, instance in ipairs(accessoryInstances) do
            pcall(function() instance:Destroy() end)
        end
        table.clear(accessoryInstances)
        if chairModel then pcall(function() chairModel:Destroy() end) end
        chairModel = nil
    end

    local function loadAssetModel(assetId)
        local ok, result = pcall(function() return InsertService:LoadAsset(assetId) end)
        if not ok or not result then
            warn("[Aizen TYBW] Asset could not be loaded (permissions/type may not support LoadAsset): " .. tostring(assetId))
            return nil
        end
        return result
    end

    local function addAccessoryAsset(assetId, target)
        local container = loadAssetModel(assetId)
        if not container then return false end
        local accessory = container:FindFirstChildWhichIsA("Accessory", true)
        if accessory and target then
            -- Accessory attachment must go through Humanoid:AddAccessory so Roblox
            -- can match Handle attachments to the character rig.
            local targetHumanoid = target:FindFirstChildOfClass("Humanoid")
            if targetHumanoid then
                accessory.Parent = container
                local okAttach = pcall(function()
                    targetHumanoid:AddAccessory(accessory)
                end)
                if okAttach and accessory.Parent == target then
                    table.insert(accessoryInstances, accessory)
                    container:Destroy()
                    return true
                end
            end
        end
        -- Do not parent arbitrary models onto the character; unknown asset structure is unsafe.
        container:Destroy()
        return false
    end

    local function placeChair()
        if not root or not root.Parent or chairModel then return end
        local container = loadAssetModel(ASSET_IDS.Chair)
        if not container then
            notify("Aizen: sandalye asset'i yüklenemedi; asset türü/izinlerini kontrol et.")
            return
        end
        chairModel = container
        chairModel.Name = "AizenTYBWChair"
        local parts = {}
        for _, obj in ipairs(chairModel:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Anchored = true
                obj.CanCollide = false
                table.insert(parts, obj)
            end
        end
        local chairRoot = chairModel:FindFirstChildWhichIsA("BasePart", true)
        if not chairRoot then
            chairModel:Destroy()
            chairModel = nil
            return
        end
        chairModel.Parent = workspace
        -- Place behind the rig; the model remains client-side and is cleaned up on Destroy.
        chairModel:PivotTo(root.CFrame * CFrame.new(0, -1.7, 1.4) * CFrame.Angles(0, math.pi, 0))
    end

    local function createHUD()
        local player = Players.LocalPlayer
        local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
        if not playerGui then return end
        local old = playerGui:FindFirstChild("AizenTYBWHUD")
        if old then old:Destroy() end
        hud = Instance.new("ScreenGui")
        hud.Name = "AizenTYBWHUD"
        hud.ResetOnSpawn = false
        hud.IgnoreGuiInset = true
        hud.Parent = playerGui

        local panel = Instance.new("Frame")
        panel.Name = "AwakeningPanel"
        panel.AnchorPoint = Vector2.new(0.5, 1)
        panel.Position = UDim2.new(0.5, 0, 1, -30)
        panel.Size = UDim2.fromOffset(280, 48)
        panel.BackgroundColor3 = Color3.fromRGB(16, 15, 23)
        panel.BackgroundTransparency = 0.12
        panel.BorderSizePixel = 0
        panel.Parent = hud
        Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(160, 90, 205)
        stroke.Transparency = 0.15
        stroke.Parent = panel

        barLabel = Instance.new("TextLabel")
        barLabel.BackgroundTransparency = 1
        barLabel.Position = UDim2.fromOffset(10, 3)
        barLabel.Size = UDim2.new(1, -20, 0, 18)
        barLabel.Font = Enum.Font.GothamBold
        barLabel.Text = "AWAKENING  0%"
        barLabel.TextSize = 11
        barLabel.TextColor3 = Color3.fromRGB(245, 235, 255)
        barLabel.TextXAlignment = Enum.TextXAlignment.Left
        barLabel.Parent = panel

        local barBack = Instance.new("Frame")
        barBack.Position = UDim2.fromOffset(10, 25)
        barBack.Size = UDim2.new(1, -20, 0, 9)
        barBack.BackgroundColor3 = Color3.fromRGB(48, 42, 59)
        barBack.BorderSizePixel = 0
        barBack.Parent = panel
        Instance.new("UICorner", barBack).CornerRadius = UDim.new(1, 0)

        barFill = Instance.new("Frame")
        barFill.Size = UDim2.new(0, 0, 1, 0)
        barFill.BackgroundColor3 = Color3.fromRGB(183, 108, 255)
        barFill.BorderSizePixel = 0
        barFill.Parent = barBack
        Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

        awakenLabel = Instance.new("TextLabel")
        awakenLabel.BackgroundTransparency = 1
        awakenLabel.AnchorPoint = Vector2.new(0.5, 0)
        awakenLabel.Position = UDim2.new(0.5, 0, 1, 4)
        awakenLabel.Size = UDim2.new(1, 0, 0, 16)
        awakenLabel.Font = Enum.Font.GothamMedium
        awakenLabel.Text = "TYBW"
        awakenLabel.TextColor3 = Color3.fromRGB(215, 190, 255)
        awakenLabel.TextSize = 10
        awakenLabel.Parent = panel
        updateBar()
    end

    local function beginAwakening()
        if awakened or awakening or not activeFigure then return end
        awakening = true
        actionLock = true
        if humanoid then
            savedWalkSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = 0
        end
        if chairModel then
            pcall(function() chairModel:Destroy() end)
            chairModel = nil
        end
        local played = playAnimation("Awakening", false)
        if not played then played = playAnimation("StandUp", false) end
        if not played then
            -- Keep the feature usable without pretending a missing animation exists.
            notify("Aizen uyanışı tetiklendi; StandUp/Awakening .anim dosyaları henüz eklenmemiş.")
        end
        if not played then
            -- No animation clip exists yet, so use a short transition rather than
            -- passing nil to task.delay. Accessories still appear after the fallback.
            task.delay(3, function()
                if not activeFigure then return end
                awakened = true
                awakening = false
                actionLock = false
                if humanoid and savedWalkSpeed then humanoid.WalkSpeed = savedWalkSpeed end
                addAccessoryAsset(ASSET_IDS.Goryutenmetsu, activeFigure)
                addAccessoryAsset(ASSET_IDS.PurpleAura, activeFigure)
                addAccessoryAsset(ASSET_IDS.AizenHead, activeFigure)
                updateBar()
                if not playAnimation("Idle", true) then stopAnimation() end
            end)
        end
        updateBar()
    end

    m.Config = function(parent: GuiBase2d)
        local info = Instance.new("TextLabel")
        info.Name = "AizenTYBWInfo"
        info.BackgroundTransparency = 1
        info.Size = UDim2.new(1, 0, 0, 28)
        info.Font = Enum.Font.GothamMedium
        info.Text = "AIZEN TYBW  •  Awakening charges automatically"
        info.TextColor3 = Color3.fromRGB(218, 203, 242)
        info.TextSize = 12
        info.Parent = parent
    end

    m.Init = function(figure: Model)
        clearVisuals()
        stopAnimation()
        activeFigure = figure
        humanoid = figure:FindFirstChildOfClass("Humanoid")
        root = resolveRoot(figure)
        awakened, awakening, introStarted, actionLock = false, false, false, false
        charge = 0
        savedWalkSpeed = humanoid and humanoid.WalkSpeed or 16
        createHUD()
        placeChair()
        -- Chair pose is played only if the converted local animation exists.
        introStarted = playAnimation("ChairIdle", true)
        if not introStarted then
            notify("Aizen: ChairIdle.anim eksik; animasyon dosyasını ekleyince başlangıç pozu oynatılacak.")
        end
    end

    m.Update = function(dt: number, figure: Model)
        activeFigure = figure
        humanoid = figure:FindFirstChildOfClass("Humanoid")
        root = resolveRoot(figure)
        if not activeFigure or not root then return end

        if not awakened and not awakening then
            charge = math.min(100, charge + math.max(0, dt or 0) * CHARGE_PER_SECOND)
            updateBar()
            if charge >= 100 then beginAwakening() end
        end

        if activeAnimator and startedAt then
            activeAnimator:Step(os.clock() - startedAt)
            if not activeAnimator.looped and activeDuration and os.clock() - startedAt >= activeDuration then
                if awakening then
                    -- Finish the awakening transition only once the current clip ends.
                    awakened = true
                    awakening = false
                    actionLock = false
                    if humanoid and savedWalkSpeed then humanoid.WalkSpeed = savedWalkSpeed end
                    addAccessoryAsset(ASSET_IDS.Goryutenmetsu, activeFigure)
                    addAccessoryAsset(ASSET_IDS.PurpleAura, activeFigure)
                    addAccessoryAsset(ASSET_IDS.AizenHead, activeFigure)
                    updateBar()
                    if not playAnimation("Idle", true) then stopAnimation() end
                elseif awakened then
                    actionLock = false
                    if not playAnimation("Idle", true) then stopAnimation() end
                end
            end
        end

        if actionLock or awakening then return end
        if not awakened then
            if humanoid and activeName ~= "ChairIdle" and humanoid.MoveDirection.Magnitude < 0.05 then
                playAnimation("ChairIdle", true)
            end
            return
        end

        local wanted = "Idle"
        if humanoid and humanoid.MoveDirection.Magnitude > 0.05 then
            wanted = "Walk"
        end
        if wanted ~= activeName then
            if not playAnimation(wanted, true) then stopAnimation() end
        elseif activeAnimator and startedAt then
            activeAnimator:Step(os.clock() - startedAt)
        end
    end

    m.Destroy = function()
        if humanoid and savedWalkSpeed then pcall(function() humanoid.WalkSpeed = savedWalkSpeed end) end
        stopAnimation()
        clearVisuals()
        for _, connection in ipairs(guiConnections) do pcall(function() connection:Disconnect() end) end
        table.clear(guiConnections)
        if hud then hud:Destroy() end
        hud = nil
        activeFigure, humanoid, root = nil, nil, nil
        awakened, awakening, actionLock = false, false, false
    end

    return m
end)

return modules
