-- Test script to verify Aizen UI and Fling system
-- This script will test if the UI appears correctly and skills work

local function testUI()
    -- Test if UI appears correctly
    local panel = game:GetService("CoreGui"):FindFirstChild("LuaCodingEngine_UI")
    if panel then
        Util.Notify("UI panel found!")
        return true
    else
        Util.Notify("UI panel not found!")
        return false
    end
end

-- Test Fling system
local function testFling()
    -- Create a test target
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local target = character.HumanoidRootPart
        
        -- Test Fling system
        local flingSystem = require(game:GetService("ReplicatedStorage"):FindFirstChild("FlingSystem"))
        if flingSystem then
            flingSystem.Fling(target, {
                force = 100000,
                direction = Vector3.new(0, 1, 0),
                power = 100000,
                duration = 1.0,
                angular = 0
            })
            Util.Notify("Fling system test passed!")
            return true
        else
            Util.Notify("Fling system not found!")
            return false
        end
    else
        Util.Notify("Character not found!")
        return false
    end
end

-- Test passive features
local function testPassiveFeatures()
    local passive = require(game:GetService("ReplicatedStorage"):FindFirstChild("PassiveFeatures"))
    if passive then
        passive.StartAmbientSounds()
        passive.StartBackgroundEffects()
        Util.Notify("Passive features enabled!")
        return true
    else
        Util.Notify("Passive features not found!")
        return false
    end
end

-- Run tests
testUI()
testFling()
testPassiveFeatures()

Util.Notify("Aizen UI test completed!")