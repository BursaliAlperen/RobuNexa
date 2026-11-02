--!strict
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local pg=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local remotes=require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Remotes"))
local gui=pg:WaitForChild("MobileGameHub",10); if not gui then return end
local hud=gui:WaitForChild("GameHUD",10); if not hud then return end
local labels={}
for _,c in ipairs(hud:GetChildren()) do if c:IsA("TextLabel") then table.insert(labels,c) end end
local score=labels[1]; local combo=labels[2]
if not score then return end
remotes.GameStateChanged.OnClientEvent:Connect(function(p)
	if typeof(p)~="table" then return end
	if p.State=="Score" then
		local target=math.floor(tonumber(p.Score) or 0)
		local current=tonumber(score.Text) or 0
		local value=Instance.new("NumberValue"); value.Value=current
		local conn=value:GetPropertyChangedSignal("Value"):Connect(function() score.Text=tostring(math.floor(value.Value)) end)
		TweenService:Create(value,TweenInfo.new(.18,Enum.EasingStyle.Quad),{Value=target}):Play()
		task.delay(.25,function() conn:Disconnect(); value:Destroy() end)
		if combo then combo.Text="x"..tostring(p.Multiplier or 1).."  COMBO "..tostring(p.Combo or 0) end
	end
end)
