--!nocheck
--[[
    ROBUNEXA ONE-CLICK INSTALLER
    Paste this entire script into Roblox Studio's Command Bar and run it.

    Source:
      https://github.com/BursaliAlperen/RobuNexa
    Branch:
      rbxm-moveset-system

    IMPORTANT:
      - This installer NEVER uses loadstring.
      - It downloads trusted Lua source and writes it into real Studio Script/LocalScript/ModuleScript objects.
      - Run it only from the Studio Command Bar. Roblox protects Script.Source from normal in-game scripts.
      - RBXM binary assets are intentionally NOT downloaded/deserialized here.
]]

local HttpService = game:GetService("HttpService")
local ScriptEditorService = game:GetService("ScriptEditorService")

local OWNER = "BursaliAlperen"
local REPO = "RobuNexa"
local BRANCH = "rbxm-moveset-system"

local API_TREE = string.format(
    "https://api.github.com/repos/%s/%s/git/trees/%s?recursive=1",
    OWNER, REPO, BRANCH
)
local RAW_ROOT = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/",
    OWNER, REPO, BRANCH
)

local STARTED_AT = os.clock()
local installed = 0
local updated = 0
local failed = {}
local skipped = 0

local function log(message)
    print("[RobuNexa Installer] " .. message)
end

local function fail(message)
    table.insert(failed, message)
    warn("[RobuNexa Installer] " .. message)
end

local function get(url)
    local ok, result = pcall(function()
        return HttpService:GetAsync(url, true)
    end)
    if not ok then
        return false, tostring(result)
    end
    return true, result
end

local function splitPath(path)
    local out = {}
    for part in string.gmatch(path, "[^/]+") do
        table.insert(out, part)
    end
    return out
end

local function serviceRoot(name)
    if name == "ReplicatedStorage" then
        return game:GetService("ReplicatedStorage")
    elseif name == "ServerScriptService" then
        return game:GetService("ServerScriptService")
    elseif name == "ServerStorage" then
        return game:GetService("ServerStorage")
    elseif name == "StarterGui" then
        return game:GetService("StarterGui")
    elseif name == "StarterPlayerScripts" then
        return game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
    elseif name == "StarterCharacterScripts" then
        return game:GetService("StarterPlayer"):WaitForChild("StarterCharacterScripts")
    elseif name == "ReplicatedFirst" then
        return game:GetService("ReplicatedFirst")
    elseif name == "Workspace" then
        return workspace
    end
    return nil
end

