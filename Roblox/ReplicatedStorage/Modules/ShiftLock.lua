--!strict
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ShiftLock = {}

function ShiftLock.Start(player: Player, onChanged: ((boolean) -> ())?)
    local enabled = false
    local renderConnection = RunService.RenderStepped:Connect(function()
        if not enabled then return end
        local camera = workspace.CurrentCamera
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if camera and root and humanoid and humanoid.MoveDirection.Magnitude > 0.05 then
            local flat = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
            if flat.Magnitude > 0.01 then root.CFrame = CFrame.lookAt(root.Position, root.Position + flat.Unit) end
        end
    end)
    local function apply(value: boolean)
        enabled = value
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.AutoRotate = not enabled end
        if onChanged then onChanged(enabled) end
    end
    local inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.LeftShift then apply(not enabled) end
    end)
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid")
        task.defer(function() apply(enabled) end)
    end)
    return {
        Toggle = function() apply(not enabled) end,
        Set = apply,
        IsEnabled = function() return enabled end,
        Destroy = function() inputConnection:Disconnect(); renderConnection:Disconnect(); apply(false) end,
    }
end
return ShiftLock
