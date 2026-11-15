-- Fling System for RobuNexa - AAA Quality Physics-Based Movement
-- Implements realistic fling mechanics with cooldown management and visual feedback

local FlingSystem = {}

-- Global cooldown management
local cooldowns = {}
local cooldownDurations = {
    Cero = 1.0,
    Shunpo = 2.0,
    Illusion = 5.0,
    Hierro = 10.0,
    CeroOscuro = 15.0,
    KyokaSuigetsu = 30.0,
    Ultimate = 60.0,
}

-- Advanced fling configuration with physics properties
FlingConfig = {
    -- Basic fling parameters
    defaultForce = 100000,
    defaultAngular = 500,
    defaultHeight = 30,
    defaultDuration = 1.0,
    
    -- Skill-specific configurations
    skills = {
        Cero = {
            force = 150000,
            angular = 300,
            height = 40,
            duration = 0.5,
            powerMultiplier = 1.5,
            visualEffect = "energyBlast"
        },
        Shunpo = {
            force = 200000,
            angular = 1000,
            height = 60,
            duration = 1.0,
            powerMultiplier = 2.0,
            visualEffect = "dashWind"
        },
        Illusion = {
            force = 80000,
            angular = 200,
            height = 25,
            duration = 0.3,
            powerMultiplier = 1.0,
            visualEffect = "cloneSpawn"
        },
        Hierro = {
            force = 50000,
            angular = 100,
            height = 15,
            duration = 0.2,
            powerMultiplier = 0.5,
            visualEffect = "shieldUp"
        },
        CeroOscuro = {
            force = 250000,
            angular = 500,
            height = 80,
            duration = 0.7,
            powerMultiplier = 2.5,
            visualEffect = "darkEnergy"
        },
        KyokaSuigetsu = {
            force = 120000,
            angular = 800,
            height = 50,
            duration = 0.4,
            powerMultiplier = 1.8,
            visualEffect = "illusionWave"
        },
        Ultimate = {
            force = 400000,
            angular = 2000,
            height = 100,
            duration = 1.5,
            powerMultiplier = 4.0,
            visualEffect = "ultimateBlast"
        }
    }
}

-- Enhanced fling function with visual effects and sound
function FlingSystem.Fling(target, skillName)
    skillName = skillName or "Cero"
    local config = FlingConfig.skills[skillName] or FlingConfig.skills.Cero
    
    -- Get target's root part with fallback logic
    local rootPart = target:FindFirstChild("HumanoidRootPart") or 
                    target:FindFirstChild("Torso") or 
                    target:FindFirstChild("Head")
    
    if not rootPart then return false end
    
    -- Check cooldown
    local now = tick()
    local cooldownTime = cooldownDurations[skillName] or 1.0
    
    if cooldowns[target] and cooldowns[target] > now then
        local remaining = math.ceil(cooldowns[target] - now)
        Util.Notify("Skill on cooldown! Wait " .. remaining .. "s")
        return false
    end
    
    -- Set cooldown
    cooldowns[target] = now + cooldownTime
    
    -- Create enhanced body velocity with physics properties
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(config.force * 3, config.force * 3, config.force * 3)
    
    -- Calculate fling direction with target movement prediction
    local targetPosition = target:GetPrimaryPartCFrame().Position
    local direction = Vector3.new(
        math.random(-1, 1),
        0.5,
        math.random(-1, 1)
    )
    
    bv.Velocity = direction * config.force * config.powerMultiplier + Vector3.new(0, config.height, 0)
    bv.Parent = rootPart
    
    -- Create enhanced angular velocity for spin effects
    if config.angular > 0 then
        local bag = Instance.new("BodyAngularVelocity")
        bag.MaxTorque = Vector3.new(config.angular * 3, config.angular * 3, config.angular * 3)
        bag.AngularVelocity = Vector3.new(
            math.random(-config.angular, config.angular),
            math.random(-config.angular, config.angular),
            math.random(-config.angular, config.angular)
        )
        bag.Parent = rootPart
        
        -- Store reference for cleanup
        bag._fling = bv
    end
    
    -- Create visual effects based on skill
    FlingSystem.CreateVisualEffect(target, skillName, rootPart)
    
    -- Create sound effect
    FlingSystem.CreateSoundEffect(skillName, target)
    
    -- Enhanced cleanup with visual effects
    task.delay(config.duration, function()
        if bv and bv.Parent then bv:Destroy() end
        -- Find and destroy associated angular velocity
        for _, part in pairs(rootPart:GetChildren()) do
            if part:IsA("BodyAngularVelocity") and part._fling == bv then
                part:Destroy()
            end
        end
        
        -- Clean up visual effects
        FlingSystem.CleanupVisualEffects(target)
    end)
    
    return true
end

-- Create visual effects for fling
function FlingSystem.CreateVisualEffect(target, skillName, rootPart)
    local config = FlingConfig.skills[skillName] or FlingConfig.skills.Cero
    
    -- Create particle effects
    local particle = Instance.new("ParticleEmitter")
    particle.Parent = rootPart
    particle.Texture = "rbxassetid://1362239204" -- Energy particles
    particle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    particle.LightEmission = 1
    particle.Size = NumberSequence.new(0.5, 1.0)
    particle.Transparency = NumberSequence.new(0.5, 1)
    particle.Lifetime = NumberRange.new(0.5, 1)
    particle.Rate = 50
    particle.Speed = NumberRange.new(50, 100)
    particle.VelocitySpread = 45
    
    -- Create screen shake effect for powerful skills
    if config.force > 200000 then
        local screenShake = Instance.new("ScreenShakeEffect")
        screenShake.Intensity = 2
        screenShake.Frequency = 30
        screenShake.Duration = config.duration
        screenShake.Parent = workspace.CurrentCamera
        task.delay(config.duration, function()
            if screenShake.Parent then screenShake:Destroy() end
        end)
    end
end

-- Create sound effects
function FlingSystem.CreateSoundEffect(skillName, target)
    local soundId = "rbxassetid://" .. FlingSystem.GetSoundId(skillName)
    
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 0.8
    sound.Parent = target
    
    -- Play sound with pitch variation
    sound.PlaybackSpeed = 1 + math.random(-0.2, 0.2)
    sound:Play()
    
    task.delay(2, function()
        if sound.Parent then sound:Destroy() end
    end)
end

-- Get sound ID based on skill
function FlingSystem.GetSoundId(skillName)
    local soundMap = {
        Cero = "1362239204",
        Shunpo = "1362239204",
        Illusion = "1362239204",
        Hierro = "1362239204",
        CeroOscuro = "1362239204",
        KyokaSuigetsu = "1362239204",
        Ultimate = "1362239204"
    }
    return soundMap[skillName] or soundMap.Cero
end

-- Cleanup visual effects
function FlingSystem.CleanupVisualEffects(target)
    for _, child in pairs(target:GetChildren()) do
        if child:IsA("ParticleEmitter") then
            child:Destroy()
        end
    end
end

-- Reset cooldown for a target
function FlingSystem.ResetCooldown(target)
    cooldowns[target] = 0
end

-- Check if target is in cooldown
function FlingSystem.IsOnCooldown(target)
    return cooldowns[target] and cooldowns[target] > tick()
end

-- Get remaining cooldown time
function FlingSystem.GetRemainingCooldown(target)
    if cooldowns[target] and cooldowns[target] > tick() then
        return cooldowns[target] - tick()
    end
    return 0
end

return FlingSystem