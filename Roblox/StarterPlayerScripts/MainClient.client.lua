--!strict
-- RobuNexa Mobile Game Hub UI
-- Responsive: 16:9 desktop/tablet canvas + full-screen portrait/mobile fallback.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function loadModule(name: string)
    local ok, value = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild(name, 10))
    end)
    if not ok then
        warn("[RobuNexa UI] Failed to load " .. name .. ": " .. tostring(value))
        return nil
    end
    return value
end

local Config = loadModule("GameConfig")
local Theme = loadModule("UITheme")
local Anim = loadModule("Anim")
local Fx = loadModule("FxKit")
local Remotes = loadModule("Remotes")

if not Config or not Theme or not Anim or not Fx or not Remotes then
    return
end

local C = {
    BG = Color3.fromRGB(18, 18, 21),
    PANEL = Color3.fromRGB(31, 30, 34),
    PANEL_2 = Color3.fromRGB(40, 38, 42),
    CREAM = Theme.Cream,
    ORANGE = Theme.Orange,
    WHITE = Theme.White,
    MUTED = Theme.Muted,
    GREEN = Theme.Success,
    RED = Theme.Danger,
    BLACK = Color3.fromRGB(8, 8, 10),
}

local gui = Instance.new("ScreenGui")
gui.Name = "MobileGameHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 50
pcall(function()
    gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
end)
gui.Parent = playerGui

local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.fromScale(1, 1)
root.BackgroundColor3 = C.BG
root.BorderSizePixel = 0
root.Parent = gui

local stage = Instance.new("Frame")
stage.Name = "Stage"
stage.AnchorPoint = Vector2.new(0.5, 0.5)
stage.Position = UDim2.fromScale(0.5, 0.5)
stage.Size = UDim2.new(1, -24, 1, -24)
stage.BackgroundColor3 = C.BG
stage.BorderSizePixel = 0
stage.Parent = root

local stageAspect = Instance.new("UIAspectRatioConstraint")
stageAspect.Name = "Desktop16x9"
stageAspect.AspectRatio = 16 / 9
stageAspect.DominantAxis = Enum.DominantAxis.Width
stageAspect.Parent = stage

local stageSize = Instance.new("UISizeConstraint")
stageSize.MinSize = Vector2.new(0, 0)
stageSize.MaxSize = Vector2.new(1600, 900)
stageSize.Parent = stage

local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = stage

local function updateLayout()
    local viewport = root.AbsoluteSize
    if viewport.X <= 1 or viewport.Y <= 1 then
        return
    end

    local ratio = viewport.X / math.max(viewport.Y, 1)
    if ratio < 1.45 then
        -- Portrait/mobile: use the whole safe area instead of letterboxing.
        stageAspect.Enabled = false
        stage.Size = UDim2.new(1, -20, 1, -20)
        stage.Position = UDim2.fromScale(0.5, 0.5)
    else
        -- Desktop/tablet: preserve a clean 16:9 composition.
        stageAspect.Enabled = true
        stage.Size = UDim2.new(1, -24, 1, -24)
        stage.Position = UDim2.fromScale(0.5, 0.5)
    end
end

root:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout)
task.defer(updateLayout)

local function corner(parent: Instance, radius: number)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function stroke(parent: Instance, color: Color3, transparency: number?, thickness: number?)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = transparency or 0
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function label(parent: Instance, text: string, pos: UDim2, size: UDim2, textSize: number, color: Color3?, bold: boolean?)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or C.WHITE
    l.Font = bold == false and Enum.Font.Gotham or Enum.Font.GothamBold
    l.TextSize = textSize
    l.TextWrapped = true
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Position = pos
    l.Size = size
    l.Parent = parent
    local constraint = Instance.new("UITextSizeConstraint")
    constraint.MinTextSize = math.max(10, math.floor(textSize * 0.62))
    constraint.MaxTextSize = textSize
    constraint.Parent = l
    return l
end

local function centerLabel(parent: Instance, text: string, pos: UDim2, size: UDim2, textSize: number, color: Color3?, bold: boolean?)
    local l = label(parent, text, pos, size, textSize, color, bold)
    l.TextXAlignment = Enum.TextXAlignment.Center
    l.TextYAlignment = Enum.TextYAlignment.Center
    return l
end

