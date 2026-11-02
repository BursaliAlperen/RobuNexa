-- RobuNexa: NPC Fling Test Toggle
-- Location: Roblox/Studio/RobuNexa_NPCFlingTest.client.lua
-- Use only in your own Roblox Studio test place.
-- F6 toggles the test. Targets NPC models only; player characters are excluded.
-- Client-side impulses may not replicate for server-owned NPCs.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local enabled = false
local heartbeatConnection

local RANGE = 8
local HORIZONTAL_IMPULSE = 100
local VERTICAL_IMPULSE = 60

local function stopTest()
    enabled = false
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    print("[RobuNexa] NPC fling test: OFF")
end

local function startTest()
    if enabled then
        return
    end

    enabled = true
    print("[RobuNexa] NPC fling test: ON")

    heartbeatConnection = RunService.Heartbeat:Connect(function()
        local character = localPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then
            return
        end

        for _, model in ipairs(workspace:GetDescendants()) do
            if not model:IsA("Model") or model == character then
                continue
            end

            local humanoid = model:FindFirstChildOfClass("Humanoid")
            local targetRoot = model:FindFirstChild("HumanoidRootPart")
            if not humanoid or humanoid.Health <= 0 or not targetRoot then
                continue
            end

            -- Hard exclusion: never apply force to a player character.
            if Players:GetPlayerFromCharacter(model) then
                continue
            end

            if (targetRoot.Position - root.Position).Magnitude <= RANGE then
                targetRoot:ApplyImpulse(
                    (root.CFrame.LookVector * HORIZONTAL_IMPULSE
                        + Vector3.new(0, VERTICAL_IMPULSE, 0))
                    * targetRoot.AssemblyMass
                )
            end
        end
    end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or input.KeyCode ~= Enum.KeyCode.F6 then
        return
    end

    if enabled then
        stopTest()
    else
        startTest()
    end
end)

localPlayer.CharacterRemoving:Connect(stopTest)

print("[RobuNexa] NPC fling test loaded. Press F6 to toggle.")
