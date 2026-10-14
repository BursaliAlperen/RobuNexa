-- AnimationManager.lua
-- Safe animation loader for Animation instances already imported into Studio.
local AnimationManager = {}
AnimationManager.__index = AnimationManager

function AnimationManager.new(config, animationFolder, humanoid)
    assert(config and animationFolder and humanoid, "AnimationManager requires config, folder and humanoid")
    local self = setmetatable({}, AnimationManager)
    self.Config = config
    self.Folder = animationFolder
    self.Humanoid = humanoid
    self.Animator = humanoid:FindFirstChildOfClass("Animator")
    if not self.Animator then
        self.Animator = Instance.new("Animator")
        self.Animator.Parent = humanoid
    end
    self.Tracks = {}
    self.Destroyed = false
    return self
end

function AnimationManager:GetTrack(actionName)
    if self.Destroyed then return nil end
    if self.Tracks[actionName] then return self.Tracks[actionName] end

    local actionConfig = self.Config.Actions[actionName]
    if not actionConfig then
        warn("[NAM'S AIZEN] Unknown action:", actionName)
        return nil
    end

    local animation = self.Folder:FindFirstChild(actionName)
    if not animation or not animation:IsA("Animation") then
        warn("[NAM'S AIZEN] Missing Animation instance:", actionName)
        return nil
    end
    if animation.AnimationId == "" then
        warn("[NAM'S AIZEN] AnimationId is empty. Import and publish the .anim first:", actionName)
        return nil
    end

    local ok, trackOrError = pcall(function()
        return self.Animator:LoadAnimation(animation)
    end)
    if not ok then
        warn("[NAM'S AIZEN] Could not load", actionName, trackOrError)
        return nil
    end

    local track = trackOrError
    track.Looped = actionConfig.looped
    track.Priority = actionConfig.priority
    self.Tracks[actionName] = track
    return track
end

function AnimationManager:Play(actionName, fadeTime)
    local track = self:GetTrack(actionName)
    if not track then return false end

    -- Movement loops can coexist with a one-shot only when their priority permits it.
    -- Stop other movement tracks to avoid Idle/Walk/Run fighting each other.
    if actionName == "Idle" or actionName == "Walk" or actionName == "Run" then
        for name, other in pairs(self.Tracks) do
            if name ~= actionName and (name == "Idle" or name == "Walk" or name == "Run") and other.IsPlaying then
                other:Stop(fadeTime or self.Config.FadeTime)
            end
        end
    end

    if not track.IsPlaying then
        track:Play(fadeTime or self.Config.FadeTime)
    end
    return true
end

function AnimationManager:Stop(actionName, fadeTime)
    local track = self.Tracks[actionName]
    if track and track.IsPlaying then
        track:Stop(fadeTime or self.Config.FadeTime)
    end
end

function AnimationManager:StopAll(fadeTime)
    for _, track in pairs(self.Tracks) do
        if track.IsPlaying then track:Stop(fadeTime or self.Config.FadeTime) end
    end
end

function AnimationManager:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    for _, track in pairs(self.Tracks) do
        pcall(function() track:Stop(0) track:Destroy() end)
    end
    table.clear(self.Tracks)
end

return AnimationManager