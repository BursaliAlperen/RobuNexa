--!strict
-- Server-authoritative screenshot-inspired battleground combat.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local modules = ReplicatedStorage:WaitForChild("Modules")
local Config = require(modules:WaitForChild("BattleConfig"))
local KillService = require(ServerScriptService:WaitForChild("ServerModules"):WaitForChild("KillService"))
local Targeting = require(ServerScriptService:WaitForChild("ServerModules"):WaitForChild("Targeting"))

local remotes = ReplicatedStorage:FindFirstChild("BattleRemotes") or Instance.new("Folder")
remotes.Name = "BattleRemotes"; remotes.Parent = ReplicatedStorage
local Action = remotes:FindFirstChild("Action") or Instance.new("RemoteEvent")
Action.Name = "Action"; Action.Parent = remotes
local Feed = remotes:FindFirstChild("Feed") or Instance.new("RemoteEvent")
Feed.Name = "Feed"; Feed.Parent = remotes

local cooldowns: {[Player]: {[string]: number}} = {}

local function setupStats(player: Player)
    local stats = player:FindFirstChild("leaderstats") or Instance.new("Folder")
    stats.Name = "leaderstats"; stats.Parent = player
    local kills = stats:FindFirstChild("Kills") or Instance.new("IntValue")
    kills.Name = "Kills"; kills.Parent = stats
    local cash = stats:FindFirstChild("Cash") or Instance.new("IntValue")
    cash.Name = "Cash"; cash.Parent = stats
end

local function allowed(player: Player, action: string, duration: number): boolean
    cooldowns[player] = cooldowns[player] or {}
    local now = os.clock()
    local last = cooldowns[player][action] or 0
    if now - last < duration then return false end
    cooldowns[player][action] = now
    return true
end

local function getRoot(player: Player): BasePart?
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return if root and root:IsA("BasePart") then root else nil
end

local function attack(player: Player, key: string)
    local root = getRoot(player)
    if not root then return end
    local duration = key == "M1" and Config.Combat.M1Cooldown or (Config.Combat.SkillCooldowns[key] or 1)
    if not allowed(player, key, duration) then return end
    local target = Targeting.FindNearest(player, root.Position, Config.Combat.MaxRange)
    if not target or not Targeting.InFront(player, target, Config.Combat.MaxRange) then return end
    local humanoid = target:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    local damage = if key == "M1" then Config.Combat.M1Damage else (Config.Combat.SkillDamage[key] or 0)
    if damage <= 0 then return end
    KillService.MarkHit(player, humanoid)
    humanoid:TakeDamage(damage)
    Feed:FireAllClients({kind="hit", attacker=player.Name, target=target.Name, damage=damage})
    if humanoid.Health <= 0 then
        local killer = KillService.ResolveKill(target)
        if killer then
            local character = killer.Character
            local killerHumanoid = character and character:FindFirstChildOfClass("Humanoid")
            if killerHumanoid then killerHumanoid.Health = math.min(killerHumanoid.MaxHealth, killerHumanoid.Health + Config.Combat.KillHeal) end
            Feed:FireAllClients({kind="kill", attacker=killer.Name, target=target.Name, reward=Config.Combat.KillReward})
        end
    end
end

Action.OnServerEvent:Connect(function(player, key)
    if typeof(key) ~= "string" then return end
    if key ~= "M1" and key ~= "Z" and key ~= "X" and key ~= "C" and key ~= "V" then return end
    attack(player, key)
end)
Players.PlayerAdded:Connect(setupStats)
Players.PlayerRemoving:Connect(function(player) cooldowns[player] = nil end)
for _, player in ipairs(Players:GetPlayers()) do setupStats(player) end
