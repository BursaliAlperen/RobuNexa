--!strict
local Players = game:GetService("Players")
local KillService = {}
type HitRecord = { UserId: number, At: number }
local records: {[Humanoid]: HitRecord} = {}

local function getHumanoid(target: Instance): Humanoid?
    if target:IsA("Humanoid") then return target end
    local model = target:FindFirstAncestorOfClass("Model")
    return if model then model:FindFirstChildOfClass("Humanoid") else nil
end

function KillService.MarkHit(attacker: Player, target: Instance)
    local humanoid = getHumanoid(target)
    if not humanoid or humanoid.Health <= 0 then return end
    if attacker.Character and humanoid.Parent == attacker.Character then return end
    records[humanoid] = { UserId = attacker.UserId, At = os.clock() }
end

function KillService.ResolveKill(target: Instance): Player?
    local humanoid = getHumanoid(target)
    if not humanoid then return nil end
    local record = records[humanoid]
    records[humanoid] = nil
    if not record or os.clock() - record.At > 8 then return nil end
    local attacker = Players:GetPlayerByUserId(record.UserId)
    if not attacker then return nil end
    local stats = attacker:FindFirstChild("leaderstats")
    if not stats then return nil end
    local kills = stats:FindFirstChild("Kills")
    local cash = stats:FindFirstChild("Cash")
    if kills and kills:IsA("IntValue") then kills.Value += 1 end
    if cash and cash:IsA("IntValue") then cash.Value += 47 end
    return attacker
end
return KillService
