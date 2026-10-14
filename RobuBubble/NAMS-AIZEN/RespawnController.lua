-- RespawnController.lua
-- Prevents duplicate character bindings and reliably cleans up old tracks.
local RespawnController = {}
RespawnController.__index = RespawnController

function RespawnController.new(player, onCharacter, onCleanup)
    local self = setmetatable({}, RespawnController)
    self.Player = player
    self.OnCharacter = onCharacter
    self.OnCleanup = onCleanup
    self.Generation = 0
    self.Destroyed = false
    self.Connections = {}

    table.insert(self.Connections, player.CharacterAdded:Connect(function(character)
        if self.Destroyed then return end
        self.Generation += 1
        local generation = self.Generation
        if self.OnCleanup then pcall(self.OnCleanup) end
        task.defer(function()
            if self.Destroyed or generation ~= self.Generation then return end
            if character ~= player.Character then return end
            if self.OnCharacter then self.OnCharacter(character, generation) end
        end)
    end))

    table.insert(self.Connections, player.CharacterRemoving:Connect(function()
        self.Generation += 1
        if self.OnCleanup then pcall(self.OnCleanup) end
    end))

    if player.Character then
        self.Generation += 1
        local generation = self.Generation
        task.defer(function()
            if not self.Destroyed and generation == self.Generation and self.OnCharacter then
                self.OnCharacter(player.Character, generation)
            end
        end)
    end
    return self
end

function RespawnController:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    self.Generation += 1
    for _, connection in ipairs(self.Connections) do connection:Disconnect() end
    table.clear(self.Connections)
    if self.OnCleanup then pcall(self.OnCleanup) end
end

return RespawnController