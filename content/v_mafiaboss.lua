-- Mafia Boss moveset for RobuNexa / NAM.
-- Procedural R6/R15-compatible poses; no missing external animation files required.
local modules = {}
local function AddModule(m)
    table.insert(modules, m)
end

AddModule(function()
    local m = {}
    m.ModuleType = "MOVESET"
    m.Name = "Mafia Boss"
    m.InternalName = "MAFIABOSS"
    m.Description = "Mafia Boss: Boss Stance, Threaten, Call Backup and Execute emotes."
    m.Assets = {}

    local figure
    local actionName
    local actionUntil = 0
    local savedTransforms = {}
    local buttons = {}
    local poseMotors = {}

    local function collectMotors(model)
        poseMotors = {}
        if not model then return end
        for _, obj in ipairs(model:GetDescendants()) do
            if obj:IsA("Motor6D") then
                poseMotors[obj.Name] = obj
            end
        end
    end

    local function resetPose()
        for motor, transform in pairs(savedTransforms) do
            if motor and motor.Parent then
                pcall(function() motor.Transform = transform end)
            end
        end
        savedTransforms = {}
    end

    local function setPose(name, duration)
        if not figure or not figure.Parent then return end
        resetPose()
        collectMotors(figure)
        actionName = name
        actionUntil = os.clock() + (duration or 3)
        for _, motor in pairs(poseMotors) do
            savedTransforms[motor] = motor.Transform
        end
    end

    local function applyPose()
        if not actionName then return end
        if os.clock() >= actionUntil and actionName ~= "Boss Stance" then
            resetPose()
            actionName = nil
            return
        end
        local right = poseMotors["Right Shoulder"] or poseMotors["RightShoulder"]
        local left = poseMotors["Left Shoulder"] or poseMotors["LeftShoulder"]
        local neck = poseMotors["Neck"]
        local root = poseMotors["Root"] or poseMotors["RootJoint"]
        local t = os.clock()
        if actionName == "Boss Stance" then
            if right then right.Transform = CFrame.Angles(math.rad(-12), 0, math.rad(22)) end
            if left then left.Transform = CFrame.Angles(math.rad(-12), 0, math.rad(-22)) end
            if neck then neck.Transform = CFrame.Angles(math.rad(-4), math.rad(7), 0) end
        elseif actionName == "Threaten" then
            local pulse = math.sin(t * 8) * 0.04
            if right then right.Transform = CFrame.Angles(math.rad(-70) + pulse, 0, math.rad(20)) end
            if left then left.Transform = CFrame.Angles(math.rad(-15), 0, math.rad(-12)) end
            if neck then neck.Transform = CFrame.Angles(math.rad(8), math.rad(-8), 0) end
        elseif actionName == "Call Backup" then
            if right then right.Transform = CFrame.Angles(math.rad(-95), 0, math.rad(8)) end
            if left then left.Transform = CFrame.Angles(math.rad(-25), 0, math.rad(-18)) end
            if neck then neck.Transform = CFrame.Angles(math.rad(-5), 0, 0) end
        elseif actionName == "Execute" then
            local pulse = math.sin(t * 12) * 0.025
            if right then right.Transform = CFrame.Angles(math.rad(-105) + pulse, 0, math.rad(5)) end
            if left then left.Transform = CFrame.Angles(math.rad(18), 0, math.rad(-25)) end
            if neck then neck.Transform = CFrame.Angles(math.rad(12), 0, 0) end
            if root then root.Transform = CFrame.Angles(math.rad(-5), 0, 0) end
        end
    end

    m.Config = function(parent: GuiBase2d)
        local panel = Instance.new("Frame")
        panel.Name = "MafiaBossControls"
        panel.BackgroundTransparency = 1
        panel.Size = UDim2.new(1, 0, 0, 82)
        panel.Parent = parent

        local title = Instance.new("TextLabel")
        title.Name = "MafiaBossTitle"
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, 0, 0, 22)
        title.Font = Enum.Font.GothamBold
        title.Text = "MAFIA BOSS"
        title.TextColor3 = Color3.fromRGB(220, 185, 110)
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = panel

        local row = Instance.new("Frame")
        row.BackgroundTransparency = 1
        row.Position = UDim2.new(0, 0, 0, 25)
        row.Size = UDim2.new(1, 0, 0, 52)
        row.Parent = panel

        local layout = Instance.new("UIGridLayout")
        layout.CellSize = UDim2.new(0, 112, 0, 36)
        layout.CellPadding = UDim2.new(0, 6, 0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = row

        for index, name in ipairs({"Boss Stance", "Threaten", "Call Backup", "Execute"}) do
            local button = Instance.new("TextButton")
            button.Name = string.gsub(name, " ", "") .. "Button"
            button.LayoutOrder = index
            button.BackgroundColor3 = Color3.fromRGB(38, 31, 25)
            button.BorderSizePixel = 0
            button.Font = Enum.Font.GothamMedium
            button.Text = name
            button.TextColor3 = Color3.fromRGB(240, 222, 185)
            button.TextSize = 12
            button.AutoButtonColor = true
            button.Parent = row
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 7)
            corner.Parent = button
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(133, 99, 53)
            stroke.Thickness = 1
            stroke.Parent = button
            buttons[name] = button
            button.Activated:Connect(function()
                if actionName == name then
                    resetPose()
                    actionName = nil
                else
                    setPose(name, name == "Boss Stance" and 999999 or 3)
                end
            end)
        end
    end

    m.Init = function(model: Model)
        resetPose()
        figure = model
        actionName = nil
        collectMotors(figure)
    end

    m.Update = function(dt: number, model: Model)
        if model and model ~= figure then
            resetPose()
            figure = model
            collectMotors(figure)
        end
        applyPose()
    end

    m.Destroy = function()
        resetPose()
        figure = nil
        actionName = nil
        poseMotors = {}
        buttons = {}
    end

    return m
end)

return modules
