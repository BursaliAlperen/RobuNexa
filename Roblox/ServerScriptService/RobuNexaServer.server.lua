-- ROBUNEXA // AAA STUDDED EDITION
-- ONLY REQUIRED SERVER SCRIPT
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local DSS=game:GetService("DataStoreService")
local RunService=game:GetService("RunService")

local remotes=RS:FindFirstChild("RobuNexaRemotes") or Instance.new("Folder")
remotes.Name="RobuNexaRemotes"; remotes.Parent=RS
local function R(n)
 local x=remotes:FindFirstChild(n) or Instance.new("RemoteEvent"); x.Name=n; x.Parent=remotes; return x
end
local Start=R("Start"); local Action=R("Action"); local State=R("State"); local Exit=R("Exit"); local World=R("World"); local Leaderboard=R("Leaderboard")

local Games={
 DodgeRun={name="DODGE RUN",duration=30,max=10000,accent=Color3.fromRGB(240,75,62)},
 TargetRush={name="TARGET RUSH",duration=30,max=10000,accent=Color3.fromRGB(65,145,240)},
 StackTower={name="STACK TOWER",duration=30,max=10000,accent=Color3.fromRGB(245,145,35)},
 CoinRush={name="COIN RUSH",duration=30,max=10000,accent=Color3.fromRGB(255,210,60)},
 FloorIsLava={name="FLOOR IS LAVA",duration=30,max=10000,accent=Color3.fromRGB(255,72,48)}
}
local BestStore=DSS:GetDataStore("RobuNexa_AAA_v1")
local WorldRoot=workspace:FindFirstChild("RobuNexaWorld") or Instance.new("Folder")
WorldRoot.Name="RobuNexaWorld"; WorldRoot.Parent=workspace
local sessions={}; local cooldown={}; local nextSlot=0; local freeSlots={}

local function fire(p,d) if p and p.Parent then State:FireClient(p,d) end end
local function part(parent,name,size,cf,color,mat,trans)
 local x=Instance.new("Part"); x.Name=name; x.Size=size; x.CFrame=cf; x.Anchored=true; x.CanCollide=true; x.CanTouch=true; x.CanQuery=true
 x.Color=color; x.Material=mat or Enum.Material.SmoothPlastic; x.Transparency=trans or 0; x.Parent=parent; return x
end
local function burst(root,pos,color,n)
 local a=Instance.new("Part"); a.Name="FX"; a.Size=Vector3.new(.2,.2,.2); a.CFrame=CFrame.new(pos); a.Anchored=true; a.CanCollide=false; a.CanTouch=false; a.Transparency=1; a.Parent=root
 local e=Instance.new("ParticleEmitter"); e.Texture="rbxasset://textures/particles/sparkles_main.dds"; e.Color=ColorSequence.new(color); e.LightEmission=.9; e.Rate=0; e.Lifetime=NumberRange.new(.2,.6); e.Speed=NumberRange.new(7,15); e.SpreadAngle=Vector2.new(180,180); e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.42),NumberSequenceKeypoint.new(1,0)}); e.Parent=a; e:Emit(n or 18)
 task.delay(.8,function() if a.Parent then a:Destroy() end end)
end
local function teleport(p,pos)
 local c=p.Character; if c and c:FindFirstChild("HumanoidRootPart") then c:PivotTo(CFrame.new(pos)) end
end
local function slot()
 if #freeSlots>0 then return table.remove(freeSlots,1) end
 nextSlot+=1; return nextSlot
end
local function releaseSlot(n) table.insert(freeSlots,n); table.sort(freeSlots) end
local function score(p,n,reset)
 local s=sessions[p]; if not s then return end
 if reset then s.combo=0; s.multiplier=1 else s.combo=math.min(s.combo+1,25); s.multiplier=math.min(1+math.floor(s.combo/5),5) end
 s.score=math.clamp(s.score+n*s.multiplier,0,s.max); fire(p,{state="Score",score=math.floor(s.score),combo=s.combo,multiplier=s.multiplier})
end
local function touchOK(s,key,t)
 local now=os.clock(); s.touches=s.touches or {}; local last=s.touches[key] or 0
 if now-last<t then return false end; s.touches[key]=now; return true
end
local function touch(s,p,fn)
 p.Touched:Connect(function(hit) if s.alive and hit and hit.Parent==s.player.Character then fn(hit) end end)
