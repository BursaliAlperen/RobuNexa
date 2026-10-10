-- Yhwach Almighty Moveset (Roblox Studio / own experience)
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.
-- Publish your R6 animations and replace the empty IDs below.
-- This deliberately uses Roblox's supported Animator API; it does not inject into other experiences.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CONFIG = {
    ToggleKey = Enum.KeyCode.RightControl,
    CutsceneKey = Enum.KeyCode.G,
    Animations = {
        AlmightyAwakening = "", -- Z
        AlmightySlash = "",     -- X
        Auswahlen = "",         -- C
        BlutVene = "",          -- V
        Sklaverei = "",         -- B
    },
}

local character, humanoid, animator
local tracks = {}
local busy = false
local oldCameraType, oldCameraSubject

local function getAnimator(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if not hum then return nil end
    local anim = hum:FindFirstChildOfClass("Animator")
    if not anim then
        -- In a published experience, create the Animator on the server for replication.
        warn("[Yhwach] No Animator found. Add one to the character on the server.")
        return nil
    end
    humanoid = hum
    return anim
end

local function bindCharacter(char)
    character = char
    animator = getAnimator(char)
    tracks = {}
    if not animator then return end
    for name, id in pairs(CONFIG.Animations) do
        if typeof(id) == "string" and id:match("^%d+$") then
            local animation = Instance.new("Animation")
            animation.Name = name
            animation.AnimationId = "rbxassetid://" .. id
            local ok, track = pcall(function() return animator:LoadAnimation(animation) end)
            if ok and track then
                track.Priority = Enum.AnimationPriority.Action
                tracks[name] = track
            else
                warn("[Yhwach] Could not load animation:", name, track)
            end
            animation:Destroy()
        end
    end
end

local function playMove(name)
    if not character or not character.Parent then return end
    if not animator or not animator.Parent then
        bindCharacter(player.Character or character)
    end
    local track = tracks[name]
    if track then
        for _, playing in pairs(tracks) do
            if playing ~= track and playing.IsPlaying then playing:Stop(0.12) end
        end
        track:Play(0.12, 1, 1)
    else
        warn("[Yhwach] Animation ID not configured for " .. name .. ". Edit CONFIG.Animations.")
    end
end

local gui = Instance.new("ScreenGui")
gui.Name = "YhwachAlmightyUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(1, 0.5)
panel.Position = UDim2.new(1, -18, 0.5, 0)
panel.Size = UDim2.fromOffset(230, 300)
panel.BackgroundColor3 = Color3.fromRGB(15, 18, 27)
panel.BackgroundTransparency = 0.12
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(102, 83, 185)
stroke.Transparency = 0.25
local padding = Instance.new("UIPadding", panel)
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
local list = Instance.new("UIListLayout", panel)
list.Padding = UDim.new(0, 7)
list.SortOrder = Enum.SortOrder.LayoutOrder

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 34)
title.BackgroundTransparency = 1
title.Text = "YHWACH  •  ALMIGHTY"
title.TextColor3 = Color3.fromRGB(230, 224, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.LayoutOrder = 0
title.Parent = panel

local function addButton(label, order, callback)
    local button = Instance.new("TextButton")
    button.Name = label:gsub("[^%w]", "") .. "Button"
    button.LayoutOrder = order
    button.Size = UDim2.new(1, 0, 0, 37)
    button.BackgroundColor3 = Color3.fromRGB(37, 34, 57)
    button.BorderSizePixel = 0
    button.Text = label
    button.TextColor3 = Color3.fromRGB(245, 243, 255)
    button.TextSize = 13
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = true
    button.Parent = panel
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    button.Activated:Connect(callback)
    return button
end

addButton("Z  •  Almighty Awakening", 1, function() playMove("AlmightyAwakening") end)
addButton("X  •  Almighty Slash", 2, function() playMove("AlmightySlash") end)
addButton("C  •  Auswählen", 3, function() playMove("Auswahlen") end)
addButton("V  •  Blut Vene", 4, function() playMove("BlutVene") end)
addButton("B  •  Sklaverei", 5, function() playMove("Sklaverei") end)
addButton("G  •  Almighty Cutscene", 6, function()
    if busy or not character then return end
    local camera = workspace.CurrentCamera
    local root = character:FindFirstChild("HumanoidRootPart")
    if not camera or not root then return end
    busy = true
    oldCameraType = camera.CameraType
    oldCameraSubject = camera.CameraSubject
    camera.CameraType = Enum.CameraType.Scriptable
    local start = camera.CFrame
    local target = CFrame.lookAt(root.Position + root.CFrame.LookVector * 7 + Vector3.new(0, 2.5, 0), root.Position + Vector3.new(0, 1.5, 0))
    local inTween = TweenService:Create(camera, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = target})
    inTween:Play()
    inTween.Completed:Wait()
    task.wait(0.65)
    local outTween = TweenService:Create(camera, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {CFrame = start})
    outTween:Play()
    outTween.Completed:Wait()
    camera.CameraType = oldCameraType or Enum.CameraType.Custom
    camera.CameraSubject = oldCameraSubject or humanoid
    busy = false
end)

local function togglePanel()
    panel.Visible = not panel.Visible
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == CONFIG.ToggleKey then
        togglePanel()
        return
    end
    local keyMoves = {
        [Enum.KeyCode.Z] = "AlmightyAwakening",
        [Enum.KeyCode.X] = "AlmightySlash",
        [Enum.KeyCode.C] = "Auswahlen",
        [Enum.KeyCode.V] = "BlutVene",
        [Enum.KeyCode.B] = "Sklaverei",
    }
    local move = keyMoves[input.KeyCode]
    if move then playMove(move) end
end)

player.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    bindCharacter(char)
end)
if player.Character then bindCharacter(player.Character) end
