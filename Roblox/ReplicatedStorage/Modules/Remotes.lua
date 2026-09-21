--!strict
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local folder=ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
folder.Name="Remotes"; folder.Parent=ReplicatedStorage
local function remote(name:string)
	local r=folder:FindFirstChild(name)
	if r and r:IsA("RemoteEvent") then return r end
	local e=Instance.new("RemoteEvent"); e.Name=name; e.Parent=folder; return e
end
return {
	GameStateChanged=remote("GameStateChanged"),
	SubmitScore=remote("SubmitScore"),
	RequestStart=remote("RequestStart"),
	RequestAction=remote("RequestAction"),
	RequestLeaderboard=remote("RequestLeaderboard"),
	LeaderboardResult=remote("LeaderboardResult"),
}