local function button(parent: Instance, text: string, pos: UDim2, size: UDim2, primary: boolean?)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.Active = true
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 20
    b.TextColor3 = primary and C.BLACK or C.CREAM
    b.BackgroundColor3 = primary and C.CREAM or C.PANEL_2
    b.BorderSizePixel = 0
    b.Position = pos
    b.Size = size
    b.Parent = parent
    corner(b, 14)
    if not primary then
        stroke(b, C.CREAM, 0.82, 1)
    end
    Anim.Button(b)
    return b
end

local function panel(parent: Instance, pos: UDim2, size: UDim2, color: Color3?)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = color or C.PANEL
    f.BorderSizePixel = 0
    f.Position = pos
    f.Size = size
    f.Parent = parent
    corner(f, 18)
    stroke(f, C.WHITE, 0.94, 1)
    return f
end

local screens: {[string]: Frame} = {}
for _, name in ipairs({"Boot", "Home", "Games", "Leaderboard", "Stats", "Settings", "GameOver"}) do
    local f = Instance.new("Frame")
    f.Name = name
    f.Size = UDim2.fromScale(1, 1)
    f.BackgroundTransparency = 1
    f.Visible = false
    f.Parent = stage
    screens[name] = f
end

local function show(name: string)
    for key, frame in pairs(screens) do
        frame.Visible = key == name
    end
end

local function header(parent: Instance, titleText: string, subtitle: string?)
    label(parent, titleText, UDim2.new(0, 34, 0, 24), UDim2.new(0.7, 0, 0, 48), 30, C.CREAM, true)
    if subtitle then
        label(parent, subtitle, UDim2.new(0, 36, 0, 68), UDim2.new(0.78, 0, 0, 30), 14, C.MUTED, false)
    end
end

local function backButton(parent: Instance)
    local b = button(parent, "←  HUB", UDim2.new(0, 34, 1, -72), UDim2.new(0, 150, 0, 48), false)
    b.Activated:Connect(function()
        show("Home")
    end)
    return b
end

-- BOOT
do
    local s = screens.Boot
    centerLabel(s, "ROBUNEXA", UDim2.new(0.1, 0, 0.30, 0), UDim2.new(0.8, 0, 0, 72), 46, C.CREAM, true)
    centerLabel(s, "MOBILE GAME HUB", UDim2.new(0.1, 0, 0.42, 0), UDim2.new(0.8, 0, 0, 42), 22, C.ORANGE, true)
    centerLabel(s, "10 mini oyun • tek dokunuş • ücretsiz", UDim2.new(0.1, 0, 0.51, 0), UDim2.new(0.8, 0, 0, 32), 15, C.MUTED, false)

    local bar = panel(s, UDim2.new(0.25, 0, 0.63, 0), UDim2.new(0.5, 0, 0, 8), C.PANEL_2)
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = C.ORANGE
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.Parent = bar
    corner(fill, 8)
    TweenService:Create(fill, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {Size = UDim2.fromScale(1, 1)}):Play()
end

