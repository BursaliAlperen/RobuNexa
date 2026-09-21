--!strict
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local Config=require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GameConfig"))
local WorldBuilder=require(script.Parent:WaitForChild("WorldBuilder"))
local LightingService=require(script.Parent:WaitForChild("LightingService"))
local Remotes=require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Remotes"))
local GameService={}
local sessions:{[Player]:{Id:string,Score:number,Started:number,Locked:boolean}}={}
local worlds=workspace:FindFirstChild("MiniGameWorlds") or Instance.new("Folder",workspace); worlds.Name="MiniGameWorlds"
local function safeCall(fn) local ok,r=pcall(fn); if not ok then warn("[GameService] "..tostring(r)) end return ok,r end
function GameService.Start(player:Player,id:string)
	local def=Config.GetGame(id); if not def or sessions[player] then return false end
	local session={Id=id,Score=0,Started=os.clock(),Locked=true}; sessions[player]=session
	local folder=Instance.new("Folder"); folder.Name=player.Name.."_"..id; folder.Parent=worlds
	WorldBuilder.Build(def,folder); LightingService.Apply(def)
	local module=ReplicatedStorage:WaitForChild("MiniGames"):FindFirstChild(id)
	if not module or not module:IsA("ModuleScript") then sessions[player]=nil; folder:Destroy(); return false end
	local ctx={Player=player,Game=def,World=folder,Speed=1,Score=0,Combo=0,Multiplier=1,OnFinish=function(score:number,victory:boolean) GameService.Finish(player,score,victory) end,onFinish=function(score:number,victory:boolean) GameService.Finish(player,score,victory) end}
	local ok,mod=safeCall(function() return require(module) end)
	if not ok or type(mod)~="table" or type(mod.start)~="function" then sessions[player]=nil; folder:Destroy(); return false end
	local okStart=safeCall(function() mod.start(ctx) end)
	if not okStart then sessions[player]=nil; folder:Destroy(); return false end
	sessions[player].Module=mod; sessions[player].Context=ctx
	Remotes.GameStateChanged:FireClient(player,{State="Started",GameId=id,Duration=def.Duration})
	return true
end
function GameService.Finish(player:Player,score:number,victory:boolean)
	local s=sessions[player]; if not s or not s.Locked then return end
	s.Locked=false
	local def=Config.GetGame(s.Id); local max=def and def.MaxScore or Config.MaxPerGame
	score=math.clamp(tonumber(score) or 0,0,max)
	if s.Context then s.Context.Score=score end
	if s.Module and type(s.Module.cleanup)=="function" then safeCall(function() s.Module.cleanup(player) end) end
	if s.Context and s.Context.World then s.Context.World:Destroy() end
	sessions[player]=nil
	Remotes.GameStateChanged:FireClient(player,{State="Finished",GameId=s.Id,Score=score,Victory=victory==true})
end
function GameService.Stop(player:Player)
	local s=sessions[player]; if s then GameService.Finish(player,0,false) end
end
function GameService.IsPlaying(player:Player) return sessions[player]~=nil end
Players.PlayerRemoving:Connect(function(p) GameService.Stop(p) end)
return GameService
