-- RobuNexa / NAM - Sukuna accessory-driven Domain and Cleave.
-- Uses equipped catalog accessories as HatReanimator targets with eased transitions.
-- Fuuga projectile/aura are local visual prototypes; shared visibility requires server replication.
local modules = {}
-- Keep factories intact: NAM's loader injects its API before invoking each factory.
local function AddModule(fn) table.insert(modules, fn) end

AddModule(function()
    local m = {}
    m.ModuleType = "MOVESET"
    m.Name = "Sukuna"
    m.Description = "Malevolent Shrine, Cleave, Dismantle, and Fuuga Flame Arrow."
    -- NAM downloads these repository assets before calling Init.
    m.Assets = {
        "Sukuna/Cleave.rbxm",
        "Sukuna/FlameArrow.rbxm",
        "Sukuna/Domain Expansion: Malevolent Shrine.rbxm",
        "Sukuna/Sukuna Laugh.rbxm",
        "Sukuna/Walk.rbxm",
        "Sukuna/Combo.rbxm",
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

    -- Load a KeyframeSequence/Animation stored inside a downloaded .rbxm model.
    -- This keeps the source assets in GitHub and avoids inventing animation IDs.
    local function playBundledAnimation(filename, preferredName, looped)
        if not activeFigure or not activeFigure.Parent then return false end
        local humanoid = activeFigure:FindFirstChildOfClass("Humanoid")
        if not humanoid then return false end

        local path = AssetGetPathFromFilename(filename)
        if not isfile or not isfile(path) then return false end

        local okLoad, objects = pcall(function()
            local assetUri = getcustomasset(path)
            return game:GetObjects(assetUri)
        end)
        if not okLoad or type(objects) ~= "table" then
            -- Some executors expose local model loading through InsertService instead.
            okLoad, objects = pcall(function()
                return {game:GetService("InsertService"):LoadLocalAsset(path)}
            end)
        end
        if not okLoad or type(objects) ~= "table" then return false end

        local selected
        local wanted = string.lower(preferredName or "")
        for _, object in ipairs(objects) do
            for _, item in ipairs(object:GetDescendants()) do
                if item:IsA("KeyframeSequence") or item:IsA("Animation") then
                    if string.find(string.lower(item.Name), wanted, 1, true) then
                        selected = item
                        break
                    elseif not selected then
                        selected = item
                    end
                end
            end
            if selected and string.find(string.lower(selected.Name), wanted, 1, true) then break end
        end
        if not selected then
            for _, object in ipairs(objects) do pcall(function() object:Destroy() end) end
            return false
        end

        local animation = Instance.new("Animation")
        animation.Name = "SukunaBundled_" .. tostring(preferredName or "Animation")
        if selected:IsA("Animation") and selected.AnimationId ~= "" then
            animation.AnimationId = selected.AnimationId
        elseif selected:IsA("KeyframeSequence") then
            local okId, contentId = pcall(function()
                return game:GetService("KeyframeSequenceProvider"):RegisterKeyframeSequence(selected)
            end)
            if not okId or not contentId then
                animation:Destroy()
                for _, object in ipairs(objects) do pcall(function() object:Destroy() end) end
                return false
            end
            animation.AnimationId = contentId
        else
            animation:Destroy()
            for _, object in ipairs(objects) do pcall(function() object:Destroy() end) end
            return false
        end

        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = humanoid
        end
        local okTrack, track = pcall(function() return animator:LoadAnimation(animation) end)
        if not okTrack or not track then
            animation:Destroy()
            for _, object in ipairs(objects) do pcall(function() object:Destroy() end) end
            return false
        end
        track.Priority = Enum.AnimationPriority.Action
        track.Looped = looped == true
        track:Play(0.12, 1, 1)
        task.delay(12, function()
            for _, object in ipairs(objects) do pcall(function() object:Destroy() end) end
            pcall(function() animation:Destroy() end)
        end)
        return track
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
        task.delay(1.05, function()
            if not cutsceneActive or not targetPosition then return end
            local currentCamera = workspace.CurrentCamera
            if currentCamera then
                game:GetService("TweenService"):Create(currentCamera, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                    CFrame = CFrame.lookAt(targetPosition + Vector3.new(0, 9, 14), targetPosition)
                }):Play()
            end
        end)
        task.delay(2.6, function()
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
        panel.Position = UDim2.new(1, -16, 0.57, 0)
        panel.Size = UDim2.fromOffset(66, 300)
        panel.BackgroundTransparency = 1
        panel.Parent = hud
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 8)
        layout.Parent = panel
        local mobile = UserInputService.TouchEnabled
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
        table.insert(connections, UserInputService.InputBegan:Connect(function(input, processed)
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

    local function createFingerSearch()
        -- Local prototype: true shared world pickups require server-side code in the experience.
        if fingerFolder then fingerFolder:Destroy() end
        fingerFolder = Instance.new("Folder")
        fingerFolder.Name = "SukunaFingerSearch_Local"
        fingerFolder.Parent = workspace
        fingersFound = 0
        local base = root and root.Position or Vector3.new(0, 10, 0)
        local rng = Random.new()
        for i = 1, 11 do
            local pos = base + Vector3.new(rng:NextInteger(-420, 420), rng:NextInteger(1, 20), rng:NextInteger(-420, 420))
            local finger = Instance.new("Part")
            finger.Name = "SukunaFinger_" .. i
            finger.Size = Vector3.new(0.35, 1.1, 0.35)
            finger.Material = Enum.Material.Neon
            finger.Color = Color3.fromRGB(122, 20, 34)
            finger.Anchored = true
            finger.CanCollide = false
            finger.CanTouch = false
            finger.CFrame = CFrame.new(pos)
            finger.Parent = fingerFolder
            local light = Instance.new("PointLight")
            light.Color = finger.Color
            light.Range = 10
            light.Brightness = 1.2
            light.Parent = finger
            local prompt = Instance.new("ProximityPrompt")
            prompt.ActionText = "Collect"
            prompt.ObjectText = "Sukuna Finger " .. i .. "/11"
            prompt.HoldDuration = 0.4
            prompt.MaxActivationDistance = 10
            prompt.Parent = finger
            local spin = game:GetService("RunService").RenderStepped:Connect(function()
                if not finger.Parent then spin:Disconnect(); return end
                finger.CFrame = CFrame.new(pos) * CFrame.Angles(0, os.clock() * 1.7, math.rad(12))
            end)
            table.insert(connections, spin)
            table.insert(connections, prompt.Triggered:Connect(function(player)
                if player ~= game:GetService("Players").LocalPlayer or not finger.Parent then return end
                if not fingerEquipped then
                    announceFinger("[Sukuna] Equip Finger accessory (ID 18762839664) before collecting fingers.")
                    return
                end
                fingersFound += 1
                finger:Destroy()
                announceFinger(string.format("[Sukuna] Finger collected: %d/11", fingersFound))
                if fingersFound == 11 then
                    announceFinger("[Sukuna] All 11 fingers found. The King of Curses awakens.")
                end
            end))
        end
    end

    local function launchFuuga()
        if fuugaBusy or not activeFigure or not root then return end
        fuugaBusy = true
        refreshButtons()
        local humanoid = activeFigure:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                if fuugaAnimationTrack then fuugaAnimationTrack:Stop(0.1); fuugaAnimationTrack:Destroy() end
                local animator = humanoid:FindFirstChildOfClass("Animator")
                if not animator then animator = Instance.new("Animator"); animator.Parent = humanoid end
                local animation = Instance.new("Animation")
                animation.AnimationId = "rbxassetid://131873641508713"
                fuugaAnimationTrack = animator:LoadAnimation(animation)
                fuugaAnimationTrack.Priority = Enum.AnimationPriority.Action
                fuugaAnimationTrack:Play(0.12, 1, 1)
                game:GetService("Debris"):AddItem(animation, 8)
            end)
        end

        local players = game:GetService("Players")
        local character = getLocalCharacter()
        local hand = activeFigure:FindFirstChild("RightHand") or activeFigure:FindFirstChild("Right Arm")
            or activeFigure:FindFirstChild("RightLowerArm") or root
        local targetPosition = fuugaTargetPosition
        local forward = targetPosition and (targetPosition - root.Position).Magnitude > 2
            and (targetPosition - root.Position).Unit or root.CFrame.LookVector
        local position = (hand and hand:IsA("BasePart") and hand.Position or root.Position)
            + forward * 1.4 + Vector3.new(0, 0.25, 0)
        local started = os.clock()
        local hitCharacter
        local projectileFolder = Instance.new("Folder")
        projectileFolder.Name = "SukunaFuuga_LocalVisual"
        projectileFolder.Parent = workspace
        fuugaProjectile = projectileFolder

        local arrow = Instance.new("Part")
        arrow.Name = "FuugaFlameArrow"
        arrow.Shape = Enum.PartType.Cylinder
        arrow.Size = Vector3.new(0.22, 2.8, 0.22)
        arrow.Material = Enum.Material.Neon
        arrow.Color = Color3.fromRGB(255, 92, 18)
        arrow.Anchored = true
        arrow.CanCollide = false
        arrow.CanTouch = false
        arrow.CastShadow = false
        arrow.Parent = projectileFolder

        local arrowHead = Instance.new("WedgePart")
        arrowHead.Name = "FlameArrowHead"
        arrowHead.Size = Vector3.new(0.65, 0.6, 0.65)
        arrowHead.Material = Enum.Material.Neon
        arrowHead.Color = Color3.fromRGB(255, 205, 68)
        arrowHead.Anchored = true
        arrowHead.CanCollide = false
        arrowHead.CanTouch = false
        arrowHead.CastShadow = false
        arrowHead.Parent = projectileFolder

        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255, 85, 16)
        light.Brightness = 3
        light.Range = 13
        light.Parent = arrow
        local flame = Instance.new("ParticleEmitter")
        flame.Name = "FuugaTrail"
        flame.Texture = "rbxasset://textures/particles/fire_main.dds"
        flame.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 235, 116)),
            ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 96, 12)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 18, 8)),
        })
        flame.LightEmission = 0.9
        flame.Rate = 75
        flame.Lifetime = NumberRange.new(0.18, 0.42)
        flame.Speed = NumberRange.new(0.4, 2.2)
        flame.SpreadAngle = Vector2.new(25, 25)
        flame.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 0)})
        flame.Parent = arrow

        local function placeArrow(pos)
            local cf = CFrame.lookAt(pos, pos + forward)
            arrow.CFrame = cf * CFrame.Angles(math.rad(90), 0, 0)
            arrowHead.CFrame = cf * CFrame.new(0, 0, -1.45)
        end
        placeArrow(position)
        -- Keep the flame arrow visible in the hand briefly before release.
        task.wait(0.45)

        task.spawn(function()
            local runService = game:GetService("RunService")
            while projectileFolder.Parent and os.clock() - started < 3.2 do
                local dt = runService.RenderStepped:Wait()
                if not root or not root.Parent then break end
                local nextPosition = position + forward * (115 * math.min(dt, 0.05))
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = {activeFigure, projectileFolder, character}
                local hit = workspace:Raycast(position, nextPosition - position, rayParams)
                if hit then
                    local model = hit.Instance:FindFirstAncestorOfClass("Model")
                    local player = model and players:GetPlayerFromCharacter(model)
                    if player and player ~= players.LocalPlayer then
                        hitCharacter = model
                        position = hit.Position
                        break
                    elseif hit.Instance.CanCollide then
                        position = hit.Position
                        break
                    end
                end
                position = nextPosition
                placeArrow(position)
            end

            if hitCharacter and hitCharacter.Parent then
                local targetRoot = hitCharacter:FindFirstChild("HumanoidRootPart")
                    or hitCharacter:FindFirstChild("Torso") or hitCharacter:FindFirstChild("UpperTorso")
                if targetRoot and targetRoot:IsA("BasePart") then
                    local aura = Instance.new("Attachment")
                    aura.Name = "SukunaFuugaFlameAura_Local"
                    aura.Parent = targetRoot
                    table.insert(fuugaAuraInstances, aura)
                    local fire = Instance.new("ParticleEmitter")
                    fire.Name = "AnimatedFlameAura"
                    fire.Texture = "rbxasset://textures/particles/fire_main.dds"
                    fire.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 241, 130)),
                        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255, 105, 12)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 12, 4)),
                    })
                    fire.LightEmission = 0.85
                    fire.Rate = 110
                    fire.Lifetime = NumberRange.new(0.35, 0.85)
                    fire.Speed = NumberRange.new(1, 4)
                    fire.SpreadAngle = Vector2.new(180, 180)
                    fire.RotSpeed = NumberRange.new(-180, 180)
                    fire.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1.25),
                        NumberSequenceKeypoint.new(0.55, 0.85),
                        NumberSequenceKeypoint.new(1, 0),
                    })
                    fire.Parent = aura
                    local glow = Instance.new("PointLight")
                    glow.Color = Color3.fromRGB(255, 84, 12)
                    glow.Brightness = 2
                    glow.Range = 12
                    glow.Parent = aura
                    task.delay(5, function()
                        if aura and aura.Parent then
                            for _, descendant in ipairs(aura:GetDescendants()) do
                                if descendant:IsA("ParticleEmitter") then descendant.Enabled = false end
                            end
                            task.wait(0.8)
                            if aura then aura:Destroy() end
                        end
                    end)
                end
            end
            if projectileFolder then projectileFolder:Destroy() end
            if fuugaProjectile == projectileFolder then fuugaProjectile = nil end
            task.delay(1.1, function() fuugaBusy = false; refreshButtons() end)
        end)
    end

    activateAbility = function(name, targetPosition)
        if not activeFigure or not activeFigure.Parent or not root then
            notify("Reanimation karakteri hazır değil.")
            return
        end
        local now = os.clock()
        local readyAt = abilityReadyAt[name] or 0
        if now < readyAt then
            notify(string.format("%s cooldown: %.1f saniye", name, readyAt - now))
            return
        end
        refreshAccessories()
        local slashEquipped = presentIds[100475161263482] or presentIds[97087028126781]
        if name == "Domain" and not slashEquipped then
            notify("Domain için Cleave Aura veya White Domain Slashes aksesuarı tak.")
            return
        elseif (name == "Cleave" or name == "Dismantle") and not slashEquipped then
            notify(name .. " için slash aksesuarlarından biri takılı olmalı.")
            return
        elseif name == "Fuuga" and not presentIds[124144353587446] then
            notify("Fuuga için Fuga Furnace aksesuarını tak.")
            return
        end
        targetPosition = targetPosition or (root.Position + root.CFrame.LookVector * 24)
        showTargetMarker(targetPosition, name)
        playDomainCutscene(targetPosition)
        if name == "Domain" then playSkillAnimation(nil) end
        abilityReadyAt[name] = now + (abilityCooldowns[name] or 3)
        if name == "Domain" then
            domainEnabled = not domainEnabled
            if domainEnabled then domainStartedAt = os.clock(); notify("Malevolent Shrine açıldı.") else notify("Domain kapatıldı.") end
            applyAccessoryPositions()
        elseif name == "Cleave" then
            playSkillAnimation(nil)
            cleaveUntil = os.clock() + 2.5
            applyAccessoryPositions()
        elseif name == "Dismantle" then
            playSkillAnimation(nil)
            cleaveUntil = os.clock() + 1.6
            applyAccessoryPositions()
        elseif name == "Fuuga" then
            fuugaTargetPosition = targetPosition
            launchFuuga()
        end
        refreshButtons()
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
                local track = playBundledAnimation("Sukuna/Sukuna Laugh.rbxm", "laugh", false)
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
