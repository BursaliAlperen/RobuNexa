-- RobuNexa NAM Reanimate launcher
-- Entry point pinned to an immutable GitHub commit.
-- Review the repository source before running this in an executor.

local URL = "https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/2d1070e80dd105635ded81148a7976cf8314fd1e/Reanim.txt"

local ok, source = pcall(function()
    return game:HttpGet(URL)
end)

if not ok or type(source) ~= "string" or #source == 0 then
    error("RobuNexa: failed to download the pinned Reanim.txt entry point")
end

if type(loadstring) ~= "function" then
    error("RobuNexa: this environment does not provide loadstring")
end

local chunk, compileError = loadstring(source, "@RobuNexa/Reanim.txt")
if not chunk then
    error("RobuNexa: entry point compilation failed: " .. tostring(compileError))
end

chunk()
