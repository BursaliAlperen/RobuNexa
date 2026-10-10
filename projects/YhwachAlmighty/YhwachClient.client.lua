-- YhwachClient.client.lua
-- Unified Yhwach moveset + R6/R15 animation playback + awakening cinematic.
-- For a Roblox experience you own. Place this LocalScript beside YhwachCutscenes (ModuleScript).
-- Replace the 0 animation IDs below with animation assets uploaded/owned for your experience.
-- This intentionally does not use executor APIs, loadstring, or remote code injection.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local cutsceneModule = script.Parent:WaitForChild("YhwachCutscenes")
local Cutscenes = require(cutsceneModule)

local CONFIG = {
    Name = "THE ALMIGHTY",
    Cooldown = 0.8,
    Animations = {
        Slash = 0,       -- Animation asset ID
        Auswahlen = 0,   -- Animation asset ID
        BlutVene = 0,    -- Animation asset ID
        Sklaverei = 0,   -- Animation asset ID
        Awakening = 0,   -- Animation asset ID
    },
}

local character, humanoid, animator
local lastUsed = {}
local activeTracks = {}
local gui
local destroyed = false

local function getAnimator(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil, nil end
    local anim = hum:FindFirstChildOfClass("Animator")
    if not anim then
        anim = Instance.new("Animator")
        anim.Parent = hum
    end
    return hum, anim
end

local function bindCharacter(char)
    character = char
    humanoid, animator = getAnimator(char)
    table.clear(activeTracks)
end

local function playAnimation(name)
    if not character or not humanoid or humanoid.Health <= 0 or not animator then
        warn("[Yhwach] Character/Animator not ready.")
        return false
    end
    local id = CONFIG.Animations[name]
    if type(id) ~= "number" or id <= 0 then
        warn(("[Yhwach] Set CONFIG.Animations.%s to an uploaded animation asset ID."):format(name))
        return false
    end
    local now = os.clock()
    if lastUsed[name] and now - lastUsed[name] < CONFIG.Cooldown then return false end
    lastUsed[name] = now

    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. tostring(id)
    local ok, trackOrError = pcall(function()
        return animator:LoadAnimation(animation)
    end)
    animation:Destroy()
    if not ok then
        warn("[Yhwach] Could not load animation " .. name .. ": " .. tostring(trackOrError))
        return false
    end

    local track = trackOrError
    track.Priority = Enum.AnimationPriority.Action
    track.Looped = false
    for _, oldTrack in pairs(activeTracks) do
        if oldTrack and oldTrack.IsPlaying then
            pcall(function() oldTrack:Stop(0.12) end)
        end
    end
    activeTracks[name] = track
    track:Play(0.12, 1, 1)
    track.Stopped:Once(function()
        if activeTracks[name] == track then activeTracks[name] = nil end
        pcall(function() track:Destroy() end)
    end)
    return true
end

local function createButton(parent, label, key, callback, order)
    local button = Instance.new("TextButton")
    button.Name = label:gsub("%W", "") .. "Button"
    button.LayoutOrder = order
    button.Size = UDim2.new(1, 0, 0, 42)
    button.BackgroundColor3 = Color3.fromRGB(27, 22, 43)
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Text = label .. "   [" .. key .. "]"
    button.TextColor3 = Color3.fromRGB(241, 234, 255)
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    button.Activated:Connect(callback)
    return button
end

local function buildUI()
    local playerGui = player:WaitForChild("PlayerGui")
    local previous = playerGui:FindFirstChild("YhwachMoveset")
    if previous then previous:Destroy() end

    gui = Instance.new("ScreenGui")
    gui.Name = "YhwachMoveset"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 20
    gui.Parent = playerGui

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.AnchorPoint = Vector2.new(1, 0.5)
    panel.Position = UDim2.new(1, -16, 0.5, 0)
    panel.Size = UDim2.fromOffset(220, 270)
    panel.BackgroundColor3 = Color3.fromRGB(12, 10, 19)
    panel.BackgroundTransparency = 0.12
    panel.BorderSizePixel = 0
    panel.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = panel

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -16, 0, 36)
    title.Position = UDim2.fromOffset(8, 5)
    title.BackgroundTransparency = 1
    title.Text = CONFIG.Name
    title.TextColor3 = Color3.fromRGB(220, 202, 255)
    title.TextSize = 17
    title.Font = Enum.Font.GothamBlack
    title.Parent = panel

    local list = Instance.new("Frame")
    list.Position = UDim2.fromOffset(10, 45)
    list.Size = UDim2.new(1, -20, 1, -55)
    list.BackgroundTransparency = 1
    list.Parent = panel
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = list

    createButton(list, "Almighty Slash", "Z", function() playAnimation("Slash") end, 1)
    createButton(list, "Auswählen", "X", function() playAnimation("Auswahlen") end, 2)
    createButton(list, "Blut Vene", "C", function() playAnimation("BlutVene") end, 3)
    createButton(list, "Sklaverei", "V", function() playAnimation("Sklaverei") end, 4)
    createButton(list, "Awakening", "G", function()
        playAnimation("Awakening")
        local ok, err = pcall(function() Cutscenes.PlayAwakening(character) end)
        if not ok then warn("[Yhwach] Cutscene failed: " .. tostring(err)) end
    end, 5)
end

local keyActions = {
    [Enum.KeyCode.Z] = function() playAnimation("Slash") end,
    [Enum.KeyCode.X] = function() playAnimation("Auswahlen") end,
    [Enum.KeyCode.C] = function() playAnimation("BlutVene") end,
    [Enum.KeyCode.V] = function() playAnimation("Sklaverei") end,
    [Enum.KeyCode.G] = function()
        playAnimation("Awakening")
        local ok, err = pcall(function() Cutscenes.PlayAwakening(character) end)
        if not ok then warn("[Yhwach] Cutscene failed: " .. tostring(err)) end
    end,
}

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or UserInputService:GetFocusedTextBox() then return end
    local action = keyActions[input.KeyCode]
    if action then action() end
end)

player.CharacterAdded:Connect(bindCharacter)
player.CharacterRemoving:Connect(function()
    pcall(function() Cutscenes.Stop() end)
    table.clear(activeTracks)
end)

if player.Character then bindCharacter(player.Character) end
buildUI()

script.Destroying:Connect(function()
    destroyed = true
    pcall(function() Cutscenes.Stop() end)
    if gui then gui:Destroy() end
    for _, track in pairs(activeTracks) do
        pcall(function() track:Stop(0) track:Destroy() end)
    end
end)
