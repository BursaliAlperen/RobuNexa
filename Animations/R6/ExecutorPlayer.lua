-- RobuNexa R6 .anim player (executor-side, local character only)
-- Animation files are passive JSON; they are decoded, never loadstring'ed.
-- Usage:
-- local player = loadstring(game:HttpGet("https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/robunexa-nam-adaptation/Animations/R6/ExecutorPlayer.lua"))()
-- player:Play("wave")
-- player:Play("anime_guard")
-- player:Stop()

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local ROOT = "https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/robunexa-nam-adaptation/Animations/R6/"
local player = {}
local connection
local startedAt = 0
local activeSequence
local joints = {}
local originalTransforms = {}

local function getCharacter()
    local localPlayer = Players.LocalPlayer
    assert(localPlayer, "RobuNexa: LocalPlayer is unavailable")
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    assert(humanoid and humanoid.RigType == Enum.HumanoidRigType.R6, "RobuNexa .anim player requires an R6 character")
    return character
end

local function collectJoints(character)
    local found = {}
    for _, item in ipairs(character:GetDescendants()) do
        if item:IsA("Motor6D") then
            found[item.Name] = item
        end
    end
    return found
end

local function fetchAnimation(name)
    assert(type(name) == "string" and name:match("^[%w_%-]+$"), "Use a simple animation filename, e.g. 'wave'")
    local response = game:HttpGet(ROOT .. name .. ".anim")
    local data = HttpService:JSONDecode(response)
    assert(data.format == "robunexa.anim.v1", "Unsupported .anim format")
    assert(data.rig == "R6" and type(data.frames) == "table" and #data.frames >= 2, "Invalid R6 animation data")
    local previous = -1
    for _, frame in ipairs(data.frames) do
        assert(type(frame.t) == "number" and frame.t >= previous, "Animation frames must be time-sorted")
        assert(type(frame.joints) == "table", "Frame is missing joints")
        previous = frame.t
    end
    return data
end

local function framePose(frame, jointName)
    local value = frame.joints[jointName]
    if not value then return CFrame.identity end
    local x = math.rad(tonumber(value.x) or 0)
    local y = math.rad(tonumber(value.y) or 0)
    local z = math.rad(tonumber(value.z) or 0)
    return CFrame.Angles(x, y, z)
end

local function sample(data, timePosition, jointName)
    local frames = data.frames
    if timePosition <= frames[1].t then return framePose(frames[1], jointName) end
    if timePosition >= frames[#frames].t then return framePose(frames[#frames], jointName) end
    for index = 1, #frames - 1 do
        local a, b = frames[index], frames[index + 1]
        if timePosition >= a.t and timePosition <= b.t then
            local span = math.max(b.t - a.t, 1e-5)
            local alpha = math.clamp((timePosition - a.t) / span, 0, 1)
            return framePose(a, jointName):Lerp(framePose(b, jointName), alpha)
        end
    end
    return CFrame.identity
end

function player:Stop()
    if connection then connection:Disconnect(); connection = nil end
    for name, joint in pairs(joints) do
        if joint and joint.Parent then
            joint.Transform = originalTransforms[name] or CFrame.identity
        end
    end
    activeSequence = nil
end

function player:Play(name)
    self:Stop()
    local character = getCharacter()
    joints = collectJoints(character)
    originalTransforms = {}
    for jointName, joint in pairs(joints) do
        originalTransforms[jointName] = joint.Transform
    end

    local data = fetchAnimation(name)
    local duration = data.frames[#data.frames].t
    assert(duration > 0, "Animation duration must be greater than zero")
    activeSequence = data
    startedAt = os.clock()

    connection = RunService.PreSimulation:Connect(function()
        if not activeSequence then return end
        local elapsed = os.clock() - startedAt
        local position = elapsed
        if activeSequence.looped then
            position = elapsed % duration
        elseif elapsed >= duration then
            self:Stop()
            return
        end
        for jointName, joint in pairs(joints) do
            if joint and joint.Parent then
                joint.Transform = sample(activeSequence, position, jointName)
            end
        end
    end)
    return data
end

function player:List()
    return {"idle", "walk", "wave", "anime_guard", "dash", "victory_pose"}
end

function player:Destroy()
    self:Stop()
    table.clear(joints)
    table.clear(originalTransforms)
end

return player