-- HOME
do
    local s = screens.Home
    header(s, "GAME HUB", "Hızlı başla. Skorunu yükselt. Her run yeni bir meydan okuma.")

    local hero = panel(s, UDim2.new(0.04, 0, 0.18, 0), UDim2.new(0.92, 0, 0.40, 0), C.PANEL)
    label(hero, "10", UDim2.new(0.05, 0, 0.12, 0), UDim2.new(0.18, 0, 0.34, 0), 72, C.ORANGE, true)
    label(hero, "FARKLI OYUN", UDim2.new(0.05, 0, 0.50, 0), UDim2.new(0.30, 0, 0.16, 0), 16, C.CREAM, true)
    label(hero, "Refleks, hafıza, ritim, kaçış ve daha fazlası.", UDim2.new(0.32, 0, 0.17, 0), UDim2.new(0.62, 0, 0.25, 0), 23, C.CREAM, true)
    label(hero, "Kısa round'lar • server doğrulamalı skor • global leaderboard", UDim2.new(0.32, 0, 0.45, 0), UDim2.new(0.62, 0, 0.18, 0), 14, C.MUTED, false)

    local play = button(hero, "OYNA  →", UDim2.new(0.32, 0, 0.68, 0), UDim2.new(0.32, 0, 0, 58), true)
    play.Activated:Connect(function()
        show("Games")
    end)

    local quick = panel(s, UDim2.new(0.04, 0, 0.62, 0), UDim2.new(0.92, 0, 0.21, 0), C.PANEL)
    centerLabel(quick, "NO ROBUX • NO ADS • FREE", UDim2.new(0.03, 0, 0.12, 0), UDim2.new(0.28, 0, 0.32, 0), 17, C.GREEN, true)
    centerLabel(quick, "TOP 10", UDim2.new(0.36, 0, 0.12, 0), UDim2.new(0.28, 0, 0.32, 0), 17, C.CREAM, true)
    centerLabel(quick, "MOBILE FIRST", UDim2.new(0.69, 0, 0.12, 0), UDim2.new(0.28, 0, 0.32, 0), 17, C.ORANGE, true)
    centerLabel(quick, "10", UDim2.new(0.03, 0, 0.48, 0), UDim2.new(0.28, 0, 0.32, 0), 26, C.CREAM, true)
    centerLabel(quick, "oyun", UDim2.new(0.36, 0, 0.48, 0), UDim2.new(0.28, 0, 0.32, 0), 26, C.CREAM, true)
    centerLabel(quick, "16:9", UDim2.new(0.69, 0, 0.48, 0), UDim2.new(0.28, 0, 0.32, 0), 26, C.CREAM, true)

    local navY = UDim2.new(0, 0, 1, -54)
    local games = button(s, "OYUNLAR", UDim2.new(0.04, 0, navY.Y.Scale, navY.Y.Offset), UDim2.new(0.21, 0, 0, 42), false)
    local board = button(s, "LEADERBOARD", UDim2.new(0.27, 0, navY.Y.Scale, navY.Y.Offset), UDim2.new(0.23, 0, 0, 42), false)
    local stats = button(s, "STATS", UDim2.new(0.52, 0, navY.Y.Scale, navY.Y.Offset), UDim2.new(0.18, 0, 0, 42), false)
    local settings = button(s, "AYAR", UDim2.new(0.72, 0, navY.Y.Scale, navY.Y.Offset), UDim2.new(0.18, 0, 0, 42), false)
    games.Activated:Connect(function() show("Games") end)
    board.Activated:Connect(function()
        show("Leaderboard")
        Remotes.RequestLeaderboard:FireServer({GameId = Config.Games[1].Id})
    end)
    stats.Activated:Connect(function() show("Stats") end)
    settings.Activated:Connect(function() show("Settings") end)
end

-- GAMES
local selectedGame = nil
do
    local s = screens.Games
    header(s, "OYUNLAR", "Bir karta dokun ve round'u başlat.")

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "GameList"
    scroll.Position = UDim2.new(0.04, 0, 0.17, 0)
    scroll.Size = UDim2.new(0.92, 0, 0.70, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 5
    scroll.ScrollBarImageColor3 = C.ORANGE
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = s

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0.48, 0, 0, 118)
    grid.CellPadding = UDim2.new(0.02, 0, 0, 12)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = scroll

    local aspect = Instance.new("UIAspectRatioConstraint")
    aspect.AspectRatio = 2.2
    aspect.Parent = grid

    for index, gameDef in ipairs(Config.Games) do
        local card = Instance.new("TextButton")
        card.Name = gameDef.Id
        card.Text = ""
        card.AutoButtonColor = false
        card.BackgroundColor3 = C.PANEL
        card.BorderSizePixel = 0
        card.LayoutOrder = index
        card.Parent = scroll
        corner(card, 16)
        stroke(card, C.WHITE, 0.93, 1)
        Anim.Button(card)

        local number = centerLabel(card, string.format("%02d", index), UDim2.new(0, 12, 0, 12), UDim2.new(0, 52, 0, 42), 20, C.ORANGE, true)
        number.BackgroundColor3 = C.PANEL_2
        number.BackgroundTransparency = 0
        corner(number, 10)

        label(card, gameDef.Name, UDim2.new(0, 78, 0, 10), UDim2.new(1, -90, 0, 30), 19, C.CREAM, true)
        label(card, gameDef.Description, UDim2.new(0, 78, 0, 44), UDim2.new(1, -90, 0, 38), 12, C.MUTED, false)
        label(card, string.format("%ds  •  MAX %d", gameDef.Duration, gameDef.MaxScore), UDim2.new(0, 78, 1, -30), UDim2.new(1, -90, 0, 20), 11, C.ORANGE, true)

        card.Activated:Connect(function()
            selectedGame = gameDef
            Remotes.RequestStart:FireServer({GameId = gameDef.Id})
        end)
    end

    backButton(s)
