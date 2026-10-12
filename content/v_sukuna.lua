-- RobuNexa / NAM - Sukuna Domain + Cleave visual module.
-- Local visual effects only: no animation tracks, damage, hitboxes, or Shrine model.
-- The Shrine itself intentionally stays invisible; red slashes run while Domain is active.
local modules = {}
local function AddModule(fn) table.insert(modules, fn()) end

AddModule(function()
    local m = {}
    m.ModuleType = "MOVESET"
    m.Name = "Sukuna"
    m.Description = "Malevolent Shrine (invisible) and continuous Cleave slash visuals."
    m.Assets = {}

    local REQUIRED_IDS = {
        [97087028126781] = true,
        [100475161263482] = true,
        [124144353587446] = true,
        [18726352770] = true,
    }

    local activeFigure, root, playerGui
    local hud, domainButton, cleaveButton
    local connections = {}
    local domainEnabled = false
    local cleaveUntil = 0
    local slashAccumulator = 0
    local slashFolder
    local lastAccessorySignature
    local ACCESSORY_CHECK_INTERVAL = 1.5
    local accessoryCheckAccumulator = 0
    local accessoriesReady = false

    local function notify(message)
        pcall(function() Util.Notify("Sukuna: " .. message) end)
    end

    local function resolveRoot(character)
        if not character then return nil end
        local part = character:FindFirstChild("HumanoidRootPart")
            or character.PrimaryPart
            or character:FindFirstChild("Torso")
            or character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Head")
        return part and part:IsA("BasePart") and part or nil
    end

    local function equippedIds(character)
        local found = {}
        if not character or not character:IsA("Model") then return found end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local ok, description = pcall(function() return humanoid:GetAppliedDescription() end)
            if ok and description then
                local okAccessories, list = pcall(function() return description:GetAccessories(true) end)
                if okAccessories and type(list) == "table" then
                    for _, info in ipairs(list) do
                        local id = tonumber(info.AssetId)
                        if id then found[id] = true end
                    end
                end
                for _, propertyName in ipairs({
                    "HatAccessory", "HairAccessory", "FaceAccessory", "NeckAccessory",
                    "ShouldersAccessory", "FrontAccessory", "BackAccessory", "WaistAccessory",
                }) do
                    local okValue, value = pcall(function() return description[propertyName] end)
                    if okValue and type(value) == "string" then
                        for token in string.gmatch(value, "%d+") do
                            local id = tonumber(token)
                            if id then found[id] = true end
                        end
                    end
                end
            end
        end
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Accessory") then
                local id = tonumber(child:GetAttribute("AssetId"))
                if id then found[id] = true end
            end
        end
        return found
    end

    local function updateAccessoryStatus()
        local found = equippedIds(activeFigure)
        local matched = {}
        for id in pairs(REQUIRED_IDS) do
            if found[id] then table.insert(matched, tostring(id)) end
        end
        table.sort(matched)
        local signature = table.concat(matched, ",")
        accessoriesReady = #matched > 0
        if signature ~= lastAccessorySignature then
            lastAccessorySignature = signature
            if #matched > 0 then
                notify(string.format("Aksesuar algılandı: %d/4 (%s)", #matched, signature))
            else
                notify("Verdiğin 4 aksesuardan hiçbiri algılanmadı.")
            end
        end
        return accessoriesReady
    end

    local function refreshButtons()
        if domainButton then
            domainButton.Text = domainEnabled and "DOMAIN ON" or "DOMAIN"
            domainButton.BackgroundColor3 = domainEnabled and Color3.fromRGB(126, 24, 31) or Color3.fromRGB(35, 27, 31)
        end
        if cleaveButton then
            cleaveButton.BackgroundColor3 = os.clock() < cleaveUntil
                and Color3.fromRGB(150, 35, 40) or Color3.fromRGB(35, 27, 31)
        end
    end

    local function createHUD()
        local player = game:GetService("Players").LocalPlayer
        playerGui = player and player:FindFirstChildOfClass("PlayerGui")
        if not playerGui then
            task.spawn(function()
                for _ = 1, 24 do
                    task.wait(0.25)
                    playerGui = player and player:FindFirstChildOfClass("PlayerGui")
                    if playerGui then createHUD(); return end
                end
            end)
            return
        end
        local old = playerGui:FindFirstChild("SukunaAbilityHUD")
        if old then old:Destroy() end
        table.clear(connections)
        hud = Instance.new("ScreenGui")
        hud.Name = "SukunaAbilityHUD"
        hud.ResetOnSpawn = false
        hud.IgnoreGuiInset = true
        hud.DisplayOrder = 50
        hud.Parent = playerGui

        local panel = Instance.new("Frame")
        panel.Name = "AbilityButtons"
        panel.AnchorPoint = Vector2.new(1, 1)
        panel.Position = UDim2.new(1, -10, 1, -112)
        panel.Size = UDim2.fromOffset(152, 40)
        panel.BackgroundTransparency = 1
        panel.Parent = hud

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 6)
        layout.Parent = panel

        local function makeButton(name, text, order)
            local button = Instance.new("TextButton")
            button.Name = name
            button.LayoutOrder = order
            button.Size = UDim2.fromOffset(72, 36)
            button.BackgroundColor3 = Color3.fromRGB(35, 27, 31)
            button.BackgroundTransparency = 0.08
            button.BorderSizePixel = 0
            button.Text = text
            button.TextColor3 = Color3.fromRGB(255, 242, 242)
            button.TextSize = 10
            button.Font = Enum.Font.GothamBold
            button.TextWrapped = true
            button.AutoButtonColor = true
            button.Parent = panel
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = button
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(210, 74, 80)
            stroke.Thickness = 1
            stroke.Transparency = 0.2
            stroke.Parent = button
            return button
        end

        domainButton = makeButton("DomainButton", "DOMAIN", 1)
        cleaveButton = makeButton("CleaveButton", "CLEAVE", 2)
        table.insert(connections, domainButton.Activated:Connect(function()
            if not activeFigure or not activeFigure.Parent then return end
            if not updateAccessoryStatus() then
                notify("Domain için verdiğin 4 aksesuardan en az biri takılı olmalı.")
                return
            end
            domainEnabled = not domainEnabled
            if domainEnabled then
                notify("Malevolent Shrine açıldı. Shrine görünmez; slash efektleri sürekli çalışır.")
            else
                notify("Domain kapatıldı.")
            end
            refreshButtons()
        end))
        table.insert(connections, cleaveButton.Activated:Connect(function()
            if not activeFigure or not activeFigure.Parent then return end
            if not updateAccessoryStatus() then
                notify("Cleave için verdiğin 4 aksesuardan en az biri takılı olmalı.")
                return
            end
            cleaveUntil = os.clock() + 2.5
            slashAccumulator = 0
            refreshButtons()
        end))
        refreshButtons()
    end

    local function clearSlashFolder()
        if slashFolder then slashFolder:Destroy(); slashFolder = nil end
    end

    local function spawnSlash()
        if not root or not root.Parent then return end
        if not slashFolder or not slashFolder.Parent then
            slashFolder = Instance.new("Folder")
            slashFolder.Name = "SukunaLocalSlashEffects"
            slashFolder.Parent = workspace
        end

        -- Red-black curved-looking slash streak, placed around the player rather
        -- than at the accessory geometry's distant location.
        local angle = math.random() * math.pi * 2
        local radius = math.random(5, 13)
        local height = math.random(0, 7) - 2
        local center = root.Position + Vector3.new(math.cos(angle) * radius, height, math.sin(angle) * radius)
        local tangent = Vector3.new(-math.sin(angle), math.random(-20, 20) / 100, math.cos(angle))
        if tangent.Magnitude < 0.1 then tangent = Vector3.xAxis end
        local length = math.random(5, 10)
        local part = Instance.new("Part")
        part.Name = "CleaveSlash"
        part.Anchored = true
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.CastShadow = false
        part.Material = Enum.Material.Neon
        part.Color = math.random(1, 3) == 1 and Color3.fromRGB(255, 45, 50) or Color3.fromRGB(135, 8, 20)
        part.Transparency = 0.05
        part.Size = Vector3.new(length, 0.07, 0.12)
        part.CFrame = CFrame.lookAt(center, center + tangent) * CFrame.Angles(0, 0, math.rad(math.random(-35, 35)))
        part.Parent = slashFolder

        local tweenService = game:GetService("TweenService")
        local tween = tweenService:Create(part, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(length * 1.35, 0.015, 0.035),
            Transparency = 1,
            CFrame = part.CFrame * CFrame.new(0, 0.45, 0),
        })
        tween:Play()
        game:GetService("Debris"):AddItem(part, 0.3)
    end

    m.Config = function(parent) end

    m.Init = function(figure)
        activeFigure = figure
        root = resolveRoot(figure)
        domainEnabled = false
        cleaveUntil = 0
        slashAccumulator = 0
        accessoryCheckAccumulator = 0
        lastAccessorySignature = nil
        clearSlashFolder()
        updateAccessoryStatus()
        createHUD()
    end

    m.Update = function(dt, figure)
        activeFigure = figure or activeFigure
        root = resolveRoot(activeFigure)
        if not root then return end

        accessoryCheckAccumulator += math.max(0, dt or 0)
        if accessoryCheckAccumulator >= ACCESSORY_CHECK_INTERVAL then
            accessoryCheckAccumulator = 0
            updateAccessoryStatus()
        end

        local cleaveActive = os.clock() < cleaveUntil
        if not domainEnabled and not cleaveActive then return end

        -- Domain produces persistent slash visuals. Cleave uses the same effect
        -- burst at a higher rate for a short duration.
        slashAccumulator += math.max(0, dt or 0)
        local interval = cleaveActive and 0.055 or 0.13
        local spawned = 0
        while slashAccumulator >= interval and spawned < 4 do
            slashAccumulator -= interval
            spawnSlash()
            spawned += 1
        end
        if not cleaveActive and not domainEnabled then slashAccumulator = 0 end
        refreshButtons()
    end

    m.Destroy = function()
        domainEnabled = false
        cleaveUntil = 0
        clearSlashFolder()
        for _, connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
        table.clear(connections)
        if hud then hud:Destroy(); hud = nil end
        local player = game:GetService("Players").LocalPlayer
        local gui = player and player:FindFirstChildOfClass("PlayerGui")
        local old = gui and gui:FindFirstChild("SukunaAbilityHUD")
        if old then old:Destroy() end
        domainButton, cleaveButton = nil, nil
        activeFigure, root, playerGui = nil, nil, nil
        lastAccessorySignature = nil
    end

    return m
end)

return modules
