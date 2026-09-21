--!strict
-- ROBUNEXA SINGLE SERVER
-- 1 Script only: ServerScriptService > RobuNexaServer
-- Stage 4: 10 complete core mini-game mechanics, server-authoritative scoring,
-- isolated player arenas, mobile-safe interaction, VFX and camera-feedback events.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local DataStoreService=game:GetService("DataStoreService")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")

local REMOTES=ReplicatedStorage:FindFirstChild("RobuNexaRemotes") or Instance.new("Folder")
REMOTES.Name="RobuNexaRemotes"; REMOTES.Parent=ReplicatedStorage
local function remote(name)
	local x=REMOTES:FindFirstChild(name) or Instance.new("RemoteEvent")
	x.Name=name; x.Parent=REMOTES; return x
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

local store=DataStoreService:GetDataStore("RobuNexa_v4")
local world=workspace:FindFirstChild("RobuNexaWorld") or Instance.new("Folder")
world.Name="RobuNexaWorld"; world.Parent=workspace

local sessions={}
local cooldown={}
local freeSlots={}
local nextSlot=0

local COLORS={
	red=Color3.fromRGB(235,72,65), orange=Color3.fromRGB(245,130,30),
	yellow=Color3.fromRGB(255,210,55), green=Color3.fromRGB(75,205,110),
	cyan=Color3.fromRGB(65,195,220), blue=Color3.fromRGB(65,125,235),
	purple=Color3.fromRGB(175,85,220), white=Color3.fromRGB(245,245,245),
	dark=Color3.fromRGB(32,32,36), gold=Color3.fromRGB(255,205,55),
}

local function fire(p,data)
	if p and p.Parent then State:FireClient(p,data) end
end

local function vfx(root,pos,color,amount,scale)
	local a=Instance.new("Attachment")
	a.Position=root.CFrame:PointToObjectSpace(pos); a.Parent=root
	local e=Instance.new("ParticleEmitter")
	e.Texture="rbxasset://textures/particles/sparkles_main.dds"
	e.Color=ColorSequence.new(color)
	e.LightEmission=.85; e.Lifetime=NumberRange.new(.25,.6)
	e.Speed=NumberRange.new(5,13); e.SpreadAngle=Vector2.new(180,180)
	e.Rate=0; e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,scale or .35),NumberSequenceKeypoint.new(1,0)})
	e.Parent=a; e:Emit(amount or 18)
	task.delay(.8,function() if a.Parent then a:Destroy() end end)
end

local function makePart(parent,name,size,cf,color,material,transparency)
	local p=Instance.new("Part")
	p.Name=name; p.Size=size; p.CFrame=cf; p.Anchored=true
	p.CanCollide=true; p.CanTouch=true; p.CanQuery=true
	p.Color=color; p.Material=material or Enum.Material.SmoothPlastic
	p.Transparency=transparency or 0; p.Parent=parent
	return p
end

local function getSlot()
	if #freeSlots>0 then
		return table.remove(freeSlots,1)
	end
	nextSlot+=1
	return nextSlot
end

local function releaseSlot(slot)
	table.insert(freeSlots,slot)
	table.sort(freeSlots)
end

local function clearSessionWorld(s)
	if s and s.root and s.root.Parent then s.root:Destroy() end
end

local function teleport(p,pos)
	local c=p.Character
	if c and c:FindFirstChild("HumanoidRootPart") then
		c:PivotTo(CFrame.new(pos))
	end
end

local function objective(p,text,value,extra)
	local d={state="Objective",text=text,value=value}
	if extra then for k,v in pairs(extra) do d[k]=v end end
	fire(p,d)
end

local function score(p,amount,resetCombo)
	local s=sessions[p]
	if not s or not s.alive then return end
	if resetCombo then
		s.combo=0
		s.multiplier=1
	else
		s.combo=math.min((s.combo or 0)+1,25)
		s.multiplier=math.min(1+math.floor(s.combo/5),5)
	end
	s.score=math.clamp(s.score+(amount*s.multiplier),0,s.max)
	fire(p,{state="Score",score=math.floor(s.score),combo=s.combo,multiplier=s.multiplier})
	fire(p,{state="FX",kind=amount>=0 and "Good" or "Bad",intensity=math.clamp(math.abs(amount)/40,0.15,1)})
end

local function touchOnce(s,key,window)
	s.touchTimes=s.touchTimes or {}
	local now=os.clock()
	local last=s.touchTimes[key] or 0
	if now-last<window then return false end
	s.touchTimes[key]=now
	return true
