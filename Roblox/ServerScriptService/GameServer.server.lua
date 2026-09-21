--!strict
local WorldBuilder=require(script.Parent:WaitForChild("ServerModules"):WaitForChild("WorldBuilder"))
local Config=require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("GameConfig"))
local hub=workspace:FindFirstChild("GameHub") or Instance.new("Folder",workspace); hub.Name="GameHub"
WorldBuilder.BuildHub(Config.Games,hub)
require(script.Parent:WaitForChild("ServerModules"):WaitForChild("GameService"))
print("[Mobile Game Hub] Server ready. "..tostring(#Config.Games).." games registered.")
