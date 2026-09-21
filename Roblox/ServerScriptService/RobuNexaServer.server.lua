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
local RunService = game:GetService("RunService")

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
local World=remote("World")

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

local hub=workspace:FindFirstChild("RobuNexaWorld") or Instance.new("Folder")
hub.Name="RobuNexaWorld"; hub.Parent=workspace

local function part(parent,name,size,cf,color,material,transparency)
 local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf; p.Anchored=true; p.CanCollide=true; p.Color=color; p.Material=material or Enum.Material.SmoothPlastic; p.Transparency=transparency or 0; p.Parent=parent; return p
end
local function clearWorld(p)
 local old=p:FindFirstChild("ActiveGameWorld"); if old then old:Destroy() end
end
local function buildWorld(p,gameId)
 clearWorld(p)
 local root=Instance.new("Folder"); root.Name="ActiveGameWorld"; root.Parent=p
 local defs={
  DodgeRun={Color=Color3.fromRGB(180,45,40),Size=Vector3.new(90,2,90)},
  TargetRush={Color=Color3.fromRGB(40,120,210),Size=Vector3.new(80,2,80)},
  StackTower={Color=Color3.fromRGB(180,120,40),Size=Vector3.new(55,2,55)},
  CoinRush={Color=Color3.fromRGB(210,170,40),Size=Vector3.new(85,2,85)},
  JumpChallenge={Color=Color3.fromRGB(70,170,100),Size=Vector3.new(100,2,55)},
  ReactionTest={Color=Color3.fromRGB(180,60,160),Size=Vector3.new(65,2,65)},
  ColorRush={Color=Color3.fromRGB(90,70,180),Size=Vector3.new(75,2,75)},
  MemoryMatch={Color=Color3.fromRGB(50,150,150),Size=Vector3.new(70,2,70)},
  FallingPlatforms={Color=Color3.fromRGB(90,90,100),Size=Vector3.new(100,2,60)},
  FloorIsLava={Color=Color3.fromRGB(220,70,30),Size=Vector3.new(90,2,90)},
 }
 local d=defs[gameId] or defs.DodgeRun
 part(root,"Arena",d.Size,CFrame.new(0,0,0),d.Color,Enum.Material.SmoothPlastic)
 part(root,"BackWall",Vector3.new(d.Size.X,18,2),CFrame.new(0,9,-d.Size.Z/2),d.Color,Enum.Material.Concrete)
 part(root,"LeftWall",Vector3.new(2,18,d.Size.Z),CFrame.new(-d.Size.X/2,9,0),d.Color,Enum.Material.Concrete)
 part(root,"RightWall",Vector3.new(2,18,d.Size.Z),CFrame.new(d.Size.X/2,9,0),d.Color,Enum.Material.Concrete)
 local spawn=part(root,"Spawn",Vector3.new(8,1,8),CFrame.new(0,2,0),Color3.fromRGB(250,220,160),Enum.Material.Neon)
 spawn.CanCollide=false
 for i=1,8 do
  local x=((i-1)%4-1.5)*(d.Size.X/5)
  local z=(math.floor((i-1)/4)-.5)*(d.Size.Z/3)
  local h=2+((i*7)%5)
  part(root,"Decor_"..i,Vector3.new(4,h,4),CFrame.new(x,h/2,z),d.Color,Enum.Material.Neon,.1)
 end
 local spawnLocation=Instance.new("SpawnLocation"); spawnLocation.Name="GameSpawn"; spawnLocation.Size=Vector3.new(8,1,8); spawnLocation.CFrame=CFrame.new(0,3,0); spawnLocation.Anchored=true; spawnLocation.Neutral=true; spawnLocation.Transparency=1; spawnLocation.CanCollide=false; spawnLocation.Parent=root
 if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character:PivotTo(CFrame.new(0,5,0)) end
 World:FireClient(p,{state="WorldReady",gameId=gameId})
end

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
	clearWorld(p)

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
	buildWorld(p,gameId)
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
	clearWorld(p)
	sessions[p]=nil; cooldown[p]=nil
end)

print("[RobuNexa][Stage 3] Game selection -> 3D world bootstrap ready.")
