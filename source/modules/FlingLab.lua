-- RobuNexa Fling Lab (NPC-only test module)
-- Client-side sandbox helper. Intentionally excludes Player characters.
-- Load as a separate module; do not merge into the main UI until its layout is reviewed.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local FlingLab = {}
FlingLab.Enabled = false
FlingLab.MaxRange = 35
FlingLab.Impulse = 65
FlingLab.Cooldown = 0.8

local lastLaunch = 0
local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local function getRoot(model)
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("UpperTorso")
end

local function findNearestNPC()
    local character = LocalPlayer.Character
    local myRoot = character and getRoot(character)
    if not myRoot then return nil end

    local nearest, nearestDistance = nil, FlingLab.MaxRange
    for _, instance in ipairs(workspace:GetDescendants()) do
        if instance:IsA("Model") and instance ~= character
            and not isPlayerCharacter(instance) then
            local humanoid = instance:FindFirstChildOfClass("Humanoid")
            local root = getRoot(instance)
            if humanoid and humanoid.Health > 0 and root and not root.Anchored then
                local distance = (root.Position - myRoot.Position).Magnitude
                if distance < nearestDistance then
                    nearest, nearestDistance = instance, distance
                end
            end
        end
    end
    return nearest, myRoot
end

function FlingLab.SetEnabled(enabled)
    FlingLab.Enabled = enabled == true
end

function FlingLab.Step()
    if not FlingLab.Enabled or os.clock() - lastLaunch < FlingLab.Cooldown then
        return false
    end

    local npc, myRoot = findNearestNPC()
    if not npc then return false end
    local root = getRoot(npc)
    if not root or isPlayerCharacter(npc) then return false end

    local direction = root.Position - myRoot.Position
    if direction.Magnitude < 0.01 then direction = myRoot.CFrame.LookVector end
    direction = direction.Unit

    -- Bounded test impulse; this is local and is not guaranteed to replicate.
    local mass = root.AssemblyMass
    root:ApplyImpulse((direction * FlingLab.Impulse + Vector3.new(0, FlingLab.Impulse * 0.65, 0))
        * math.clamp(mass, 1, 20))
    lastLaunch = os.clock()
    return true, npc.Name
end

function FlingLab.AttachToggle(parent)
    local button = Instance.new("TextButton")
    button.Name = "FlingLabToggle"
    button.Size = UDim2.fromOffset(140, 36)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = "NPC Fling: OFF"
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 13
    button.Parent = parent

    button.Activated:Connect(function()
        FlingLab.SetEnabled(not FlingLab.Enabled)
        button.Text = FlingLab.Enabled and "NPC Fling: ON" or "NPC Fling: OFF"
        button.BackgroundColor3 = FlingLab.Enabled
            and Color3.fromRGB(30, 125, 80) or Color3.fromRGB(45, 45, 52)
    end)

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not button.Parent then
            connection:Disconnect()
            return
        end
        FlingLab.Step()
    end)
    return button
end

return FlingLab