local function resolveTarget(path)
    if path:sub(1, 7) ~= "Roblox/" then
        return nil, "outside Roblox/"
    end

    local relative = path:sub(8)
    local pieces = splitPath(relative)
    local rootName = pieces[1]
    local root = serviceRoot(rootName)

    if not root then
        return nil, "unsupported root: " .. tostring(rootName)
    end

    table.remove(pieces, 1)

    if #pieces == 0 then
        return nil, "empty target"
    end

    local filename = pieces[#pieces]
    table.remove(pieces, #pieces)

    local parent = root
    for _, folderName in ipairs(pieces) do
        local child = parent:FindFirstChild(folderName)
        if child and child:IsA("Folder") then
            parent = child
        elseif child then
            return nil, "path collision at " .. child:GetFullName()
        else
            child = Instance.new("Folder")
            child.Name = folderName
            child:SetAttribute("RobuNexaManaged", true)
            child.Parent = parent
            parent = child
        end
    end

    return parent, filename
end

local function shouldInstall(path)
    if not path:match("^Roblox/") then
        return false
    end
    if path:match("^Roblox/Studio/") then
        return false
    end
    if path:match("^Roblox/Assets/") then
        return false
    end
    if path:match("%.md$") then
        return false
    end
    return path:match("%.lua$") ~= nil or path:match("%.luau$") ~= nil
end

local function classify(path)
    if path:match("%.server%.lua$") then
        return "Script"
    end
    if path:match("%.client%.lua$") then
        return "LocalScript"
    end

    if path:find("/Modules/", 1, true)
        or path:find("/MiniGames/", 1, true)
        or path:find("/ServerModules/", 1, true)
        or path:find("/Movesets/", 1, true)
        or path:match("/_Util%.lua$")
    then
        return "ModuleScript"
    end

    -- Safe defaults for the current RobuNexa runtime tree.
    if path:match("^Roblox/ServerScriptService/") then
        return "Script"
    end
    if path:match("^Roblox/StarterPlayerScripts/")
        or path:match("^Roblox/StarterCharacterScripts/")
        or path:match("^Roblox/StarterGui/")
        or path:match("^Roblox/ReplicatedFirst/")
    then
        return "LocalScript"
    end

    -- Avoid guessing for unknown files.
    return nil
end

local function writeSource(instance, source)
    local ok, err = pcall(function()
        instance.Source = source
    end)
    if ok then
        return true
    end

    local ok2, err2 = pcall(function()
        ScriptEditorService:UpdateSourceAsync(instance, function()
            return source
        end)
    end)
    if ok2 then
        return true
    end

    return false, tostring(err) .. " | UpdateSourceAsync: " .. tostring(err2)
end

local function upsertScript(parent, filename, className, source)
    local old = parent:FindFirstChild(filename)

    if old and old:GetAttribute("RobuNexaManaged") then
        old:Destroy()
        old = nil
    elseif old and old.ClassName ~= className then
        fail("Class collision: " .. old:GetFullName() .. " expected " .. className)
        return false
    end

    local object = old
    local wasExisting = object ~= nil

    if not object then
        object = Instance.new(className)
        object.Name = filename
    end

    object:SetAttribute("RobuNexaManaged", true)
    object:SetAttribute("RobuNexaSourcePath", filename)
    if object:IsA("BaseScript") then
        object.Enabled = false
    end

    local ok, err = writeSource(object, source)
    if not ok then
        fail("Source write failed for " .. filename .. ": " .. tostring(err))
        object:Destroy()
        return false
    end

    -- Parent last so runtime scripts cannot execute half-installed.
    object.Parent = parent

    if object:IsA("BaseScript") then
        object.Enabled = false
    end

    if wasExisting then
        updated += 1
    else
        installed += 1
    end

    return true
end

log("Starting GitHub sync...")
log("Repository: " .. OWNER .. "/" .. REPO)
log("Branch: " .. BRANCH)

local treeOk, treeBody = get(API_TREE)
if not treeOk then
    error("GitHub tree request failed: " .. treeBody)
end

local decoded = HttpService:JSONDecode(treeBody)
local tree = decoded.tree
if type(tree) ~= "table" then
    error("GitHub returned an invalid tree response.")
end

local files = {}
for _, entry in ipairs(tree) do
    if entry.type == "blob" and shouldInstall(entry.path) then
        local className = classify(entry.path)
        if className then
            table.insert(files, {
                path = entry.path,
                className = className,
            })
        else
            skipped += 1
            log("Skip (unknown script target): " .. entry.path)
        end
    end
end

table.sort(files, function(a, b)
    return a.path < b.path
end)

log("Found " .. tostring(#files) .. " runtime Lua files.")

for index, file in ipairs(files) do
    local parent, filenameOrError = resolveTarget(file.path)
    if not parent then
        fail(file.path .. " -> " .. tostring(filenameOrError))
        continue
    end

    local rawUrl = RAW_ROOT .. file.path:sub(8):gsub(" ", "%%20")
    local ok, source = get(rawUrl)

    if not ok then
        fail(file.path .. " download failed: " .. tostring(source))
        continue
    end

    if type(source) ~= "string" or #source == 0 then
        fail(file.path .. " returned empty source.")
        continue
    end

    log(string.format("[%d/%d] Installing %s", index, #files, file.path))
    upsertScript(parent, filenameOrError, file.className, source)

    -- Keep the installer friendly to HTTP rate limits.
    task.wait(0.03)
end

-- Enable only managed runtime scripts after every file has been written.
local roots = {
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerScriptService"),
    game:GetService("ServerStorage"),
    game:GetService("StarterGui"),
    game:GetService("StarterPlayer"),
    game:GetService("ReplicatedFirst"),
    workspace,
}

local enabled = 0
for _, root in ipairs(roots) do
    for _, descendant in ipairs(root:GetDescendants()) do
        if descendant:GetAttribute("RobuNexaManaged") and descendant:IsA("BaseScript") then
            descendant.Enabled = true
            enabled += 1
        end
    end
end

-- Installation marker.
local marker = game:FindFirstChild("RobuNexa_InstallInfo")
if not marker then
    marker = Instance.new("Folder")
    marker.Name = "RobuNexa_InstallInfo"
    marker.Parent = game
end
marker:SetAttribute("Repository", OWNER .. "/" .. REPO)
marker:SetAttribute("Branch", BRANCH)
marker:SetAttribute("InstalledAtUnix", os.time())
marker:SetAttribute("InstalledFiles", installed + updated)
marker:SetAttribute("FailedFiles", #failed)

log("========================================")
log("INSTALL COMPLETE")
log("New scripts: " .. tostring(installed))
log("Updated scripts: " .. tostring(updated))
log("Enabled scripts: " .. tostring(enabled))
log("Skipped files: " .. tostring(skipped))
log("Failures: " .. tostring(#failed))
log(string.format("Time: %.2fs", os.clock() - STARTED_AT))

if #failed > 0 then
    warn("[RobuNexa Installer] Some files failed:")
    for _, message in ipairs(failed) do
        warn("  - " .. message)
    end
else
    log("All runtime Lua files installed successfully.")
end

log("Next: File > Publish to Roblox As...")
