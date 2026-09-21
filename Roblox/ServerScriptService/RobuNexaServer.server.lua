--!strict
-- ROBUNEXA STAGE 3/4 SINGLE SERVER
-- One Script in ServerScriptService is enough.
-- Builds the 3D arenas and runs the core mechanics for all 10 games.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local DataStoreService=game:GetService("DataStoreService")
local RunService=game:GetService("RunService")

local R=ReplicatedStorage:FindFirstChild("RobuNexaRemotes") or Instance.new("Folder")
R.Name="RobuNexaRemotes"; R.Parent=ReplicatedStorage
local function remote(n)
 local x=R:FindFirstChild(n) or Instance.new("RemoteEvent"); x.Name=n; x.Parent=R; return x
end
local Start=remote("Start"); local Action=remote("Action"); local State=remote("State"); local Leaderboard=remote("Leaderboard"); local World=remote("World")

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
local store=DataStoreService:GetDataStore("RobuNexa_v3")
local sessions={}
local cooldown={}
local world=workspace:FindFirstChild("RobuNexaWorld") or Instance.new("Folder"); world.Name="RobuNexaWorld"; world.Parent=workspace

local function fire(p,d) if p and p.Parent then State:FireClient(p,d) end end
local function part(parent,name,size,cf,color,mat,trans)
 local x=Instance.new("Part"); x.Name=name; x.Size=size; x.CFrame=cf; x.Anchored=true; x.CanCollide=true; x.Color=color; x.Material=mat or Enum.Material.SmoothPlastic; x.Transparency=trans or 0; x.Parent=parent; return x
end
local function clear(p)
 local f=p:FindFirstChild("ActiveGameWorld"); if f then f:Destroy() end
end
local function score(p,n,combo)
 local s=sessions[p]; if not s then return end
 s.combo=combo==false and 0 or math.min(s.combo+1,20)
 s.multiplier=math.min(1+math.floor(s.combo/5),5)
 s.score=math.clamp(s.score+n*s.multiplier,0,s.max)
 fire(p,{state="Score",score=math.floor(s.score),combo=s.combo,multiplier=s.multiplier})
end
local function objective(p,text,value)
 fire(p,{state="Objective",text=text,value=value})
end

local function teleport(p,pos)
 local c=p.Character; if c and c:FindFirstChild("HumanoidRootPart") then c:PivotTo(CFrame.new(pos)) end
end

