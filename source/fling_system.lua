--[[
    Fling System for RobuNexa
    Provides powerful fling mechanics for knocking players
    Supports multiple fling modes and configurations
]]

local FlingSystem = {}

-- Fling configuration
FlingSystem.Config = {
    DefaultDuration = 0.5,
    MaxForceMultiplier = 1000,
    SafeFallDistance = 50,
    EnableAngularFling = true,
}

-- Available fling modes
FlingSystem.Modes = {
    ["Standard"] = {
        Name = "Standard",
        Description = "Basic fling that throws the target forward",
        Force = 80000,
        Direction = Vector3.new(0, 1, 0),
        Height = 25,
        Angular = 300,
    },
    ["Headshot"] = {
        Name = "Headshot",
        Description = "Fling targets high into the air (head-focused)",
        Force = 60000,
        Direction = Vector3.new(0, 1, 0),
        Height = 40,
        Angular = 800,
    },
    ["Orbital"] = {
        Name = "Orbital",
        Description = "Fling target in orbital motion around sender",
        Force = 50000,
        Direction = Vector3.new(1, 0, 0),
        Height = 60,
        Angular = 1200,
    },
    ["Gravity"] = {
        Name = "Gravity",
        Description = "Fling target with strong gravitational pull",
        Force = 200000,
        Direction = Vector3.new(0, -1, 0),
        Height = 100,
        Angular = 0,
    },
    ["Quake"] = {
        Name = "Quake",
        Description = "Ground pound effect that flings nearby targets",
        Force = 150000,
        Direction = Vector3.new(1, 0, 0),
        Height = 10,
        Angular = 100,
    },
}

-- Apply fling to a target
function FlingSystem.Fling(target, mode, duration, customDirection)
    local config = FlingSystem.Modes[mode]
    if not config then
        warn("[FlingSystem] Invalid fling mode: " .. tostring(mode))
        return false
    end
    
    local duration = duration or FlingSystem.Config.DefaultDuration
    
    -- Find the root part to apply fling to
    local rootPart = target:FindFirstChild("HumanoidRootPart")
        or target:FindFirstChild("Torso")
        or target:FindFirstChild("UpperTorso")
    
    if not rootPart then
        warn("[FlingSystem] No root part found on target")
        return false
    end
    
    -- Create body velocity for linear fling
    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(
        config.Force * 3,
        config.Force * 3,
        config.Force * 3
    )
    
    -- Calculate direction with height adjustment
    local direction = (customDirection or config.Direction)
    local velocity = direction * config.Force + Vector3.new(0, config.Height, 0)
    
    bodyVel.Velocity = velocity
    bodyVel.Parent = rootPart
    
    -- Create angular velocity for spinning
    if FlingSystem.Config.EnableAngularFling then
        local bodyAngVel = Instance.new("BodyAngularVelocity")
        bodyAngVel.MaxTorque = Vector3.new(
            config.Angular * 3,
            config.Angular * 3,
            config.Angular * 3
        )
        
        -- Random initial angular velocity for realistic spinning
        local randAng = Vector3.new(
            math.random(-100, 100),
            math.random(-100, 100),
            math.random(-100, 100)
        )
        
        -- Add mode-specific angular velocity
        if mode == "Orbital" then
            randAng = Vector3.new(0, config.Angular * 2, 0)
        end
        
        bodyAngVel.AngularVelocity = randAng
        bodyAngVel.Parent = rootPart
    end
    
    -- Clean up after duration
    task.delay(duration, function()
        if bodyVel.Parent then
            bodyVel:Destroy()
        end
        local bag = rootPart:FindFirstChildWhichIsA("BodyAngularVelocity")
        if bag then
            bag:Destroy()
        end
    end)
    
    return true
end

-- Quick fling function for common use cases
function FlingSystem.QuickFling(target, direction, power)
    power = power or 80000
    return FlingSystem.Fling(target, "Standard", 0.5, direction * power)
end

-- Area fling - affects multiple targets in radius
function FlingSystem.AreaFling(centerPosition, radius, mode, power)
    power = power or 80000
    local targets = {}
    
    -- Find all players in radius
    local players = game:GetService("Players"):GetPlayers()
    for _, player in ipairs(players) do
        local character = player.Character
        if character then
            local humRoot = character:FindFirstChild("HumanoidRootPart")
            if humRoot then
                local distance = (humRoot.Position - centerPosition).Magnitude
                if distance <= radius then
                    table.insert(targets, character)
                end
            end
        end
    end
    
    -- Fling each target
    for _, target in ipairs(targets) do
        FlingSystem.Fling(target, mode, 0.5, Vector3.new(0, power, 0))
    end
    
    return #targets
end

-- Return the module
return FlingSystem