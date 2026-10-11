-- NPC-only touch fling (R6 + R15 compatible)
-- Place this Script in ServerScriptService.
-- Players trigger the effect, but only NPCs receive the impulse.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local NPC_FOLDER_NAME = "NPCs" -- Optional: if Workspace.NPCs exists, only NPCs in it are affected.
local FLING_HORIZONTAL_SPEED = 95
local FLING_UPWARD_SPEED = 42
local COOLDOWN = 1.0

local lastFling = setmetatable({}, { __mode = "k" })
local connected = setmetatable({}, { __mode = "k" })

local function getNPCFolder()
    return Workspace:FindFirstChild(NPC_FOLDER_NAME)
end

local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local function isNPC(model)
    if not model or not model:IsA("Model") or isPlayerCharacter(model) then
        return false
    end

    local folder = getNPCFolder()
    if folder then
        return model:IsDescendantOf(folder)
    end

    return model:IsDescendantOf(Workspace)
        and model:FindFirstChildOfClass("Humanoid") ~= nil
        and model:FindFirstChild("HumanoidRootPart") ~= nil
end

local function findCharacterModel(part)
    local current = part
    while current and current ~= Workspace do
        if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
            return current
        end
        current = current.Parent
    end
    return nil
end

local function flingNPC(npc, playerCharacter)
    if not isNPC(npc) then return end

    local humanoid = npc:FindFirstChildOfClass("Humanoid")
    local root = npc:FindFirstChild("HumanoidRootPart")
    local playerRoot = playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart")

    if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
        return
    end

    local now = os.clock()
    if lastFling[npc] and now - lastFling[npc] < COOLDOWN then
        return
    end
    lastFling[npc] = now

    local direction
    if playerRoot and playerRoot:IsA("BasePart") then
        local offset = root.Position - playerRoot.Position
        direction = Vector3.new(offset.X, 0, offset.Z)
    else
        direction = root.CFrame.LookVector
    end

    if direction.Magnitude < 0.01 then
        direction = Vector3.new(0, 0, -1)
    else
        direction = direction.Unit
    end

    -- Apply impulse only to the NPC root; no player part is modified.
    pcall(function()
        root:SetNetworkOwner(nil)
    end)

    local mass = root.AssemblyMass
    root:ApplyImpulse((direction * FLING_HORIZONTAL_SPEED + Vector3.new(0, FLING_UPWARD_SPEED, 0)) * mass)
end

local function connectNPC(npc)
    if not npc:IsA("Model") or connected[npc] or isPlayerCharacter(npc) then return end
    local humanoid = npc:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    connected[npc] = true

    local function connectPart(part)
        if not part:IsA("BasePart") then return end
        part.Touched:Connect(function(hit)
            local playerCharacter = findCharacterModel(hit)
            if not playerCharacter or not isPlayerCharacter(playerCharacter) then return end
            flingNPC(npc, playerCharacter)
        end)
    end

    for _, descendant in ipairs(npc:GetDescendants()) do
        connectPart(descendant)
    end
    npc.DescendantAdded:Connect(connectPart)
end

local function scan(container)
    for _, descendant in ipairs(container:GetDescendants()) do
        if descendant:IsA("Model") and descendant:FindFirstChildOfClass("Humanoid") then
            connectNPC(descendant)
        end
    end
end

local folder = getNPCFolder()
if folder then
    scan(folder)
    folder.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Model") then
            task.defer(connectNPC, descendant)
        end
    end)
else
    scan(Workspace)
    Workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Model") then
            task.defer(connectNPC, descendant)
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Player characters are never registered as fling targets.
        character:SetAttribute("NPCFlingPlayerCharacter", true)
    end)
end)
