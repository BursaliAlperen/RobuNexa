-- Aizen NAM moveset for RobuNexa.
-- Client-side visual/mobility abilities only; this module does not claim to damage
-- or control other players. Add animation/audio assets when verified files are available.
local modules = {}

table.insert(modules, function()
    local m = {}
    m.ModuleType = "MOVESET"
    m.Name = "Aizen"
    m.Description = "Aizen: Kyoka Suigetsu, Shunpo, Cero, Kurohitsugi, Hadō 90, Afterimage and Hogyoku."

    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local Debris = game:GetService("Debris")
    local Lighting = game:GetService("Lighting")

    local player = Players.LocalPlayer
    local figure
    local root
    local humanoid
    local gui
    local highlight
    local screenEffect
    local connections = {}
    local spawned = {}
    local cooldowns = {}
    local buttons = {}
    local destroyed = false

    local abilities = {
        { key = "Kyoka", label = "KYOKA", cooldown = 18 },
        { key = "Shunpo", label = "SHUNPO", cooldown = 6 },
        { key = "Cero", label = "CERO", cooldown = 9 },
        { key = "Kurohitsugi", label = "BLACK BOX", cooldown = 22 },
        { key = "Hado90", label = "HADŌ 90", cooldown = 28 },
        { key = "Afterimage", label = "AFTERIMAGE", cooldown = 16 },
        { key = "Hogyoku", label = "HŌGYOKU", cooldown = 30 },
    }

    local function notify(message)
        pcall(function()
            if Util and Util.Notify then Util.Notify("Aizen: " .. message) end
        end)
    end

    local function track(instance)
        table.insert(spawned, instance)
        return instance
    end

    local function getRoot(model)
        if not model then return nil end
        local candidate = model:FindFirstChild("HumanoidRootPart")
            or model.PrimaryPart
            or model:FindFirstChild("Torso")
            or model:FindFirstChild("UpperTorso")
        if candidate and candidate:IsA("BasePart") then return candidate end
        return nil
    end

    local function makePart(name, size, cframe, color, transparency, shape)
        local part = Instance.new("Part")
        part.Name = name
        part.Size = size
        part.CFrame = cframe
        part.Color = color
        part.Material = Enum.Material.Neon
        part.Transparency = transparency or 0.2
        part.Shape = shape or Enum.PartType.Block
        part.Anchored = true
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.CastShadow = false
        part.Parent = workspace
        return track(part)
    end

    local function flash(color, duration)
        if screenEffect then screenEffect:Destroy(); screenEffect = nil end
        local effect = Instance.new("ColorCorrectionEffect")
        effect.Name = "RobuNexaAizenScreen"
        effect.TintColor = color
        effect.Saturation = -0.25
        effect.Contrast = 0.12
        effect.Parent = Lighting
        screenEffect = track(effect)
        TweenService:Create(effect, TweenInfo.new(duration or 1.2), {
            TintColor = Color3.new(1, 1, 1),
            Saturation = 0,
            Contrast = 0,
        }):Play()
        Debris:AddItem(effect, (duration or 1.2) + 0.2)
        task.delay((duration or 1.2) + 0.25, function()
            if screenEffect == effect then screenEffect = nil end
        end)
    end

    local function kyokaSuigetsu()
        flash(Color3.fromRGB(190, 175, 255), 2.4)
        if root then
            local ring = makePart("AizenKyokaRing", Vector3.new(0.2, 9, 9),
                root.CFrame * CFrame.Angles(0, 0, math.rad(90)),
                Color3.fromRGB(205, 190, 255), 0.25, Enum.PartType.Cylinder)
            TweenService:Create(ring, TweenInfo.new(1.1), {
                Size = Vector3.new(0.2, 22, 22), Transparency = 1,
            }):Play()
            Debris:AddItem(ring, 1.2)
        end
        notify("Kyoka Suigetsu görsel efekti etkin.")
    end

    local function shunpo()
        if not root or not root.Parent then return end
        local direction = humanoid and humanoid.MoveDirection or root.CFrame.LookVector
        if direction.Magnitude < 0.05 then direction = root.CFrame.LookVector end
        root.AssemblyLinearVelocity = direction.Unit * 78 + Vector3.new(0, 8, 0)
        local streak = makePart("AizenShunpoTrail", Vector3.new(2.5, 3.5, 5),
            root.CFrame * CFrame.new(0, 0, 2), Color3.fromRGB(190, 190, 220), 0.45)
        TweenService:Create(streak, TweenInfo.new(0.35), {
            Transparency = 1, Size = Vector3.new(0.2, 0.2, 8),
        }):Play()
        Debris:AddItem(streak, 0.4)
    end

    local function cero()
        if not root then return end
        local origin = root.Position + Vector3.new(0, 1.5, 0) + root.CFrame.LookVector * 3
        local orb = makePart("AizenCeroVisual", Vector3.new(2.2, 2.2, 2.2),
            CFrame.new(origin), Color3.fromRGB(175, 30, 45), 0.08, Enum.PartType.Ball)
        local destination = origin + root.CFrame.LookVector * 65
        TweenService:Create(orb, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = destination, Size = Vector3.new(7, 7, 7), Transparency = 1,
        }):Play()
        Debris:AddItem(orb, 0.65)
    end

    local function kurohitsugi()
        if not root then return end
        local center = root.Position + root.CFrame.LookVector * 9
        local pieces = {}
        for i = 1, 4 do
            local angle = (i - 1) * math.pi / 2
            local offset = Vector3.new(math.cos(angle) * 4, 4, math.sin(angle) * 4)
            local wall = makePart("AizenBlackCoffin", Vector3.new(0.35, 8, 8),
                CFrame.new(center + offset) * CFrame.Angles(0, -angle, 0),
                Color3.fromRGB(35, 20, 55), 0.18)
            table.insert(pieces, wall)
            TweenService:Create(wall, TweenInfo.new(0.7), { Transparency = 0.85 }):Play()
            Debris:AddItem(wall, 0.9)
        end
        flash(Color3.fromRGB(90, 55, 125), 1.1)
    end

    local function hado90()
        if not root then return end
        local center = root.Position + root.CFrame.LookVector * 8
        for i = 1, 5 do
            local height = i * 2.5
            local pillar = makePart("AizenHado90", Vector3.new(1.2, height, 1.2),
                CFrame.new(center + Vector3.new(0, height / 2, 0)),
                Color3.fromRGB(100, 65, 155), 0.22)
            TweenService:Create(pillar, TweenInfo.new(0.65), {
                Size = Vector3.new(0.15, height * 1.4, 0.15), Transparency = 1,
            }):Play()
            Debris:AddItem(pillar, 0.75)
        end
    end

    local function afterimage()
        if not figure or not figure.Parent then return end
        local oldArchivable = figure.Archivable
        figure.Archivable = true
        local ok, clone = pcall(function() return figure:Clone() end)
        figure.Archivable = oldArchivable
        if not ok or not clone then
            notify("Afterimage klonu oluşturulamadı.")
            return
        end
        clone.Name = "AizenAfterimage"
        for _, item in ipairs(clone:GetDescendants()) do
            if item:IsA("Script") or item:IsA("LocalScript") then
                item:Destroy()
            elseif item:IsA("BasePart") then
                item.Anchored = true
                item.CanCollide = false
                item.CanTouch = false
                item.CanQuery = false
                item.Material = Enum.Material.Neon
                item.Color = Color3.fromRGB(185, 175, 220)
                item.Transparency = math.max(item.Transparency, 0.45)
            elseif item:IsA("Decal") then
                item.Transparency = math.max(item.Transparency, 0.5)
            end
        end
        clone.Parent = workspace
        local cloneRoot = getRoot(clone)
        if cloneRoot and root then clone:PivotTo(root.CFrame * CFrame.new(0, 0, 3)) end
        track(clone)
        for _, item in ipairs(clone:GetDescendants()) do
            if item:IsA("BasePart") then
                TweenService:Create(item, TweenInfo.new(1.1), { Transparency = 1 }):Play()
            end
        end
        Debris:AddItem(clone, 1.2)
    end

    local function hogyoku()
        if not figure then return end
        if highlight then highlight:Destroy(); highlight = nil end
        local glow = Instance.new("Highlight")
        glow.Name = "AizenHogyokuAura"
        glow.FillColor = Color3.fromRGB(170, 125, 255)
        glow.OutlineColor = Color3.fromRGB(245, 225, 255)
        glow.FillTransparency = 0.45
        glow.OutlineTransparency = 0.05
        glow.DepthMode = Enum.HighlightDepthMode.Occluded
        glow.Parent = figure
        highlight = track(glow)
        flash(Color3.fromRGB(225, 205, 255), 1.6)
        task.delay(5, function()
            if highlight == glow then highlight = nil end
            if glow.Parent then glow:Destroy() end
        end)
    end

    local handlers = {
        Kyoka = kyokaSuigetsu,
        Shunpo = shunpo,
        Cero = cero,
        Kurohitsugi = kurohitsugi,
        Hado90 = hado90,
        Afterimage = afterimage,
        Hogyoku = hogyoku,
    }

    local function refreshButton(key)
        local button = buttons[key]
        if not button then return end
        local remaining = (cooldowns[key] or 0) - os.clock()
        if remaining > 0 then
            button.Text = string.format("%s  %.1f", key == "Kurohitsugi" and "BLACK BOX" or key:upper(), remaining)
            button.BackgroundColor3 = Color3.fromRGB(65, 55, 75)
        else
            for _, ability in ipairs(abilities) do
                if ability.key == key then button.Text = ability.label; break end
            end
            button.BackgroundColor3 = Color3.fromRGB(28, 25, 38)
        end
    end

    local function activate(key)
        if destroyed or not handlers[key] then return end
        if not root or not root.Parent then
            notify("Reanimate karakteri hazır değil.")
            return
        end
        local remaining = (cooldowns[key] or 0) - os.clock()
        if remaining > 0 then
            notify(key .. " bekleme süresi: " .. string.format("%.1f", remaining) .. " sn")
            return
        end
        local cooldown = 8
        for _, ability in ipairs(abilities) do
            if ability.key == key then cooldown = ability.cooldown; break end
        end
        local ok, err = pcall(handlers[key])
        if not ok then
            warn("[Aizen] " .. key .. " failed: " .. tostring(err))
            notify(key .. " kullanılamadı.")
            return
        end
        cooldowns[key] = os.clock() + cooldown
        refreshButton(key)
        task.spawn(function()
            while buttons[key] and os.clock() < cooldowns[key] do
                refreshButton(key)
                task.wait(0.1)
            end
            refreshButton(key)
        end)
    end

    local function createHud()
        local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
        if not playerGui then return end
        local previous = playerGui:FindFirstChild("AizenAbilityHUD")
        if previous then previous:Destroy() end
        gui = Instance.new("ScreenGui")
        gui.Name = "AizenAbilityHUD"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 51
        gui.Parent = playerGui

        local panel = Instance.new("Frame")
        panel.Name = "Abilities"
        panel.AnchorPoint = Vector2.new(1, 1)
        panel.Position = UDim2.new(1, -12, 1, -108)
        panel.Size = UDim2.fromOffset(228, 94)
        panel.BackgroundTransparency = 1
        panel.Parent = gui

        local grid = Instance.new("UIGridLayout")
        grid.CellSize = UDim2.fromOffset(72, 42)
        grid.CellPadding = UDim2.fromOffset(4, 4)
        grid.FillDirectionMaxCells = 3
        grid.HorizontalAlignment = Enum.HorizontalAlignment.Right
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        grid.Parent = panel

        for index, ability in ipairs(abilities) do
            local button = Instance.new("TextButton")
            button.Name = ability.key .. "Button"
            button.LayoutOrder = index
            button.BackgroundColor3 = Color3.fromRGB(28, 25, 38)
            button.BackgroundTransparency = 0.12
            button.BorderSizePixel = 0
            button.Text = ability.label
            button.TextColor3 = Color3.fromRGB(245, 240, 255)
            button.TextSize = 10
            button.Font = Enum.Font.GothamBold
            button.TextWrapped = true
            button.Parent = panel
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = button
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(155, 125, 205)
            stroke.Transparency = 0.3
            stroke.Thickness = 1
            stroke.Parent = button
            buttons[ability.key] = button
            table.insert(connections, button.Activated:Connect(function()
                activate(ability.key)
            end))
        end
    end

    m.Config = function(_parent)
        -- The ability HUD is created by Init only while Aizen is equipped.
    end

    m.Init = function(newFigure)
        destroyed = false
        figure = newFigure
        humanoid = figure and figure:FindFirstChildOfClass("Humanoid")
        root = getRoot(figure)
        cooldowns = {}
        createHud()
        notify("7 yetenek hazır.")
    end

    m.Update = function(_dt, newFigure)
        if newFigure and newFigure ~= figure then
            figure = newFigure
            humanoid = figure:FindFirstChildOfClass("Humanoid")
            root = getRoot(figure)
        elseif figure then
            root = getRoot(figure)
        end
    end

    m.Destroy = function()
        destroyed = true
        for _, connection in ipairs(connections) do
            pcall(function() connection:Disconnect() end)
        end
        table.clear(connections)
        for _, instance in ipairs(spawned) do
            if instance and instance.Parent then pcall(function() instance:Destroy() end) end
        end
        table.clear(spawned)
        if gui then gui:Destroy(); gui = nil end
        if highlight then highlight:Destroy(); highlight = nil end
        if screenEffect then screenEffect:Destroy(); screenEffect = nil end
        table.clear(buttons)
        figure, root, humanoid = nil, nil, nil
    end

    return m
end)

return modules
