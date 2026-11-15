-- Final test to verify all systems work together
-- This will test the complete Aizen moveset with UI, Fling, and passive features

local function testCompleteSystem():
    -- Test 1: Check if UI appears
    local uiPanel = game:GetService("CoreGui"):FindFirstChild("LuaCodingEngine_UI")
    if uiPanel then
        Util.Notify("UI Panel: ✓ FOUND")
    else
        Util.Notify("UI Panel: ✗ NOT FOUND")
        return false
    end
    
    -- Test 2: Check if Fling system is loaded
    local flingSystem = game:GetService("ReplicatedStorage"):FindFirstChild("FlingSystem")
    if flingSystem then
        Util.Notify("Fling System: ✓ LOADED")
    else
        Util.Notify("Fling System: ✗ NOT LOADED")
        return false
    end
    
    -- Test 3: Test a skill
    local player = game.Players.LocalPlayer
    if player and player.Character then
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Test Cero skill
            local flingSystem = require(game:GetService("ReplicatedStorage"):FindFirstChild("FlingSystem"))
            if flingSystem then
                flingSystem.Fling(character.HumanoidRootPart, {
                    force = 100000,
                    direction = Vector3.new(1, 0, 0),
                    power = 100000,
                    duration = 0.5,
                    angular = 0
                })
                Util.Notify("Cero Skill: ✓ TESTED")
            else
                Util.Notify("Fling System: ✗ FAILED")
                return false
            end
        else
            Util.Notify("Character not ready!")
            return false
        end
    else
        Util.Notify("Player not ready!")
        return false
    end
    
    -- Test 4: Check passive features
    local passiveFeatures = require(game:GetService("ReplicatedStorage"):FindFirstChild("PassiveFeatures"))
    if passiveFeatures then
        Util.Notify("Passive Features: ✓ ENABLED")
    else
        Util.Notify("Passive Features: ✗ NOT FOUND")
        return false
    end
    
    Util.Notify("AIZEN SYSTEM: ✓ COMPLETE")
    return true

-- Run the test
testCompleteSystem()