end

local function connectTouched(s,part,fn)
	part.Touched:Connect(function(hit)
		if not s.alive or not s.root or not s.root.Parent then return end
		if hit and hit.Parent==s.player.Character then fn(hit) end
	end)
end

local function addFloor(root,size,origin,color)
	return makePart(root,"Arena",size,CFrame.new(origin),color,Enum.Material.SmoothPlastic)
end

local function buildCommon(root,origin,color)
	addFloor(root,Vector3.new(96,2,72),origin,color)
	makePart(root,"BackWall",Vector3.new(96,18,2),CFrame.new(origin+Vector3.new(0,9,-36)),color,Enum.Material.Concrete)
	makePart(root,"LeftWall",Vector3.new(2,18,72),CFrame.new(origin+Vector3.new(-48,9,0)),color,Enum.Material.Concrete)
	makePart(root,"RightWall",Vector3.new(2,18,72),CFrame.new(origin+Vector3.new(48,9,0)),color,Enum.Material.Concrete)
	for i=1,8 do
		local x=((i-1)%4-1.5)*22
		local z=(math.floor((i-1)/4)-.5)*20
		local h=2+((i*7)%4)
		makePart(root,"Decor_"..i,Vector3.new(3,h,3),CFrame.new(origin+Vector3.new(x,h/2,z)),color,Enum.Material.Neon,.18)
	end
end

local function setupDodge(s,origin,color)
	local root=s.root
	s.spawn=origin+Vector3.new(0,5,28)
	objective(s.player,"ENGELLERDEN KAÇ • HAYATTA KAL","dodge")
	for lane=1,3 do
		local x=(lane-2)*24
		makePart(root,"Lane_"..lane,Vector3.new(20,.4,62),CFrame.new(origin+Vector3.new(x,.95,-2)),Color3.fromRGB(45,45,50),Enum.Material.Metal,.25)
	end
	for i=1,7 do
		local z=24-i*7
		local o=makePart(root,"MovingObstacle_"..i,Vector3.new(13,6,3),CFrame.new(origin+Vector3.new((i%2==0) and -25 or 25,3,z)),COLORS.dark,Enum.Material.Metal)
		o:SetAttribute("phase",(i%2==0) and 0 or 1)
		s.obstacles=s.obstacles or {}
		table.insert(s.obstacles,o)
		connectTouched(s,o,function()
			if touchOnce(s,"ob"..i,.75) then
				local hrp=s.player.Character and s.player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then hrp.AssemblyLinearVelocity=Vector3.new((hrp.Position.X-origin.X)>0 and -24 or 24,18,0) end
				score(s.player,-25,true)
				fire(s.player,{state="Hit"})
			end
		end)
	end
	s.connections=s.connections or {}
	table.insert(s.connections,RunService.Heartbeat:Connect(function()
		if not s.alive then return end
		for i,o in ipairs(s.obstacles or {}) do
			if o.Parent then
				local z=o.Position.Z
				local amp=27
				local nx=origin.X+math.sin(os.clock()*1.7+i)*amp
				o.CFrame=CFrame.new(nx,o.Position.Y,z)
			end
		end
	end))
end

local function setupTargetRush(s,origin,color)
	objective(s.player,"HEDEFİN ÜZERİNE DOKUN / TIKLA","targets")
	s.targets={}
	for i=1,14 do
		local angle=(i/14)*math.pi*2
		local radius=(i%2==0) and 26 or 17
		local pos=origin+Vector3.new(math.cos(angle)*radius,6,math.sin(angle)*radius)
		local t=makePart(s.root,"Target_"..i,Vector3.new(6,6,1.4),CFrame.lookAt(pos,origin+Vector3.new(0,6,0)),(i%2==0) and COLORS.red or COLORS.orange,Enum.Material.Neon)
		t.CanCollide=false
		t:SetAttribute("Active",true)
		table.insert(s.targets,t)
	end
end

