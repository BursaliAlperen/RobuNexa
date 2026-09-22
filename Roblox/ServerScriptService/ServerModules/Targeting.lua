--!strict
local Players = game:GetService("Players")
local Targeting = {}

function Targeting.FindNearest(attacker: Player, origin: Vector3, range: number): Model?
    local best: Model? = nil
    local bestDistance = range
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= attacker and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local root = character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and root then
                local distance = (root.Position - origin).Magnitude
                if distance <= bestDistance then bestDistance, best = distance, character end
            end
        end
    end
    local npcFolder = workspace:FindFirstChild("BattleNPCs")
    if npcFolder then
        for _, model in ipairs(npcFolder:GetChildren()) do
            if model:IsA("Model") then
                local humanoid = model:FindFirstChildOfClass("Humanoid")
                local root = model:FindFirstChild("HumanoidRootPart")
                if humanoid and humanoid.Health > 0 and root then
                    local distance = (root.Position - origin).Magnitude
                    if distance <= bestDistance then bestDistance, best = distance, model end
                end
            end
        end
    end
    return best
end

function Targeting.InFront(attacker: Player, target: Model, maxRange: number): boolean
    local character = attacker.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then return false end
    local offset = targetRoot.Position - root.Position
    if offset.Magnitude > maxRange then return false end
    return root.CFrame.LookVector:Dot(offset.Unit) >= -0.15
end
return Targeting
