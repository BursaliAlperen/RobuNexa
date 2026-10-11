-- RealFlingServer.server.lua
-- Place in ServerScriptService in YOUR OWN Roblox experience.
-- Server-authorized fling mechanic; not intended for use in third-party games.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local REMOTE_NAME = "RealFlingRequest"
local MAX_RANGE = 35
local MAX_POWER = 120
local MIN_POWER = 20
local COOLDOWN = 1.25

-- For group-owned experiences, add trusted UserIds here.
local ALLOWED_USER_IDS = {
    -- [123456789] = true,
}

local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = REMOTE_NAME
    remote.Parent = ReplicatedStorage
end

local lastUse = {}

local function isAuthorized(player)
    if ALLOWED_USER_IDS[player.UserId] then
        return true
    end
    return game.CreatorType == Enum.CreatorType.User and player.UserId == game.CreatorId
end

local function getRoot(character)
    if not character then return nil end
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then
        return nil
    end
    return root
end

local function findTarget(name)
    if typeof(name) ~= "string" or #name > 32 then return nil end
    local needle = string.lower(name)
    for _, candidate in ipairs(Players:GetPlayers()) do
        if string.lower(candidate.Name) == needle or string.lower(candidate.DisplayName) == needle then
            return candidate
        end
    end
    return nil
end

remote.OnServerEvent:Connect(function(player, action, targetName, requestedPower, mode)
    if action ~= "Fling" or not isAuthorized(player) then return end

    local now = os.clock()
    if lastUse[player] and now - lastUse[player] < COOLDOWN then return end
    lastUse[player] = now

    local target = findTarget(targetName)
    if not target or target == player then return end

    local sourceRoot = getRoot(player.Character)
    local targetRoot = getRoot(target.Character)
    if not sourceRoot or not targetRoot then return end

    local offset = targetRoot.Position - sourceRoot.Position
    if offset.Magnitude < 0.1 or offset.Magnitude > MAX_RANGE then return end

    local power = math.clamp(tonumber(requestedPower) or 60, MIN_POWER, MAX_POWER)
    if mode ~= "Velocity" and mode ~= "Angular" and mode ~= "Hybrid" then
        mode = "Hybrid"
    end

    -- Apply the impulse on the server. The target's network ownership is briefly
    -- assigned to the server to make the result authoritative and predictable.
    pcall(function() targetRoot:SetNetworkOwner(nil) end)

    local direction = (offset.Unit + Vector3.new(0, 0.65, 0)).Unit
    local mass = targetRoot.AssemblyMass
    if mode == "Velocity" then
        targetRoot:ApplyImpulse(direction * mass * power)
    elseif mode == "Angular" then
        targetRoot:ApplyImpulse(Vector3.new(0, mass * power * 0.45, 0))
        targetRoot:ApplyAngularImpulse(Vector3.new(power * mass * 0.8, 0, power * mass * 0.8))
    else
        targetRoot:ApplyImpulse(direction * mass * power)
        targetRoot:ApplyAngularImpulse(Vector3.new(power * mass * 0.45, 0, power * mass * 0.45))
    end
end)

Players.PlayerRemoving:Connect(function(player)
    lastUse[player] = nil
end)
