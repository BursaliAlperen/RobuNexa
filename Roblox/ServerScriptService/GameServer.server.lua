--!strict
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local WorldBuilder=require(script.Parent:WaitForChild("ServerModules"):WaitForChild("WorldBuilder"))
local Config=require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GameConfig"))
local GameService=require(script.Parent:WaitForChild("ServerModules"):WaitForChild("GameService"))
local hub=workspace:FindFirstChild("GameHub") or Instance.new("Folder",workspace); hub.Name="GameHub"
WorldBuilder.BuildHub(Config.Games,hub)
for _,obj in ipairs(hub:GetDescendants()) do
	if obj:IsA("ProximityPrompt") then
		local portal=obj.Parent
		local id=portal:GetAttribute("GameId")
		if typeof(id)=="string" then obj.Triggered:Connect(function(player) GameService.Start(player,id) end) end
	end
end
print("[Mobile Game Hub] Server ready. "..tostring(#Config.Games).." games registered.")