end
local function common(s)
 local o=s.origin; local c=s.accent
 part(s.root,"Floor",Vector3.new(96,2,74),CFrame.new(o),c,Enum.Material.SmoothPlastic)
 part(s.root,"BackWall",Vector3.new(96,18,2),CFrame.new(o+Vector3.new(0,9,-37)),c,Enum.Material.Concrete)
 part(s.root,"LeftWall",Vector3.new(2,18,74),CFrame.new(o+Vector3.new(-48,9,0)),c,Enum.Material.Concrete)
 part(s.root,"RightWall",Vector3.new(2,18,74),CFrame.new(o+Vector3.new(48,9,0)),c,Enum.Material.Concrete)
 for x=-40,40,8 do part(s.root,"Stud"..x,Vector3.new(2.2,.6,2.2),CFrame.new(o+Vector3.new(x,1.3,33)),c,Enum.Material.Neon) end
end

local function setupDodge(s)
 local o=s.origin; s.spawn=o+Vector3.new(0,5,28); fire(s.player,{state="Objective",text="MOVE • DODGE • CROSS THE GATES"})
 for i=1,6 do
  local g=part(s.root,"Gate"..i,Vector3.new(88,.7,1.5),CFrame.new(o+Vector3.new(0,2,20-i*8)),s.accent,Enum.Material.Neon,.75); g.CanCollide=false
  touch(s,g,function() if not g:GetAttribute("Scored") then g:SetAttribute("Scored",true); score(s.player,18,false); fire(s.player,{state="Progress",value=i/6}) end end)
 end
 s.obstacles={}
 for i=1,8 do
  local o2=part(s.root,"Obstacle"..i,Vector3.new(14,5.5,3),CFrame.new(o+Vector3.new(0,3.5,22-i*6)),Color3.fromRGB(30,30,35),Enum.Material.Metal)
  table.insert(s.obstacles,o2)
  touch(s,o2,function() if touchOK(s,"hit"..i,.8) then score(s.player,-24,true); teleport(s.player,s.spawn); fire(s.player,{state="Hit"}); burst(s.root,o2.Position,Color3.fromRGB(255,70,60),24) end end)
 end
 table.insert(s.connections,RunService.Heartbeat:Connect(function()
  for i,o2 in ipairs(s.obstacles) do if o2.Parent then o2.CFrame=CFrame.new(o+Vector3.new(math.sin(os.clock()*1.5+i)*30,3.5,22-i*6)) end end
 end))
end

local function setupTargets(s)
 local o=s.origin; s.spawn=o+Vector3.new(0,5,26); fire(s.player,{state="Objective",text="TOUCH THE NEON TARGETS"})
 s.targets={}
 for i=1,12 do
  local a=i/12*math.pi*2; local r=(i%2==0) and 27 or 17
  local t=part(s.root,"Target"..i,Vector3.new(5.5,5.5,1.2),CFrame.lookAt(o+Vector3.new(math.cos(a)*r,5+(i%3)*2,math.sin(a)*r),o+Vector3.new(0,5,0)),i%2==0 and Color3.fromRGB(255,70,70) or Color3.fromRGB(255,170,45),Enum.Material.Neon)
  t.CanCollide=false; t:SetAttribute("Active",true); table.insert(s.targets,t)
 end
 table.insert(s.connections,RunService.Heartbeat:Connect(function(dt)
  for i,t in ipairs(s.targets) do if t.Parent then t.CFrame=t.CFrame*CFrame.Angles(0,0,dt*1.8) end end
 end))
end

local function setupStack(s)
 local o=s.origin; s.spawn=o+Vector3.new(0,5,25); s.stack={height=0,width=12,lastX=o.X,direction=1}
 part(s.root,"Base",Vector3.new(14,2,14),CFrame.new(o+Vector3.new(0,1,0)),s.accent,Enum.Material.Neon)
 s.stack.current=part(s.root,"MovingBlock",Vector3.new(12,2,12),CFrame.new(o+Vector3.new(-28,3,0)),Color3.fromRGB(255,215,70),Enum.Material.Neon)
 fire(s.player,{state="Objective",text="DROP WHEN THE BLOCK IS ALIGNED"})
 table.insert(s.connections,RunService.Heartbeat:Connect(function(dt)
  local b=s.stack.current; if not s.alive or not b or not b.Parent then return end
  local x=b.Position.X+s.stack.direction*18*dt
  if x>o.X+28 then s.stack.direction=-1; x=o.X+28 end
  if x<o.X-28 then s.stack.direction=1; x=o.X-28 end
  b.CFrame=CFrame.new(x,b.Position.Y,o.Z)
 end))