end

-- LEADERBOARD
local leaderboardText
do
    local s = screens.Leaderboard
    header(s, "GLOBAL LEADERBOARD", "En yüksek skorlar • seçilen oyuna göre.")

    local picker = Instance.new("ScrollingFrame")
    picker.Position = UDim2.new(0.04, 0, 0.16, 0)
    picker.Size = UDim2.new(0.92, 0, 0, 50)
    picker.BackgroundTransparency = 1
    picker.BorderSizePixel = 0
    picker.ScrollBarThickness = 0
    picker.CanvasSize = UDim2.new(0, 0, 0, 0)
    picker.AutomaticCanvasSize = Enum.AutomaticSize.X
    picker.Parent = s

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 8)
    layout.Parent = picker

    for _, gameDef in ipairs(Config.Games) do
        local b = button(picker, gameDef.Name, UDim2.new(), UDim2.new(0, 150, 0, 44), false)
        b.Activated:Connect(function()
            Remotes.RequestLeaderboard:FireServer({GameId = gameDef.Id})
        end)
    end

    local board = panel(s, UDim2.new(0.04, 0, 0.25, 0), UDim2.new(0.92, 0, 0.58, 0), C.PANEL)
    leaderboardText = Instance.new("TextLabel")
    leaderboardText.BackgroundTransparency = 1
    leaderboardText.Text = "Bir oyun seç..."
    leaderboardText.TextColor3 = C.CREAM
    leaderboardText.Font = Enum.Font.GothamBold
    leaderboardText.TextSize = 18
    leaderboardText.TextWrapped = true
    leaderboardText.TextXAlignment = Enum.TextXAlignment.Left
    leaderboardText.TextYAlignment = Enum.TextYAlignment.Top
    leaderboardText.Position = UDim2.new(0, 22, 0, 18)
    leaderboardText.Size = UDim2.new(1, -44, 1, -36)
    leaderboardText.Parent = board

    backButton(s)
end

-- STATS
do
    local s = screens.Stats
    header(s, "İSTATİSTİKLER", "Skor geçmişin server tarafından kaydedilir.")

    local a = panel(s, UDim2.new(0.04, 0, 0.20, 0), UDim2.new(0.28, 0, 0.22, 0), C.PANEL)
    local b = panel(s, UDim2.new(0.36, 0, 0.20, 0), UDim2.new(0.28, 0, 0.22, 0), C.PANEL)
    local c = panel(s, UDim2.new(0.68, 0, 0.20, 0), UDim2.new(0.28, 0, 0.22, 0), C.PANEL)
    centerLabel(a, "10", UDim2.new(0, 0, 0.12, 0), UDim2.fromScale(1, 0.48), 38, C.ORANGE, true)
    centerLabel(a, "OYUN", UDim2.new(0, 0, 0.56, 0), UDim2.fromScale(1, 0.25), 13, C.MUTED, true)
    centerLabel(b, "TOP 10", UDim2.new(0, 0, 0.12, 0), UDim2.fromScale(1, 0.48), 28, C.CREAM, true)
    centerLabel(b, "GLOBAL", UDim2.new(0, 0, 0.56, 0), UDim2.fromScale(1, 0.25), 13, C.MUTED, true)
    centerLabel(c, "∞", UDim2.new(0, 0, 0.12, 0), UDim2.fromScale(1, 0.48), 38, C.GREEN, true)
    centerLabel(c, "DENEME", UDim2.new(0, 0, 0.56, 0), UDim2.fromScale(1, 0.25), 13, C.MUTED, true)

    local note = panel(s, UDim2.new(0.04, 0, 0.48, 0), UDim2.new(0.92, 0, 0.25, 0), C.PANEL)
    centerLabel(note, "Her oyun kendi best skorunu ve leaderboard kaydını tutar.", UDim2.new(0.05, 0, 0.22, 0), UDim2.new(0.90, 0, 0.30, 0), 18, C.CREAM, true)
    centerLabel(note, "DataStore kapalıysa oyun yine çalışır; skor kayıtları yayınlanmış deneyimde aktif olur.", UDim2.new(0.05, 0, 0.54, 0), UDim2.new(0.90, 0, 0.24, 0), 12, C.MUTED, false)

    backButton(s)