local function setupStackTower(s,origin,color)
	s.spawn=origin+Vector3.new(0,4,26)
	s.stack={height=0,width=12,lastX=origin.X,current=nil,speed=15,direction=1}
	local base=makePart(s.root,"TowerBase",Vector3.new(14,2,14),CFrame.new(origin+Vector3.new(0,1,0)),COLORS.orange,Enum.Material.Neon)
	s.stack.base=base
	local moving=makePart(s.root,"MovingBlock",Vector3.new(12,2,12),CFrame.new(origin+Vector3.new(-28,3,0)),COLORS.gold,Enum.Material.Neon)
	s.stack.current=moving
	objective(s.player,"HAREKETLİ BLOĞU TAM KAYDIRILMADAN TAP","stack")
	s.connections=s.connections or {}
	table.insert(s.connections,RunService.Heartbeat:Connect(function(dt)
		if not s.alive or not s.stack.current or not s.stack.current.Parent then return end
		local st=s.stack
		local x=st.current.Position.X+st.speed*st.direction*dt
		if x>origin.X+28 then x=origin.X+28; st.direction=-1 end
		if x<origin.X-28 then x=origin.X-28; st.direction=1 end
		st.current.CFrame=CFrame.new(x,st.current.Position.Y,origin.Z)
	end))
end

local function setupCoinRush(s,origin,color)
	objective(s.player,"COINLERİ TOPLA • 30 SANİYE","coins")
	s.coins={}
	for i=1,32 do
		local a=i*.58
		local pos=origin+Vector3.new(math.cos(a)*32,3+((i%3)),math.sin(a)*22)
		local c=makePart(s.root,"Coin_"..i,Vector3.new(2.6,2.6,2.6),CFrame.new(pos),COLORS.gold,Enum.Material.Neon)
		c.Shape=Enum.PartType.Ball; c.CanCollide=false
		c:SetAttribute("Taken",false)
		table.insert(s.coins,c)
		connectTouched(s,c,function()
			if c:GetAttribute("Taken") then return end
			c:SetAttribute("Taken",true)
			c.CanTouch=false; c.Transparency=1
			score(s.player,22,false)
			vfx(s.root,c.Position,COLORS.gold,22,.42)
			task.delay(.9,function()
				if s.alive and c.Parent then
					c.CFrame=CFrame.new(origin+Vector3.new(math.random(-34,34),math.random(2,6),math.random(-25,25)))
					c.Transparency=0; c.CanTouch=true; c:SetAttribute("Taken",false)
				end
			end)
		end)
	end
	s.connections=s.connections or {}
	table.insert(s.connections,RunService.Heartbeat:Connect(function(dt)
		for _,c in ipairs(s.coins or {}) do
			if c.Parent and not c:GetAttribute("Taken") then
				c.CFrame=c.CFrame*CFrame.Angles(0,dt*4,0)
			end
		end
	end))
end

local function setupJump(s,origin,color)
	s.spawn=origin+Vector3.new(0,5,28)
	s.progress=0
	objective(s.player,"PLATFORMLARDA İLERLE • CHECKPOINT TOPLA","jump")
	for i=1,18 do
		local x=math.sin(i*1.55)*18
		local z=28-i*4
		local y=2+((i%4)*1.4)
		local p=makePart(s.root,"JumpPlatform_"..i,Vector3.new(13,1.5,7),CFrame.new(origin+Vector3.new(x,y,z)),color,Enum.Material.Neon)
		p:SetAttribute("Index",i)
		connectTouched(s,p,function()
			if i>s.progress then
				s.progress=i
				score(s.player,18,false)
				fire(s.player,{state="Checkpoint",value=i})
				vfx(s.root,p.Position,COLORS.green,15,.3)
			end
		end)
	end
end

local function setupReaction(s,origin,color)
	s.spawn=origin+Vector3.new(0,4,0)
	local pad=makePart(s.root,"ReactionPad",Vector3.new(20,1.5,20),CFrame.new(s.spawn-Vector3.new(0,2,0)),color,Enum.Material.Neon)
	s.reaction={active=false,signalAt=0,round=0}
	objective(s.player,"SİNYAL GELENE KADAR BEKLE","reaction")
	s.connections=s.connections or {}
	task.spawn(function()
		while s.alive do
			task.wait(math.random(2,4))
			if not s.alive then break end
			s.reaction.round+=1
			s.reaction.active=true
			s.reaction.signalAt=os.clock()
			pad.Color=COLORS.green
			objective(s.player,"⚡ TAP!","reaction")
			fire(s.player,{state="Reaction",active=true})
			local myRound=s.reaction.round
			task.wait(1.35)
			if s.alive and s.reaction.round==myRound and s.reaction.active then
				s.reaction.active=false; pad.Color=color
				fire(s.player,{state="Reaction",result="MISS"}); score(s.player,-18,true)
			end
		end
	end)
end

