-- Place in ServerScriptService in YOUR Roblox experience.
-- Server-owned decorative Sukuna finger pickups: every player sees the same world objects.
-- Collecting a finger removes it for the whole server and notifies the collector's client.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local FINGER_COUNT = 11
local FOLDER_NAME = "SukunaFingerWorld"
local EVENT_NAME = "SukunaFingerFound"

local event = ReplicatedStorage:FindFirstChild(EVENT_NAME)
if not event then
    event = Instance.new("RemoteEvent")
    event.Name = EVENT_NAME
    event.Parent = ReplicatedStorage
end

local oldFolder = Workspace:FindFirstChild(FOLDER_NAME)
if oldFolder then oldFolder:Destroy() end
local folder = Instance.new("Folder")
folder.Name = FOLDER_NAME
folder.Parent = Workspace

local function getAnchors()
    local anchors = {}
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item:IsA("SpawnLocation") then
            table.insert(anchors, item.Position)
        end
    end
    if #anchors == 0 then
        local firstPlayer = Players:GetPlayers()[1]
        local character = firstPlayer and firstPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        table.insert(anchors, root and root.Position or Vector3.new(0, 5, 0))
    end
    return anchors
end

local anchors = getAnchors()
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = {folder}
rayParams.IgnoreWater = true

local fingers = {}
local rng = Random.new()
for i = 1, FINGER_COUNT do
    local anchor = anchors[((i - 1) % #anchors) + 1]
    local angle = (i / FINGER_COUNT) * math.pi * 2 + rng:NextNumber(-0.18, 0.18)
    local radius = 45 + ((i * 31) % 95)
    local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
    local castFrom = anchor + offset + Vector3.new(0, 250, 0)
    local hit = Workspace:Raycast(castFrom, Vector3.new(0, -700, 0), rayParams)
    local position = hit and (hit.Position + Vector3.new(0, 2.2, 0)) or (anchor + offset + Vector3.new(0, 4, 0))

    local finger = Instance.new("Part")
    finger.Name = "SukunaFinger_" .. i
    finger.Shape = Enum.PartType.Cylinder
    finger.Size = Vector3.new(0.38, 1.15, 0.38)
    finger.Material = Enum.Material.Neon
    finger.Color = Color3.fromRGB(122, 20, 34)
    finger.Anchored = true
    finger.CanCollide = false
    finger.CanTouch = false
    finger.CastShadow = false
    finger.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(108))
    finger.Parent = folder

    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 35, 66)
    light.Range = 13
    light.Brightness = 1.5
    light.Parent = finger

    local particles = Instance.new("ParticleEmitter")
    particles.Name = "CurseAura"
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particles.Color = ColorSequence.new(Color3.fromRGB(255, 45, 72), Color3.fromRGB(75, 0, 12))
    particles.LightEmission = 0.7
    particles.Rate = 5
    particles.Lifetime = NumberRange.new(0.45, 0.9)
    particles.Speed = NumberRange.new(0.2, 0.8)
    particles.SpreadAngle = Vector2.new(180, 180)
    particles.Parent = finger

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Collect Finger"
    prompt.ObjectText = "Cursed Finger " .. i .. "/" .. FINGER_COUNT
    prompt.HoldDuration = 0.35
    prompt.MaxActivationDistance = 11
    prompt.RequiresLineOfSight = false
    prompt.Parent = finger

    local entry = {part = finger, origin = position, index = i, collected = false}
    table.insert(fingers, entry)
    prompt.Triggered:Connect(function(player)
        if entry.collected or not finger.Parent then return end
        entry.collected = true
        event:FireClient(player, i, FINGER_COUNT, position)
        finger:Destroy() -- Server destruction replicates to every player.
    end)
end

local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
    elapsed += dt
    for _, entry in ipairs(fingers) do
        local part = entry.part
        if not entry.collected and part and part.Parent then
            part.CFrame = CFrame.new(entry.origin) * CFrame.Angles(0, elapsed * 1.45, math.rad(108))
        end
    end
end)
