-- OP Fruit Finder — Delta-safe companion UI
-- This is a manual alert dashboard only. It does not inspect game internals,
-- teleport automatically, execute remote code, or modify player inventory.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
if not player then return end

local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("OPFruitFinder")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "OPFruitFinder"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local panel = make("Frame", {
    Name = "Panel", Size = UDim2.fromOffset(330, 390),
    Position = UDim2.new(0.5, -165, 0.5, -195),
    BackgroundColor3 = Color3.fromRGB(15, 16, 22), BorderSizePixel = 0
}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, panel)
make("UIStroke", {Color = Color3.fromRGB(139, 92, 246), Thickness = 1.4}, panel)

local title = make("TextLabel", {
    Size = UDim2.new(1, -48, 0, 38), Position = UDim2.fromOffset(14, 8),
    BackgroundTransparency = 1, Text = "OP FRUIT FINDER",
    TextColor3 = Color3.fromRGB(238, 232, 255), TextSize = 18,
    Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left
}, panel)

local close = make("TextButton", {
    Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -38, 0, 8),
    Text = "×", TextSize = 22, Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(255,255,255), BackgroundColor3 = Color3.fromRGB(48, 39, 65),
    BorderSizePixel = 0
}, panel)
make("UICorner", {CornerRadius = UDim.new(0, 8)}, close)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local function label(text, y)
    return make("TextLabel", {
        Size = UDim2.new(1, -28, 0, 20), Position = UDim2.fromOffset(14, y),
        BackgroundTransparency = 1, Text = text, TextColor3 = Color3.fromRGB(178, 174, 193),
        TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left
    }, panel)
end

local function textbox(placeholder, y, height)
    local box = make("TextBox", {
        Size = UDim2.new(1, -28, 0, height or 36), Position = UDim2.fromOffset(14, y),
        BackgroundColor3 = Color3.fromRGB(28, 29, 39), TextColor3 = Color3.fromRGB(245,245,250),
        PlaceholderColor3 = Color3.fromRGB(128,126,143), PlaceholderText = placeholder,
        Text = "", TextSize = 13, Font = Enum.Font.Gotham, ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0
    }, panel)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, box)
    make("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, box)
    return box
end

label("PASTE A FRUIT NOTIFIER ALERT", 54)
local alertBox = textbox("Example: Fruit=Kitsune | Rarity=Mythical | Sea=First | ServerId=...", 76, 54)
alertBox.TextWrapped = true
alertBox.TextYAlignment = Enum.TextYAlignment.Top

label("SERVER INSTANCE ID", 140)
local serverBox = textbox("Paste the server ID from your alert", 162, 36)

local status = label("Waiting for a manually pasted alert.", 208)
status.Size = UDim2.new(1, -28, 0, 34)
status.TextWrapped = true
status.TextYAlignment = Enum.TextYAlignment.Top

local function button(text, y)
    local b = make("TextButton", {
        Size = UDim2.new(1, -28, 0, 36), Position = UDim2.fromOffset(14, y),
        BackgroundColor3 = Color3.fromRGB(104, 67, 180), TextColor3 = Color3.new(1,1,1),
        Text = text, TextSize = 13, Font = Enum.Font.GothamBold, BorderSizePixel = 0
    }, panel)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, b)
    return b
end

local parseButton = button("VALIDATE ALERT", 250)
local linkButton = button("COPY SERVER JOIN LINK", 294)
local clearButton = button("CLEAR", 338)

local currentLink = nil
local function extract(text, key)
    local pattern = key .. "%s*[:=]%s*([^|,\n]+)"
    return text:match(pattern)
end

parseButton.MouseButton1Click:Connect(function()
    local raw = alertBox.Text
    local fruit = extract(raw, "[Ff]ruit") or extract(raw, "[Ff]ruit [Nn]ame")
    local rarity = extract(raw, "[Rr]arity")
    local sea = extract(raw, "[Ss]ea")
    local serverId = extract(raw, "[Ss]erver[Ii][Dd]") or extract(raw, "[Ss]erver [Ii][Dd]")
    if serverId and serverBox.Text == "" then serverBox.Text = serverId:gsub("%s+$", "") end
    local id = serverBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if not fruit or not rarity or not sea or id == "" then
        status.TextColor3 = Color3.fromRGB(255, 174, 95)
        status.Text = "Alert format incomplete. Include Fruit, Rarity, Sea and ServerId."
        currentLink = nil
        return
    end
    rarity = rarity:gsub("%s+$", "")
    sea = sea:gsub("%s+$", "")
    if rarity:lower() ~= "legendary" and rarity:lower() ~= "mythical" then
        status.TextColor3 = Color3.fromRGB(255, 110, 110)
        status.Text = "Filtered out: rarity is not Legendary or Mythical."
        currentLink = nil
        return
    end
    if sea:lower() ~= "first" and sea:lower() ~= "first sea" then
        status.TextColor3 = Color3.fromRGB(255, 110, 110)
        status.Text = "Filtered out: alert is not from the First Sea."
        currentLink = nil
        return
    end
    if not id:match("^[%w%-]+$") then
        status.TextColor3 = Color3.fromRGB(255, 110, 110)
        status.Text = "Invalid server ID. Use only letters, numbers and hyphens."
        currentLink = nil
        return
    end
    currentLink = "https://www.roblox.com/games/start?placeId=2753915549&gameInstanceId=" .. id
    status.TextColor3 = Color3.fromRGB(130, 235, 170)
    status.Text = "MATCH: " .. fruit .. " (" .. rarity .. ") — First Sea. Join link prepared."
end)

linkButton.MouseButton1Click:Connect(function()
    if not currentLink then
        status.TextColor3 = Color3.fromRGB(255, 174, 95)
        status.Text = "Validate a matching alert first."
        return
    end
    if typeof(setclipboard) == "function" then
        setclipboard(currentLink)
        status.Text = "Join link copied. Open it manually in Roblox."
    else
        status.Text = "Clipboard API unavailable. Link: " .. currentLink
    end
end)

clearButton.MouseButton1Click:Connect(function()
    alertBox.Text = ""
    serverBox.Text = ""
    currentLink = nil
    status.TextColor3 = Color3.fromRGB(178, 174, 193)
    status.Text = "Waiting for a manually pasted alert."
end)
