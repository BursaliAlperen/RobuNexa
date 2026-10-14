-- AizenController.lua
local AizenController = {}
AizenController.__index = AizenController

function AizenController.new(config, animationManager, humanoid)
    local self = setmetatable({}, AizenController)
    self.Config = config
    self.Animations = animationManager
    self.Humanoid = humanoid
    self.Connections = {}
    self.Destroyed = false
    self.ManualAction = false
    self.LastMovementAction = nil

    table.insert(self.Connections, humanoid.Running:Connect(function(speed)
        if self.Destroyed or self.ManualAction then return end
        if speed < config.MovementThreshold then
            self.LastMovementAction = "Idle"
            self.Animations:Play("Idle")
        elseif speed >= config.RunThreshold then
            self.LastMovementAction = "Run"
            self.Animations:Play("Run")
        else
            self.LastMovementAction = "Walk"
            self.Animations:Play("Walk")
        end
    end))

    table.insert(self.Connections, humanoid.Died:Connect(function()
        self:Destroy()
    end))
    return self
end

function AizenController:PlayAction(actionName)
    if self.Destroyed then return false end
    if not self.Config.Actions[actionName] then return false end
    if actionName == "Idle" or actionName == "Walk" or actionName == "Run" then
        self.ManualAction = false
        return self.Animations:Play(actionName)
    end

    self.ManualAction = true
    self.Animations:Stop("Idle")
    self.Animations:Stop("Walk")
    self.Animations:Stop("Run")
    local played = self.Animations:Play(actionName)
    if not played then
        self.ManualAction = false
        return false
    end

    local track = self.Animations:GetTrack(actionName)
    if track then
        local finishedConnection
        finishedConnection = track.Stopped:Connect(function()
            if finishedConnection then finishedConnection:Disconnect() end
            if self.Destroyed then return end
            self.ManualAction = false
            local root = self.Humanoid.RootPart
            if root and self.Humanoid.MoveDirection.Magnitude > 0 then
                self.Animations:Play("Walk")
            else
                self.Animations:Play("Idle")
            end
        end)
    end
    return true
end

function AizenController:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    for _, connection in ipairs(self.Connections) do connection:Disconnect() end
    table.clear(self.Connections)
    self.Animations:StopAll(0)
    self.Animations:Destroy()
end

return AizenController