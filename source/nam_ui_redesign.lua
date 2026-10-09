-- NAM UI Redesign (safe standalone Roblox Studio UI)
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.
-- This file only creates a UI; it does not implement character reanimation or exploit APIs.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("NAM_Redesign")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "NAM_Redesign"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 20
gui.Parent = playerGui

local root = Instance.new("Frame")
root.Name = "Window"
root.AnchorPoint = Vector2.new(0.5, 0.5)
root.Position = UDim2.fromScale(0.5, 0.5)
root.Size = UDim2.new(0.88, 0, 0.68, 0)
root.BackgroundColor3 = Color3.fromRGB(15, 16, 19)
root.BorderSizePixel = 0
root.Parent = gui
Instance.new("UICorner", root).CornerRadius = UDim.new(0, 12)

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(300, 250)
sizeConstraint.MaxSize = Vector2.new(680, 460)
sizeConstraint.Parent = root

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(153, 255, 58)
stroke.Thickness = 2
stroke.Parent = root

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = root

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)
layout.Parent = root

local function makeLabel(parent, name, text, height, fontSize)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Size = UDim2.new(1, 0, 0, height)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240, 242, 245)
    label.TextSize = fontSize
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local header = Instance.new("Frame")
header.Name = "Header"
header.LayoutOrder = 1
header.Size = UDim2.new(1, 0, 0, 34)
header.BackgroundTransparency = 1
header.Parent = root

local title = makeLabel(header, "Title", "NAM", 34, 21)
title.Size = UDim2.new(1, -48, 1, 0)
title.Position = UDim2.fromOffset(2, 0)

local close = Instance.new("TextButton")
close.Name = "Close"
close.Size = UDim2.fromOffset(42, 34)
close.Position = UDim2.new(1, -42, 0, 0)
close.Text = "×"
close.TextSize = 26
close.Font = Enum.Font.Gotham
close.TextColor3 = Color3.fromRGB(240, 242, 245)
close.BackgroundColor3 = Color3.fromRGB(38, 40, 45)
close.AutoButtonColor = true
close.Parent = header
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
close.Activated:Connect(function() root.Visible = false end)

local tabs = Instance.new("Frame")
tabs.Name = "Tabs"
tabs.LayoutOrder = 2
tabs.Size = UDim2.new(1, 0, 0, 42)
tabs.BackgroundTransparency = 1
tabs.Parent = root

local tabLayout = Instance.new("UIGridLayout")
tabLayout.CellPadding = UDim2.fromOffset(6, 0)
tabLayout.CellSize = UDim2.new(0.25, -5, 1, 0)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabs

local content = Instance.new("Frame")
content.Name = "Content"
content.LayoutOrder = 3
content.Size = UDim2.new(1, 0, 1, -92)
content.BackgroundColor3 = Color3.fromRGB(23, 24, 28)
content.BorderSizePixel = 0
content.Parent = root
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 9)

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 12)
contentPadding.PaddingBottom = UDim.new(0, 12)
contentPadding.PaddingLeft = UDim.new(0, 12)
contentPadding.PaddingRight = UDim.new(0, 12)
contentPadding.Parent = content

local pages = {}
local tabButtons = {}
local currentTab

local function addAction(parent, labelText, callback)
    local button = Instance.new("TextButton")
    button.Name = labelText:gsub("%W", "") .. "Button"
    button.Size = UDim2.new(1, 0, 0, 42)
    button.BackgroundColor3 = Color3.fromRGB(42, 45, 51)
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Text = labelText
    button.TextColor3 = Color3.fromRGB(245, 246, 248)
    button.TextSize = 15
    button.Font = Enum.Font.Gotham
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)
    button.Activated:Connect(callback or function()
        print("[NAM UI] Selected: " .. labelText)
    end)
    return button
end

local function createPage(name, description)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new()
    page.Visible = false
    page.Parent = content

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = page

    makeLabel(page, "Description", description, 34, 14)
    pages[name] = page
    return page
end

local function selectTab(name)
    if not pages[name] then return end
    currentTab = name
    for tabName, page in pairs(pages) do
        page.Visible = tabName == name
    end
    for tabName, button in pairs(tabButtons) do
        local selected = tabName == name
        button.BackgroundColor3 = selected and Color3.fromRGB(184, 255, 67) or Color3.fromRGB(39, 41, 46)
        button.TextColor3 = selected and Color3.fromRGB(17, 19, 14) or Color3.fromRGB(235, 237, 240)
    end
end

local tabNames = {"Anims", "Limbs", "Hitboxes", "Settings"}
for index, name in ipairs(tabNames) do
    local button = Instance.new("TextButton")
    button.Name = name .. "Tab"
    button.LayoutOrder = index
    button.BackgroundColor3 = Color3.fromRGB(39, 41, 46)
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Text = name
    button.TextSize = 13
    button.TextScaled = true
    button.Font = Enum.Font.GothamMedium
    button.TextColor3 = Color3.fromRGB(235, 237, 240)
    button.Parent = tabs
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)
    local textConstraint = Instance.new("UITextSizeConstraint")
    textConstraint.MinTextSize = 11
    textConstraint.MaxTextSize = 15
    textConstraint.Parent = button
    tabButtons[name] = button
    button.Activated:Connect(function() selectTab(name) end)
end

local animPage = createPage("Anims", "Animation controls")
addAction(animPage, "Play (connect your own animation)", function()
    print("[NAM UI] Add your own authorized animation logic here.")
end)
addAction(animPage, "Stop (connect your own animation)", function()
    print("[NAM UI] Add your own authorized animation stop logic here.")
end)

local limbsPage = createPage("Limbs", "Limb options")
addAction(limbsPage, "Refresh limb list", function()
    print("[NAM UI] Limb list refreshed.")
end)

local hitboxesPage = createPage("Hitboxes", "Hitbox visualization options")
addAction(hitboxesPage, "Toggle debug display", function()
    print("[NAM UI] Connect this button to your own Studio debug visualization.")
end)

local settingsPage = createPage("Settings", "Interface preferences")
addAction(settingsPage, "Hide window", function() root.Visible = false end)
addAction(settingsPage, "Reset window position", function()
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.Position = UDim2.fromScale(0.5, 0.5)
end)

-- Responsive sizing: preserve a usable tap target on phones and tablets.
local function updateForViewport()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    if viewport.X < 600 then
        root.Size = UDim2.new(0.94, 0, 0.62, 0)
    else
        root.Size = UDim2.new(0.78, 0, 0.68, 0)
    end
end
updateForViewport()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateForViewport)
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(updateForViewport)

selectTab("Anims")
