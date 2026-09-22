--!strict
-- Mobile-first HUD + M1/Z/X/C/V + custom ShiftLock.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local modules = ReplicatedStorage:WaitForChild("Modules")
local BattleUI = require(modules:WaitForChild("BattleUI"))
local ShiftLock = require(modules:WaitForChild("ShiftLock"))
local remotes = ReplicatedStorage:WaitForChild("BattleRemotes", 15)
if not remotes then return end
local Action = remotes:WaitForChild("Action")
local Feed = remotes:WaitForChild("Feed")

local gui = Instance.new("ScreenGui")
gui.Name="BattleHUD"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.DisplayOrder=120
pcall(function() gui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets end)
gui.Parent=player:WaitForChild("PlayerGui")
local ui=BattleUI.Build(gui)
local shift=ShiftLock.Start(player,function(enabled)
    ui.ShiftLock.BackgroundColor3=enabled and Color3.fromRGB(58,120,82) or Color3.fromRGB(26,28,35)
end)
ui.ShiftLock.Activated:Connect(shift.Toggle)
local function fire(key:string) Action:FireServer(key) end

local bindings={
    BattleM1={Enum.UserInputType.MouseButton1,Enum.KeyCode.ButtonR2,"M1"},
    BattleZ={Enum.KeyCode.Z,Enum.KeyCode.ButtonX,"Z"},
    BattleX={Enum.KeyCode.X,Enum.KeyCode.ButtonY,"X"},
    BattleC={Enum.KeyCode.C,Enum.KeyCode.ButtonB,"C"},
    BattleV={Enum.KeyCode.V,Enum.KeyCode.ButtonL1,"V"},
}
for actionName,data in pairs(bindings) do
    ContextActionService:BindAction(actionName,function(_,state)
        if state==Enum.UserInputState.Begin then fire(data[3] :: string) end
        return Enum.ContextActionResult.Sink
    end,false,data[1] :: Enum.KeyCode,data[2] :: Enum.KeyCode)
end
for key,button in pairs(ui.Skills) do button.Activated:Connect(function() fire(key) end) end

local function updateStats()
    local stats=player:FindFirstChild("leaderstats"); if not stats then return end
    local kills=stats:FindFirstChild("Kills"); local cash=stats:FindFirstChild("Cash")
    if kills and kills:IsA("IntValue") then ui.Kills.Text="K  "..tostring(kills.Value) end
    if cash and cash:IsA("IntValue") then ui.Cash.Text="$  "..tostring(cash.Value) end
end
task.spawn(function()
    local stats=player:WaitForChild("leaderstats",10); if not stats then return end
    for _,value in ipairs(stats:GetChildren()) do if value:IsA("IntValue") then value.Changed:Connect(updateStats) end end
    updateStats()
end)

Feed.OnClientEvent:Connect(function(data)
    if typeof(data)~="table" then return end
    if data.kind=="kill" then
        ui.Feed.Text=string.format("%s  KILL  %s  +%s",tostring(data.attacker),tostring(data.target),tostring(data.reward))
        ui.Feed.TextColor3=Color3.fromRGB(255,90,55)
    elseif data.kind=="hit" then
        ui.Feed.Text=string.format("%s  ->  %s  -%s",tostring(data.attacker),tostring(data.target),tostring(data.damage))
        ui.Feed.TextColor3=Color3.fromRGB(255,125,55)
    end
end)

local function watchCharacter(character:Model)
    character:WaitForChild("Humanoid",10)
    task.defer(function() shift.Set(shift.IsEnabled()) end)
end
if player.Character then watchCharacter(player.Character) end
player.CharacterAdded:Connect(watchCharacter)

local function tryTarget(model:Instance)
    if not model:IsA("Model") or model==player.Character then return end
    if model:FindFirstChildOfClass("Humanoid") and model:FindFirstChild("HumanoidRootPart") then ui.MakeTarget(model) end
end
for _,model in ipairs(workspace:GetDescendants()) do if model:IsA("Model") then tryTarget(model) end end
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") then task.defer(function() tryTarget(obj) end) end
end)