end

-- SETTINGS
do
    local s = screens.Settings
    header(s, "AYARLAR", "Mobil ve masaüstü için temel tercihler.")

    local soundOn = true
    local soundButton = button(s, "SES  •  AÇIK", UDim2.new(0.08, 0, 0.22, 0), UDim2.new(0.84, 0, 0, 60), true)
    soundButton.Activated:Connect(function()
        soundOn = not soundOn
        soundButton.Text = "SES  •  " .. (soundOn and "AÇIK" or "KAPALI")
        soundButton.BackgroundColor3 = soundOn and C.CREAM or C.PANEL_2
        soundButton.TextColor3 = soundOn and C.BLACK or C.CREAM
    end)

    local info = panel(s, UDim2.new(0.08, 0, 0.34, 0), UDim2.new(0.84, 0, 0.28, 0), C.PANEL)
    label(info, "UI", UDim2.new(0.06, 0, 0.12, 0), UDim2.new(0.22, 0, 0, 30), 16, C.ORANGE, true)
    label(info, "16:9 responsive canvas", UDim2.new(0.29, 0, 0.12, 0), UDim2.new(0.62, 0, 0, 30), 16, C.CREAM, true)
    label(info, "Safe-area aware", UDim2.new(0.29, 0, 0.38, 0), UDim2.new(0.62, 0, 0, 30), 16, C.CREAM, true)
    label(info, "Touch-friendly buttons", UDim2.new(0.29, 0, 0.64, 0), UDim2.new(0.62, 0, 0, 30), 16, C.CREAM, true)

    backButton(s)
end

-- GAME HUD
local hud = Instance.new("Frame")
hud.Name = "GameHUD"
hud.Size = UDim2.fromScale(1, 1)
hud.BackgroundTransparency = 1
hud.Visible = false
hud.Parent = stage

local hudTop = panel(hud, UDim2.new(0.04, 0, 0.04, 0), UDim2.new(0.92, 0, 0, 78), C.PANEL)
local hudGame = label(hudTop, "GAME", UDim2.new(0, 18, 0, 8), UDim2.new(0.42, 0, 0, 28), 17, C.CREAM, true)
local hudScore = centerLabel(hudTop, "0", UDim2.new(0.42, 0, 0, 6), UDim2.new(0.20, 0, 0, 34), 25, C.CREAM, true)
local hudCombo = centerLabel(hudTop, "x1", UDim2.new(0.65, 0, 0, 8), UDim2.new(0.14, 0, 0, 28), 17, C.ORANGE, true)
local hudTimer = centerLabel(hudTop, "00", UDim2.new(0.82, 0, 0, 8), UDim2.new(0.14, 0, 0, 28), 17, C.GREEN, true)

local instruction = centerLabel(hud, "TAP", UDim2.new(0.08, 0, 0.19, 0), UDim2.new(0.84, 0, 0, 46), 20, C.CREAM, true)

local tap = button(hud, "TAP!", UDim2.new(0.10, 0, 0.64, 0), UDim2.new(0.80, 0, 0, 92), true)
tap.TextSize = 32

local countdown = centerLabel(hud, "3", UDim2.new(0.15, 0, 0.37, 0), UDim2.new(0.70, 0, 0, 120), 76, C.ORANGE, true)
countdown.Visible = false

local currentGame = nil
local countdownToken = 0

