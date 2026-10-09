-- RobuNexa repository locations.
-- This module only defines URLs; it does not fetch or execute remote content.
-- Revision is an immutable commit containing the reviewed migration assets.

local RobuNexa = {}

RobuNexa.Repository = "BursaliAlperen/RobuNexa"
RobuNexa.Revision = "61eb806d301615ff83e0b926ca0fc7abb6304dae"
RobuNexa.RawRoot = "https://raw.githubusercontent.com/" .. RobuNexa.Repository .. "/" .. RobuNexa.Revision .. "/"

RobuNexa.Paths = {
    R6AnimationGenerator = "Animations/R6/GenerateR6Keyframes.lua",
    R6AnimationGuide = "Animations/R6/README.md",
    NAMAnimationModule = "content/v_robunexa_anime.lua",
}

function RobuNexa.RawUrl(path)
    assert(type(path) == "string" and path ~= "", "path must be a non-empty string")
    assert(not path:find("..", 1, true), "parent-directory traversal is not allowed")
    assert(path:sub(1, 1) ~= "/", "path must be relative")
    return RobuNexa.RawRoot .. path
end

return RobuNexa