local function setupColorRush(s,origin,color)
	s.spawn=origin+Vector3.new(0,4,22)
	local choices={COLORS.red,COLORS.blue,COLORS.green,COLORS.yellow}
	for i,c in ipairs(choices) do
		local x=((i-1)%2)*12-6
		local z=(math.floor((i-1)/2))*12-8
		makePart(s.root,"ColorPad_"..i,Vector3.new(10,.8,10),CFrame.new(origin+Vector3.new(x,1,z)),c,Enum.Material.Neon)
	end
	s.color={choices=choices,target=1,round=0}
	s.connections=s.connections or {}
	local function newRound()
		if not s.alive then return end
		s.color.round+=1
		s.color.target=math.random(1,4)
		objective(s.player,"AYNI RENGE DOKUN", "color",{colorIndex=s.color.target,color=s.color.choices[s.color.target],round=s.color.round})
	end
	newRound()
	table.insert(s.connections,task.spawn(function()
		while s.alive do
			task.wait(2.6)
			if s.alive then newRound() end
		end
	end))
end

local function setupMemory(s,origin,color)
	s.spawn=origin+Vector3.new(0,4,22)
	s.memory={round=0,sequence={},active=false,step=1}
	for i=1,4 do
		local x=((i-1)%2)*12-6
		local z=(math.floor((i-1)/2))*12-8
		makePart(s.root,"MemoryPad_"..i,Vector3.new(10,.8,10),CFrame.new(origin+Vector3.new(x,1,z)),{COLORS.cyan,COLORS.purple,COLORS.orange,COLORS.green}[i],Enum.Material.Neon)
	end
	objective(s.player,"DİZİYİ HATIRLA","memory")
	s.connections=s.connections or {}
	task.spawn(function()
		while s.alive do
			task.wait(2.8)
			if not s.alive then break end
			s.memory.round+=1
			local len=2+((s.memory.round-1)%3)
			s.memory.sequence={}
			for i=1,len do s.memory.sequence[i]=math.random(1,4) end
			s.memory.active=false; s.memory.step=1
			fire(s.player,{state="MemoryShow",sequence=s.memory.sequence})
			task.wait(1.55)
			if s.alive then
				s.memory.active=true
				s.memory.step=1
				objective(s.player,"ŞİMDİ SIRA SENDE","memoryInput",{length=len})
			end
		end
	end)
end

local function setupFalling(s,origin,color)
	s.spawn=origin+Vector3.new(0,5,27)
	objective(s.player,"BAS • PLATFORM ÇÖKSÜN • İLERLE","fall")
	for i=1,28 do
		local x=((i-1)%4-1.5)*17
		local z=27-math.floor((i-1)/4)*6
		local y=2+(i%3)
		local p=makePart(s.root,"Fall_"..i,Vector3.new(13,1.2,5),CFrame.new(origin+Vector3.new(x,y,z)),color,Enum.Material.Neon)
		connectTouched(s,p,function()
			if p:GetAttribute("Busy") then return end
			p:SetAttribute("Busy",true)
			score(s.player,12,false)
			task.delay(.18,function()
				if p.Parent then
					p.CanCollide=false; p.Transparency=.82
					task.wait(1.25)
					if p.Parent and s.alive then p.CanCollide=true; p.Transparency=0; p:SetAttribute("Busy",false) end
				end
			end)
		end)
	end
end

local function setupLava(s,origin,color)
	s.spawn=origin+Vector3.new(0,5,27)
	objective(s.player,"GÜVENLİ ZEMİNDE KAL • LAVA YÜKSELİYOR","lava")
	for i=1,20 do
		local x=((i-1)%5-2)*14
		local z=18-math.floor((i-1)/5)*10
		local safe=(i%4~=0 or i<5)
		local tile=makePart(s.root,"Tile_"..i,Vector3.new(11,1.5,8),CFrame.new(origin+Vector3.new(x,2,z)),safe and COLORS.green or COLORS.red,Enum.Material.Neon)
		tile:SetAttribute("Safe",safe)
		if safe then
			connectTouched(s,tile,function()
				if touchOnce(s,"safe"..i,.35) then score(s.player,7,false) end
			end)
		end
	end
	local lava=makePart(s.root,"RisingLava",Vector3.new(96,2,72),CFrame.new(origin+Vector3.new(0,-4,0)),COLORS.red,Enum.Material.Neon,.1)
	lava.CanCollide=false
	connectTouched(s,lava,function()
		score(s.player,-35,true)
		teleport(s.player,s.spawn)
		fire(s.player,{state="LavaHit"})
	end)
	s.lava=lava
	s.connections=s.connections or {}
	table.insert(s.connections,RunService.Heartbeat:Connect(function()
		if not s.alive or not lava.Parent then return end
		local elapsed=os.clock()-s.started
		local y=-4+math.clamp(elapsed*.48,0,11)
		lava.CFrame=CFrame.new(origin+Vector3.new(0,y,0))
	end))
