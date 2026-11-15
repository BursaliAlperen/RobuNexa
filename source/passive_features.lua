--[[
    Passive Features for RobuNexa
    Provides background effects, ambient sounds, and passive abilities
    Runs continuously while the moveset is active
]]

local PassiveFeatures = {}

-- Ambient sound configuration
PassiveFeatures.Sounds = {
    Ambient = {
        Enabled = true,
        Volume = 0.3,
        Loop = true,
        Sounds = {
            "rbxassetid://616118832", -- Background hum
            "rbxassetid://616119256", -- Low frequency
            "rbxassetid://616119532", -- Atmospheric
        }
    },
    AbilitySounds = {
        Enabled = true,
        Volume = 0.8,
        Loop = false,
    }
}

-- Particle effects configuration
PassiveFeatures.Particles = {
    Enabled = true,
    Size = 5,
    Opacity = 0.5,
    Colors = {
        Color3.fromRGB(255, 215, 0), -- Gold
        Color3.fromRGB(255, 255, 255), -- White
        Color3.fromRGB(200, 150, 255), -- Purple
    }
}

-- Player tracking and effects
PassiveFeatures.TrackedPlayers = {}

-- Initialize ambient effects
function PassiveFeatures.Initialize()
    print("[PassiveFeatures] Initializing ambient effects...")
    
    -- Setup ambient sound loop
    if PassiveFeatures.Sounds.Ambient.Enabled then
        local sound = Instance.new("Sound")
        sound.Name = "AmbientSound"
        sound.Volume = PassiveFeatures.Sounds.Ambient.Volume
        sound.Loop = PassiveFeatures.Sounds.Ambient.Loop
        sound.SoundId = PassiveFeatures.Sounds.Ambient.Sounds[1]
        sound.Parent = game:GetService("SoundService")
        sound:Play()
        print("[PassiveFeatures] Ambient sound started")
    end
    
    -- Track player for passive effects
    local Players = game:GetService("Players")
    Players.PlayerAdded:Connect(function(player)
        PassiveFeatures.TrackedPlayers[player] = true
        print("[PassiveFeatures] Player added: " .. player.Name)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        PassiveFeatures.TrackedPlayers[player] = nil
        print("[PassiveFeatures] Player removed: " .. player.Name)
    end)
    
    return true
end

-- Add ambient particle effect
function PassiveFeatures.AddParticleEffect(position, color, duration)
    local effect = Instance.new("ParticleEmitter")
    effect.Name = "PassiveParticle"
    effect.Position = position
    effect.Color = ColorSequence.new(color or PassiveFeatures.Particles.Colors[1])
    effect.Size = NumberSequence.new(PassiveFeatures.Particles.Size)
    effect.Opacity = NumberSequence.new(PassiveFeatures.Particles.Opacity)
    effect.Lifetime = NumberRange.new(duration or 5)
    effect.Rate = 10
    effect.Parent = workspace.Terrain
    
    -- Clean up after duration
    task.delay(duration or 5, function()
        if effect.Parent then
            effect:Destroy()
        end
    end)
    
    return effect
end

-- Apply passive ability to a player
function PassiveFeatures.ApplyPassiveAbility(player, abilityName)
    local character = player.Character
    if not character then
        return false
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return false
    end
    
    -- Apply ability based on name
    if abilityName == "Regeneration" then
        -- Regeneration passive - slowly restore health
        local connection
        connection = game:GetService("RunService").Heartbeat:Connect(function()
            if humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = math.min(humanoid.Health + 1, humanoid.MaxHealth)
            else
                connection:Disconnect()
            end
        end)
        return true
    
    elseif abilityName == "Strength" then
        -- Strength passive - increase damage
        -- This would be handled by the moveset system
        return true
    
    elseif abilityName == "Shield" then
        -- Shield passive - damage reduction
        -- This would be handled by the moveset system
        return true
    end
    
    warn("[PassiveFeatures] Unknown ability: " .. tostring(abilityName))
    return false
end

-- Toggle all passive features on/off
function PassiveFeatures.Toggle(enabled)
    -- This would toggle the entire passive system
    print("[PassiveFeatures] Passive features " .. (enabled and "enabled" or "disabled"))
end

-- Return the module
return PassiveFeatures