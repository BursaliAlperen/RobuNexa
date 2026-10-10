-- YhwachMoveset.lua
-- Single-file LocalScript for an experience you own.
-- Place in StarterPlayer > StarterPlayerScripts.
-- Publish each source .anim through Roblox Animation Editor and fill in the IDs below.
-- This intentionally does not implement executor-based hat-drop/reanimation.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local CONFIG = {
    AnimationIds = {
        AlmightyAwakening = "", -- AlmightyAwake.anim
        AlmightyAura = "",      -- AlmightyAura.anim
        AlmightySlash = "",     -- AlmightySlash.anim
        Auswahlen = "",         -- Auswählen.anim
        BlutVeneAnhaben = "",   -- Blut Vene Anhaben.anim
        Sklaverei = "",         -- Sklaverei .anim
    },
    -- Catalog references from the project manifest; these IDs do not auto-equip themselves.
    AccessoryAssetIds = {
        Base = {87291559615126, 128893482026011, 120111604252410, 90788603154080, 88886554182275},
        Almighty = {108684178086287, 75672773594451, 83293970715566, 122497534796344,
                    104304509923191, 87969060185631, 100693570818976},
    },
    AccessoryPoseName = "", -- exact name of an Accessory already equipped on the character
}

local MOVE_NAMES = {
    {"Awakening", "AlmightyAwakening"},
    {"Aura", "AlmightyAura"},
    {"Slash", "AlmightySlash"},
    {"Auswahlen", "Auswahlen"},
    {"Blut Vene", "BlutVeneAnhaben"},
    {"Sklaverei", "Sklaverei"},
}

local character, humanoid, animator
local tracks = {}
local activePoseTween, posedWeld, originalC0

local function setStatus(label, message)
    label.Text = message
end

local function stopTracks()
    for _, track in pairs(tracks) do
        pcall(function() track:Stop(0.15) end)
    end
    table.clear(tracks)
end

local function bindCharacter(char)
    stopTracks()
    character = char
    humanoid = char:WaitForChild("Humanoid", 10)
    animator = humanoid and humanoid:WaitForChild("Animator", 10)
end

bindCharacter(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(bindCharacter)

local gui = Instance.new("ScreenGui")
gui.Name = "YhwachMoveset"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(260, 340)
panel.Position = UDim2.new(0, 16, 0.5, -170)
panel.BackgroundColor3 = Color3.fromRGB(16, 17, 23)
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(94, 78, 160)
stroke.Transparency = 0.25
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 34)
title.Position = UDim2.fromOffset(10, 8)
title.BackgroundTransparency = 1
title.Text = "YHWACH • THE ALMIGHTY"
title.TextColor3 = Color3.fromRGB(235, 232, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = panel

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 32)
status.Position = UDim2.fromOffset(10, 42)
status.BackgroundTransparency = 1
status.Text = "Ready • publish animation IDs first"
status.TextColor3 = Color3.fromRGB(175, 174, 193)
status.TextWrapped = true
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.Parent = panel

local list = Instance.new("Frame")
list.Size = UDim2.new(1, -20, 0, 222)
list.Position = UDim2.fromOffset(10, 80)
list.BackgroundTransparency = 1
list.Parent = panel

local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.new(0.5, -5, 0, 48)
layout.CellPadding = UDim2.fromOffset(8, 8)
layout.Parent = list

local function playMove(displayName, key)
    if not character or not humanoid or not animator then
        setStatus(status, "Character/Animator not ready.")
        return
    end
    local id = CONFIG.AnimationIds[key]
    if type(id) ~= "string" or id == "" then
        setStatus(status, "Missing published Animation ID: " .. key)
        warn("[YhwachMoveset] Publish the matching .anim and fill CONFIG.AnimationIds." )
        return
    end
    if not id:match("^rbxassetid://") then id = "rbxassetid://" .. id end

    local animation = Instance.new("Animation")
    animation.AnimationId = id
    local ok, trackOrError = pcall(function()
        return animator:LoadAnimation(animation)
    end)
    animation:Destroy()
    if not ok then
        setStatus(status, "Could not load " .. displayName .. ". Check ID/permissions.")
        warn("[YhwachMoveset] LoadAnimation failed:", trackOrError)
        return
    end
    local track = trackOrError
    track.Priority = Enum.AnimationPriority.Action
    track.Looped = (key == "AlmightyAura")
    track:Play(0.15)
    tracks[key] = track
    setStatus(status, "Playing: " .. displayName)
end

for _, item in ipairs(MOVE_NAMES) do
    local button = Instance.new("TextButton")
    button.Name = item[2]
    button.Text = item[1]
    button.BackgroundColor3 = Color3.fromRGB(39, 35, 58)
    button.TextColor3 = Color3.fromRGB(245, 243, 255)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 12
    button.AutoButtonColor = true
    button.Parent = list
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    button.Activated:Connect(function() playMove(item[1], item[2]) end)
end

local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(1, -20, 0, 30)
stopButton.Position = UDim2.new(0, 10, 1, -40)
stopButton.Text = "STOP ANIMATIONS"
stopButton.BackgroundColor3 = Color3.fromRGB(77, 36, 48)
stopButton.TextColor3 = Color3.fromRGB(255, 238, 242)
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 11
stopButton.Parent = panel
Instance.new("UICorner", stopButton).CornerRadius = UDim.new(0, 8)
stopButton.Activated:Connect(function()
    stopTracks()
    setStatus(status, "Animations stopped.")
end)

-- Optional local visual pose for an Accessory already equipped on your own character.
-- Set CONFIG.AccessoryPoseName to the exact accessory name; no accessory is inserted or stolen.
local function poseEquippedAccessory()
    if not character or CONFIG.AccessoryPoseName == "" then return end
    local accessory = character:FindFirstChild(CONFIG.AccessoryPoseName)
    local handle = accessory and accessory:IsA("Accessory") and accessory:FindFirstChild("Handle")
    if not handle then
        setStatus(status, "Accessory not equipped: " .. CONFIG.AccessoryPoseName)
        return
    end
    local weld
    for _, obj in ipairs(handle:GetDescendants()) do
        if obj:IsA("Weld") or obj:IsA("Motor6D") then weld = obj break end
    end
    if not weld then
        setStatus(status, "No accessory weld found to pose.")
        return
    end
    if activePoseTween then activePoseTween:Cancel() end
    posedWeld = weld
    originalC0 = weld.C0
    activePoseTween = TweenService:Create(
        weld,
        TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        {C0 = originalC0 * CFrame.new(0, 0.15, 0) * CFrame.Angles(math.rad(-10), 0, math.rad(8))}
    )
    activePoseTween:Play()
    setStatus(status, "Posing equipped accessory locally.")
end

-- Tap the title to try the optional accessory pose after setting its exact name above.
title.Active = true
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        poseEquippedAccessory()
    end
end)

print("[YhwachMoveset] Loaded. Publish the six animations and set CONFIG.AnimationIds.")