end

local function build(p,id)
	local old=sessions[p]
	if old then return end
	local slot=getSlot()
	local origin=Vector3.new((slot-1)*150,0,0)
	local root=Instance.new("Folder")
	root.Name="Arena_"..p.UserId; root.Parent=world
	local s={
		player=p,gameId=id,name=games[id].name,max=games[id].max,duration=games[id].duration,
		score=0,combo=0,multiplier=1,alive=true,started=os.clock(),slot=slot,origin=origin,root=root,
		connections={},touchTimes={}
	}
	sessions[p]=s
	local palette={
		DodgeRun=COLORS.red,TargetRush=COLORS.blue,StackTower=COLORS.orange,CoinRush=COLORS.gold,
		JumpChallenge=COLORS.green,ReactionTest=COLORS.purple,ColorRush=COLORS.blue,MemoryMatch=COLORS.cyan,
		FallingPlatforms=COLORS.dark,FloorIsLava=COLORS.red
	}
	buildCommon(root,origin,palette[id] or COLORS.white)
	if id=="DodgeRun" then setupDodge(s,origin,palette[id])
	elseif id=="TargetRush" then setupTargetRush(s,origin,palette[id])
	elseif id=="StackTower" then setupStackTower(s,origin,palette[id])
	elseif id=="CoinRush" then setupCoinRush(s,origin,palette[id])
	elseif id=="JumpChallenge" then setupJump(s,origin,palette[id])
	elseif id=="ReactionTest" then setupReaction(s,origin,palette[id])
	elseif id=="ColorRush" then setupColorRush(s,origin,palette[id])
	elseif id=="MemoryMatch" then setupMemory(s,origin,palette[id])
	elseif id=="FallingPlatforms" then setupFalling(s,origin,palette[id])
	elseif id=="FloorIsLava" then setupLava(s,origin,palette[id])
	end
	teleport(p, s.spawn or origin+Vector3.new(0,5,25))
	World:FireClient(p,{state="WorldReady",gameId=id,origin=origin,color=palette[id]})
end

local function finish(p,reason)
	local s=sessions[p]
	if not s then return end
	s.alive=false
	if s.connections then
		for _,c in ipairs(s.connections) do
			if typeof(c)=="RBXScriptConnection" then c:Disconnect() end
		end
	end
	clearSessionWorld(s)
	sessions[p]=nil
	if s.slot then releaseSlot(s.slot) end
	local final=math.clamp(math.floor(s.score),0,s.max)
	task.spawn(function()
		pcall(function()
			store:UpdateAsync(tostring(p.UserId)..":"..s.gameId,function(old)
				old=tonumber(old) or 0
				return math.max(old,final)
			end)
		end)
	end)
	fire(p,{state="Finished",gameId=s.gameId,gameName=s.name,score=final,reason=reason or "Time"})
end

Start.OnServerEvent:Connect(function(p,id)
	if typeof(id)~="string" or not games[id] or sessions[p] then return end
	build(p,id)
	local s=sessions[p]
	fire(p,{state="Started",gameId=id})
	task.spawn(function()
		for t=s.duration,0,-1 do
			if sessions[p]~=s or not s.alive then return end
			fire(p,{state="Time",time=t})
			task.wait(1)
		end
		if sessions[p]==s then finish(p,"Time") end
	end)
end)

