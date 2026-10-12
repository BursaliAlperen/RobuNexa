-- Sukuna visual moveset for RobuNexa / NAM.
-- No .anim files or reanimation changes are used here.
-- Shrine and slash effects are client-side visuals only; no damage/remotes are fired.
local modules = {}

local function AddModule(fn)
    table.insert(modules, fn())
end

AddModule(function()
    local m = {}
    m.ModuleType = "MOVESET"
    m.Name = "Sukuna"
    m.Description = "Malevolent Shrine with a large rear shrine and rapid, wide-area visual slashes."
    m.Assets = {}

    local Players = game:GetService("Players")
    local Debris = game:GetService("Debris")
    local RunService = game:GetService("RunService")
    local REQUIRED_IDS = {
        [97087028126781] = "Sukuna accessory 1",
        [100475161263482] = "Sukuna Cleave and Dismantle Aura",
        [124144353587446] = "Sukuna accessory 3",
        [18726352770] = "Sukuna Malevolent Shrine",
    }

    local figure, root, humanoid
    local gui, button
    local connections = {}
    local domainFolder
    local domainUntil = 0
    local domainGeneration = 0
    local accessoryStatus = "Accessories not checked"

    local function notify(message)
        pcall(function() Util.Notify("Sukuna: " .. message) end)
    end

    local function resolveRoot(model)
        if not model then return nil end
        for _, name in ipairs({"HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "Head"}) do
            local part = model:FindFirstChild(name)
            if part and part:IsA("BasePart") then return part end
        end
        return model:FindFirstChildWhichIsA("BasePart", true)
    end

    local function checkAccessories(model)
        local h = model and model:FindFirstChildOfClass("Humanoid")
        if not h then return 0, 4 end
        local ok, description = pcall(function() return h:GetAppliedDescription() end)
        if not ok or not description then return 0, 4 end
        local found = {}
        local okList, list = pcall(function() return description:GetAccessories(true) end)
        if okList and type(list) == "table" then
            for _, item in ipairs(list) do
                local id = tonumber(item.AssetId)
                if id then found[id] = true end
            end
        end
        local count = 0
        for id in pairs(REQUIRED_IDS) do
            if found[id] then count += 1 end
        end
        return count, 4
    end

    local function part(parent, name, size, cf, color, material, transparency)
        local p = Instance.new("Part")
        p.Name = name
        p.Size = size
        p.CFrame = cf
        p.Color = color
        p.Material = material or Enum.Material.Neon
        p.Transparency = transparency or 0
        p.Anchored = true
        p.CanCollide = false
        p.CanTouch = false
        p.CanQuery = false
        p.CastShadow = false
        p.Parent = parent
        return p
    end

    local function clearDomain()
        domainGeneration += 1
        domainUntil = 0
        if domainFolder then domainFolder:Destroy(); domainFolder = nil end
    end

    local function makeShrine(origin, parent)
        local red = Color3.fromRGB(155, 15, 25)
        local dark = Color3.fromRGB(28, 10, 15)
        local gold = Color3.fromRGB(220, 160, 60)
        -- Oversized, stylized shrine behind the reanimated figure.
        local base = origin * CFrame.new(0, 1, 13)
        part(parent, "ShrineBase", Vector3.new(19, 1.2, 7), base, dark, Enum.Material.Slate)
        part(parent, "ShrinePlatform", Vector3.new(16, 0.5, 5), base * CFrame.new(0, 0.8, 0), red)
        for _, x in ipairs({-7, -3.5, 3.5, 7}) do
            part(parent, "ShrinePillar", Vector3.new(1, 10, 1), base * CFrame.new(x, 5.7, 0), dark, Enum.Material.Slate)
            part(parent, "PillarGlow", Vector3.new(0.18, 8.8, 0.18), base * CFrame.new(x + 0.56, 5.8, -0.05), red)
        end
        part(parent, "ShrineLintel", Vector3.new(18, 1.3, 1.6), base * CFrame.new(0, 10.7, 0), red)
        part(parent, "ShrineRoof", Vector3.new(21, 0.8, 3.2), base * CFrame.new(0, 11.5, 0), dark, Enum.Material.Slate)
        part(parent, "ShrineRoofGlow", Vector3.new(19, 0.18, 0.35), base * CFrame.new(0, 12, -0.2), gold)
        part(parent, "ShrineCenter", Vector3.new(4, 6, 0.5), base * CFrame.new(0, 4.2, -0.9), dark, Enum.Material.Slate)
        for _, y in ipairs({2.2, 4.2, 6.2}) do
            part(parent, "ShrineSigil", Vector3.new(2.8, 0.14, 0.12), base * CFrame.new(0, y, -1.2), gold)
        end
    end

    local function spawnSlash(center, parent, scale)
        local angle = math.random() * math.pi * 2
        local radius = math.random(8, 48)
        local height = math.random(1, 18)
        local position = center + Vector3.new(math.cos(angle) * radius, height, math.sin(angle) * radius)
        local direction = Vector3.new(math.random(-100,100)/100, math.random(-35,35)/100, math.random(-100,100)/100)
        if direction.Magnitude < 0.1 then direction = Vector3.new(1, 0, 0) end
        direction = direction.Unit
        local length = math.random(14, 30) * scale
        local slash = part(parent, "DismantleSlash", Vector3.new(length, 0.16 * scale, 0.22 * scale),
            CFrame.lookAt(position, position + direction) * CFrame.Angles(0, 0, math.rad(math.random(-55,55))),
            (math.random() < 0.7) and Color3.fromRGB(235, 235, 245) or Color3.fromRGB(190, 15, 30),
            Enum.Material.Neon, 0.08)
        slash.CFrame = slash.CFrame * CFrame.new(0, 0, -0.5)
        task.delay(0.12, function()
            if slash and slash.Parent then
                slash.Transparency = 0.45
                task.delay(0.12, function() if slash and slash.Parent then slash:Destroy() end end)
            end
        end)
    end

    local function startDomain()
        root = resolveRoot(figure)
        if not figure or not figure.Parent or not root then
            notify("Hat reanimation karakteri bulunamadı.")
            return
        end
        local equippedCount = checkAccessories(figure)
        if equippedCount < 1 then
            notify("Domain için verdiğin 4 aksesuar ID'sinden en az biri karakterde takılı olmalı.")
            return
        end
        clearDomain()
        domainGeneration += 1
        local generation = domainGeneration
        domainUntil = os.clock() + 8
        domainFolder = Instance.new("Folder")
        domainFolder.Name = "SukunaMalevolentShrineVisual"
        domainFolder.Parent = workspace
        makeShrine(root.CFrame, domainFolder)
        notify("Malevolent Shrine açıldı — geniş alanda slash yağmuru!")
        task.spawn(function()
            while generation == domainGeneration and os.clock() < domainUntil and root and root.Parent and domainFolder and domainFolder.Parent do
                local center = root.Position
                -- Dense visual barrage; purely local visual parts, no hitboxes or damage.
                for _ = 1, 5 do
                    if generation ~= domainGeneration or not domainFolder then break end
                    spawnSlash(center, domainFolder, 1)
                end
                task.wait(0.12)
            end
            if generation == domainGeneration then clearDomain() end
        end)
    end

    local function createControls()
        local player = Players.LocalPlayer
        local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
        if not playerGui then return end
        local old = playerGui:FindFirstChild("SukunaAbilityHUD")
        if old then old:Destroy() end
        gui = Instance.new("ScreenGui")
        gui.Name = "SukunaAbilityHUD"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 55
        gui.Parent = playerGui
        button = Instance.new("TextButton")
        button.Name = "MalevolentShrineButton"
        button.AnchorPoint = Vector2.new(1, 0)
        button.Position = UDim2.new(1, -14, 0, 160)
        button.Size = UDim2.fromOffset(112, 42)
        button.BackgroundColor3 = Color3.fromRGB(95, 10, 20)
        button.BorderSizePixel = 0
        button.Text = "DOMAIN"
        button.TextColor3 = Color3.fromRGB(255, 240, 240)
        button.TextSize = 13
        button.Font = Enum.Font.GothamBold
        button.Parent = gui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 9)
        corner.Parent = button
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(220, 45, 55)
        stroke.Thickness = 1.5
        stroke.Parent = button
        table.insert(connections, button.Activated:Connect(startDomain))
    end

    m.Config = function(parent) end

    m.Init = function(model)
        clearDomain()
        figure = model
        humanoid = figure and figure:FindFirstChildOfClass("Humanoid")
        root = resolveRoot(figure)
        local equipped, total = checkAccessories(figure)
        accessoryStatus = string.format("%d/%d listed accessories currently equipped", equipped, total)
        createControls()
        notify(accessoryStatus .. ". Shrine visual works without animation files.")
    end

    m.Update = function(dt, model)
        figure = model
        root = resolveRoot(figure)
    end

    m.Destroy = function()
        clearDomain()
        for _, connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
        table.clear(connections)
        if gui then gui:Destroy(); gui = nil end
        button = nil
        figure, root, humanoid = nil, nil, nil
    end

    return m
end)

return modules