local function actionPayload()
    if not currentGame then
        return {Action = "tap"}
    end

    local id = currentGame.Id
    if id == "DodgeRun" then
        return {Action = "lane", Value = math.random(1, 5)}
    elseif id == "TargetRush" then
        return {Action = "tapTarget", Value = math.random(1, 9)}
    elseif id == "StackTower" then
        return {Action = "place", Value = math.random(-10, 10) / 10}
    elseif id == "CoinRush" then
        return {Action = "coin", Value = math.random(1, 12)}
    elseif id == "JumpChallenge" or id == "FallingPlatforms" then
        return {Action = "jump"}
    elseif id == "ReactionTest" then
        return {Action = "react"}
    elseif id == "ColorRush" then
        local colors = {"Red", "Blue", "Green", "Yellow"}
        return {Action = "color", Value = colors[math.random(1, #colors)]}
    elseif id == "MemoryMatch" then
        return {Action = "card", Value = math.random(1, 6)}
    elseif id == "FloorIsLava" then
        return {Action = "safe", Value = math.random(1, 6)}
    end
    return {Action = "tapTarget"}
end

tap.Activated:Connect(function()
    if not currentGame then
        return
    end

    Remotes.RequestAction:FireServer(actionPayload())

    local camera = workspace.CurrentCamera
    if camera then
        Fx.Punch(camera)
    end
    Fx.Popup(gui, "+", UDim2.fromScale(0.45, 0.58), C.ORANGE)
end)

local function runCountdown()
    countdownToken += 1
    local token = countdownToken
    countdown.Visible = true

    for _, value in ipairs({"3", "2", "1", "GO!"}) do
        if token ~= countdownToken then
            return
        end
        countdown.Text = value
        countdown.TextTransparency = 0
        countdown.Size = UDim2.new(0.70, 0, 0, 120)
        TweenService:Create(countdown, TweenInfo.new(0.22, Enum.EasingStyle.Back), {
            Size = UDim2.new(0.78, 0, 0, 140)
        }):Play()
        task.wait(value == "GO!" and 0.45 or 0.85)
    end

    countdown.Visible = false
end

Remotes.GameStateChanged.OnClientEvent:Connect(function(payload)
    if typeof(payload) ~= "table" or typeof(payload.State) ~= "string" then
        return
    end

    if payload.State == "Started" then
        currentGame = Config.GetGame(payload.GameId)
        if not currentGame then
            return
        end

        hudGame.Text = string.upper(currentGame.Name)
        instruction.Text = currentGame.Description
        hudScore.Text = "0"
        hudCombo.Text = "x1"
        hudTimer.Text = tostring(currentGame.Duration)
        hud.Visible = true
        for _, screen in pairs(screens) do
            screen.Visible = false
        end
        task.spawn(runCountdown)

    elseif payload.State == "Score" then
        hudScore.Text = tostring(math.floor(tonumber(payload.Score) or 0))
        hudCombo.Text = "x" .. tostring(tonumber(payload.Multiplier) or 1)

    elseif payload.State == "Finished" then
        countdownToken += 1
        countdown.Visible = false
        hud.Visible = false

        local scoreValue = math.floor(tonumber(payload.Score) or 0)
        local over = screens.GameOver
        local result = over:FindFirstChild("Result")
        if result and result:IsA("TextLabel") then
            result.Text = string.format("%s\n%06d", currentGame and string.upper(currentGame.Name) or "RUN", scoreValue)
        end

        show("GameOver")
        currentGame = nil
    end
end)

-- GAME OVER
do
    local s = screens.GameOver
    header(s, "RUN BİTTİ", "Sonucun kaydedildi.")

    local resultPanel = panel(s, UDim2.new(0.16, 0, 0.24, 0), UDim2.new(0.68, 0, 0.28, 0), C.PANEL)
    local result = centerLabel(resultPanel, "RUN\n000000", UDim2.new(0.05, 0, 0.08, 0), UDim2.new(0.90, 0, 0.84, 0), 34, C.CREAM, true)
    result.Name = "Result"

    local again = button(s, "TEKRAR OYNA", UDim2.new(0.16, 0, 0.58, 0), UDim2.new(0.68, 0, 0, 56), true)
    again.Activated:Connect(function()
        show("Games")
    end)

    local home = button(s, "HUB'A DÖN", UDim2.new(0.16, 0, 0.69, 0), UDim2.new(0.68, 0, 0, 50), false)
    home.Activated:Connect(function()
        show("Home")
    end)
end

Remotes.LeaderboardResult.OnClientEvent:Connect(function(payload)
    if typeof(payload) ~= "table" or typeof(payload.Top) ~= "table" then
        return
    end

    local lines = {}
    for _, entry in ipairs(payload.Top) do
        table.insert(lines, string.format("#%02d    %s    %d", tonumber(entry.Rank) or 0, tostring(entry.UserId), tonumber(entry.Score) or 0))
    end
    table.insert(lines, "")
    table.insert(lines, "SENİN RANK: " .. tostring(payload.Rank or "-"))

    if leaderboardText then
        leaderboardText.Text = table.concat(lines, "\n")
    end
end)

show("Boot")
task.delay(1.0, function()
    if screens.Boot.Visible then
        show("Home")
    end
end)