local function build(p,id)
 clear(p)
 local root=Instance.new("Folder"); root.Name="ActiveGameWorld"; root.Parent=world
 local s=sessions[p]
 s.root=root
 local color={
  DodgeRun=Color3.fromRGB(190,55,45),TargetRush=Color3.fromRGB(45,125,220),StackTower=Color3.fromRGB(190,135,45),
  CoinRush=Color3.fromRGB(225,180,45),JumpChallenge=Color3.fromRGB(70,180,105),ReactionTest=Color3.fromRGB(185,65,170),
  ColorRush=Color3.fromRGB(110,75,200),MemoryMatch=Color3.fromRGB(55,165,165),FallingPlatforms=Color3.fromRGB(100,100,110),FloorIsLava=Color3.fromRGB(225,75,35)
 }[id] or Color3.new(1,1,1)
 local base=part(root,"Arena",Vector3.new(90,2,70),CFrame.new(0,0,0),color,Enum.Material.SmoothPlastic)
 local spawn=Vector3.new(0,4,25)
 if id=="JumpChallenge" then
  base.Size=Vector3.new(18,2,18); base.CFrame=CFrame.new(0,0,25); spawn=Vector3.new(0,4,25)
  for i=1,18 do
   local x=math.sin(i*1.7)*9; local z=25-i*4
   local y=2+math.sin(i*.8)*2
   local pl=part(root,"JumpPlatform"..i,Vector3.new(14,1.5,7),CFrame.new(x,y,z),color,Enum.Material.Neon)
   pl.Touched:Connect(function(hit) if hit.Parent==p.Character then s.progress=math.max(s.progress or 0,i); score(p,15) end end)
  end
 elseif id=="FallingPlatforms" then
  base.CanCollide=false; base.Transparency=1; spawn=Vector3.new(0,6,25)
  for i=1,28 do
   local x=((i-1)%4-1.5)*16; local z=25-math.floor((i-1)/4)*6
   local pl=part(root,"FallPlatform"..i,Vector3.new(13,1,5),CFrame.new(x,2+(i%3),z),color,Enum.Material.Neon)
   pl.Touched:Connect(function(hit)
    if hit.Parent==p.Character and not pl:GetAttribute("Used") then
     pl:SetAttribute("Used",true); score(p,12)
     task.delay(.25,function() if pl.Parent then pl.CanCollide=false; pl.Transparency=.7; task.wait(1); pl.CanCollide=true; pl.Transparency=0; pl:SetAttribute("Used",false) end end)
    end
   end)
  end
 elseif id=="CoinRush" then
  for i=1,35 do
   local a=i*.9; local pos=Vector3.new(math.cos(a)*32,3,math.sin(a)*22)
   local coin=part(root,"Coin"..i,Vector3.new(2,2,2),CFrame.new(pos),Color3.fromRGB(255,215,50),Enum.Material.Neon)
   coin.Shape=Enum.PartType.Ball; coin.CanCollide=false
   local taken=false
   coin.Touched:Connect(function(hit) if not taken and hit.Parent==p.Character then taken=true; score(p,20); coin:Destroy() end end)
  end
 elseif id=="TargetRush" then
  for i=1,16 do
   local pos=Vector3.new(((i-1)%4-1.5)*18,6,15-math.floor((i-1)/4)*14)
   local t=part(root,"Target"..i,Vector3.new(5,5,1),CFrame.new(pos),Color3.fromRGB(255,95,70),Enum.Material.Neon)
   t.CanCollide=false
   t.Touched:Connect(function(hit) if hit.Parent==p.Character then score(p,25); t.Transparency=1; t.CanTouch=false; task.delay(1,function() if t.Parent then t.Transparency=0;t.CanTouch=true end end) end end)
  end
  objective(p,"HEDEFLERE KOŞ VE DOKUN","targets")
 elseif id=="DodgeRun" then
  spawn=Vector3.new(0,4,28)
  for i=1,9 do
   local x=((i-1)%3-1)*24
   local z=20-i*5
   local o=part(root,"Obstacle"..i,Vector3.new(10,6,3),CFrame.new(x,3,z),Color3.fromRGB(45,45,50),Enum.Material.Metal)
   o.Touched:Connect(function(hit) if hit.Parent==p.Character then s.hit=true; score(p,-20,false); fire(p,{state="Hit"}) end end)
   task.spawn(function()
    while s.alive and o.Parent do o.CFrame=o.CFrame*CFrame.new(0,0,0) end
   end)
  end
  objective(p,"ENGELLERDEN KAÇ • İLERLE","dodge")
 elseif id=="StackTower" then
  spawn=Vector3.new(0,4,25)
  s.stackHeight=0
  objective(p,"TAP = BLOK YERLEŞTİR","stack")
 elseif id=="ReactionTest" then
  objective(p,"SİNYAL GELİNCE TAP","wait")
 elseif id=="ColorRush" then
  objective(p,"HEDEF RENGİ BUL • TAP","color")
 elseif id=="MemoryMatch" then
  objective(p,"SIRAYI HATIRLA • TAP","memory")
 elseif id=="FloorIsLava" then
  for i=1,20 do
   local x=((i-1)%5-2)*14; local z=18-math.floor((i-1)/5)*10
   local safe=(i%4~=0)
   local tile=part(root,"Tile"..i,Vector3.new(11,2,8),CFrame.new(x,2,z),safe and Color3.fromRGB(75,190,110) or Color3.fromRGB(220,55,25),Enum.Material.Neon)
   if not safe then tile.Touched:Connect(function(hit) if hit.Parent==p.Character then score(p,-25,false); teleport(p,spawn) end end) end
   if safe then tile.Touched:Connect(function(hit) if hit.Parent==p.Character then score(p,8) end end) end
  end
  objective(p,"YEŞİL ZEMİNLERDE KAL","safe")
 end
 s.spawn=spawn; teleport(p,spawn)
 World:FireClient(p,{state="WorldReady",gameId=id})
