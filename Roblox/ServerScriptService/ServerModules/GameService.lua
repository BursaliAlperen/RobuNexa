--!strict
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local Config=require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GameConfig"))
local WorldBuilder=require(script.Parent:WaitForChild("WorldBuilder"))
local LightingService=require(script.Parent:WaitForChild("LightingService"))
local Remotes=require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Remotes"))
local GameService={}
local sessions:{[Player]:any}={}
local worlds=workspace:FindFirstChild("MiniGameWorlds") or Instance.new("Folder",workspace); worlds.Name="MiniGameWorlds"
local function safeCall(fn) local ok,r=pcall(fn); if not ok then warn("[GameService] "..tostring(r)) end return ok,r end
function GameService.Start(player:Player,id:string)
	if typeof(id)~="string" or #id>40 then return false end
	local def=Config.GetGame(id); if not def or sessions[player] then return false end
	local session={Id=id,Score=0,Started=os.clock(),Locked=true,ActionAt=0}; sessions[player]=session
	local folder=Instance.new("Folder"); folder.Name=player.Name.."_"..id; folder.Parent=worlds
	local okBuild=safeCall(function() WorldBuilder.Build(def,folder); LightingService.Apply(def) end)
	if not okBuild then sessions[player]=nil; folder:Destroy(); return false end
	local module=ReplicatedStorage:WaitForChild("MiniGames"):FindFirstChild(id)
	if not module or not module:IsA("ModuleScript") then sessions[player]=nil; folder:Destroy(); return false end
	local ctx={Player=player,Game=def,World=folder,Speed=1,Score=0,Combo=0,Multiplier=1,Started=session.Started,
		OnFinish=function(score:number,victory:boolean) GameService.Finish(player,score,victory) end,
		onFinish=function(score:number,victory:boolean) GameService.Finish(player,score,victory) end,
		onAction=function(payload:any) end}
	local ok,mod=safeCall(function() return require(module) end)
	if not ok or type(mod)~="table" or type(mod.start)~="function" then sessions[player]=nil; folder:Destroy(); return false end
	local okStart=safeCall(function() mod.start(ctx) end)
	if not okStart then sessions[player]=nil; folder:Destroy(); return false end
	session.Module=mod; session.Context=ctx
	Remotes.GameStateChanged:FireClient(player,{State="Started",GameId=id,Duration=def.Duration})
	task.delay(def.Duration,function()
		if sessions[player]==session then GameService.Finish(player,ctx.Score,true) end
	end)
	return true
end
function GameService.Action(player:Player,payload:any)
	local s=sessions[player]; if not s or not s.Locked then return end
	if os.clock()-s.ActionAt<0.03 then return end
	s.ActionAt=os.clock()
	if typeof(payload)~="table" then return end
	if typeof(payload.Action)~="string" or #payload.Action>32 then return end
	if payload.Value~=nil and typeof(payload.Value)~="number" and typeof(payload.Value)~="string" and typeof(payload.Value)~="boolean" then return end
	if s.Context and type(s.Context.onAction)=="function" then
		safeCall(function() s.Context:onAction(payload) end)
	end
end
function GameService.Finish(player:Player,score:number,victory:boolean)
	local s=sessions[player]; if not s or not s.Locked then return end
	s.Locked=false
	local def=Config.GetGame(s.Id); local max=def and def.MaxScore or Config.MaxPerGame
	score=math.clamp(tonumber(score) or 0,0,max)
	if s.Context then s.Context.Score=score end
	if s.Module and type(s.Module.cleanup)=="function" then safeCall(function() s.Module.cleanup(player) end) end
	if s.Context and s.Context.World and s.Context.World.Parent then s.Context.World:Destroy() end
	sessions[player]=nil
	Remotes.GameStateChanged:FireClient(player,{State="Finished",GameId=s.Id,Score=score,Victory=victory==true})
end
function GameService.Stop(player:Player) if sessions[player] then GameService.Finish(player,0,false) end end
function GameService.IsPlaying(player:Player) return sessions[player]~=nil end
Remotes.RequestStart.OnServerEvent:Connect(function(player,payload)
	if typeof(payload)~="table" or typeof(payload.GameId)~="string" then return end
	GameService.Start(player,payload.GameId)
end)
Remotes.RequestAction.OnServerEvent:Connect(function(player,payload) GameService.Action(player,payload) end)
Players.PlayerRemoving:Connect(function(p) GameService.Stop(p) end)
return GameService
