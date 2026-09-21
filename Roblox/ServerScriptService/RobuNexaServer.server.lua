--!strict
-- ROBUNEXA SINGLE SERVER
-- Put ONLY this Script in:
-- ServerScriptService > RobuNexaServer
--
-- No ModuleScripts are required for the basic game hub.
-- This script creates remotes, sessions, scoring and leaderboards.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local REMOTES = ReplicatedStorage:FindFirstChild("RobuNexaRemotes") or Instance.new("Folder")
REMOTES.Name="RobuNexaRemotes"; REMOTES.Parent=ReplicatedStorage

local function remote(name)
	local r=REMOTES:FindFirstChild(name) or Instance.new("RemoteEvent")
	r.Name=name; r.Parent=REMOTES; return r
end
local Start=remote("Start")
local Action=remote("Action")
local State=remote("State")
local Leaderboard=remote("Leaderboard")

local games={
	DodgeRun={name="Dodge Run",max=10000,duration=30},
	TargetRush={name="Target Rush",max=10000,duration=30},
	StackTower={name="Stack Tower",max=10000,duration=30},
	CoinRush={name="Coin Rush",max=10000,duration=30},
	JumpChallenge={name="Jump Challenge",max=10000,duration=30},
	ReactionTest={name="Reaction Test",max=10000,duration=30},
	ColorRush={name="Color Rush",max=10000,duration=30},
	MemoryMatch={name="Memory Match",max=10000,duration=30},
	FallingPlatforms={name="Falling Platforms",max=10000,duration=30},
	FloorIsLava={name="Floor Is Lava",max=10000,duration=30},
}

local store=DataStoreService:GetDataStore("RobuNexa_v2")
local boards={}
local sessions={}
local cooldown={}

local function fire(p,data) if p and p.Parent then State:FireClient(p,data) end end

local function saveBest(p,gameId,score)
	local key=tostring(p.UserId)..":"..gameId
	task.spawn(function()
		pcall(function()
			store:UpdateAsync(key,function(old)
				old=tonumber(old) or 0
				return math.max(old,score)
			end)
		end)
	end)
end

local function finish(p)
	local s=sessions[p]
	if not s then return end
	sessions[p]=nil
	s.alive=false
	local score=math.clamp(math.floor(s.score),0,s.max)
	saveBest(p,s.gameId,score)
	fire(p,{state="Finished",gameId=s.gameId,gameName=s.name,score=score})
end

Start.OnServerEvent:Connect(function(p,gameId)
	if typeof(gameId)~="string" or not games[gameId] or sessions[p] then return end
	local g=games[gameId]
	local s={gameId=gameId,name=g.name,max=g.max,duration=g.duration,score=0,combo=0,multiplier=1,alive=true,lastAction=0}
	sessions[p]=s
	fire(p,{state="Started",gameId=gameId})
	task.spawn(function()
		for t=g.duration,0,-1 do
			if sessions[p]~=s or not s.alive then return end
			fire(p,{state="Time",time=t})
			task.wait(1)
		end
		if sessions[p]==s then finish(p) end
	end)
end)

Action.OnServerEvent:Connect(function(p,gameId,payload)
	local s=sessions[p]
	if not s or s.gameId~=gameId or not s.alive then return end
	local now=os.clock()
	if now-(cooldown[p] or 0)<0.08 then return end
	cooldown[p]=now
	if typeof(payload)~="table" then return end
	s.combo=math.min(s.combo+1,20)
	s.multiplier=math.min(1+math.floor(s.combo/5),5)
	local gain=math.random(8,24)*s.multiplier
	s.score=math.clamp(s.score+gain,0,s.max)
	fire(p,{state="Score",score=s.score,combo=s.combo,multiplier=s.multiplier})
end)

Leaderboard.OnServerEvent:Connect(function(p,gameId)
	if typeof(gameId)~="string" or not games[gameId] then return end
	-- Lightweight local-session leaderboard. Persistent best scores are still saved above.
	local rows={}
	for other,s in pairs(sessions) do
		if s.gameId==gameId then table.insert(rows,{userId=other.UserId,name=other.Name,score=math.floor(s.score)}) end
	end
	table.sort(rows,function(a,b) return a.score>b.score end)
	local out={}
	for i=1,math.min(10,#rows) do rows[i].rank=i; table.insert(out,rows[i]) end
	Leaderboard:FireClient(p,out)
end)

Players.PlayerRemoving:Connect(function(p)
	if sessions[p] then finish(p) end
	sessions[p]=nil; cooldown[p]=nil
end)

print("[RobuNexa] Single-script server bootstrap ready.")