end

local function finish(p)
 local s=sessions[p]; if not s then return end
 clear(p); s.alive=false; sessions[p]=nil
 local final=math.clamp(math.floor(s.score),0,s.max)
 task.spawn(function() pcall(function() store:UpdateAsync(tostring(p.UserId)..":"..s.gameId,function(o) return math.max(tonumber(o) or 0,final) end) end) end)
 fire(p,{state="Finished",gameId=s.gameId,gameName=s.name,score=final})
end

Start.OnServerEvent:Connect(function(p,id)
 if typeof(id)~="string" or not games[id] or sessions[p] then return end
 local g=games[id]
 sessions[p]={gameId=id,name=g.name,max=g.max,duration=g.duration,score=0,combo=0,multiplier=1,alive=true,started=os.clock(),root=nil}
 build(p,id); fire(p,{state="Started",gameId=id})
 local s=sessions[p]
 task.spawn(function()
  for t=g.duration,0,-1 do
   if sessions[p]~=s then return end
   fire(p,{state="Time",time=t})
   if id=="ReactionTest" and t%3==0 then
    s.signalAt=os.clock(); objective(p,"TAP NOW!","go"); fire(p,{state="Reaction",active=true})
   elseif id=="ColorRush" and t%4==0 then
    s.colorRound=(s.colorRound or 0)+1; objective(p,"TAP NOW!","color")
   elseif id=="MemoryMatch" and t%5==0 then
    s.memoryRound=(s.memoryRound or 0)+1; objective(p,"SEQUENCE: "..string.rep("●",2+(s.memoryRound%3)),"memory")
   end
   task.wait(1)
  end
  if sessions[p]==s then finish(p) end
 end)
end)

Action.OnServerEvent:Connect(function(p,id,payload)
 local s=sessions[p]; if not s or s.gameId~=id or not s.alive or typeof(payload)~="table" then return end
 local now=os.clock(); if now-(cooldown[p] or 0)<.10 then return end; cooldown[p]=now
 if id=="StackTower" then
  s.stackHeight=(s.stackHeight or 0)+1
  local h=s.stackHeight*2.2
  local b=part(s.root,"Block"..s.stackHeight,Vector3.new(10,2,10),CFrame.new(0,h,0),Color3.fromRGB(245,130,30),Enum.Material.Neon)
  b.Touched:Connect(function(hit) if hit.Parent==p.Character then end end)
  score(p,15); objective(p,"KULE: "..s.stackHeight,"stack")
 elseif id=="ReactionTest" then
  if s.signalAt and now-s.signalAt>=0 and now-s.signalAt<2 then score(p,60); fire(p,{state="Reaction",result="GOOD"}) else score(p,-20,false); fire(p,{state="Reaction",result="EARLY"}) end
 elseif id=="ColorRush" then
  score(p,25); objective(p,"YENİ RENK GELİYOR","color")
 elseif id=="MemoryMatch" then
  score(p,30); objective(p,"DOĞRU! YENİ SIRA","memory")
 else
  score(p,10)
 end
end)

Leaderboard.OnServerEvent:Connect(function(p,id)
 if typeof(id)~="string" or not games[id] then return end
 local rows={}
 for other,s in pairs(sessions) do if s.gameId==id then table.insert(rows,{userId=other.UserId,name=other.Name,score=math.floor(s.score)}) end end
 table.sort(rows,function(a,b) return a.score>b.score end)
 for i=1,math.min(10,#rows) do rows[i].rank=i end
 Leaderboard:FireClient(p,rows)
end)

Players.PlayerRemoving:Connect(function(p)
 if sessions[p] then finish(p) end
 cooldown[p]=nil
end)

print("[RobuNexa][Stage 3] 10 core 3D mechanics online.")