end

local function setupCoins(s)
 local o=s.origin; s.spawn=o+Vector3.new(0,5,25); fire(s.player,{state="Objective",text="COLLECT COINS • BUILD COMBO"}); s.coins={}
 for i=1,36 do
  local a=i*.6; local c=part(s.root,"Coin"..i,Vector3.new(2.6,2.6,2.6),CFrame.new(o+Vector3.new(math.cos(a)*32,3+(i%3),math.sin(a)*23)),Color3.fromRGB(255,210,55),Enum.Material.Neon)
  c.Shape=Enum.PartType.Ball; c.CanCollide=false; c:SetAttribute("Taken",false); table.insert(s.coins,c)
  touch(s,c,function()
   if c:GetAttribute("Taken") then return end
   c:SetAttribute("Taken",true); c.CanTouch=false; c.Transparency=1; score(s.player,20,false); burst(s.root,c.Position,Color3.fromRGB(255,220,80),20)
   task.delay(.8,function() if s.alive and c.Parent then c.CFrame=CFrame.new(o+Vector3.new(math.random(-34,34),math.random(2,7),math.random(-25,25))); c.Transparency=0; c.CanTouch=true; c:SetAttribute("Taken",false) end end)
  end)
 end
 table.insert(s.connections,RunService.Heartbeat:Connect(function(dt) for _,c in ipairs(s.coins) do if c.Parent and not c:GetAttribute("Taken") then c.CFrame=c.CFrame*CFrame.Angles(0,dt*4,0) end end end))
end

local function setupLava(s)
 local o=s.origin; s.spawn=o+Vector3.new(0,6,28); fire(s.player,{state="Objective",text="GREEN IS SAFE • LAVA IS RISING"})
 for i=1,25 do
  local x=((i-1)%5-2)*14; local z=20-math.floor((i-1)/5)*10; local safe=(i%4~=0)
  local t=part(s.root,"Tile"..i,Vector3.new(11,1.3,8),CFrame.new(o+Vector3.new(x,2,z)),safe and Color3.fromRGB(75,205,110) or Color3.fromRGB(230,60,45),Enum.Material.Neon)
  if safe then touch(s,t,function() if touchOK(s,"safe"..i,.35) then score(s.player,8,false) end end) end
 end
 local lava=part(s.root,"RisingLava",Vector3.new(96,2,74),CFrame.new(o+Vector3.new(0,-6,0)),Color3.fromRGB(255,55,35),Enum.Material.Neon,.1); lava.CanCollide=false; s.lava=lava
 touch(s,lava,function() if touchOK(s,"lava",.5) then score(s.player,-30,true); teleport(s.player,s.spawn); fire(s.player,{state="Hit"}); burst(s.root,lava.Position,Color3.fromRGB(255,75,35),28) end end)
 table.insert(s.connections,RunService.Heartbeat:Connect(function() if s.alive and lava.Parent then lava.CFrame=CFrame.new(o+Vector3.new(0,-6+math.clamp((os.clock()-s.started)*.62,0,13),0)) end end))
end

local function build(p,id)
 if sessions[p] then return end
 local sl=slot(); local o=Vector3.new((sl-1)*150,0,0); local r=Instance.new("Folder"); r.Name="Arena_"..p.UserId; r.Parent=WorldRoot
 local g=Games[id]; local s={player=p,gameId=id,name=g.name,duration=g.duration,max=g.max,accent=g.accent,slot=sl,origin=o,root=r,score=0,combo=0,multiplier=1,alive=true,started=os.clock(),connections={},touches={}}
 sessions[p]=s; common(s)
 if id=="DodgeRun" then setupDodge(s) elseif id=="TargetRush" then setupTargets(s) elseif id=="StackTower" then setupStack(s) elseif id=="CoinRush" then setupCoins(s) elseif id=="FloorIsLava" then setupLava(s) end
 teleport(p,s.spawn); World:FireClient(p,{state="WorldReady",gameId=id,origin=o,accent=g.accent})
end

