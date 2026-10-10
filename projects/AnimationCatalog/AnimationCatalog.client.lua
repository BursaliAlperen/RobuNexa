-- RobuNexa Animation Catalog (Roblox Studio / R6-R15)
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.
-- Roblox cannot play raw .anim/.mp3 files directly from GitHub.
-- Upload animations/audio you own or have permission to use, then enter Roblox asset IDs below.
-- This is for your own experience; it is not an executor/reanimation script.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local player = Players.LocalPlayer

-- Replace 0 values with Roblox asset IDs you own or are authorized to use.
-- Add one record per animation; do not duplicate entries.
local CATALOG = {
    {
        Name = "Hakari's Dance",
        AnimationId = 0, -- rbxassetid://ANIMATION_ID
        SoundId = 0,     -- rbxassetid://AUDIO_ID
        Looped = true,
        PlaybackSpeed = 1,
    },
    -- Example:
    -- { Name = "My Dance", AnimationId = 1234567890, SoundId = 2345678901, Looped = true, PlaybackSpeed = 1 },
}

local currentTrack
local currentSound
local gui
local statusLabel

local function stopCurrent()
    if currentTrack then
        pcall(function() currentTrack:Stop(0.15) end)
        pcall(function() currentTrack:Destroy() end)
        currentTrack = nil
    end
    if currentSound then
        pcall(function() currentSound:Stop() end)
        currentSound:Destroy()
        currentSound = nil
    end
end

local function getAnimator()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return nil, "Humanoid not found." end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        return nil, "Animator missing. Keep the default server-created Animator."
    end
    return animator
end

local function playEntry(entry)
    stopCurrent()
    local animator, reason = getAnimator()
    if not animator then statusLabel.Text = reason; return end
    if type(entry.AnimationId) ~= "number" or entry.AnimationId <= 0 then
        statusLabel.Text = "Set a valid Roblox AnimationId for " .. entry.Name .. "."
        return
    end

    local animation = Instance.new("Animation")
    animation.Name = entry.Name
    animation.AnimationId = "rbxassetid://" .. tostring(entry.AnimationId)
    local ok, result = pcall(function()
        local track = animator:LoadAnimation(animation)
        track.Priority = Enum.AnimationPriority.Action
        track.Looped = entry.Looped == true
        track:Play(0.15, 1, tonumber(entry.PlaybackSpeed) or 1)
        return track
    end)
    animation:Destroy()
    if not ok then
        statusLabel.Text = "Animation failed: " .. tostring(result)
        warn("[RobuNexa Catalog] Animation failed:", entry.Name, result)
        return
    end
    currentTrack = result

    if type(entry.SoundId) == "number" and entry.SoundId > 0 then
        local sound = Instance.new("Sound")
        sound.Name = "RobuNexaCatalogMusic"
        sound.SoundId = "rbxassetid://" .. tostring(entry.SoundId)
        sound.Looped = entry.Looped == true
        sound.Volume = 0.6
        sound.Parent = SoundService
        currentSound = sound
        local soundOk, soundError = pcall(function() sound:Play() end)
        if not soundOk then warn("[RobuNexa Catalog] Sound failed:", entry.Name, soundError) end
    end
    statusLabel.Text = "Playing: " .. entry.Name
end

local function buildGui()
    local playerGui = player:WaitForChild("PlayerGui")
    local old = playerGui:FindFirstChild("RobuNexaAnimationCatalog")
    if old then old:Destroy() end

    gui = Instance.new("ScreenGui")
    gui.Name = "RobuNexaAnimationCatalog"
    gui.ResetOnSpawn = false
    gui.Enabled = false
    gui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Name = "Panel"
    frame.Size = UDim2.fromOffset(280, 300)
    frame.Position = UDim2.new(0, 18, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -48, 0, 38)
    title.Position = UDim2.fromOffset(12, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "RobuNexa Animations"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local close = Instance.new("TextButton")
    close.Size = UDim2.fromOffset(30, 30)
    close.Position = UDim2.new(1, -36, 0, 6)
    close.Text = "×"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 22
    close.TextColor3 = Color3.new(1, 1, 1)
    close.BackgroundColor3 = Color3.fromRGB(55, 58, 68)
    close.Parent = frame
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)
    close.Activated:Connect(function() gui.Enabled = false end)

    statusLabel = Instance.new("TextLabel")
    statusLabel.Position = UDim2.fromOffset(12, 42)
    statusLabel.Size = UDim2.new(1, -24, 0, 36)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = "Choose an animation. Press G to toggle."
    statusLabel.TextColor3 = Color3.fromRGB(180, 190, 205)
    statusLabel.TextSize = 11
    statusLabel.TextWrapped = true
    statusLabel.Parent = frame

    local list = Instance.new("ScrollingFrame")
    list.Position = UDim2.fromOffset(12, 82)
    list.Size = UDim2.new(1, -24, 1, -94)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 4
    list.CanvasSize = UDim2.new()
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = list

    for index, entry in ipairs(CATALOG) do
        local button = Instance.new("TextButton")
        button.Name = "Animation_" .. index
        button.LayoutOrder = index
        button.Size = UDim2.new(1, -6, 0, 38)
        button.BackgroundColor3 = Color3.fromRGB(44, 48, 60)
        button.BorderSizePixel = 0
        button.Text = entry.Name
        button.Font = Enum.Font.GothamMedium
        button.TextSize = 13
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Parent = list
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)
        button.Activated:Connect(function() playEntry(entry) end)
    end

    local stop = Instance.new("TextButton")
    stop.Name = "StopAnimation"
    stop.LayoutOrder = #CATALOG + 1
    stop.Size = UDim2.new(1, -6, 0, 34)
    stop.BackgroundColor3 = Color3.fromRGB(115, 48, 55)
    stop.BorderSizePixel = 0
    stop.Text = "Stop animation + sound"
    stop.Font = Enum.Font.GothamBold
    stop.TextSize = 12
    stop.TextColor3 = Color3.new(1, 1, 1)
    stop.Parent = list
    Instance.new("UICorner", stop).CornerRadius = UDim.new(0, 7)
    stop.Activated:Connect(function()
        stopCurrent()
        statusLabel.Text = "Stopped."
    end)
end

buildGui()
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.G then gui.Enabled = not gui.Enabled end
end)
player.CharacterAdded:Connect(function()
    stopCurrent()
    if statusLabel then statusLabel.Text = "Character respawned. Ready." end
end)
warn("[RobuNexa Catalog] Loaded. Press G to open. Add authorized Roblox asset IDs in CATALOG.")
