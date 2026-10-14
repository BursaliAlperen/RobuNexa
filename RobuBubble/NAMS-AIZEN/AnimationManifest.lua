-- NAM'S AIZEN — animation manifest
-- Fill these fields after the supplied .anim files are inspected and imported.
-- This file intentionally contains no executor, reanimation, or Permadeath logic.

local AnimationManifest = {
    Idle = "",
    Walk = "",
    Run = "",
    M1 = {
        "",
        "",
        "",
        "",
    },
    Skills = {
        Skill1 = "",
        Skill2 = "",
        Skill3 = "",
        Skill4 = "",
        Domain = "",
        Finisher = "",
    },
}

local function isConfigured(value)
    return type(value) == "string" and value:match("^%d+$") ~= nil
end

function AnimationManifest.GetConfigured()
    local configured = {}

    for name, value in pairs(AnimationManifest) do
        if type(value) == "string" then
            if isConfigured(value) then
                configured[name] = value
            end
        elseif type(value) == "table" then
            local entries = {}
            for key, id in pairs(value) do
                if isConfigured(id) then
                    entries[key] = id
                end
            end
            configured[name] = entries
        end
    end

    return configured
end

return AnimationManifest