local function finish(p,why)
 local s=sessions[p]; if not s then return end; s.alive=false
 for _,c in ipairs(s.connections) do if typeof(c)=="RBXScriptConnection" then c:Disconnect() end end
 if s.root and s.root.Parent then s.root:Destroy() end
 sessions[p]=nil; releaseSlot(s.slot)
 local final=math.floor(math.clamp(s.score,0,s.max)); local best=final
 local ok,res=pcall(function() return BestStore:UpdateAsync(tostring(p.UserId)..":"..s.gameId,function(old) return math.max(tonumber(old) or 0,final) end) end)
 if ok and tonumber(res) then best=tonumber(res) end
 fire(p,{state="Finished",gameId=s.gameId,gameName=s.name,score=final,best=best,reason=why or "TIME"})
end

Start.OnServerEvent:Connect(function(p,id)
 if typeof(id)~="string" or not Games[id] or sessions[p] then return end
 build(p,id); local s=sessions[p]; if not s then return end
 fire(p,{state="Started",gameId=id,gameName=s.name,duration=s.duration})
 task.spawn(function() for t=s.duration,0,-1 do if sessions[p]~=s or not s.alive then return end; fire(p,{state="Time",time=t}); task.wait(1) end; if sessions[p]==s then finish(p,"TIME") end end)
end)

Action.OnServerEvent:Connect(function(p,id,data)
 local s=sessions[p]; if not s or s.gameId~=id or not s.alive or typeof(data)~="table" then return end
 if os.clock()-(cooldown[p] or 0)<.08 then return end; cooldown[p]=os.clock()
 if id=="TargetRush" and data.kind=="target" then
  local t=s.root:FindFirstChild(tostring(data.name or "")); local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
  if t and t:IsA("BasePart") and t:GetAttribute("Active") and hrp and (hrp.Position-t.Position).Magnitude<=90 then
   t:SetAttribute("Active",false); t.Transparency=1; score(p,30,false); burst(s.root,t.Position,s.accent,24); fire(p,{state="TargetHit"})
   task.delay(.55,function() if s.alive and t.Parent then t.Transparency=0; t:SetAttribute("Active",true) end end)
  end
 elseif id=="StackTower" and data.kind=="stack" then
  local st=s.stack; local b=st and st.current; if not b or not b.Parent then return end
  local overlap=st.width/2+b.Size.X/2-math.abs(b.Position.X-st.lastX)
  if overlap<=1 then
   burst(s.root,b.Position,Color3.fromRGB(255,70,55),24); score(p,-30,true); fire(p,{state="StackMiss"}); b:Destroy(); st.height=0; st.width=12; st.lastX=s.origin.X; st.current=part(s.root,"MovingBlock",Vector3.new(12,2,12),CFrame.new(s.origin+Vector3.new(-28,3,0)),Color3.fromRGB(255,215,70),Enum.Material.Neon)
   return
  end
  local center=(b.Position.X+st.lastX)/2; st.height+=1; st.width=math.min(overlap,12); st.lastX=center; local y=3+(st.height-1)*2.05
  local locked=part(s.root,"Stack"..st.height,Vector3.new(st.width,2,12),CFrame.new(center,y,s.origin.Z),Color3.fromRGB(245,130,30),Enum.Material.Neon); burst(s.root,locked.Position,Color3.fromRGB(255,175,55),20)
  b:Destroy(); st.current=part(s.root,"MovingBlock",Vector3.new(st.width,2,12),CFrame.new(s.origin.X-28,y+2.05,s.origin.Z),Color3.fromRGB(255,220,75),Enum.Material.Neon); score(p,20,false); fire(p,{state="Progress",value=math.clamp(st.height/15,0,1)})
 end
end)

Exit.OnServerEvent:Connect(function(p) if sessions[p] then finish(p,"EXIT") end end)
Leaderboard.OnServerEvent:Connect(function(p,id)
 if typeof(id)~="string" or not Games[id] then return end
 local rows={}; for other,s in pairs(sessions) do if s.gameId==id then table.insert(rows,{userId=other.UserId,name=other.Name,score=math.floor(s.score)}) end end
 table.sort(rows,function(a,b) return a.score>b.score end); for i=1,math.min(10,#rows) do rows[i].rank=i end; Leaderboard:FireClient(p,rows)
end)
Players.PlayerRemoving:Connect(function(p) if sessions[p] then finish(p,"LEAVE") end; cooldown[p]=nil end)
print("[RobuNexa][AAA] 5-game studded build online")
