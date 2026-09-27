-- Astra AI Studio Bridge
-- Install as a Studio plugin. It connects the Astra web app to Roblox Studio.
-- It never uses loadstring or executes arbitrary AI code.
local HttpService = game:GetService("HttpService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local StudioService = game:GetService("StudioService")

local ENDPOINT = "https://astra-ai-studio.hatchable.site/api/roblox-agent"

local toolbar = plugin:CreateToolbar("Astra AI")
local button = toolbar:CreateButton("Astra", "Open Astra AI Roblox Agent", "")
button.ClickableWhenViewportHidden = true

local info = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Float,
    true, true, 420, 560, 320, 420
)
local widget = plugin:CreateDockWidgetPluginGui("AstraRobloxAgent", info)
widget.Title = "Astra AI — Roblox Studio"
widget.Enabled = false

local root = Instance.new("Frame")
root.Size = UDim2.fromScale(1,1)
root.BackgroundColor3 = Color3.fromRGB(18,20,26)
root.Parent = widget

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0,12)
padding.PaddingBottom = UDim.new(0,12)
padding.PaddingLeft = UDim.new(0,12)
padding.PaddingRight = UDim.new(0,12)
padding.Parent = root

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,28)
title.BackgroundTransparency = 1
title.Text = "Astra AI Roblox Agent"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = root

local prompt = Instance.new("TextBox")
prompt.Position = UDim2.new(0,0,0,42)
prompt.Size = UDim2.new(1,0,0,120)
prompt.BackgroundColor3 = Color3.fromRGB(28,31,40)
prompt.TextColor3 = Color3.new(1,1,1)
prompt.PlaceholderText = "Örn: Gojo için 4 skill ve sağ tarafta mobil uyumlu skill GUI oluştur."
prompt.TextWrapped = true
prompt.TextYAlignment = Enum.TextYAlignment.Top
prompt.ClearTextOnFocus = false
prompt.TextSize = 14
prompt.MultiLine = true
prompt.Parent = root

local run = Instance.new("TextButton")
run.Position = UDim2.new(0,0,0,174)
run.Size = UDim2.new(1,0,0,38)
run.BackgroundColor3 = Color3.fromRGB(90,75,220)
run.TextColor3 = Color3.new(1,1,1)
run.Text = "Astra ile oluştur"
run.TextSize = 14
run.Font = Enum.Font.GothamBold
run.Parent = root

local status = Instance.new("TextLabel")
status.Position = UDim2.new(0,0,0,222)
status.Size = UDim2.new(1,0,0,70)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(190,195,210)
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Top
status.Text = "Hazır."
status.TextSize = 12
status.Parent = root

local function findService(name)
    return game:GetService(name)
end

local function findOrCreateFolder(parent, name)
    local existing = parent:FindFirstChild(name)
    if existing then return existing end
    local f = Instance.new("Folder")
    f.Name = name
    f.Parent = parent
    return f
end

local function applyAction(a)
    if a.type == "create_folder" then
        local parent = findService(a.service)
        findOrCreateFolder(parent, a.name)
        return "Klasör: "..a.service.."/"..a.name
    end

    if a.type == "create_script" then
        local parent = findService(a.service)
        local className = a.className or "ModuleScript"
        local obj = parent:FindFirstChild(a.name)
        if obj and not obj:IsA("LuaSourceContainer") then
            error("Aynı isimde Lua olmayan nesne var: "..a.name)
        end
        if not obj then
            obj = Instance.new(className)
            obj.Name = a.name
            obj.Parent = parent
        end
        obj.Source = a.source or ""
        Selection:Set({obj})
        return "Script: "..a.service.."/"..a.name
    end

    if a.type == "update_script" then
        local parts = string.split(a.path or "", "/")
        if #parts < 2 then error("Geçersiz script yolu: "..tostring(a.path)) end
        local current = findService(parts[1])
        for i=2,#parts do
            current = current:FindFirstChild(parts[i])
            if not current then error("Bulunamadı: "..a.path) end
        end
        if not current:IsA("LuaSourceContainer") then error("Lua script değil: "..a.path) end
        current.Source = a.source or ""
        Selection:Set({current})
        return "Güncellendi: "..a.path
    end

    if a.type == "command" then
        return "Komut üretildi; güvenlik nedeniyle otomatik çalıştırılmadı."
    end

    return "Bilinmeyen işlem: "..tostring(a.type)
end

local function buildContext()
    local selected = Selection:Get()
    local names = {}
    for _, obj in ipairs(selected) do
        table.insert(names, obj:GetFullName())
    end
    return "Selected objects:\n"..table.concat(names, "\n")
end

button.Click:Connect(function()
    widget.Enabled = not widget.Enabled
end)

run.MouseButton1Click:Connect(function()
    if prompt.Text:gsub("%s","") == "" then
        status.Text = "Önce bir görev yaz."
        return
    end

    run.Active = false
    run.AutoButtonColor = false
    run.Text = "Astra çalışıyor..."
    status.Text = "AI planı hazırlanıyor..."

    local ok, response = pcall(function()
        return HttpService:RequestAsync({
            Url = ENDPOINT,
            Method = "POST",
            Headers = {["Content-Type"]="application/json"},
            Body = HttpService:JSONEncode({
                prompt = prompt.Text,
                context = buildContext(),
            }),
        })
    end)

    if not ok or not response.Success then
        status.Text = "Bağlantı hatası: "..tostring(response and response.StatusCode or response)
        run.Active = true
        run.AutoButtonColor = true
        run.Text = "Astra ile oluştur"
        return
    end

    local decoded
    local parseOk, parseErr = pcall(function()
        decoded = HttpService:JSONDecode(response.Body)
    end)
    if not parseOk then
        status.Text = "AI yanıtı okunamadı: "..tostring(parseErr)
        run.Active = true
        run.Text = "Astra ile oluştur"
        return
    end

    local actions = decoded.actions or {}
    local applied = 0
    local errors = {}

    ChangeHistoryService:SetWaypoint("Astra AI - Before")
    for _, action in ipairs(actions) do
        local actionOk, result = pcall(applyAction, action)
        if actionOk then
            applied += 1
        else
            table.insert(errors, tostring(result))
        end
    end
    ChangeHistoryService:SetWaypoint("Astra AI - After")

    status.Text = (decoded.message or "Plan tamamlandı.")..
        "\nUygulanan: "..applied..
        " / "..#actions..
        (#errors > 0 and "\nHatalar: "..table.concat(errors," | ") or "")
    run.Active = true
    run.AutoButtonColor = true
    run.Text = "Astra ile oluştur"
end)
