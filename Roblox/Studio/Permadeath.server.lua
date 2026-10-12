-- Place in ServerScriptService in YOUR Roblox experience.
-- Session permadeath: after a character dies, they cannot respawn in this server session.
-- This is intentionally server-authoritative; remove/disable this script to restore normal respawns.

local Players = game:GetService("Players")
Players.CharacterAutoLoads = false

local function setupPlayer(player)
    if player:GetAttribute("PermanentDeath") == true then
        return
    end

    local characterConnection
    characterConnection = player.CharacterAdded:Connect(function(character)
        if player:GetAttribute("PermanentDeath") == true then
            character:Destroy()
            return
        end

        local humanoid = character:WaitForChild("Humanoid", 10)
        if not humanoid then return end
        humanoid.Died:Connect(function()
            if player.Parent ~= Players then return end
            player:SetAttribute("PermanentDeath", true)
            player:SetAttribute("PermanentDeathAt", os.time())
            -- No LoadCharacter call: death is final for this player until they rejoin.
        end)
    end)

    player:SetAttribute("PermanentDeath", false)
    task.defer(function()
        if player.Parent == Players and player:GetAttribute("PermanentDeath") ~= true and not player.Character then
            local ok, err = pcall(function() player:LoadCharacter() end)
            if not ok then warn("[Permadeath] Could not load initial character for " .. player.Name .. ": " .. tostring(err)) end
        end
    end)

    player.AncestryChanged:Connect(function(_, parent)
        if parent == nil and characterConnection then
            characterConnection:Disconnect()
        end
    end)
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(setupPlayer, player)
end
