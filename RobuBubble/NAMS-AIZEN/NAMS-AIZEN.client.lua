-- NAMS-AIZEN.client.lua
-- Put this LocalScript in StarterPlayer/StarterPlayerScripts.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local root = ReplicatedStorage:WaitForChild("NAMS_AIZEN")
local Config = require(root:WaitForChild("Config"))
local AnimationManager = require(root:WaitForChild("AnimationManager"))
local AizenController = require(root:WaitForChild("AizenController"))
local RespawnController = require(root:WaitForChild("RespawnController"))

local currentController
local currentManager
local gui

local function cleanup()
    if currentController then currentController:Destroy() currentController = nil end
    if currentManager then currentManager:Destroy() currentManager = nil end
end

local function bindCharacter(character)
    cleanup()
    local humanoid = character:WaitForChild("Humanoid", 10)
    local folder = root:FindFirstChild(Config.AnimationFolderName)
    if not humanoid or not folder then
        warn("[NAM'S AIZEN] Humanoid or Animations folder missing")
        return
    end
    currentManager = AnimationManager.new(Config, folder, humanoid)
    currentController = AizenController.new(Config, currentManager, humanoid)
end

local respawn = RespawnController.new(player, bindCharacter, cleanup)

local function buildUI()
    if not Config.EnableMobileTestUI then return end
    local playerGui = player:WaitForChild("PlayerGui")
    gui = Instance.new("ScreenGui")
    gui.Name = "NAMS_AIZEN_UI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = false
    gui.Parent = playerGui

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.AnchorPoint = Vector2.new(1, 0.5)
    panel.Position = UDim2.new(1, -14, 0.55, 0)
    panel.Size = UDim2.fromOffset(156, 300)
    panel.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    panel.BackgroundTransparency = 0.08
    panel.BorderSizePixel = 0
    panel.Parent = gui
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -12, 0, 32)
    title.Position = UDim2.fromOffset(6, 4)
    title.BackgroundTransparency = 1
    title.Text = "NAM'S AIZEN"
    title.TextColor3 = Color3.fromRGB(210, 190, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = panel

    local actions = {"Idle", "Walk", "Run", "M1_1", "M1_2", "M1_3", "M1_4", "Skill_1", "Skill_2", "Domain"}
    for index, action in ipairs(actions) do
        local button = Instance.new("TextButton")
        button.Name = action
        button.Size = UDim2.new(0.5, -9, 0, 30)
        local column = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        button.Position = UDim2.new(0, 6 + column * 75, 0, 40 + row * 34)
        button.BackgroundColor3 = Color3.fromRGB(48, 42, 67)
        button.BorderSizePixel = 0
        button.Text = action
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextSize = 11
        button.Font = Enum.Font.GothamMedium
        button.Parent = panel
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)
        button.Activated:Connect(function()
            if currentController then
                currentController:PlayAction(action)
            end
        end)
    end

    local stop = Instance.new("TextButton")
    stop.Name = "Stop"
    stop.Position = UDim2.new(0, 6, 1, -34)
    stop.Size = UDim2.new(1, -12, 0, 28)
    stop.Text = "STOP ANIMATIONS"
    stop.BackgroundColor3 = Color3.fromRGB(100, 42, 50)
    stop.TextColor3 = Color3.new(1, 1, 1)
    stop.Font = Enum.Font.GothamBold
    stop.TextSize = 11
    stop.Parent = panel
    Instance.new("UICorner", stop).CornerRadius = UDim.new(0, 7)
    stop.Activated:Connect(function()
        if currentManager then
            currentManager:StopAll()
            if currentController then currentController.ManualAction = false end
        end
    end)
end

buildUI()
script.Destroying:Connect(function()
    respawn:Destroy()
    cleanup()
    if gui then gui:Destroy() end
end)