Action.OnServerEvent:Connect(function(p,id,payload)
	local s=sessions[p]
	if not s or s.gameId~=id or not s.alive or typeof(payload)~="table" then return end
	local now=os.clock()
	if now-(cooldown[p] or 0)<.07 then return end
	cooldown[p]=now
	local kind=payload.kind

	if id=="StackTower" and kind=="stack" and s.stack then
		local st=s.stack
		local current=st.current
		if not current or not current.Parent then return end
		local prevX=st.lastX
		local overlap=st.width/2+current.Size.X/2-math.abs(current.Position.X-prevX)
		local y=3+(st.height+1)*2.05
		if overlap<=1 then
			vfx(s.root,current.Position,COLORS.red,24,.5)
			fire(p,{state="StackMiss"})
			st.height=0; st.width=12; st.lastX=s.origin.X
			current:Destroy()
			st.current=makePart(s.root,"MovingBlock",Vector3.new(12,2,12),CFrame.new(s.origin+Vector3.new(-28,3,0)),COLORS.gold,Enum.Material.Neon)
			score(p,-30,true)
			objective(p,"KAÇIRDI! TEKRAR KUR","stack")
			return
		end
		local center=(current.Position.X+prevX)/2
		current:Destroy()
		st.height+=1
		st.width=math.min(overlap,12)
		st.lastX=center
		local locked=makePart(s.root,"Stack_"..st.height,Vector3.new(st.width,2,12),CFrame.new(center,y,s.origin.Z),COLORS.orange,Enum.Material.Neon)
		vfx(s.root,locked.Position,COLORS.orange,18,.35)
		st.current=makePart(s.root,"MovingBlock",Vector3.new(st.width,2,12),CFrame.new(s.origin.X-28,y+2.05,s.origin.Z),COLORS.gold,Enum.Material.Neon)
		score(p,20,false)
		objective(p,"KULE: "..st.height,"stack")
	elseif id=="ReactionTest" and kind=="reaction" then
		local r=s.reaction
		if not r then return end
		if r.active then
			local reactionTime=now-r.signalAt
			r.active=false
			r.lastTime=reactionTime
			if reactionTime<=.35 then score(p,75,false) else score(p,55,false) end
			fire(p,{state="Reaction",result="GOOD",time=reactionTime})
			vfx(s.root,s.spawn,COLORS.green,28,.45)
		else
			score(p,-20,true)
			fire(p,{state="Reaction",result="EARLY"})
		end
	elseif id=="ColorRush" and kind=="color" then
		local c=s.color
		local index=tonumber(payload.index)
		if not c or not index or not c.target then return end
		if index==c.target then
			score(p,35,false); fire(p,{state="ColorResult",correct=true})
			vfx(s.root,s.origin+Vector3.new(0,3,0),COLORS.green,18,.35)
		else
			score(p,-20,true); fire(p,{state="ColorResult",correct=false})
		end
	elseif id=="MemoryMatch" and kind=="memory" then
		local m=s.memory
		local index=tonumber(payload.index)
		if not m or not m.active or not index then return end
		local expected=m.sequence[m.step]
		if index==expected then
			m.step+=1
			if m.step>#m.sequence then
				m.active=false; score(p,70,false); fire(p,{state="MemoryResult",correct=true})
				vfx(s.root,s.origin+Vector3.new(0,3,0),COLORS.cyan,24,.4)
			else
				fire(p,{state="MemoryStep",step=m.step,total=#m.sequence})
			end
		else
			m.active=false; score(p,-25,true); fire(p,{state="MemoryResult",correct=false}); objective(p,"YANLIŞ SIRA • YENİ TUR BEKLE","memory")
		end
	elseif id=="TargetRush" and kind=="target" then
		local name=tostring(payload.name or "")
		local t=s.root:FindFirstChild(name)
		if t and t:IsA("BasePart") and t:GetAttribute("Active") then
			local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
			if not hrp or (hrp.Position-t.Position).Magnitude>65 then return end
			t:SetAttribute("Active",false); t.Transparency=.1
			score(p,28,false); vfx(s.root,t.Position,COLORS.orange,20,.35)
			task.delay(.65,function()
				if t.Parent and s.alive then t:SetAttribute("Active",true); t.Transparency=0 end
			end)
		end
	else
		-- Generic tap is intentionally limited to games that need it.
		if id=="CoinRush" or id=="JumpChallenge" or id=="FallingPlatforms" or id=="DodgeRun" or id=="FloorIsLava" then
			return
		end
	end
end)

Leaderboard.OnServerEvent:Connect(function(p,id)
	if typeof(id)~="string" or not games[id] then return end
	local rows={}
	for other,s in pairs(sessions) do
		if s.gameId==id then table.insert(rows,{userId=other.UserId,name=other.Name,score=math.floor(s.score)}) end
	end
	table.sort(rows,function(a,b) return a.score>b.score end)
	for i=1,math.min(10,#rows) do rows[i].rank=i end
	Leaderboard:FireClient(p,rows)
end)

Players.PlayerRemoving:Connect(function(p)
	if sessions[p] then finish(p,"Leaving") end
	cooldown[p]=nil
end)

print("[RobuNexa][Stage 4] 10 real mechanics + isolated arenas + VFX online.")
