-- Aizen TYBW (R6 ONLY) for RobuNexa / NAM.
-- Animation + accessory presentation only. No R15 rig, combat damage, hitboxes, or VFX systems.
-- Place converted R6 .anim files in content/animations/Aizen/ using the filenames below.
local modules = {}
local function AddModule(fn) table.insert(modules, fn) end

AddModule(function()
    local m = {}
    local Players = game:GetService("Players")
    local InsertService = game:GetService("InsertService")
    local TweenService = game:GetService("TweenService")

    m.ModuleType = "MOVESET"
    m.Name = "Aizen TYBW (R6)"
    m.Description = "R6-only Aizen: Kyoka Suigetsu, Hado 90, passive Perfect Hypnosis, animations and accessories."
    m.Assets = {
        "Aizen/ChairIdle.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Aizen/ChairIdle.anim",
        "Aizen/StandUp.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Aizen/StandUp.anim",
        "Aizen/Idle.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Aizen/Idle.anim",
        "Aizen/Walk.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Aizen/Walk.anim",
        "Aizen/KyokaSuigetsu.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Aizen/KyokaSuigetsu.anim",
        "Aizen/Hado90.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Aizen/Hado90.anim",
        "Aizen/FlashStep.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Aizen/FlashStep.anim",
        "Aizen/Butterfly.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Aizen/Butterfly.anim",
    }

    local ASSET_IDS = {
        Chair = 103501121910392,
        Goryutenmetsu = 114712538192357,
        PurpleAura = 83002193396907,
        AizenHead = 96379261062372,
        Unverified = 106080031550988,
    }
    local animationFiles = {
        ChairIdle = "Aizen/ChairIdle.anim",
        StandUp = "Aizen/StandUp.anim",
        Idle = "Aizen/Idle.anim",
        Walk = "Aizen/Walk.anim",
        KyokaSuigetsu = "Aizen/KyokaSuigetsu.anim",
        Hado90 = "Aizen/Hado90.anim",
        FlashStep = "Aizen/FlashStep.anim",
        Butterfly = "Aizen/Butterfly.anim",
    }
    local abilityOrder = {"Kyoka Suigetsu", "Hado 90", "Flash Step", "Perfect Hypnosis"}
    local activeFigure, humanoid, root
    local activeAnimator, activeName, startedAt, activeDuration
    local accessoryInstances = {}
    local chairModel, hud, barFill, barLabel, statusLabel
    local buttons, guiConnections = {}, {}
    local cooldownUntil = {}
    local passiveHypnosis = false
    local charge, awakened, awakening, actionLock = 0, false, false, false
    local savedWalkSpeed = 16
    local CHARGE_PER_SECOND = 2.5
    local COOLDOWNS = { ["Kyoka Suigetsu"] = 8, ["Hado 90"] = 14, ["Flash Step"] = 5, ["Perfect Hypnosis"] = 0 }
    local R6_PARTS = {"Torso", "Head", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}

    local function notify(message)
        pcall(function() Util.Notify("Aizen: " .. message) end)
    end
    local function resolveRoot(model)
        return model and (model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model.PrimaryPart)
    end
    local function isR6(model)
        if not model then return false end
        for _, name in ipairs(R6_PARTS) do
            local part = model:FindFirstChild(name)
            if not part or not part:IsA("BasePart") then return false end
        end
        return true
    end
    local function stopAnimation()
        if activeAnimator then pcall(function() if activeAnimator.Stop then activeAnimator:Stop() end end) end
        activeAnimator, activeName, startedAt, activeDuration = nil, nil, nil, nil
        if activeFigure then
            for _, item in ipairs(activeFigure:GetDescendants()) do
                if item:IsA("Motor6D") then pcall(function() item.Transform = CFrame.identity end) end
            end
        end
    end
    local function playAnimation(name, looped)
        if not activeFigure or not isR6(activeFigure) then return false end
        local filename = animationFiles[name]
        if not filename then return false end
        local path = AssetGetPathFromFilename(filename)
        if not isfile or not isfile(path) then
            local okEnsure, result = pcall(function() return AssetEnsure({filename}) end)
            if not okEnsure or not result or not isfile or not isfile(path) then
                notify(filename .. " eksik/indirilemedi; R6 .anim dosyasını ekle.")
                return false
            end
        end
        local ok, track = pcall(function() return AnimLib.Track.fromfile(path) end)
        if not ok or not track or not track.Keyframes or #track.Keyframes == 0 then
            notify(filename .. " geçerli bir AnimLib .anim dosyası değil.")
            return false
        end
        stopAnimation()
        activeAnimator = AnimLib.Animator.new()
        activeAnimator.rig = activeFigure
        activeAnimator.track = track
        activeAnimator.looped = looped == true
        activeName = name
        startedAt = os.clock()
        activeDuration = 0
        for _, keyframe in ipairs(track.Keyframes) do
            if type(keyframe.Time) == "number" and keyframe.Time > activeDuration then activeDuration = keyframe.Time end
        end
        if activeDuration <= 0 then activeDuration = 2 end
        return true
    end
    local function loadAssetModel(assetId)
        local ok, result = pcall(function() return InsertService:LoadAsset(assetId) end)
        if not ok or not result then
            warn("[Aizen R6] Asset load failed: " .. tostring(assetId) .. " (asset type/permissions may prevent LoadAsset)")
            return nil
        end
        return result
    end
    local function equipAccessory(assetId)
        if not activeFigure or not humanoid then return false end
        local container = loadAssetModel(assetId)
        if not container then return false end
        local accessory = container:FindFirstChildWhichIsA("Accessory", true)
        if not accessory then container:Destroy(); return false end
        local ok = pcall(function() humanoid:AddAccessory(accessory) end)
        if ok and accessory.Parent == activeFigure then
            table.insert(accessoryInstances, accessory)
            container:Destroy()
            return true
        end
        container:Destroy()
        return false
    end
    local function placeChair()
        if not root or chairModel then return end
        local model = loadAssetModel(ASSET_IDS.Chair)
        if not model then notify("Sandalye asset'i yüklenemedi; ID türü/erişimini kontrol et."); return end
        local part = model:FindFirstChildWhichIsA("BasePart", true)
        if not part then model:Destroy(); return end
        chairModel = model
        chairModel.Name = "AizenR6Chair"
        for _, item in ipairs(chairModel:GetDescendants()) do
            if item:IsA("BasePart") then item.Anchored = true; item.CanCollide = false end
        end
        chairModel.Parent = workspace
        chairModel:PivotTo(root.CFrame * CFrame.new(0, -1.7, 1.4) * CFrame.Angles(0, math.pi, 0))
    end
    local function clearVisuals()
        for _, item in ipairs(accessoryInstances) do pcall(function() item:Destroy() end) end
        table.clear(accessoryInstances)
        if chairModel then pcall(function() chairModel:Destroy() end) end
        chairModel = nil
    end
    local function updateHUD()
        if barFill then TweenService:Create(barFill, TweenInfo.new(0.1), {Size = UDim2.new(math.clamp(charge / 100, 0, 1), 0, 1, 0)}):Play() end
        if barLabel then barLabel.Text = "AWAKENING  " .. tostring(math.floor(charge)) .. "%" end
        if statusLabel then
            statusLabel.Text = passiveHypnosis and "PERFECT HYPNOSIS: ON" or (awakened and "TYBW AWAKENED" or (awakening and "AWAKENING..." or "R6 • TYBW"))
        end
        for name, button in pairs(buttons) do
            if button and button.Parent then
                if name == "Perfect Hypnosis" then
                    button.Text = passiveHypnosis and "Hypnosis: ON" or "Perfect Hypnosis"
                elseif (cooldownUntil[name] or 0) > os.clock() then
                    button.Text = name .. " (" .. math.ceil(cooldownUntil[name] - os.clock()) .. ")"
                else
                    button.Text = name
                end
            end
        end
    end
    local function createHUD()
        local player = Players.LocalPlayer
        local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
        if not playerGui then return end
        local old = playerGui:FindFirstChild("AizenR6HUD")
        if old then old:Destroy() end
        hud = Instance.new("ScreenGui")
        hud.Name = "AizenR6HUD"
        hud.ResetOnSpawn = false
        hud.IgnoreGuiInset = true
        hud.Parent = playerGui
        local panel = Instance.new("Frame")
        panel.Name = "AizenPanel"
        panel.AnchorPoint = Vector2.new(0.5, 1)
        panel.Position = UDim2.new(0.5, 0, 1, -22)
        panel.Size = UDim2.fromOffset(330, 112)
        panel.BackgroundColor3 = Color3.fromRGB(16, 15, 23)
        panel.BackgroundTransparency = 0.1
        panel.BorderSizePixel = 0
        panel.Parent = hud
        Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", panel)
        stroke.Color = Color3.fromRGB(160, 90, 205)
        stroke.Transparency = 0.15
        barLabel = Instance.new("TextLabel")
        barLabel.BackgroundTransparency = 1
        barLabel.Position = UDim2.fromOffset(10, 5)
        barLabel.Size = UDim2.new(1, -20, 0, 18)
        barLabel.Font = Enum.Font.GothamBold
        barLabel.TextSize = 11
        barLabel.TextColor3 = Color3.fromRGB(245, 235, 255)
        barLabel.TextXAlignment = Enum.TextXAlignment.Left
        barLabel.Parent = panel
        local back = Instance.new("Frame")
        back.Position = UDim2.fromOffset(10, 26)
        back.Size = UDim2.new(1, -20, 0, 8)
        back.BackgroundColor3 = Color3.fromRGB(48, 42, 59)
        back.BorderSizePixel = 0
        back.Parent = panel
        Instance.new("UICorner", back).CornerRadius = UDim.new(1, 0)
        barFill = Instance.new("Frame")
        barFill.Size = UDim2.new(0, 0, 1, 0)
        barFill.BackgroundColor3 = Color3.fromRGB(183, 108, 255)
        barFill.BorderSizePixel = 0
        barFill.Parent = back
        Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
        statusLabel = Instance.new("TextLabel")
        statusLabel.BackgroundTransparency = 1
        statusLabel.Position = UDim2.fromOffset(10, 37)
        statusLabel.Size = UDim2.new(1, -20, 0, 16)
        statusLabel.Font = Enum.Font.GothamMedium
        statusLabel.TextSize = 10
        statusLabel.TextColor3 = Color3.fromRGB(215, 190, 255)
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.Parent = panel
        local row = Instance.new("Frame")
        row.BackgroundTransparency = 1
        row.Position = UDim2.fromOffset(8, 58)
        row.Size = UDim2.new(1, -16, 0, 44)
        row.Parent = panel
        local layout = Instance.new("UIGridLayout")
        layout.CellSize = UDim2.new(0, 76, 0, 38)
        layout.CellPadding = UDim2.fromOffset(4, 4)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = row
        for index, name in ipairs(abilityOrder) do
            local button = Instance.new("TextButton")
            button.Name = name:gsub("%W", "") .. "Button"
            button.LayoutOrder = index
            button.BackgroundColor3 = Color3.fromRGB(38, 29, 54)
            button.BorderSizePixel = 0
            button.Text = name
            button.TextColor3 = Color3.fromRGB(245, 240, 255)
            button.TextSize = 10
            button.TextWrapped = true
            button.Font = Enum.Font.GothamSemibold
            button.Parent = row
            Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)
            buttons[name] = button
            table.insert(guiConnections, button.Activated:Connect(function()
                if not activeFigure or actionLock then return end
                if name == "Perfect Hypnosis" then
                    passiveHypnosis = not passiveHypnosis
                    updateHUD()
                    notify(passiveHypnosis and "Perfect Hypnosis pasifi açıldı (görsel durum)." or "Perfect Hypnosis pasifi kapatıldı.")
                    return
                end
                if (cooldownUntil[name] or 0) > os.clock() then return end
                local animationName = ({["Kyoka Suigetsu"] = "KyokaSuigetsu", ["Hado 90"] = "Hado90", ["Flash Step"] = "FlashStep"})[name]
                if animationName and playAnimation(animationName, false) then
                    actionLock = true
                    cooldownUntil[name] = os.clock() + (COOLDOWNS[name] or 5)
                end
            end))
        end
        updateHUD()
    end
    local function awaken()
        if awakened or awakening then return end
        awakening = true
        actionLock = true
        if humanoid then savedWalkSpeed = humanoid.WalkSpeed; humanoid.WalkSpeed = 0 end
        if chairModel then chairModel:Destroy(); chairModel = nil end
        local played = playAnimation("StandUp", false)
        if not played then
            task.delay(2, function()
                if not activeFigure then return end
                awakened, awakening, actionLock = true, false, false
                if humanoid then humanoid.WalkSpeed = savedWalkSpeed end
                equipAccessory(ASSET_IDS.Goryutenmetsu)
                equipAccessory(ASSET_IDS.PurpleAura)
                equipAccessory(ASSET_IDS.AizenHead)
                updateHUD()
            end)
        end
        updateHUD()
    end

    m.Config = function(parent: GuiBase2d)
        local info = Instance.new("TextLabel")
        info.Name = "AizenR6Info"
        info.BackgroundTransparency = 1
        info.Size = UDim2.new(1, 0, 0, 30)
        info.Font = Enum.Font.GothamMedium
        info.Text = "AIZEN TYBW R6 • Kyoka Suigetsu • Hado 90 • Perfect Hypnosis"
        info.TextColor3 = Color3.fromRGB(218, 203, 242)
        info.TextSize = 11
        info.TextWrapped = true
        info.Parent = parent
    end
    m.Init = function(figure: Model)
        clearVisuals()
        stopAnimation()
        activeFigure = figure
        humanoid = figure and figure:FindFirstChildOfClass("Humanoid")
        root = resolveRoot(figure)
        if not isR6(figure) then
            notify("Bu moveset yalnızca R6 rig içindir; R15 üzerinde başlatılmadı.")
            return
        end
        charge, awakened, awakening, actionLock, passiveHypnosis = 0, false, false, false, false
        savedWalkSpeed = humanoid and humanoid.WalkSpeed or 16
        table.clear(cooldownUntil)
        createHUD()
        placeChair()
        if not playAnimation("ChairIdle", true) then notify("ChairIdle.anim eksik; sandalye animasyonu olmadan devam ediyor.") end
    end
    m.Update = function(dt: number, figure: Model)
        if not figure or not figure.Parent then return end
        activeFigure = figure
        humanoid = figure:FindFirstChildOfClass("Humanoid")
        root = resolveRoot(figure)
        if not isR6(figure) or not root then return end
        if not awakened and not awakening then
            charge = math.min(100, charge + math.max(0, dt or 0) * CHARGE_PER_SECOND)
            if charge >= 100 then awaken() end
        end
        if activeAnimator and startedAt then
            activeAnimator:Step(os.clock() - startedAt)
            if not activeAnimator.looped and activeDuration and os.clock() - startedAt >= activeDuration then
                if awakening then
                    awakened, awakening, actionLock = true, false, false
                    if humanoid then humanoid.WalkSpeed = savedWalkSpeed end
                    equipAccessory(ASSET_IDS.Goryutenmetsu)
                    equipAccessory(ASSET_IDS.PurpleAura)
                    equipAccessory(ASSET_IDS.AizenHead)
                    if not playAnimation("Idle", true) then stopAnimation() end
                elseif actionLock then
                    actionLock = false
                    if awakened and not playAnimation("Idle", true) then stopAnimation() end
                end
            end
        end
        if not actionLock and not awakening and awakened then
            local wanted = (humanoid and humanoid.MoveDirection.Magnitude > 0.05) and "Walk" or "Idle"
            if activeName ~= wanted then playAnimation(wanted, true)
            elseif activeAnimator then activeAnimator:Step(os.clock() - (startedAt or os.clock())) end
        elseif not awakened and not awakening and humanoid and humanoid.MoveDirection.Magnitude > 0.05 then
            -- Keep the intro pose from locking locomotion; no custom R15 fallback.
            stopAnimation()
        end
        updateHUD()
    end
    m.Destroy = function()
        if humanoid and humanoid.Parent then pcall(function() humanoid.WalkSpeed = savedWalkSpeed end) end
        stopAnimation()
        clearVisuals()
        for _, connection in ipairs(guiConnections) do pcall(function() connection:Disconnect() end) end
        table.clear(guiConnections)
        if hud then hud:Destroy() end
        hud, activeFigure, humanoid, root = nil, nil, nil, nil
        table.clear(buttons)
        charge, awakened, awakening, actionLock, passiveHypnosis = 0, false, false, false, false
    end
    return m
end)
return modules
