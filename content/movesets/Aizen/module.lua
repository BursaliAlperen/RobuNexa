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
        local ability
        for _, item in ipairs(abilities) do
            if item.key == key then ability = item; break end
        end
        if not ability then return end
        local remaining = math.max(0, (cooldowns[key] or 0) - os.clock())
        local fill = button:FindFirstChild("CooldownFill")
        local label = button:FindFirstChild("AbilityLabel")
        if remaining > 0 then
            local ratio = math.clamp(remaining / ability.cooldown, 0, 1)
            if label then label.Text = string.format("%s  %.1fs", ability.label, remaining) end
            button.BackgroundColor3 = Color3.fromRGB(43, 37, 57)
            if fill then fill.Size = UDim2.new(ratio, 0, 1, 0); fill.Visible = true end
        else
            if label then label.Text = ability.label end
            button.BackgroundColor3 = Color3.fromRGB(31, 27, 43)
            if fill then fill.Size = UDim2.new(0, 0, 1, 0); fill.Visible = false end
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
        if not playerGui then
            playerGui = player and player:WaitForChild("PlayerGui", 5)
        end
        if not playerGui then
            notify("Arayüz oluşturulamadı: PlayerGui bulunamadı.")
            return
        end
        local previous = playerGui:FindFirstChild("AizenAbilityHUD")
        if previous then previous:Destroy() end

        gui = Instance.new("ScreenGui")
        gui.Name = "AizenAbilityHUD"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 51
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = playerGui

        local panel = Instance.new("Frame")
        panel.Name = "AizenPanel"
        panel.AnchorPoint = Vector2.new(1, 1)
        panel.Position = UDim2.new(1, -18, 1, -112)
        panel.Size = UDim2.fromOffset(274, 218)
        panel.BackgroundColor3 = Color3.fromRGB(17, 15, 25)
        panel.BackgroundTransparency = 0.08
        panel.BorderSizePixel = 0
        panel.ClipsDescendants = true
        panel.Parent = gui

        local panelCorner = Instance.new("UICorner")
        panelCorner.CornerRadius = UDim.new(0, 13)
        panelCorner.Parent = panel
        local panelStroke = Instance.new("UIStroke")
        panelStroke.Color = Color3.fromRGB(145, 112, 205)
        panelStroke.Transparency = 0.18
        panelStroke.Thickness = 1.25
        panelStroke.Parent = panel
        local panelGradient = Instance.new("UIGradient")
        panelGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(31, 25, 47)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(13, 13, 20)),
        })
        panelGradient.Rotation = 90
        panelGradient.Parent = panel

        local header = Instance.new("Frame")
        header.Name = "Header"
        header.BackgroundTransparency = 1
        header.Position = UDim2.fromOffset(12, 8)
        header.Size = UDim2.new(1, -24, 0, 35)
        header.Parent = panel

        local emblem = Instance.new("Frame")
        emblem.Size = UDim2.fromOffset(30, 30)
        emblem.Position = UDim2.fromOffset(0, 1)
        emblem.BackgroundColor3 = Color3.fromRGB(113, 78, 165)
        emblem.BorderSizePixel = 0
        emblem.Parent = header
        local emblemCorner = Instance.new("UICorner")
        emblemCorner.CornerRadius = UDim.new(1, 0)
        emblemCorner.Parent = emblem
        local emblemText = Instance.new("TextLabel")
        emblemText.BackgroundTransparency = 1
        emblemText.Size = UDim2.fromScale(1, 1)
        emblemText.Font = Enum.Font.GothamBlack
        emblemText.Text = "藍"
        emblemText.TextColor3 = Color3.fromRGB(255, 247, 255)
        emblemText.TextSize = 17
        emblemText.Parent = emblem

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Position = UDim2.fromOffset(39, 0)
        title.Size = UDim2.new(1, -80, 0, 19)
        title.Font = Enum.Font.GothamBold
        title.Text = "AIZEN SOSUKE"
        title.TextColor3 = Color3.fromRGB(249, 243, 255)
        title.TextSize = 13
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = header

        local subtitle = Instance.new("TextLabel")
        subtitle.BackgroundTransparency = 1
        subtitle.Position = UDim2.fromOffset(39, 18)
        subtitle.Size = UDim2.new(1, -80, 0, 13)
        subtitle.Font = Enum.Font.Gotham
        subtitle.Text = "HOGYOKU  •  ABILITY CONTROL"
        subtitle.TextColor3 = Color3.fromRGB(166, 151, 190)
        subtitle.TextSize = 8
        subtitle.TextXAlignment = Enum.TextXAlignment.Left
        subtitle.Parent = header

        local minimize = Instance.new("TextButton")
        minimize.Name = "Minimize"
        minimize.AnchorPoint = Vector2.new(1, 0)
        minimize.Position = UDim2.new(1, 0, 0, 1)
        minimize.Size = UDim2.fromOffset(27, 27)
        minimize.BackgroundColor3 = Color3.fromRGB(52, 43, 69)
        minimize.BorderSizePixel = 0
        minimize.Text = "−"
        minimize.TextColor3 = Color3.fromRGB(245, 235, 255)
        minimize.TextSize = 20
        minimize.Font = Enum.Font.GothamMedium
        minimize.Parent = header
        local minCorner = Instance.new("UICorner")
        minCorner.CornerRadius = UDim.new(0, 7)
        minCorner.Parent = minimize

        local divider = Instance.new("Frame")
        divider.Position = UDim2.fromOffset(12, 49)
        divider.Size = UDim2.new(1, -24, 0, 1)
        divider.BackgroundColor3 = Color3.fromRGB(104, 82, 133)
        divider.BackgroundTransparency = 0.45
        divider.BorderSizePixel = 0
        divider.Parent = panel

        local section = Instance.new("TextLabel")
        section.BackgroundTransparency = 1
        section.Position = UDim2.fromOffset(13, 56)
        section.Size = UDim2.new(1, -26, 0, 14)
        section.Font = Enum.Font.GothamBold
        section.Text = "KIDŌ & SPECIAL TECHNIQUES"
        section.TextColor3 = Color3.fromRGB(185, 166, 215)
        section.TextSize = 9
        section.TextXAlignment = Enum.TextXAlignment.Left
        section.Parent = panel

        local gridHolder = Instance.new("Frame")
        gridHolder.Name = "AbilityGrid"
        gridHolder.BackgroundTransparency = 1
        gridHolder.Position = UDim2.fromOffset(12, 77)
        gridHolder.Size = UDim2.new(1, -24, 0, 120)
        gridHolder.Parent = panel

        local grid = Instance.new("UIGridLayout")
        grid.CellSize = UDim2.new(1/3, -4, 0, 53)
        grid.CellPadding = UDim2.fromOffset(5, 5)
        grid.FillDirectionMaxCells = 3
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        grid.Parent = gridHolder

        for index, ability in ipairs(abilities) do
            local button = Instance.new("TextButton")
            button.Name = ability.key .. "Button"
            button.LayoutOrder = index
            button.BackgroundColor3 = Color3.fromRGB(31, 27, 43)
            button.BackgroundTransparency = 0.02
            button.BorderSizePixel = 0
            button.Text = ""
            button.AutoButtonColor = false
            button.ClipsDescendants = true
            button.Parent = gridHolder

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = button
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(119, 91, 158)
            stroke.Transparency = 0.48
            stroke.Thickness = 1
            stroke.Parent = button

            local fill = Instance.new("Frame")
            fill.Name = "CooldownFill"
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(105, 76, 145)
            fill.BackgroundTransparency = 0.48
            fill.BorderSizePixel = 0
            fill.Visible = false
            fill.ZIndex = 1
            fill.Parent = button

            local label = Instance.new("TextLabel")
            label.Name = "AbilityLabel"
            label.BackgroundTransparency = 1
            label.Position = UDim2.fromOffset(3, 1)
            label.Size = UDim2.new(1, -6, 1, -2)
            label.Font = Enum.Font.GothamBold
            label.Text = ability.label
            label.TextColor3 = Color3.fromRGB(245, 239, 255)
            label.TextSize = 9
            label.TextWrapped = true
            label.ZIndex = 2
            label.Parent = button

            buttons[ability.key] = button
            table.insert(connections, button.Activated:Connect(function()
                activate(ability.key)
            end))
            table.insert(connections, button.MouseEnter:Connect(function()
                TweenService:Create(stroke, TweenInfo.new(0.12), {
                    Transparency = 0.08, Color = Color3.fromRGB(195, 157, 245),
                }):Play()
            end))
            table.insert(connections, button.MouseLeave:Connect(function()
                TweenService:Create(stroke, TweenInfo.new(0.12), {
                    Transparency = 0.48, Color = Color3.fromRGB(119, 91, 158),
                }):Play()
            end))
            refreshButton(ability.key)
        end

        local footer = Instance.new("TextLabel")
        footer.Name = "Footer"
        footer.BackgroundTransparency = 1
        footer.Position = UDim2.new(0, 13, 1, -17)
        footer.Size = UDim2.new(1, -26, 0, 12)
        footer.Font = Enum.Font.Gotham
        footer.Text = "SELECT A TECHNIQUE  •  COOLDOWNS SHOWN LIVE"
        footer.TextColor3 = Color3.fromRGB(135, 123, 153)
        footer.TextSize = 7
        footer.TextXAlignment = Enum.TextXAlignment.Left
        footer.Parent = panel

        local expandedSize = panel.Size
        local collapsed = false
        table.insert(connections, minimize.Activated:Connect(function()
            collapsed = not collapsed
            minimize.Text = collapsed and "+" or "−"
            section.Visible = not collapsed
            gridHolder.Visible = not collapsed
            footer.Visible = not collapsed
            TweenService:Create(panel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = collapsed and UDim2.fromOffset(274, 51) or expandedSize,
            }):Play()
        end))

        -- Keep the compact panel usable on narrow phone screens.
        local camera = workspace.CurrentCamera
        if camera then
            local viewport = camera.ViewportSize
            if viewport.X < 520 then
                panel.Position = UDim2.new(1, -8, 1, -90)
                panel.Size = UDim2.fromOffset(244, 210)
                gridHolder.Size = UDim2.new(1, -24, 0, 116)
                grid.CellSize = UDim2.new(1/3, -4, 0, 51)
                expandedSize = panel.Size
            end
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
