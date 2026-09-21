--!nocheck
-- ROBUNEXA GITHUB <-> ROBLOX STUDIO BRIDGE
-- Run this ONCE from Roblox Studio Command Bar while editing the place.
-- It imports Lua source from the main branch into real Studio script instances.
-- It does NOT execute downloaded code and does NOT use loadstring.

local HttpService = game:GetService("HttpService")
local ScriptEditorService = game:GetService("ScriptEditorService")

local OWNER = "BursaliAlperen"
local REPO = "RobuNexa"
local BRANCH = "main"
local ROOT = "Roblox"
local RAW = "https://raw.githubusercontent.com/" .. OWNER .. "/" .. REPO .. "/" .. BRANCH .. "/"
local API = "https://api.github.com/repos/" .. OWNER .. "/" .. REPO .. "/git/trees/" .. BRANCH .. "?recursive=1"

local function splitPath(path)
\tlocal parts = {}
\tfor part in string.gmatch(path, "[^/]+") do table.insert(parts, part) end
\treturn parts
end

local function serviceRoot(name)
\tif name == "ReplicatedStorage" then return game:GetService("ReplicatedStorage") end
\tif name == "ServerScriptService" then return game:GetService("ServerScriptService") end
\tif name == "StarterPlayer" then return game:GetService("StarterPlayer") end
\tif name == "Workspace" then return workspace end
\treturn nil
end

local function classFor(fileName)
\tif fileName:sub(-10) == ".server.lua" then return "Script", fileName:sub(1, -11) end
\tif fileName:sub(-10) == ".client.lua" then return "LocalScript", fileName:sub(1, -11) end
\tif fileName:sub(-4) == ".lua" then return "ModuleScript", fileName:sub(1, -5) end
\treturn nil, nil
end

local function ensureFolder(parent, name)
\tlocal existing = parent:FindFirstChild(name)
\tif existing and existing:IsA("Folder") then return existing end
\tif existing then existing:Destroy() end
\tlocal folder = Instance.new("Folder")
\tfolder.Name = name
\tfolder.Parent = parent
\treturn folder
end

local function installSource(target, source)
\tScriptEditorService:UpdateSourceAsync(target, function() return source end)
end

local function installFile(repoPath)
\tlocal relative = repoPath:sub(#ROOT + 2)
\tlocal parts = splitPath(relative)
\tlocal className, objectName = classFor(parts[#parts])
\tif not className then return "skip" end

\tlocal rootName = parts[1]
\tlocal parent = serviceRoot(rootName)
\tif not parent then error("Unsupported Roblox root: " .. tostring(rootName)) end

\tfor i = 2, #parts - 1 do
\t\tparent = ensureFolder(parent, parts[i])
\tend

\tlocal old = parent:FindFirstChild(objectName)
\tlocal target
\tif old and old.ClassName == className then
\t\ttarget = old
\telse
\t\tif old then old:Destroy() end
\t\ttarget = Instance.new(className)
\t\ttarget.Name = objectName
\t\ttarget.Parent = parent
\tend

\tlocal url = RAW .. repoPath
\tlocal source = HttpService:GetAsync(url)
\tinstallSource(target, source)
\treturn "installed"
end

local response = HttpService:GetAsync(API)
local tree = HttpService:JSONDecode(response)
assert(tree and tree.tree, "GitHub tree response invalid")

local installed, skipped, failed = 0, 0, 0
for _, item in ipairs(tree.tree) do
\tif item.type == "blob" and item.path:sub(1, #ROOT + 1) == ROOT .. "/" then
\t\tlocal ok, result = pcall(function() return installFile(item.path) end)
\t\tif ok and result == "installed" then
\t\t\tinstalled += 1
\t\telseif ok and result == "skip" then
\t\t\tskipped += 1
\t\telse
\t\t\tfailed += 1
\t\t\twarn("[RobuNexa Bridge] Failed: " .. item.path .. " :: " .. tostring(result))
\t\tend
\tend
end

print(("[RobuNexa Bridge] DONE | installed=%d skipped=%d failed=%d | branch=%s"):format(installed, skipped, failed, BRANCH))
print("[RobuNexa Bridge] Source of truth: https://github.com/" .. OWNER .. "/" .. REPO .. "/tree/" .. BRANCH .. "/Roblox")