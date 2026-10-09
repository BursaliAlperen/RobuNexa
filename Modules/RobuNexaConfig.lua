-- RobuNexa repository locations.
-- This module only defines URLs; it does not fetch or execute remote content.
-- Keep remote files as passive assets/data unless they have been reviewed locally.

local RobuNexa = {}

RobuNexa.Repository = "BursaliAlperen/RobuNexa"
RobuNexa.Branch = "main"
RobuNexa.RawRoot = "https://raw.githubusercontent.com/" .. RobuNexa.Repository .. "/" .. RobuNexa.Branch .. "/"

-- Only paths verified to be part of this repository are listed here.
RobuNexa.Paths = {
    R6AnimationGenerator = "Animations/R6/GenerateR6Keyframes.lua",
    R6AnimationGuide = "Animations/R6/README.md",
}

function RobuNexa.RawUrl(path)
    assert(type(path) == "string" and path ~= "", "path must be a non-empty string")
    assert(not path:find("..", 1, true), "parent-directory traversal is not allowed")
    assert(path:sub(1, 1) ~= "/", "path must be relative")
    return RobuNexa.RawRoot .. path
end

return RobuNexa
