-- RobuNexa / NAM - Sukuna accessory-driven Domain and Cleave.
-- Uses equipped catalog accessories as HatReanimator targets with eased transitions.
-- Fuuga projectile/aura are local visual prototypes; shared visibility requires server replication.
local modules = {}
-- Keep factories intact: NAM's loader injects its API before invoking each factory.
local function AddModule(fn) table.insert(modules, fn) end

AddModule(function()
    local m = {}
    local UserInputService = game:GetService("UserInputService")
    m.ModuleType = "MOVESET"
    m.Name = "Sukuna"
    m.Description = "Malevolent Shrine, Cleave, Dismantle, and Fuuga Flame Arrow."
    -- Match Gojo's asset loader contract: logical local path @ raw GitHub URL.
    -- These are NAM AnimLib binary .anim files, not .rbxm models.
    m.Assets = {
        "Sukuna/Cleave.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Sukuna/Cleave.anim",
        "Sukuna/FlameArrow.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Sukuna/FlameArrow.anim",
        "Sukuna/MalevolentShrine.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Sukuna/MalevolentShrine.anim",
        "Sukuna/SukunaLaugh.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Sukuna/SukunaLaugh.anim",
        "Sukuna/Walk.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Sukuna/Walk.anim",
        "Sukuna/DomainCombo.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Sukuna/DomainCombo.anim",
    }

    local TARGETS = {
        [18726352770] = {
            key = "shrine",
            label = "Malevolent Shrine",
            hints = {"malevolent shrine"},
            hiddenHeight = 0,
        },
        [124144353587446] = {
            key = "furnace",
            label = "Fuga Furnace",
            hints = {"fuga furnace"},
            hiddenHeight = 0,
        },
        [100475161263482] = {
            key = "cleaveAura",
            label = "Cleave and Dismantle Aura",
            hints = {"cleave and dismantle", "dismantle animated aura"},
            hiddenHeight = 0,
        },
        [97087028126781] = {
            key = "whiteSlashes",
            label = "White Domain Slashes",
            hints = {"white domain", "expension slashes", "expansion slashes"},
            hiddenHeight = 0,
        },
    }

    local EFFECT_IDS = {100475161263482, 97087028126781}
    local FINGER_ID = 18762839664
    local activeFigure, root
    local hud
    local skillButtons = {}
    local activateAbility
    local abilityCooldowns = {Domain = 12, Cleave = 3, Dismantle = 2.5, Fuuga = 8}
    local abilityReadyAt = {}
    local targetMarker
    local fuugaTargetPosition
    local domainStartedAt = 0
    local cutsceneActive = false
    local savedCameraType, savedCameraSubject, savedCameraCFrame
    local fingerFolder
    local fingerMarker
    local fingerPrompt
    local fingerOverride
    local fingersFound = 0
    local fingerEquipped = false
    local connections = {}
    local domainEnabled = false
    local cleaveUntil = 0
    local savedWantAllHats = nil
    local accessoryCheckAccumulator = 0
    local lastAccessorySignature = nil
    local accessoryInstances = {}
    local presentIds = {}
    local overrideById = {}
    local lastHatCFrames = {}
    local scaledMeshes = {}
    local fuugaBusy = false
    local fuugaAnimationTrack
    local laughAnimationTrack
    local fuugaProjectile
    local fuugaAuraInstances = {}
    local STATUS_INTERVAL = 1.25

    local function notify(message)
        pcall(function() Util.Notify("Sukuna: " .. message) end)
    end

    local function resolveRoot(figure)
        if not figure then return nil end
        local part = figure:FindFirstChild("HumanoidRootPart")
            or figure.PrimaryPart
            or figure:FindFirstChild("Torso")
            or figure:FindFirstChild("UpperTorso")
            or figure:FindFirstChild("Head")
        return part and part:IsA("BasePart") and part or nil
    end

    -- Load through NAM's exact AnimLib pipeline, the same pattern used by Gojo.
    -- All sources are downloaded .anim binary files declared in m.Assets above.
    local function playBundledAnimation(filename, preferredName, looped)
        if not activeFigure or not activeFigure.Parent then return false end
        local path = AssetGetPathFromFilename(filename)
        if not isfile or not isfile(path) then
            notify("Animasyon dosyası bulunamadı: " .. filename)
            return false
        end

        local okTrack, track = pcall(function() return AnimLib.Track.fromfile(path) end)
        if not okTrack or not track or type(track.Keyframes) ~= "table" or #track.Keyframes == 0 then
            notify("Geçersiz .anim dosyası: " .. filename)
            return false
        end

        if laughAnimationTrack and type(laughAnimationTrack.Stop) == "function" then
            pcall(function() laughAnimationTrack:Stop() end)
            laughAnimationTrack = nil
        end

        local animator = AnimLib.Animator.new()
        animator.rig = activeFigure
        animator.track = track
        animator.looped = looped == true
        local duration = 0
        for _, keyframe in ipairs(track.Keyframes) do
            if type(keyframe.Time) == "number" then duration = math.max(duration, keyframe.Time) end
        end
        local startedAt = os.clock()
        local stopped = false
        local stepConnection
        local controller = {}
        function controller:Stop()
            if stopped then return end
            stopped = true
            if stepConnection then stepConnection:Disconnect(); stepConnection = nil end
            if activeFigure and activeFigure.Parent then
                for _, item in ipairs(activeFigure:GetDescendants()) do
                    if item:IsA("Motor6D") then
                        pcall(function() item.Transform = CFrame.identity end)
                    end
                end
            end
        end
        stepConnection = game:GetService("RunService").RenderStepped:Connect(function()
            if stopped or not activeFigure or not activeFigure.Parent then
                controller:Stop()
                return
            end
            local elapsed = os.clock() - startedAt
            if duration > 0 and elapsed > duration then
                if animator.looped then
                    startedAt = os.clock()
                    elapsed = 0
                else
                    controller:Stop()
                    return
                end
            end
            pcall(function() animator:Step(elapsed) end)
        end)
        return controller
    end

    local function getLocalCharacter()
        local players = game:GetService("Players")
        local player = players.LocalPlayer
        return player and player.Character
    end

    local function tryAccessoryInstance(descriptionEntry, character)
        local candidate
        pcall(function()
            if descriptionEntry.GetAppliedInstance then
                candidate = descriptionEntry:GetAppliedInstance()
            end
        end)
        if not candidate then
            pcall(function() candidate = descriptionEntry.Instance end)
        end
        if typeof(candidate) == "Instance" and candidate:IsA("Accessory") then
            if candidate.Parent == character or candidate:IsDescendantOf(character) then
                return candidate
            end
        end

        local candidateName
        pcall(function()
            if candidate then candidateName = candidate.Name end
        end)
        pcall(function()
            if not candidateName then candidateName = descriptionEntry.Name end
        end)
        if candidateName and character then
            for _, child in ipairs(character:GetChildren()) do
                if child:IsA("Accessory") and child.Name == candidateName then
                    return child
                end
            end
        end
        return nil
    end

    local function refreshAccessories()
        local character = getLocalCharacter()
        local nextInstances, nextPresent = {}, {}

        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local okDescription, description = pcall(function()
                    return humanoid:GetAppliedDescription()
                end)
                if okDescription and description then
                    local okList, list = pcall(function()
                        return description:GetAccessories(true)
                    end)
                    if okList and type(list) == "table" then
                        for _, entry in ipairs(list) do
                            local id
                            pcall(function() id = tonumber(entry.AssetId) end)
                            if id and TARGETS[id] then
                                nextPresent[id] = true
                                local accessory = tryAccessoryInstance(entry, character)
                                if accessory then nextInstances[id] = accessory end
                            end
                        end
                    end
                    -- Legacy accessory ID lists, for clients whose GetAccessories result
                    -- does not return applied-instance references.
                    for _, propertyName in ipairs({
                        "HatAccessory", "HairAccessory", "FaceAccessory",
                        "NeckAccessory", "ShouldersAccessory", "FrontAccessory",
                        "BackAccessory", "WaistAccessory",
                    }) do
                        local okValue, value = pcall(function()
                            return description[propertyName]
                        end)
                        if okValue and type(value) == "string" then
                            for token in string.gmatch(value, "%d+") do
                                local id = tonumber(token)
                                if id and TARGETS[id] then nextPresent[id] = true end
                            end
                        end
                    end
                end
            end

            for _, child in ipairs(character:GetChildren()) do
                if child:IsA("Accessory") then
                    local attrId = tonumber(child:GetAttribute("AssetId"))
                    if attrId and TARGETS[attrId] then
                        nextPresent[attrId] = true
                        nextInstances[attrId] = child
                    end
                end
            end

            -- Name-based fallback only applies to the known catalog items.
            local used = {}
            for id, target in pairs(TARGETS) do
                if not nextInstances[id] then
                    for _, child in ipairs(character:GetChildren()) do
                        if child:IsA("Accessory") and not used[child] then
                            local lowerName = string.lower(child.Name)
                            for _, hint in ipairs(target.hints) do
                                if string.find(lowerName, hint, 1, true) then
                                    nextInstances[id] = child
                                    nextPresent[id] = true
                                    used[child] = true
                                    break
                                end
                            end
                        end
                        if nextInstances[id] then break end
                    end
                else
                    used[nextInstances[id]] = true
                end
            end
        end

        -- The Finger catalog item is expected to remain equipped on the character.
        fingerEquipped = false
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local okDescription, description = pcall(function() return humanoid:GetAppliedDescription() end)
                if okDescription and description then
                    local okList, list = pcall(function() return description:GetAccessories(true) end)
                    if okList and type(list) == "table" then
                        for _, entry in ipairs(list) do
                            local id
                            pcall(function() id = tonumber(entry.AssetId) end)
                            if id == FINGER_ID then fingerEquipped = true; break end
                        end
                    end
                end
            end
            if not fingerEquipped then
                for _, child in ipairs(character:GetChildren()) do
                    if child:IsA("Accessory") and tonumber(child:GetAttribute("AssetId")) == FINGER_ID then
                        fingerEquipped = true
                        break
                    end
                end
            end
        end
        accessoryInstances = nextInstances
        presentIds = nextPresent
        local matched = {}
        for id in pairs(TARGETS) do
            if presentIds[id] then table.insert(matched, tostring(id)) end
        end
        table.sort(matched)
        local signature = table.concat(matched, ",")
        if signature ~= lastAccessorySignature then
            lastAccessorySignature = signature
            if #matched == 4 then
                notify("4/4 Sukuna accessories detected; Hat Reanimation targets are being prepared.")
            elseif #matched > 0 then
                notify(string.format("%d/4 accessories detected. Add the remaining Sukuna accessories.", #matched))
            else
                notify("0/4 accessories detected. Equip the four catalog accessories first.")
            end
        end
    end

    local function findMapEntry(accessory, map)
        if not accessory or type(map) ~= "table" then return nil end
        for _, entry in ipairs(map) do
            if entry.Name == accessory.Name then return entry end
        end
        local lowerName = string.lower(accessory.Name)
        for _, entry in ipairs(map) do
            local mapName = string.lower(tostring(entry.Name or ""))
            for _, target in pairs(TARGETS) do
                local accessoryLooksRight = false
                for _, hint in ipairs(target.hints) do
                    if string.find(lowerName, hint, 1, true) then
                        accessoryLooksRight = true
                        break
                    end
                end
                if accessoryLooksRight and mapName == lowerName then
                    return entry
                end
            end
        end
        return nil
    end

    local scaleShrineAccessory
    local function ensureHatOverrides()
        if not HatReanimator then return end
        if type(HatReanimator.HatCFrameOverride) ~= "table" then
            HatReanimator.HatCFrameOverride = {}
        end

        local added = false
        for id, accessory in pairs(accessoryInstances) do
            if id == 18726352770 then scaleShrineAccessory(accessory) end
            if accessory and accessory.Parent then
                local handle = accessory:FindFirstChild("Handle")
                local meshId, textureId
                if handle then
                    local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                    if mesh then
                        meshId = mesh.MeshId
                        textureId = mesh.TextureId
                    elseif handle:IsA("MeshPart") then
                        meshId = handle.MeshId
                        textureId = handle.TextureId
                    end
                end

                local override = overrideById[id]
                if not override or override.Name ~= accessory.Name
                    or override.MeshId ~= meshId or override.TextureId ~= textureId then
                    override = {
                        Name = accessory.Name,
                        MeshId = meshId,
                        TextureId = textureId,
                        C0 = CFrame.identity,
                        C1 = CFrame.identity,
                    }
                    overrideById[id] = override
                end

                if not table.find(HatReanimator.HatCFrameOverride, override) then
                    table.insert(HatReanimator.HatCFrameOverride, override)
                    added = true
                end
            end
        end
        if added then
            HatReanimator.RebuildRequired = true
        end
    end

    scaleShrineAccessory = function(accessory)
        if not accessory then return end
        local handle = accessory:FindFirstChild("Handle")
        if not handle or not handle:IsA("BasePart") then return end
        if not scaledMeshes[handle] then
            local mesh = handle:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                scaledMeshes[handle] = {instance = mesh, kind = "mesh", original = mesh.Scale, factor = 1}
            elseif handle:IsA("MeshPart") then
                scaledMeshes[handle] = {instance = handle, kind = "part", original = handle.Size, factor = 1}
            end
        end
        local saved = scaledMeshes[handle]
        if saved and saved.factor ~= 1.75 then
            pcall(function()
                if saved.kind == "mesh" then saved.instance.Scale = saved.original * 1.75
                elseif saved.kind == "part" then saved.instance.Size = saved.original * 1.75 end
            end)
            saved.factor = 1.75
            if HatReanimator then HatReanimator.RebuildRequired = true end
        end
    end

    local function setAccessoryScale(id, multiplier)
        local accessory = accessoryInstances[id]
        if not accessory then return end
        local handle = accessory:FindFirstChild("Handle")
        if not handle or not handle:IsA("BasePart") then return end
        if not scaledMeshes[handle] then
            local mesh = handle:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                scaledMeshes[handle] = {instance = mesh, kind = "mesh", original = mesh.Scale, factor = 1}
            elseif handle:IsA("MeshPart") then
                scaledMeshes[handle] = {instance = handle, kind = "part", original = handle.Size, factor = 1}
            end
        end
        local saved = scaledMeshes[handle]
        if not saved or saved.factor == multiplier then return end
        pcall(function()
            if saved.kind == "mesh" then saved.instance.Scale = saved.original * multiplier
            elseif saved.kind == "part" then saved.instance.Size = saved.original * multiplier end
        end)
        saved.factor = multiplier
        if HatReanimator then HatReanimator.RebuildRequired = true end
    end

    local function setHatWorldCFrame(id, targetCFrame)
        local override = overrideById[id]
        if not override then return end
        local previous = lastHatCFrames[id] or override.C0 or targetCFrame
        local eased = previous:Lerp(targetCFrame, 0.18)
        lastHatCFrames[id] = eased
        override.C0 = eased
        override.C1 = CFrame.identity
    end

    local function effectCenter()
        if not root then return CFrame.new(0, 500, 0) end
        return root.CFrame * CFrame.new(0, 2, -5)
    end

    local function applyAccessoryPositions()
        if not root or not root.Parent then return end
        local t = os.clock()
        -- Keep accessories close to the rig; inactive targets are hidden just below the floor.
        local center = root.CFrame * CFrame.new(0, 2, -5)
        local hiddenCenter = root.CFrame * CFrame.new(0, -28, 0)
        local active = domainEnabled or os.clock() < cleaveUntil
        local fast = os.clock() < cleaveUntil
        local rate = fast and 7.5 or 1.8

        -- Domain slash accessories grow 20x while Domain is active, then restore.
        setAccessoryScale(100475161263482, domainEnabled and 1.75 or 1)
        setAccessoryScale(97087028126781, domainEnabled and 1.75 or 1)

        -- The Shrine itself rises slowly from below ground while Domain is active.
        if domainEnabled then
            local rise = math.clamp((os.clock() - domainStartedAt) / 2.6, 0, 1)
            local eased = rise * rise * (3 - 2 * rise)
            local shrinePosition = root.Position + root.CFrame.LookVector * -22 + Vector3.new(0, -18 + eased * 24, 0)
            setHatWorldCFrame(18726352770,
                CFrame.new(shrinePosition) * root.CFrame.Rotation * CFrame.Angles(0, math.rad(180), 0))
        else
            setHatWorldCFrame(18726352770,
                hiddenCenter * CFrame.new(0, TARGETS[18726352770].hiddenHeight, 0))
        end
        setHatWorldCFrame(124144353587446,
            hiddenCenter * CFrame.new(0, TARGETS[124144353587446].hiddenHeight, 0))

        if active then
            local pulse = math.sin(t * rate)
            local sweep = math.cos(t * rate * 1.13)
            setHatWorldCFrame(100475161263482,
                center * CFrame.new(pulse * (fast and 2.8 or 1.4), 1 + math.abs(pulse) * 1.2, sweep * (fast and 2.8 or 1.4))
                    * CFrame.Angles(math.rad(pulse * 10), t * (fast and 3.5 or 0.45), math.rad(sweep * 8)))
            setHatWorldCFrame(97087028126781,
                center * CFrame.new(sweep * (fast and 3.5 or 1.8), 2.5 + pulse, pulse * (fast and 3.5 or 1.8))
                    * CFrame.Angles(math.rad(sweep * 18), t * (fast and 8 or 1.1), math.rad(pulse * 15)))
        else
            setHatWorldCFrame(100475161263482,
                hiddenCenter * CFrame.new(0, TARGETS[100475161263482].hiddenHeight, 0))
            setHatWorldCFrame(97087028126781,
                hiddenCenter * CFrame.new(0, TARGETS[97087028126781].hiddenHeight, 0))
        end
    end

    local function refreshButtons()
        for name, button in pairs(skillButtons) do
            if button and button.Parent then
                local remaining = math.max(0, (abilityReadyAt[name] or 0) - os.clock())
                button.Text = remaining > 0
                    and string.format("%.1fs", remaining)
                    or (LABELS[name] .. "\n" .. KEYBINDS[name].Name)
                button.BackgroundColor3 = remaining > 0 and Color3.fromRGB(74, 35, 42) or Color3.fromRGB(43, 22, 30)
            end
        end
    end

    local function playDomainCutscene(targetPosition)
        if cutsceneActive or not root then return end
        local camera = workspace.CurrentCamera
        if not camera then return end
        cutsceneActive = true
        savedCameraType, savedCameraSubject, savedCameraCFrame = camera.CameraType, camera.CameraSubject, camera.CFrame
        camera.CameraType = Enum.CameraType.Scriptable
        local focus = root.Position + Vector3.new(0, 3, 0)
        camera.CFrame = CFrame.lookAt(focus + root.CFrame.LookVector * -12 + Vector3.new(0, 5, 0), focus)
        game:GetService("TweenService"):Create(camera, TweenInfo.new(0.85, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
            CFrame = CFrame.lookAt(focus + root.CFrame.LookVector * -7 + Vector3.new(0, 3, 0), focus)
        }):Play()
        -- Two-clip sequence: Combo intro, then Domain Expansion. Both clips are
        -- loaded from the bundled Roblox models; no placeholder asset IDs.
        task.spawn(function()
            local first = playBundledAnimation("Sukuna/DomainCombo.anim", "combo", false)
            if first then
                local timeout = os.clock() + 1.8
                while first.IsPlaying and os.clock() < timeout and cutsceneActive do
                    task.wait(0.05)
                end
                pcall(function() first:Stop(0.08); first:Destroy() end)
            end
            if cutsceneActive then
                local second = playBundledAnimation("Sukuna/MalevolentShrine.anim", "domain", false)
                if second then
                    local timeout = os.clock() + 2.8
                    while second.IsPlaying and os.clock() < timeout and cutsceneActive do
                        task.wait(0.05)
                    end
                    pcall(function() second:Stop(0.1); second:Destroy() end)
                end
            end
        end)
        task.delay(1.05, function()
            if not cutsceneActive or not targetPosition then return end
            local currentCamera = workspace.CurrentCamera
            if currentCamera then
                game:GetService("TweenService"):Create(currentCamera, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                    CFrame = CFrame.lookAt(targetPosition + Vector3.new(0, 9, 14), targetPosition)
                }):Play()
            end
        end)
        task.delay(4.8, function()
            if not cutsceneActive then return end
            local currentCamera = workspace.CurrentCamera
            if currentCamera then
                currentCamera.CameraType = savedCameraType or Enum.CameraType.Custom
                currentCamera.CameraSubject = savedCameraSubject
                if savedCameraCFrame then currentCamera.CFrame = savedCameraCFrame end
            end
            cutsceneActive = false
        end)
    end

    local function getClickedWorldPosition(useScreenCenter)
        local player = game:GetService("Players").LocalPlayer
        local camera = workspace.CurrentCamera
        if not camera then return root and (root.Position + root.CFrame.LookVector * 24) or Vector3.new(0, 5, 0) end
        local ray
        if not useScreenCenter and player and UserInputService.MouseEnabled then
            local mouse = player:GetMouse()
            local position
            pcall(function() if mouse and mouse.Hit then position = mouse.Hit.Position end end)
            if position and (position - camera.CFrame.Position).Magnitude < 1500 then return position end
        end
        local viewport = camera.ViewportSize
        ray = camera:ViewportPointToRay(viewport.X * 0.5, viewport.Y * 0.5)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {activeFigure, getLocalCharacter(), targetMarker}
        local result = workspace:Raycast(ray.Origin, ray.Direction * 700, params)
        if result then return result.Position end
        return ray.Origin + ray.Direction * 80
    end

    local function showTargetMarker(position, abilityName)
        if targetMarker then targetMarker:Destroy() end
        local folder = Instance.new("Folder")
        folder.Name = "SukunaTargetMarker_Local"
        folder.Parent = workspace
        targetMarker = folder
        local ring = Instance.new("Part")
        ring.Name = "TargetRing"
        ring.Shape = Enum.PartType.Cylinder
        ring.Size = Vector3.new(0.16, 5, 5)
        ring.Material = Enum.Material.Neon
        ring.Color = Color3.fromRGB(195, 30, 50)
        ring.Transparency = 0.12
        ring.Anchored = true
        ring.CanCollide, ring.CanTouch, ring.CanQuery = false, false, false
        ring.CFrame = CFrame.new(position + Vector3.new(0, 0.12, 0)) * CFrame.Angles(0, 0, math.rad(90))
        ring.Parent = folder
        local finger = Instance.new("Part")
        finger.Name = "ClientFingerMarker"
        finger.Size = Vector3.new(0.32, 1.3, 0.32)
        finger.Material = Enum.Material.Neon
        finger.Color = Color3.fromRGB(255, 45, 68)
        finger.Anchored = true
        finger.CanCollide, finger.CanTouch, finger.CanQuery = false, false, false
        finger.CFrame = CFrame.new(position + Vector3.new(0, 1.15, 0)) * CFrame.Angles(0, 0, math.rad(18))
        finger.Parent = folder
        local light = Instance.new("PointLight")
        light.Color, light.Range, light.Brightness = finger.Color, 12, 2
        light.Parent = finger
        task.delay(2.8, function()
            if targetMarker == folder then targetMarker = nil end
            if folder.Parent then folder:Destroy() end
        end)
        notify(abilityName .. ": hedef client tarafında işaretlendi.")
    end

    local function playSkillAnimation(animationId)
        local humanoid = activeFigure and activeFigure:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        if animationId then
            pcall(function()
                local animator = humanoid:FindFirstChildOfClass("Animator")
                if not animator then animator = Instance.new("Animator"); animator.Parent = humanoid end
                local animation = Instance.new("Animation")
                animation.AnimationId = "rbxassetid://" .. tostring(animationId)
                local track = animator:LoadAnimation(animation)
                track.Priority = Enum.AnimationPriority.Action
                track:Play(0.1, 1, 1)
                game:GetService("Debris"):AddItem(animation, 8)
                task.delay(6, function() pcall(function() track:Stop(0.15); track:Destroy() end) end)
            end)
            return
        end
        -- Local procedural arm swing for Cleave/Dismantle; works without inventing an animation asset ID.
        local shoulder
        for _, descendant in ipairs(activeFigure:GetDescendants()) do
            if descendant:IsA("Motor6D") and (descendant.Name == "Right Shoulder" or descendant.Name == "RightShoulder") then
                shoulder = descendant
                break
            end
        end
        if not shoulder then return end
        local original = shoulder.C0
        local tweenService = game:GetService("TweenService")
        local swing = tweenService:Create(shoulder, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            C0 = original * CFrame.Angles(math.rad(-85), math.rad(10), math.rad(35))
        })
        swing:Play()
        task.delay(0.13, function()
            if shoulder and shoulder.Parent then
                tweenService:Create(shoulder, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                    C0 = original
                }):Play()
            end
        end)
    end

    local KEYBINDS = {Domain = Enum.KeyCode.Z, Cleave = Enum.KeyCode.X, Dismantle = Enum.KeyCode.C, Fuuga = Enum.KeyCode.V}
    local LABELS = {Domain = "DOMAIN", Cleave = "CLEAVE", Dismantle = "DISM.", Fuuga = "FUUGA"}
    local function createSkillControls()
        local player = game:GetService("Players").LocalPlayer
        local playerGui = player and (player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 5))
        if not playerGui then notify("Skill UI kurulamadı: PlayerGui yok."); return end
        local old = playerGui:FindFirstChild("SukunaAbilityHUD")
        if old then old:Destroy() end
        local backpack = player:FindFirstChildOfClass("Backpack")
        for _, container in ipairs({backpack, player.Character}) do
            if container then
                for _, toolName in ipairs({"Sukuna", "Domain", "Cleave", "Dismantle", "Fuuga"}) do
                    local oldTool = container:FindFirstChild(toolName)
                    if oldTool and oldTool:IsA("Tool") then oldTool:Destroy() end
                end
            end
        end
        hud = Instance.new("ScreenGui")
        hud.Name = "SukunaAbilityHUD"
        hud.ResetOnSpawn = false
        hud.IgnoreGuiInset = true
        hud.DisplayOrder = 50
        hud.Parent = playerGui
        local panel = Instance.new("Frame")
        panel.Name = "MobileSkillKeys"
        panel.AnchorPoint = Vector2.new(1, 0.5)
        panel.Position = UDim2.new(1, -100, 0.55, 0)
        panel.Size = UDim2.fromOffset(66, 292)
        panel.BackgroundTransparency = 1
        panel.Parent = hud
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 8)
        layout.Parent = panel
        local userInputService = game:GetService("UserInputService")
        local mobile = userInputService.TouchEnabled
        -- Keep the mobile ability panel visible on touch devices; don't depend on
        -- an outer/global UserInputService variable injected by the loader.
        panel.Visible = mobile
        for index, name in ipairs({"Domain", "Cleave", "Dismantle", "Fuuga"}) do
            local button = Instance.new("TextButton")
            button.Name = name .. "Key"
            button.LayoutOrder = index
            button.Size = UDim2.fromOffset(58, 58)
            button.BackgroundColor3 = Color3.fromRGB(43, 22, 30)
            button.BackgroundTransparency = 0.05
            button.BorderSizePixel = 0
            button.Text = LABELS[name] .. "\n" .. KEYBINDS[name].Name
            button.TextColor3 = Color3.fromRGB(255, 239, 239)
            button.TextSize = 11
            button.Font = Enum.Font.GothamBold
            button.TextWrapped = true
            button.AutoButtonColor = true
            button.Visible = mobile
            button.Parent = panel
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = button
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(210, 64, 82)
            stroke.Thickness = 1.5
            stroke.Parent = button
            skillButtons[name] = button
            table.insert(connections, button.Activated:Connect(function()
                if activateAbility then activateAbility(name, getClickedWorldPosition(true)) end
            end))
        end
        table.insert(connections, userInputService.InputBegan:Connect(function(input, processed)
            if processed or UserInputService:GetFocusedTextBox() then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            for name, keyCode in pairs(KEYBINDS) do
                if input.KeyCode == keyCode and activateAbility then
                    activateAbility(name, getClickedWorldPosition(false))
                    return
                end
            end
        end))
        notify("Skill kontrolleri hazır: Z Domain, X Cleave, C Dismantle, V Fuuga. Mobilde sağdaki dairesel tuşları kullan.")
    end

    local function announceFinger(text)
        pcall(function()
            game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                Text = text,
                Color = Color3.fromRGB(255, 60, 70),
                Font = Enum.Font.GothamBold,
                TextSize = 18,
            })
        end)
    end

    local function playFingerFoundCutscene(fingerPosition)
        -- This is a local presentation cutscene; the game server must own shared state.
        local camera = workspace.CurrentCamera
        if not camera or cutsceneActive then return end
        local oldType, oldSubject, oldCFrame = camera.CameraType, camera.CameraSubject, camera.CFrame
        local focus = fingerPosition + Vector3.new(0, 1.5, 0)
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = CFrame.lookAt(focus + Vector3.new(0, 5, 10), focus)
        local tween = game:GetService("TweenService"):Create(camera,
            TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {CFrame = CFrame.lookAt(focus + Vector3.new(0, 2.6, 5), focus)})
        tween:Play()
        task.delay(1.15, function()
            if not camera or not camera.Parent then return end
            camera.CameraType = oldType or Enum.CameraType.Custom
            camera.CameraSubject = oldSubject
            if oldCFrame then camera.CFrame = oldCFrame end
        end)
    end

    local function createFingerSearch()
        -- One real equipped finger accessory is used as the collectible. No fake
        -- Workspace parts and no server-created finger world are spawned by this moveset.
        if fingerFolder then fingerFolder:Destroy(); fingerFolder = nil end
        fingersFound = 0

        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local TextChatService = game:GetService("TextChatService")
        local player = Players.LocalPlayer
        local character = player and player.Character
        if not character then
            notify("Parmak bulunamadı: Sukuna parmak aksesuarını karakterine tak.")
            return
        end

        local function isFingerAccessory(item)
            if not item or not item:IsA("Accessory") then return false end
            if tonumber(item:GetAttribute("AssetId")) == FINGER_ID then return true end
            return string.find(string.lower(item.Name), "finger", 1, true) ~= nil
                or string.find(string.lower(item.Name), "parmak", 1, true) ~= nil
        end

        local accessory
        for _, item in ipairs(character:GetChildren()) do
            if isFingerAccessory(item) and item:FindFirstChild("Handle") then
                accessory = item
                break
            end
        end
        if not accessory then
            notify("Sukuna parmak aksesuarını takman gerekiyor; sahte Part oluşturulmadı.")
            return
        end

        local handle = accessory:FindFirstChild("Handle")
        if not handle or not handle:IsA("BasePart") then
            notify("Parmak aksesuarında Handle bulunamadı.")
            return
        end

        local function chatMessage(message)
            local sent = false
            pcall(function()
                local channels = TextChatService:FindFirstChild("TextChannels")
                local channel = channels and (channels:FindFirstChild("RBXGeneral") or channels:GetChildren()[1])
                if channel and channel.DisplaySystemMessage then
                    channel:DisplaySystemMessage("[SUKUNA] " .. message)
                    sent = true
                end
            end)
            if not sent then
                pcall(function()
                    game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                        Text = "[SUKUNA] " .. message,
                        Color = Color3.fromRGB(255, 70, 90),
                        Font = Enum.Font.GothamBold,
                    })
                end)
            end
        end

        local function getRootPosition()
            -- The accessory is mapped onto the reanimated rig, so use that rig's root
            -- for world-space HatCFrameOverride calculations.
            local rigRoot = (activeFigure and resolveRoot(activeFigure)) or root
            if rigRoot and rigRoot:IsA("BasePart") then return rigRoot.Position, rigRoot end
            local current = getLocalCharacter()
            local currentRoot = current and (current:FindFirstChild("HumanoidRootPart") or current.PrimaryPart)
            if currentRoot and currentRoot:IsA("BasePart") then return currentRoot.Position, currentRoot end
            return nil, nil
        end

        local function findSmartPosition()
            local base, currentRoot = getRootPosition()
            if not base then return nil end
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            local ignore = {character, accessory}
            if activeFigure then table.insert(ignore, activeFigure) end
            params.FilterDescendantsInstances = ignore
            params.IgnoreWater = true

            -- Pick a visible, walk-up-to surface, not a point inside a wall,
            -- under a ceiling, or on the far side of an obstacle.
            for attempt = 1, 48 do
                local angle = math.random() * math.pi * 2
                local radius = math.random(14, 48)
                local sample = base + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                local cast = workspace:Raycast(sample + Vector3.new(0, 140, 0), Vector3.new(0, -300, 0), params)
                if cast and cast.Normal.Y >= 0.72 then
                    local pos = cast.Position + Vector3.new(0, 1.35, 0)
                    local ceiling = workspace:Raycast(pos + Vector3.new(0, 0.5, 0), Vector3.new(0, 4.5, 0), params)
                    local origin = (currentRoot and currentRoot.Position or base) + Vector3.new(0, 2.2, 0)
                    local target = pos + Vector3.new(0, 0.5, 0)
                    local sight = workspace:Raycast(origin, target - origin, params)
                    local visible = not sight or (sight.Position - target).Magnitude < 2.75
                    if not ceiling and visible then
                        return pos
                    end
                end
            end
            return nil
        end

        local function getMeshTexture()
            local mesh = handle:FindFirstChildOfClass("SpecialMesh")
            if mesh then return mesh.MeshId, mesh.TextureId end
            if handle:IsA("MeshPart") then return handle.MeshId, handle.TextureId end
            return nil, nil
        end

        local meshId, textureId = getMeshTexture()
        local hatOverride
        if not HatReanimator or type(HatReanimator.HatCFrameOverride) ~= "table" then
            notify("Hat Reanimation bulunamadı; aksesuarı dünyaya sabitleyemiyorum.")
            return
        end
        if HatReanimator and type(HatReanimator.HatCFrameOverride) == "table" then
            hatOverride = {
                Name = accessory.Name,
                MeshId = meshId,
                TextureId = textureId,
                C0 = CFrame.identity,
                C1 = CFrame.identity,
                RepRootPart = root,
            }
            table.insert(HatReanimator.HatCFrameOverride, hatOverride)
            fingerOverride = hatOverride
            HatReanimator.RebuildRequired = true
        end

        local prompt = handle:FindFirstChild("SukunaFingerPrompt")
        if not prompt then
            prompt = Instance.new("ProximityPrompt")
            prompt.Name = "SukunaFingerPrompt"
            prompt.ActionText = "Parmağı Topla"
            prompt.ObjectText = "Sukuna'nın Parmağı"
            prompt.HoldDuration = 0.4
            prompt.MaxActivationDistance = 10
            prompt.RequiresLineOfSight = false
            prompt.Parent = handle
        end

        local marker = Instance.new("BillboardGui")
        fingerMarker = marker
        fingerPrompt = prompt
        marker.Name = "SukunaFingerMarker"
        marker.Adornee = handle
        marker.Size = UDim2.fromOffset(150, 40)
        marker.StudsOffsetWorldSpace = Vector3.new(0, 1.6, 0)
        marker.AlwaysOnTop = true
        marker.MaxDistance = 250
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundColor3 = Color3.fromRGB(35, 4, 12)
        label.BackgroundTransparency = 0.15
        label.TextColor3 = Color3.fromRGB(255, 75, 92)
        label.TextStrokeTransparency = 0.2
        label.Font = Enum.Font.GothamBold
        label.TextScaled = true
        label.Text = "☯ SUKUNA PARMAĞI"
        label.Parent = marker
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = label
        marker.Parent = player:WaitForChild("PlayerGui")

        local spawnPosition = findSmartPosition()
        if not spawnPosition then
            marker:Destroy()
            prompt.Enabled = false
            notify("Parmak için güvenli ve görünür bir yer bulunamadı. Biraz açık alana geç.")
            return
        end

        local collected = false
        local nextSpawnPending = false
        local spinTime = 0
        local function updateHatTarget(dt)
            if not accessory.Parent or not handle.Parent then return end
            if not spawnPosition then return end
            spinTime += dt or 0
            if hatOverride then
                local _, currentRoot = getRootPosition()
                if currentRoot then
                    local worldFrame = CFrame.new(spawnPosition) * CFrame.Angles(0, spinTime * 1.5, math.rad(108))
                    -- Recalculate relative to the live root so the pickup stays at its
                    -- chosen world location while the player walks away.
                    hatOverride.C0 = currentRoot.CFrame:ToObjectSpace(worldFrame)
                    hatOverride.RepRootPart = currentRoot
                end
            end
            if not collected then
                local base = getRootPosition()
                if base then
                    label.Text = ("☯ SUKUNA PARMAĞI  •  %d m"):format(math.floor((base - spawnPosition).Magnitude + 0.5))
                end
            end
        end
        table.insert(connections, RunService.RenderStepped:Connect(updateHatTarget))

        local function moveToNewSpot()
            if nextSpawnPending then return end
            nextSpawnPending = true
            task.delay(8, function()
                if not activeFigure or not activeFigure.Parent or not accessory.Parent then return end
                local newPosition = findSmartPosition()
                if not newPosition then
                    chatMessage("Parmak şu an güvenli bir konum bulamadı; yeniden dene.")
                    nextSpawnPending = false
                    prompt.Enabled = true
                    collected = false
                    return
                end
                spawnPosition = newPosition
                spinTime = 0
                collected = false
                nextSpawnPending = false
                prompt.Enabled = true
                marker.Enabled = true
                chatMessage("Parmak haritanın başka bir noktasında yeniden ortaya çıktı!")
                notify("Sukuna parmağı yeni bir noktada belirdi.")
            end)
        end

        prompt.Enabled = true
        table.insert(connections, prompt.Triggered:Connect(function(triggeringPlayer)
            if triggeringPlayer and triggeringPlayer ~= player then return end
            if collected or not spawnPosition then return end
            collected = true
            prompt.Enabled = false
            marker.Enabled = false
            fingersFound += 1
            local collectedAt = spawnPosition
            chatMessage(string.format("Sukuna parmağı toplandı! (%d)  •  8 saniye sonra başka yerde belirecek.", fingersFound))
            announceFinger(string.format("[Sukuna] PARMAK TOPLANDI  •  %d", fingersFound))
            playFingerFoundCutscene(collectedAt)
            task.spawn(function()
                if laughAnimationTrack then
                    pcall(function() laughAnimationTrack:Stop(0.05); laughAnimationTrack:Destroy() end)
                    laughAnimationTrack = nil
                end
                local track = playBundledAnimation("Sukuna/SukunaLaugh.anim", "laugh", false)
                if track then laughAnimationTrack = track end
            end)
            moveToNewSpot()
        end)
        chatMessage("Sukuna parmağı yakın çevrede, açık ve ulaşılabilir bir noktaya yerleştirildi. İşaretçiyi takip et.")
    end

    m.Config = function(parent) end

    m.Init = function(figure)
        activeFigure = figure
        root = resolveRoot(figure)
        domainEnabled = false
        cleaveUntil = 0
        accessoryCheckAccumulator = 0
        lastAccessorySignature = nil
        accessoryInstances = {}
        presentIds = {}
        overrideById = {}
        lastHatCFrames = {}

        if HatReanimator then
            savedWantAllHats = HatReanimator.IWantAllHats
            HatReanimator.IWantAllHats = true
            HatReanimator.RebuildRequired = true
        end

        refreshAccessories()
        ensureHatOverrides()
        applyAccessoryPositions()
        createSkillControls()
        createFingerSearch()

        -- Laugh is the one-shot intro as soon as the reanimated figure is ready.
        task.spawn(function()
            for attempt = 1, 10 do
                if not activeFigure or not activeFigure.Parent then return end
                local track = playBundledAnimation("Sukuna/SukunaLaugh.anim", "laugh", false)
                if track then
                    laughAnimationTrack = track
                    return
                end
                task.wait(0.6)
            end
            notify("Sukuna Laugh animasyonu yüklenemedi; modelde KeyframeSequence/Animation kontrol edilmeli.")
        end)
    end

    m.Update = function(dt, figure)
        activeFigure = figure or activeFigure
        root = resolveRoot(activeFigure)
        if not root then return end

        accessoryCheckAccumulator += math.max(0, tonumber(dt) or 0)
        if accessoryCheckAccumulator >= STATUS_INTERVAL then
            accessoryCheckAccumulator = 0
            refreshAccessories()
            ensureHatOverrides()
        end

        -- Re-add our overrides if NAM cleared the override table during a rig reload.
        ensureHatOverrides()
        applyAccessoryPositions()
        refreshButtons()
    end

    m.Destroy = function()
        domainEnabled = false
        cleaveUntil = 0
        fuugaBusy = false
        if fuugaAnimationTrack then pcall(function() fuugaAnimationTrack:Stop(0.1); fuugaAnimationTrack:Destroy() end); fuugaAnimationTrack = nil end
        if laughAnimationTrack then pcall(function() laughAnimationTrack:Stop(0.1); laughAnimationTrack:Destroy() end); laughAnimationTrack = nil end
        if fuugaProjectile then pcall(function() fuugaProjectile:Destroy() end); fuugaProjectile = nil end
        for _, aura in ipairs(fuugaAuraInstances) do pcall(function() aura:Destroy() end) end
        table.clear(fuugaAuraInstances)
        for _, saved in pairs(scaledMeshes) do
            if saved.instance and saved.instance.Parent then
                pcall(function()
                    if saved.kind == "mesh" then saved.instance.Scale = saved.original
                    elseif saved.kind == "part" then saved.instance.Size = saved.original end
                end)
            end
        end
        scaledMeshes = {}
        if inventoryTool then pcall(function() inventoryTool:Destroy() end); inventoryTool = nil end
        if fingerFolder then fingerFolder:Destroy(); fingerFolder = nil end
        if fingerMarker then pcall(function() fingerMarker:Destroy() end); fingerMarker = nil end
        if fingerPrompt and fingerPrompt.Parent then pcall(function() fingerPrompt:Destroy() end) end
        fingerPrompt = nil
        if HatReanimator and fingerOverride and type(HatReanimator.HatCFrameOverride) == "table" then
            local index = table.find(HatReanimator.HatCFrameOverride, fingerOverride)
            if index then table.remove(HatReanimator.HatCFrameOverride, index) end
            HatReanimator.RebuildRequired = true
        end
        fingerOverride = nil
        if cutsceneActive then
            local camera = workspace.CurrentCamera
            if camera then
                camera.CameraType = savedCameraType or Enum.CameraType.Custom
                camera.CameraSubject = savedCameraSubject
                if savedCameraCFrame then camera.CFrame = savedCameraCFrame end
            end
            cutsceneActive = false
        end

        if HatReanimator then
            local list = HatReanimator.HatCFrameOverride
            if type(list) == "table" then
                for _, override in pairs(overrideById) do
                    local index = table.find(list, override)
                    if index then table.remove(list, index) end
                end
            end
            if savedWantAllHats ~= nil then
                HatReanimator.IWantAllHats = savedWantAllHats
            end
            HatReanimator.RebuildRequired = true
        end

        for _, connection in ipairs(connections) do
            pcall(function() connection:Disconnect() end)
        end
        table.clear(connections)
        if hud then hud:Destroy(); hud = nil end
        local player = game:GetService("Players").LocalPlayer
        local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
        local old = playerGui and playerGui:FindFirstChild("SukunaAbilityHUD")
        if old then old:Destroy() end
        -- Skill controls are GUI-only; no Backpack Tools are created.

        skillButtons = {}
        if targetMarker then targetMarker:Destroy(); targetMarker = nil end
        activeFigure, root = nil, nil
        accessoryInstances, presentIds, overrideById = {}, {}, {}
        lastHatCFrames = {}
        savedWantAllHats = nil
        lastAccessorySignature = nil
    end

    return m
end)

return modules
