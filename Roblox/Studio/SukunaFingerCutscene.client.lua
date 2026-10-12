-- Place in StarterPlayer > StarterPlayerScripts in YOUR Roblox experience.
-- Local-only camera presentation for the server-owned finger pickup event.
-- To play the real laugh animation, add a published Animation named
-- "SukunaLaughAnimation" to ReplicatedStorage and set its AnimationId.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local event = ReplicatedStorage:WaitForChild("SukunaFingerFound", 15)
if not event then
    warn("[Sukuna] SukunaFingerFound RemoteEvent was not created by the server script.")
    return
end

local function announce(message)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "SUKUNA",
            Text = message,
            Duration = 3,
        })
    end)
end

local function playLaugh()
    local template = ReplicatedStorage:FindFirstChild("SukunaLaughAnimation")
    if not template or not template:IsA("Animation") or template.AnimationId == "" then
        return false
    end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    local ok, track = pcall(function() return animator:LoadAnimation(template) end)
    if not ok or not track then return false end
    track.Priority = Enum.AnimationPriority.Action
    track.Looped = false
    track:Play(0.12, 1, 1)
    return true
end

local sequence = 0
event.OnClientEvent:Connect(function(index, total, position)
    sequence += 1
    local thisSequence = sequence
    announce(("CURSED FINGER FOUND  %d/%d"):format(index, total))
    playLaugh()

    local camera = workspace.CurrentCamera
    if not camera or typeof(position) ~= "Vector3" then return end
    local oldType, oldSubject, oldCFrame = camera.CameraType, camera.CameraSubject, camera.CFrame
    local focus = position + Vector3.new(0, 1.5, 0)
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = CFrame.lookAt(focus + Vector3.new(0, 5, 10), focus)
    TweenService:Create(camera, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        CFrame = CFrame.lookAt(focus + Vector3.new(0, 2.6, 5), focus),
    }):Play()

    task.delay(1.25, function()
        if thisSequence ~= sequence or not camera or not camera.Parent then return end
        camera.CameraType = oldType
        camera.CameraSubject = oldSubject
        camera.CFrame = oldCFrame
    end)

    if index == total then
        announce("ALL CURSED FINGERS FOUND — THE KING OF CURSES AWAKENS.")
    end
end)
