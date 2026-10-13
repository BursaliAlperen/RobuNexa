-- RobuNexa / NAM - One-Finger Sukuna, Cleave-focused.
-- No Domain, Fuuga, or chat output. Uses the user's equipped Cleave accessory.
local modules = {}
-- Keep factories intact: NAM's loader injects its API before invoking each factory.
local function AddModule(fn) table.insert(modules, fn) end

AddModule(function()
    local m = {}
    local UserInputService = game:GetService("UserInputService")
    m.ModuleType = "MOVESET"
    m.Name = "Sukuna"
    m.Description = "One-Finger Sukuna: Cleave-focused slashes. No Domain or Fuuga."
    -- Match Gojo's asset loader contract: logical local path @ raw GitHub URL.
    -- These are NAM AnimLib binary .anim files, not .rbxm models.
    m.Assets = {
        "Sukuna/Cleave.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Sukuna/Cleave.anim",
        "Sukuna/Combo.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Sukuna/Combo.anim",
        "Sukuna/MalevolentShrine.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Sukuna/MalevolentShrine.anim",
        "Sukuna/FlameArrow.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Sukuna/FlameArrow.anim",
        "Sukuna/SukunaLaugh.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Sukuna/SukunaLaugh.anim",
        "Sukuna/Walk.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Sukuna/Walk.anim",
        "Sukuna/SukunaIdle.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Sukuna/SukunaIdle.anim",
        "Sukuna/Jump.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Sukuna/Jump.anim",
        "Sukuna/Fall.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Sukuna/Fall.anim",
        "sounds/Awaken2.mp3@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/sounds/Awaken2.mp3",
        "sounds/Awakenw1.mp3@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/sounds/Awakenw1.mp3",
    }

    local TARGETS = {
        [18445594182] = {
            key = "shrine",
            label = "Malevolent Shrine",
            hints = {"malevolent shrine", "domain expansion"},
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
        [101090904148116] = {
            key = "cleaveAura",
            label = "Equipped Cleave",
            hints = {"cleave"},
            hiddenHeight = 0,
        },
        [97087028126781] = {
            key = "whiteSlashes",
            label = "White Domain Slashes",
            hints = {"white domain", "expension slashes", "expansion slashes"},
            hiddenHeight = 0,
        },
        [18908729586] = {
            key = "cleaveSlash",
            label = "Sukuna Cleave Slash",
            hints = {"18908729586", "cleave slash", "slash effect"},
            hiddenHeight = 0,
        },
    }

    local EFFECT_IDS = {101090904148116, 100475161263482, 97087028126781, 18908729586}
    -- Strict catalog allowlist: only these known accessory IDs are accepted.
    -- 18445594182 is the active Domain/Shrine asset; 18726352770 is retained as
    -- an allowed legacy asset ID but is not used as the Domain target.
    local ALLOWED_ASSET_IDS = {
        [101090904148116] = true,
        [18445594182] = true,
        [131873641508713] = true,
        [18762839664] = true,
        [18726352770] = true,
        [124144353587446] = true,
        [100475161263482] = true,
        [97087028126781] = true,
        [18908729586] = true,
    }
    local function isAllowedAssetId(id)
        return ALLOWED_ASSET_IDS[tonumber(id)] == true
    end
    local FINGER_ID = 18762839664
    local activeFigure, root
    local hud
    local skillButtons = {}
    local activateAbility
    local abilityCooldowns = {Cleave = 5, Dismantle = 7, Combo = 15}
    local abilityReadyAt = {}
    local abilityTargets = {}
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
    local cleaveAccessoryStartedAt = 0
    local cleaveAccessoryUntil = 0
    local comboAccessoryStartedAt = 0
    local comboAccessoryUntil = 0
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
    local walkAnimationTrack
    local movementAnimationName
    local fuugaProjectile
    local fuugaAuraInstances = {}
    local awakeningSound
    local STATUS_INTERVAL = 1.25

    local function notify(message)
        pcall(function() Util.Notify("Sukuna: " .. message) end)
    end

    -- Exactly one awakening track is chosen per moveset start. These are local
    -- downloaded assets, not Roblox asset IDs. Always stop/destroy the previous
    -- instance first so reinitializing Sukuna can never overlap both tracks.
    local function playRandomAwakeningSound()
        if awakeningSound then
            pcall(function() awakeningSound:Stop(); awakeningSound:Destroy() end)
            awakeningSound = nil
        end
        local choices = {"sounds/Awaken2.mp3", "sounds/Awakenw1.mp3"}
        local chosen = choices[math.random(1, #choices)]
        local soundId = ""
        pcall(function() soundId = AssetGetContentId(chosen) end)
        if type(soundId) ~= "string" or soundId == "" then
            notify("Awakening sound missing: " .. chosen .. " (check download/getcustomasset support).")
            return
        end
        local ok, soundOrError = pcall(function()
            local sound = Instance.new("Sound")
            sound.Name = "SukunaAwakeningIntro"
            sound.SoundId = soundId
            sound.Volume = 1
            sound.Looped = false
            sound.Parent = game:GetService("SoundService")
            return sound
        end)
        if ok and soundOrError then
            awakeningSound = soundOrError
            local thisSound = awakeningSound
            -- Preload off the startup path so the moveset never freezes while
            -- waiting for audio. The identity check cancels stale starts after
            -- a quick moveset switch/reinitialization.
            task.spawn(function()
                local preloadOk, preloadError = pcall(function()
                    game:GetService("ContentProvider"):PreloadAsync({thisSound})
                end)
                if not preloadOk then
                    warn("[Sukuna] Awakening preload failed: " .. tostring(preloadError))
                end
                if awakeningSound ~= thisSound or not thisSound.Parent then return end
                local playOk, playError = pcall(function() thisSound:Play() end)
                if not playOk then
                    warn("[Sukuna] Awakening sound playback failed: " .. tostring(playError))
                end
            end)
            task.delay(30, function()
                if awakeningSound == thisSound then
                    pcall(function() thisSound:Destroy() end)
                    awakeningSound = nil
                end
            end)
        else
            warn("[Sukuna] Awakening sound creation failed: " .. tostring(soundOrError))
        end
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

    -- Use the same AnimLib stepping contract as the working Gojo moveset.
    -- Keep only one action clip active so concurrent tracks cannot reset each
    -- other's Motor6D transforms and make Cleave/Combo appear not to play.
    local activeActionTrack
    local actionAnimationTrack
    local function playBundledAnimation(filename, preferredName, looped)
        if not activeFigure or not activeFigure.Parent then return false end
        local path = AssetGetPathFromFilename(filename)
        if not isfile or not isfile(path) then
            notify("Animation file not found: " .. filename)
            return false
        end

        local okTrack, track = pcall(function() return AnimLib.Track.fromfile(path) end)
        if not okTrack or not track or type(track.Keyframes) ~= "table" or #track.Keyframes == 0 then
            notify("Invalid .anim file: " .. filename)
            return false
        end

        local clipName = string.lower(tostring(preferredName or filename))
        local isMovementClip = clipName == "walk" or clipName == "run" or clipName == "idle"
            or clipName == "jump" or clipName == "fall"
        if not isMovementClip then
            -- Stop movement before an attack; otherwise the next Update recreates
            -- the walk/idle track and immediately overwrites the attack pose.
            if walkAnimationTrack and walkAnimationTrack.IsPlaying then
                pcall(function() walkAnimationTrack:Stop(0.05); walkAnimationTrack:Destroy() end)
            end
            walkAnimationTrack = nil
            movementAnimationName = nil
        end
        if activeActionTrack and activeActionTrack.IsPlaying then
            activeActionTrack:Stop(0.05)
        end
        local okAnimator, animator = pcall(function() return AnimLib.Animator.new() end)
        if not okAnimator or not animator then
            notify("AnimLib Animator failed for " .. filename)
            return false
        end
        animator.rig = activeFigure
        animator.track = track
        animator.looped = looped == true
        local duration = 0
        for _, keyframe in ipairs(track.Keyframes) do
            if type(keyframe.Time) == "number" then duration = math.max(duration, keyframe.Time) end
        end
        if duration <= 0 then
            notify("Animation has no usable duration: " .. filename)
            return false
        end
        local startedAt = os.clock()
        local stopped = false
        local stepConnection
        local controller = {IsPlaying = true, Duration = duration, Name = preferredName or filename}
        function controller:Stop(_fadeTime)
            if stopped then return end
            stopped = true
            self.IsPlaying = false
            if stepConnection then stepConnection:Disconnect(); stepConnection = nil end
            if activeActionTrack == self then activeActionTrack = nil end
            if actionAnimationTrack == self then actionAnimationTrack = nil end
            if activeFigure and activeFigure.Parent then
                for _, item in ipairs(activeFigure:GetDescendants()) do
                    if item:IsA("Motor6D") then
                        pcall(function() item.Transform = CFrame.identity end)
                    end
                end
            end
        end
        function controller:Destroy()
            self:Stop()
        end
        activeActionTrack = controller
        if not isMovementClip then actionAnimationTrack = controller end
        stepConnection = game:GetService("RunService").RenderStepped:Connect(function()
            if stopped or not activeFigure or not activeFigure.Parent then
                controller:Stop()
                return
            end
            local elapsed = os.clock() - startedAt
            if duration > 0 and elapsed >= duration then
                if animator.looped then
                    startedAt = os.clock()
                    elapsed = 0
                else
                    controller:Stop()
                    return
                end
            end
            local okStep = pcall(function()
                animator:Step(elapsed)
            end)
            if not okStep then
                notify("Animation step failed: " .. tostring(controller.Name))
                controller:Stop()
            end
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
            local wanted = string.lower(tostring(candidateName))
            for _, child in ipairs(character:GetChildren()) do
                if child:IsA("Accessory") and string.lower(child.Name) == wanted then
                    return child
                end
            end
            -- Some avatar pipelines rename applied accessories. Compare case-insensitively
            -- and use target-specific name hints before leaving an equipped hat unmatched.
            for id, target in pairs(TARGETS) do
                local matchesEntry = false
                for _, hint in ipairs(target.hints) do
                    if string.find(wanted, hint, 1, true) then matchesEntry = true; break end
                end
                if matchesEntry then
                    for _, child in ipairs(character:GetChildren()) do
                        if child:IsA("Accessory") then
                            local childName = string.lower(child.Name)
                            for _, hint in ipairs(target.hints) do
                                if string.find(childName, hint, 1, true) then return child end
                            end
                        end
                    end
                end
            end
        end
        return nil
    end

    -- Use only accessories already equipped on the player's character.
    -- Never fetch catalog assets or create replacement accessories from this moveset.
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
                            if id and isAllowedAssetId(id) and TARGETS[id] then
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
                                if id and isAllowedAssetId(id) and TARGETS[id] then nextPresent[id] = true end
                            end
                        end
                    end
                end
            end

            for _, child in ipairs(character:GetChildren()) do
                if child:IsA("Accessory") then
                    local attrId = tonumber(child:GetAttribute("AssetId"))
                        or tonumber(child:GetAttribute("_RobuNexaSukunaAssetId"))
                    if attrId and isAllowedAssetId(attrId) and TARGETS[attrId] then
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

            -- Explicitly recover the requested slash accessory when the avatar
            -- API reports its AssetId but does not expose an applied-instance
            -- reference. Some clients put the reanimated copy under activeFigure.
            if not nextInstances[18908729586] then
                local containers = {}
                if character then table.insert(containers, character) end
                if activeFigure and activeFigure ~= character then table.insert(containers, activeFigure) end
                for _, container in ipairs(containers) do
                    for _, child in ipairs(container:GetChildren()) do
                        if child:IsA("Accessory") then
                            local assetId = tonumber(child:GetAttribute("AssetId"))
                                or tonumber(child:GetAttribute("_RobuNexaSukunaAssetId"))
                            local lowerName = string.lower(child.Name)
                            local explicitId = string.find(lowerName, "18908729586", 1, true) ~= nil
                            local slashName = string.find(lowerName, "cleave slash", 1, true) ~= nil
                                or string.find(lowerName, "slash effect", 1, true) ~= nil
                            if assetId == 18908729586 or explicitId then
                                nextInstances[18908729586] = child
                                nextPresent[18908729586] = true
                                break
                            elseif slashName and not used[child] then
                                nextInstances[18908729586] = child
                                nextPresent[18908729586] = true
                                used[child] = true
                                break
                            end
                        end
                    end
                    if nextInstances[18908729586] then break end
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
                    if child:IsA("Accessory") and (
                        tonumber(child:GetAttribute("AssetId")) == FINGER_ID
                        or tonumber(child:GetAttribute("_RobuNexaSukunaAssetId")) == FINGER_ID
                        or string.lower(child.Name) == "sukuna's finger"
                        or string.lower(child.Name) == "sukuna finger"
                    ) then
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
            if #matched == 5 then
                notify("5/5 Sukuna accessories detected; Hat Reanimation targets are being prepared.")
            elseif #matched > 0 then
                notify(string.format("%d/5 equipped Sukuna accessories matched.", #matched))
            else
                notify("0/4 equipped Sukuna accessories matched. Check the accessory names in your avatar.")
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
            if id == 18445594182 then scaleShrineAccessory(accessory) end
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
        if saved and saved.factor ~= 10 then
            pcall(function()
                if saved.kind == "mesh" then saved.instance.Scale = saved.original * 10
                elseif saved.kind == "part" then saved.instance.Size = saved.original * 10 end
            end)
            saved.factor = 10
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
        if not override or typeof(targetCFrame) ~= "CFrame" then return end
        local previous = lastHatCFrames[id] or override.C0
        -- Never interpolate from the hidden -5000-stud parking position to a
        -- short slash pulse: it would remain thousands of studs away until the
        -- pulse ended. Snap long-distance transitions; ease only local motion.
        local eased
        if typeof(previous) ~= "CFrame"
            or (previous.Position - targetCFrame.Position).Magnitude > 80 then
            eased = targetCFrame
        else
            eased = previous:Lerp(targetCFrame, 0.32)
        end
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
        -- Keep every inactive Sukuna effect accessory 5,000 studs away from the rig.
        -- These overrides use rig-local CFrames, so this is a local-space offset.
        -- The Sukuna Finger is handled separately and is intentionally excluded.
        local center = root.CFrame * CFrame.new(0, 2, -5)
        local hiddenCenter = CFrame.new(0, 0, -5000)
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
            -- The 10x domain hat accessory emerges from the ground behind the user's reanimated character.
            local shrineOffset = CFrame.new(0, -12 + eased * 12, -8)
                * CFrame.Angles(0, math.rad(180), 0)
            setHatWorldCFrame(18445594182, shrineOffset)
        else
            setHatWorldCFrame(18445594182,
                hiddenCenter * CFrame.new(0, TARGETS[18445594182].hiddenHeight, 0))
        end
        if abilityTargets.Fuuga and fuugaBusy then
            setHatWorldCFrame(124144353587446, root.CFrame:ToObjectSpace(CFrame.new(abilityTargets.Fuuga + Vector3.new(0, 3, 0))))
        else
            setHatWorldCFrame(124144353587446,
                hiddenCenter * CFrame.new(0, TARGETS[124144353587446].hiddenHeight, 0))
        end

        -- Keep the equipped Cleave accessory hidden 5,000 studs away unless a
        -- Cleave/Combo is actively playing. Animate it relative to the live rig root.
        local accessoryFrame
        if t < cleaveAccessoryUntil then
            local progress = math.clamp((t - cleaveAccessoryStartedAt) / 0.32, 0, 1)
            local eased = progress * progress * (3 - 2 * progress)
            local wobble = math.sin(t * 17) * 0.12
            accessoryFrame = CFrame.new(wobble, 1.5 + math.sin(t * 13) * 0.08, -2 - eased * 9)
                * CFrame.Angles(math.rad(math.sin(t * 14) * 2), math.rad(math.sin(t * 11) * 3), math.rad(wobble * 8))
        elseif t < comboAccessoryUntil then
            local tremble = math.sin(t * 62) * 0.22
            local trembleY = math.cos(t * 71) * 0.14
            accessoryFrame = CFrame.new(tremble, 1.5 + trembleY, -5 + math.sin(t * 48) * 0.3)
                * CFrame.Angles(math.rad(trembleY * 18), math.rad(tremble * 16), math.rad(tremble * 12))
        else
            accessoryFrame = CFrame.new(0, TARGETS[101090904148116].hiddenHeight, -5000)
        end
        setHatWorldCFrame(101090904148116, accessoryFrame)

        -- Animate the equipped catalog Cleave Slash accessory (18908729586).
        -- It must be moved from the rig toward the selected target, not just placed
        -- at the target. Keep it hidden only when no attack pulse is active.
        local slashFrame = CFrame.new(0, 0, -5000)
        local slashActive = slashBurstTarget ~= nil and t < slashBurstUntil
            and root and root.Parent
        if slashActive then
            local elapsed = math.max(0, t - slashBurstStartedAt)
            local count = math.max(1, slashBurstCount or 1)
            local pulseDuration = 0.28
            local pulseIndex = math.floor(elapsed / pulseDuration)
            local pulseTime = elapsed - pulseIndex * pulseDuration
            if pulseIndex < count and pulseTime < 0.22 then
                local travel = math.clamp(pulseTime / 0.22, 0, 1)
                local side = count > 1 and ((pulseIndex % 3) - 1) * 1.35 or 0
                local startPosition = root.Position + root.CFrame.LookVector * 2.5
                    + root.CFrame.RightVector * side + Vector3.new(0, 2, 0)
                local endPosition = slashBurstTarget + Vector3.new(side, 2, 0)
                local worldPosition = startPosition:Lerp(endPosition, travel)
                local direction = endPosition - startPosition
                if direction.Magnitude < 0.01 then direction = root.CFrame.LookVector end
                local worldFrame = CFrame.lookAt(worldPosition, worldPosition + direction.Unit)
                    * CFrame.Angles(0, 0, math.rad((pulseIndex % 2 == 0) and -35 or 35))
                slashFrame = root.CFrame:ToObjectSpace(worldFrame)
                -- Keep the catalog accessory at its original scale. Resizing it
                -- during every slash pulse forces HatReanimator rebuilds and can
                -- interrupt the effect on some clients.
            end
        else
            slashBurstTarget = nil
            slashBurstCount = 0
        end
        setHatWorldCFrame(18908729586, slashFrame)

        if active then
            local pulse = math.sin(t * rate)
            local dismantleTarget = abilityTargets.Dismantle
                or abilityTargets.Combo
            local effectTarget = abilityTargets.Cleave or dismantleTarget
            if domainEnabled and abilityTargets.Domain then effectTarget = abilityTargets.Domain end
            local sweep = math.cos(t * rate * 1.13)
            local leftTarget = abilityTargets.Cleave or effectTarget
            local rightTarget = dismantleTarget or effectTarget
            setHatWorldCFrame(100475161263482,
                leftTarget and root.CFrame:ToObjectSpace(CFrame.new(leftTarget + Vector3.new(pulse * 1.2, 2 + math.abs(pulse), sweep * 1.2)) * CFrame.Angles(0, t * 2, 0))
                or (center * CFrame.new(pulse * (fast and 2.8 or 1.4), 1 + math.abs(pulse) * 1.2, sweep * (fast and 2.8 or 1.4))
                    * CFrame.Angles(math.rad(pulse * 10), t * (fast and 3.5 or 0.45), math.rad(sweep * 8))))
            setHatWorldCFrame(97087028126781,
                rightTarget and root.CFrame:ToObjectSpace(CFrame.new(rightTarget + Vector3.new(sweep * 1.2, 2.5 + pulse, pulse * 1.2)) * CFrame.Angles(0, t * 3, 0))
                or (center * CFrame.new(sweep * (fast and 3.5 or 1.8), 2.5 + pulse, pulse * (fast and 3.5 or 1.8))
                    * CFrame.Angles(math.rad(sweep * 18), t * (fast and 8 or 1.1), math.rad(pulse * 15))))
        else
            setHatWorldCFrame(100475161263482,
                hiddenCenter * CFrame.new(0, TARGETS[100475161263482].hiddenHeight, 0))
            setHatWorldCFrame(97087028126781,
                hiddenCenter * CFrame.new(0, TARGETS[97087028126781].hiddenHeight, 0))
        end
    end

    local KEYBINDS = {
        Cleave = Enum.KeyCode.X,
        Dismantle = Enum.KeyCode.C,
        Combo = Enum.KeyCode.Z,
    }
    local LABELS = {
        Cleave = "CLEAVE",
        Dismantle = "DISMANTLE",
        Combo = "COMBO",
    }
    local SKILL_ORDER = {"Cleave", "Dismantle", "Combo"}

    local function refreshButtons()
        if type(skillButtons) ~= "table" or type(abilityReadyAt) ~= "table" then
            return
        end

        for name, button in pairs(skillButtons) do
            local keyCode = KEYBINDS[name]
            local label = LABELS[name]
            if keyCode and label and button and button.Parent then
                local remaining = math.max(0, (abilityReadyAt[name] or 0) - os.clock())
                local coolingDown = remaining > 0
                button.Text = coolingDown
                    and string.format("%s\n%.1fs", label, remaining)
                    or (label .. "\n" .. keyCode.Name)
                button.BackgroundColor3 = coolingDown
                    and Color3.fromRGB(105, 105, 105)
                    or Color3.fromRGB(43, 22, 30)
                button.TextColor3 = coolingDown
                    and Color3.fromRGB(205, 205, 205)
                    or Color3.fromRGB(255, 239, 239)
                button.AutoButtonColor = not coolingDown
                button.Active = not coolingDown
                button.Interactable = not coolingDown
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
            local first = playBundledAnimation("Sukuna/Cleave.anim", "cleave", false)
            if first then
                local timeout = os.clock() + math.max((first.Duration or 0) + 1.25, 15)
                while first.IsPlaying and os.clock() < timeout and cutsceneActive do
                    task.wait(0.05)
                end
                pcall(function() first:Stop(0.08); first:Destroy() end)
            end
            if cutsceneActive then
                local second = playBundledAnimation("Sukuna/MalevolentShrine.anim", "domain", false)
                if second then
                    local timeout = os.clock() + math.max((second.Duration or 0) + 1.25, 15)
                    while second.IsPlaying and os.clock() < timeout and cutsceneActive do
                        task.wait(0.05)
                    end
                    pcall(function() second:Stop(0.1); second:Destroy() end)
                end
            end
            if cutsceneActive then
                local currentCamera = workspace.CurrentCamera
                if currentCamera then
                    currentCamera.CameraType = savedCameraType or Enum.CameraType.Custom
                    currentCamera.CameraSubject = savedCameraSubject
                    if savedCameraCFrame then currentCamera.CFrame = savedCameraCFrame end
                end
                cutsceneActive = false
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

    -- Intentionally silent: no chat output. Keep this as a valid no-op function.
    local function chatAbilityMessage(_message)
        return nil
    end

    local function activateSukunaAbility(name, targetPosition)
        if name == "Domain" or name == "Fuuga" then return end
        local isDismantle = name == "Dismantle"
        local isCombo = name == "Combo"
        if name ~= "Cleave" and not isDismantle and not isCombo then return end
        if not activeFigure or not activeFigure.Parent or not root or not root.Parent then
            notify("Moveset is not ready yet; waiting for the Hat Reanimation rig.")
            return
        end
        local now = os.clock()
        if now < (abilityReadyAt[name] or 0) then return end
        abilityReadyAt[name] = now + (abilityCooldowns[name] or 3)
        targetPosition = typeof(targetPosition) == "Vector3" and targetPosition
            or (root.Position + root.CFrame.LookVector * 32)
        abilityTargets[name] = targetPosition

        if name == "Domain" then
            domainEnabled = not domainEnabled
            if domainEnabled then
                domainStartedAt = now
                -- Place the Shrine and slash accessories around the chosen target;
                -- unused effects remain far below the map until activated.
                setHatWorldCFrame(18445594182, root.CFrame:ToObjectSpace(CFrame.new(targetPosition + Vector3.new(0, 2, 0)) * root.CFrame.Rotation))
                setHatWorldCFrame(124144353587446, root.CFrame:ToObjectSpace(CFrame.new(targetPosition + Vector3.new(0, 5, 0)) * root.CFrame.Rotation))
                setHatWorldCFrame(100475161263482, root.CFrame:ToObjectSpace(CFrame.new(targetPosition + Vector3.new(-5, 2, 0))))
                setHatWorldCFrame(97087028126781, root.CFrame:ToObjectSpace(CFrame.new(targetPosition + Vector3.new(5, 2, 0))))
                playDomainCutscene(targetPosition)
                chatAbilityMessage("Domain Expansion: Malevolent Shrine!")
            else
                abilityTargets.Domain = nil
                chatAbilityMessage("Malevolent Shrine deactivated.")
            end
        elseif name == "Cleave" then
            cleaveUntil = now + 1.2
            cleaveAccessoryStartedAt = now
            cleaveAccessoryUntil = now + 0.72
            comboAccessoryUntil = 0
            slashBurstStartedAt = now
            slashBurstUntil = now + 0.3
            slashBurstCount = 1
            slashBurstTarget = targetPosition
            -- Play the bundled Sukuna animation only; no procedural fallback animation.
            playBundledAnimation("Sukuna/Cleave.anim", "cleave", false)
            chatAbilityMessage("Cleave!")
            task.delay(1.35, function()
                if abilityTargets.Cleave == targetPosition then abilityTargets.Cleave = nil end
            end)
        elseif isDismantle or isCombo then
            cleaveUntil = now + (isCombo and 1.8 or 1.2)
            slashBurstStartedAt = now
            slashBurstUntil = now + (isCombo and 1.5 or 0.48)
            slashBurstCount = isCombo and 5 or 2
            slashBurstTarget = targetPosition
            if isCombo then
                comboAccessoryStartedAt = now
                comboAccessoryUntil = now + 1.45
                cleaveAccessoryUntil = 0
            end
            abilityTargets.Dismantle = targetPosition
            setHatWorldCFrame(97087028126781, root.CFrame:ToObjectSpace(CFrame.new(targetPosition + Vector3.new(0, 2, 0))))
            -- Use the bundled clip directly. No procedural fallback animation.
            playBundledAnimation(
                isCombo and "Sukuna/Combo.anim" or "Sukuna/Cleave.anim",
                isCombo and "combo" or "dismantle",
                false
            )
            -- Combo produces three staggered local slash pulses without chat output.
            if isCombo then
                for hit = 1, 3 do
                    task.delay((hit - 1) * 0.18, function()
                        if activeFigure and activeFigure.Parent and root and root.Parent then
                            local offset = Vector3.new((hit - 2) * 2.5, 1.5 + hit * 0.35, 0)
                            setHatWorldCFrame(97087028126781,
                                root.CFrame:ToObjectSpace(CFrame.new(targetPosition + offset)))
                        end
                    end)
                end
            end
            task.delay(1.9, function()
                if abilityTargets[name] == targetPosition then abilityTargets[name] = nil end
                if abilityTargets.Dismantle == targetPosition then abilityTargets.Dismantle = nil end
            end)
        elseif name == "Fuuga" then
            fuugaBusy = true
            setHatWorldCFrame(124144353587446, root.CFrame:ToObjectSpace(CFrame.new(targetPosition + Vector3.new(0, 3, 0))))
            playBundledAnimation("Sukuna/FlameArrow.anim", "flame", false)
            showTargetMarker(targetPosition, "Fuuga / Flame Arrow")
            chatAbilityMessage("Fuuga: Flame Arrow!")
            task.delay(1.5, function()
                fuugaBusy = false
                if abilityTargets.Fuuga == targetPosition then abilityTargets.Fuuga = nil end
            end)
        else
            notify("Bilinmeyen yetenek: " .. tostring(name))
        end
        refreshButtons()
    end
    activateAbility = activateSukunaAbility

    local function createSkillControls()
        local player = game:GetService("Players").LocalPlayer
        local playerGui = player and (player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 5))
        if not playerGui then notify("Could not create the skill UI: PlayerGui is missing."); return end
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
        panel.Size = UDim2.fromOffset(70, 366)
        panel.BackgroundTransparency = 1
        panel.Parent = hud
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 5)
        layout.Parent = panel
        local userInputService = game:GetService("UserInputService")
        local mobile = userInputService.TouchEnabled
        -- Keep the mobile ability panel visible on touch devices; don't depend on
        -- an outer/global UserInputService variable injected by the loader.
        panel.Visible = mobile
        for index, name in ipairs(SKILL_ORDER) do
            local button = Instance.new("TextButton")
            button.Name = name .. "Key"
            button.LayoutOrder = index
            button.Size = UDim2.fromOffset(62, 48)
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
        notify("Sukuna skills ready: X Cleave, C Dismantle, Z Combo. Exactly 3 skills.")
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
            notify("Finger accessory not found. Equip the Sukuna Finger accessory on your character.")
            return
        end

        local function isFingerAccessory(item)
            if not item or not item:IsA("Accessory") then return false end
            local itemAssetId = tonumber(item:GetAttribute("AssetId"))
                or tonumber(item:GetAttribute("_RobuNexaSukunaAssetId"))
            if itemAssetId == FINGER_ID and isAllowedAssetId(itemAssetId) then return true end
            local itemName = string.lower(item.Name)
            return itemName == "sukuna's finger"
                or itemName == "sukuna finger"
        end

        local accessory
        -- Prefer the exact catalog asset ID from the applied HumanoidDescription.
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
                        if tonumber(entry.AssetId) == FINGER_ID then
                            accessory = tryAccessoryInstance(entry, character)
                            if accessory then break end
                        end
                    end
                end
            end
        end
        if not accessory then
            for _, item in ipairs(character:GetChildren()) do
                if isFingerAccessory(item) and item:FindFirstChild("Handle") then
                    accessory = item
                    break
                end
            end
        end
        if not accessory then
            notify("Equip the Sukuna Finger accessory. No fake Part was created.")
            return
        end

        local handle = accessory:FindFirstChild("Handle")
        if not handle or not handle:IsA("BasePart") then
            notify("The finger accessory has no Handle.")
            return
        end

        -- Intentionally silent: chat output is disabled to avoid polluting public chat.
        local function chatMessage(_message)
            return nil
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
            notify("Hat Reanimation was not found; the accessory cannot be anchored in the world.")
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
            prompt.ActionText = "Collect Finger"
            prompt.ObjectText = "Sukuna Finger"
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
        label.Text = "☯ SUKUNA FINGER"
        label.Parent = marker
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = label
        marker.Parent = player:WaitForChild("PlayerGui")

        local spawnPosition = findSmartPosition()
        if not spawnPosition then
            marker:Destroy()
            prompt.Enabled = false
            notify("Could not find a safe, visible spot for the finger. Move to a more open area.")
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
                    label.Text = ("☯ SUKUNA FINGER  •  %d m"):format(math.floor((base - spawnPosition).Magnitude + 0.5))
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
                    chatMessage("Could not find a safe location for the finger. Try again.")
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
                chatMessage("The finger has reappeared at another location on the map!")
                notify("The Sukuna Finger has appeared at a new location.")
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
            chatMessage(string.format("Sukuna Finger collected! (%d) • It will reappear somewhere else in 8 seconds.", fingersFound))
            announceFinger(string.format("[Sukuna] FINGER COLLECTED  •  %d", fingersFound))
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
        end))
        chatMessage("The Sukuna Finger has been placed nearby in an open, accessible spot. Follow the marker.")
    end

    m.Config = function(parent) end

    m.Init = function(figure)
        if awakeningSound then
            pcall(function() awakeningSound:Stop(); awakeningSound:Destroy() end)
            awakeningSound = nil
        end
        activeFigure = figure
        root = resolveRoot(figure)
        domainEnabled = false
        cleaveUntil = 0
        cleaveAccessoryStartedAt = 0
        cleaveAccessoryUntil = 0
        comboAccessoryStartedAt = 0
        comboAccessoryUntil = 0
        slashBurstUntil = 0
        slashBurstStartedAt = 0
        slashBurstCount = 0
        slashBurstTarget = nil
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

        -- One random awakening sound per start; never launch both choices.
        playRandomAwakeningSound()

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
            notify("Sukuna Laugh animation failed to load; check the model's KeyframeSequence/Animation.")
        end)
    end

    local function updateWalkAnimation()
        if not activeFigure or not activeFigure.Parent then
            if walkAnimationTrack then
                pcall(function() walkAnimationTrack:Stop(0.1); walkAnimationTrack:Destroy() end)
                walkAnimationTrack = nil
            end
            movementAnimationName = nil
            return
        end

        -- Action clips (Cleave/Combo/Laugh/etc.) have priority. Do not recreate
        -- idle/walk while one is applying Motor6D transforms.
        if actionAnimationTrack and actionAnimationTrack.IsPlaying then
            if walkAnimationTrack then
                pcall(function() walkAnimationTrack:Stop(0.05); walkAnimationTrack:Destroy() end)
                walkAnimationTrack = nil
            end
            movementAnimationName = nil
            return
        end

        -- The intro laugh has priority; clear the movement pose while it plays.
        if laughAnimationTrack and laughAnimationTrack.IsPlaying then
            if walkAnimationTrack then
                pcall(function() walkAnimationTrack:Stop(0.08); walkAnimationTrack:Destroy() end)
                walkAnimationTrack = nil
            end
            movementAnimationName = nil
            return
        end

        local humanoid = activeFigure:FindFirstChildOfClass("Humanoid")
        local state = humanoid and humanoid:GetState()
        local airborne = humanoid and humanoid.FloorMaterial == Enum.Material.Air
        local verticalSpeed = root and root.Parent and root.AssemblyLinearVelocity.Y or 0
        local horizontalSpeed = 0
        if root and root.Parent then
            local velocity = root.AssemblyLinearVelocity
            horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
        end

        local wanted
        if airborne then
            if state == Enum.HumanoidStateType.Freefall or verticalSpeed < -1.5 then
                wanted = "Fall"
            else
                wanted = "Jump"
            end
        elseif humanoid and (humanoid.Jump or state == Enum.HumanoidStateType.Jumping) then
            wanted = "Jump"
        elseif humanoid and (humanoid.MoveDirection.Magnitude > 0.05 or horizontalSpeed > 1.25) then
            -- No separate Sukuna Run.rbxm is present yet; use the valid Walk clip
            -- for sprinting instead of requesting a missing file and breaking movement.
            wanted = humanoid.WalkSpeed >= 20 and "Run" or "Walk"
        else
            wanted = "Idle"
        end

        local filename
        if wanted == "Run" or wanted == "Walk" then
            filename = "Sukuna/Walk.anim"
        elseif wanted == "Idle" then
            filename = "Sukuna/SukunaIdle.anim"
        else
            filename = "Sukuna/" .. wanted .. ".anim"
        end

        if wanted ~= movementAnimationName then
            if walkAnimationTrack then
                pcall(function() walkAnimationTrack:Stop(0.08); walkAnimationTrack:Destroy() end)
                walkAnimationTrack = nil
            end
            movementAnimationName = wanted
            walkAnimationTrack = playBundledAnimation(
                filename,
                string.lower(wanted),
                wanted ~= "Jump"
            )
        elseif not walkAnimationTrack or (wanted ~= "Jump" and not walkAnimationTrack.IsPlaying) then
            -- Retry if the asset was still downloading; recover looping tracks,
            -- but never restart a completed one-shot jump every frame.
            if walkAnimationTrack then pcall(function() walkAnimationTrack:Destroy() end) end
            walkAnimationTrack = playBundledAnimation(filename, string.lower(wanted), wanted ~= "Jump")
        end
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
        updateWalkAnimation()
        refreshButtons()
    end

    m.Destroy = function()
        if awakeningSound then
            pcall(function() awakeningSound:Stop(); awakeningSound:Destroy() end)
            awakeningSound = nil
        end
        domainEnabled = false
        cleaveUntil = 0
        cleaveAccessoryUntil = 0
        comboAccessoryUntil = 0
        fuugaBusy = false
        abilityTargets = {}
        if fuugaAnimationTrack then pcall(function() fuugaAnimationTrack:Stop(0.1); fuugaAnimationTrack:Destroy() end); fuugaAnimationTrack = nil end
        if laughAnimationTrack then pcall(function() laughAnimationTrack:Stop(0.1); laughAnimationTrack:Destroy() end); laughAnimationTrack = nil end
        if actionAnimationTrack then pcall(function() actionAnimationTrack:Stop(0.05); actionAnimationTrack:Destroy() end); actionAnimationTrack = nil end
        if walkAnimationTrack then pcall(function() walkAnimationTrack:Stop(0.1); walkAnimationTrack:Destroy() end); walkAnimationTrack = nil end
        movementAnimationName = nil
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

        -- Remove only the temporary copies this moveset loaded. Normal avatar hats
        -- are never deleted, and the next Sukuna init can load the effects again.
        local localCharacter = getLocalCharacter()
        if localCharacter then
            for _, child in ipairs(localCharacter:GetChildren()) do
                if child:IsA("Accessory") and child:GetAttribute("_RobuNexaSukunaSpawned") then
                    pcall(function() child:Destroy() end)
                end
            end
        end
        accessoryLoadRetryAt = {}
        accessoryLoadInFlight = {}

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
        activeFigure, root = nil, nil
        accessoryInstances, presentIds, overrideById = {}, {}, {}
        lastHatCFrames = {}
        abilityTargets = {}
        savedWantAllHats = nil
        lastAccessorySignature = nil
    end

    return m
end)

return modules
