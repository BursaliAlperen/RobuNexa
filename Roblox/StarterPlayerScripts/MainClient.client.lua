--!strict
-- ROBUNEXA SINGLE CLIENT
-- 1 LocalScript only: StarterPlayer > StarterPlayerScripts > MainClient
-- Mobile-first UI, game-specific controls, camera feedback and VFX feedback.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local SoundService=game:GetService("SoundService")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")

local C={
	BG=Color3.fromRGB(18,18,21),PANEL=Color3.fromRGB(31,30,34),PANEL2=Color3.fromRGB(43,41,46),
	CREAM=Color3.fromRGB(250,220,160),ORANGE=Color3.fromRGB(245,130,30),WHITE=Color3.fromRGB(255,255,255),
	MUTED=Color3.fromRGB(140,132,122),GREEN=Color3.fromRGB(80,205,115),RED=Color3.fromRGB(235,75,70),
	BLUE=Color3.fromRGB(70,130,235),PURPLE=Color3.fromRGB(180,85,220),CYAN=Color3.fromRGB(65,195,220),
	YELLOW=Color3.fromRGB(255,210,55)
}
local Games={
	{id="DodgeRun",name="Dodge Run",desc="Engellerden kaç!",icon="⚡",duration=30},
	{id="TargetRush",name="Target Rush",desc="Hedeflere dokun!",icon="🎯",duration=30},
	{id="StackTower",name="Stack Tower",desc="Bloğu tam hizala!",icon="🏗",duration=30},
	{id="CoinRush",name="Coin Rush",desc="Coinleri topla!",icon="🪙",duration=30},
	{id="JumpChallenge",name="Jump Challenge",desc="Platformları geç!",icon="⬆",duration=30},
	{id="ReactionTest",name="Reaction Test",desc="Doğru anda tap!",icon="💥",duration=30},
	{id="ColorRush",name="Color Rush",desc="Doğru rengi seç!",icon="🎨",duration=30},
	{id="MemoryMatch",name="Memory Match",desc="Sırayı ezberle!",icon="🧠",duration=30},
	{id="FallingPlatforms",name="Falling Platforms",desc="Çöken zeminden kaç!",icon="▦",duration=30},
	{id="FloorIsLava",name="Floor Is Lava",desc="Güvenli zeminde kal!",icon="🔥",duration=30},
}

local remotes=ReplicatedStorage:WaitForChild("RobuNexaRemotes",15)
if not remotes then return end
local Start=remotes:WaitForChild("Start",10)
local Action=remotes:WaitForChild("Action",10)
local State=remotes:WaitForChild("State",10)
local Leaderboard=remotes:WaitForChild("Leaderboard",10)
local World=remotes:WaitForChild("World",10)
if not Start or not Action or not State or not Leaderboard or not World then return end

local gui=Instance.new("ScreenGui")
gui.Name="RobuNexaUI"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.DisplayOrder=50
pcall(function() gui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets end); gui.Parent=playerGui

local root=Instance.new("Frame"); root.Size=UDim2.fromScale(1,1); root.BackgroundColor3=C.BG; root.BorderSizePixel=0; root.Parent=gui
local stage=Instance.new("Frame"); stage.AnchorPoint=Vector2.new(.5,.5); stage.Position=UDim2.fromScale(.5,.5); stage.Size=UDim2.new(1,-24,1,-24); stage.BackgroundColor3=C.BG; stage.BorderSizePixel=0; stage.Parent=root
local aspect=Instance.new("UIAspectRatioConstraint"); aspect.AspectRatio=16/9; aspect.DominantAxis=Enum.DominantAxis.Width; aspect.Parent=stage
local maxSize=Instance.new("UISizeConstraint"); maxSize.MaxSize=Vector2.new(1600,900); maxSize.Parent=stage

local function layout()
	local v=root.AbsoluteSize
	local portrait=v.Y>1 and v.X/v.Y<1.45
	aspect.Enabled=not portrait
	stage.Size=portrait and UDim2.new(1,-18,1,-18) or UDim2.new(1,-24,1,-24)
end
root:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout); task.defer(layout)

local function corner(p,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=p end
local function stroke(p,t) local s=Instance.new("UIStroke"); s.Color=C.WHITE; s.Transparency=t or .9; s.Thickness=1; s.Parent=p end
local function txt(parent,text,pos,size,sz,color,bold,center)
	local x=Instance.new("TextLabel"); x.BackgroundTransparency=1; x.Text=text; x.TextColor3=color; x.Font=bold==false and Enum.Font.Gotham or Enum.Font.GothamBold
	x.TextSize=sz; x.TextWrapped=true; x.Position=pos; x.Size=size; x.TextXAlignment=center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left; x.TextYAlignment=Enum.TextYAlignment.Center; x.Parent=parent
	local c=Instance.new("UITextSizeConstraint"); c.MinTextSize=math.max(10,math.floor(sz*.55)); c.MaxTextSize=sz; c.Parent=x; return x
end
local function panel(parent,pos,size,color)
	local f=Instance.new("Frame"); f.Position=pos; f.Size=size; f.BackgroundColor3=color or C.PANEL; f.BorderSizePixel=0; f.Parent=parent; corner(f,16); stroke(f,.92)
	return f
end
local function button(parent,text,pos,size,primary)
	local b=Instance.new("TextButton"); b.Text=text; b.AutoButtonColor=false; b.Active=true; b.Position=pos; b.Size=size; b.BackgroundColor3=primary and C.CREAM or C.PANEL2; b.TextColor3=primary and Color3.fromRGB(8,8,10) or C.CREAM
	b.Font=Enum.Font.GothamBold; b.TextSize=18; b.BorderSizePixel=0; b.Parent=parent; corner(b,14); if not primary then stroke(b,.84) end
	local normal=size
	b.Activated:Connect(function()
		TweenService:Create(b,TweenInfo.new(.07),{Size=UDim2.new(normal.X.Scale,normal.X.Offset-4,normal.Y.Scale,normal.Y.Offset-4)}):Play()
		task.delay(.08,function() if b.Parent then TweenService:Create(b,TweenInfo.new(.07),{Size=normal}):Play() end end)
	end)
	return b
end

local screens={}
for _,n in ipairs({"Boot","Home","Games","Leaderboard","Stats","Settings","GameOver"}) do
	local f=Instance.new("Frame"); f.Name=n; f.Size=UDim2.fromScale(1,1); f.BackgroundTransparency=1; f.Visible=false; f.Parent=stage; screens[n]=f
end
local function show(n) for k,v in pairs(screens) do v.Visible=k==n end end
local function header(parent,title,sub)
	txt(parent,title,UDim2.new(0,30,0,18),UDim2.new(.78,0,0,44),30,C.CREAM,true)
	txt(parent,sub,UDim2.new(0,32,0,61),UDim2.new(.84,0,0,28),13,C.MUTED,false)
end
local function back(parent)
	local b=button(parent,"← HUB",UDim2.new(0,30,1,-58),UDim2.fromOffset(130,44),false); b.Activated:Connect(function() show("Home") end)
end

do
	local s=screens.Boot
	txt(s,"ROBUNEXA",UDim2.new(.1,0,.30,0),UDim2.new(.8,0,0,70),46,C.CREAM,true,true)
	txt(s,"MOBILE GAME HUB",UDim2.new(.1,0,.42,0),UDim2.new(.8,0,0,40),21,C.ORANGE,true,true)
	txt(s,"10 mini oyun • server-authoritative • mobile first",UDim2.new(.1,0,.51,0),UDim2.new(.8,0,0,32),14,C.MUTED,false,true)
	local p=panel(s,UDim2.new(.25,0,.63,0),UDim2.new(.5,0,0,8),C.PANEL2)
	local fill=Instance.new("Frame"); fill.Size=UDim2.new(0,0,1,0); fill.BackgroundColor3=C.ORANGE; fill.BorderSizePixel=0; fill.Parent=p; corner(fill,8)
	TweenService:Create(fill,TweenInfo.new(.8),{Size=UDim2.fromScale(1,1)}):Play()
end

do
	local s=screens.Home; header(s,"GAME HUB","Hızlı başla. Skorunu yükselt.")
	local h=panel(s,UDim2.new(.04,0,.18,0),UDim2.new(.92,0,.40,0))
	txt(h,"10",UDim2.new(.05,0,.12,0),UDim2.new(.2,0,.35,0),72,C.ORANGE,true)
	txt(h,"OYUN",UDim2.new(.05,0,.51,0),UDim2.new(.25,0,.15,0),16,C.CREAM,true)
	txt(h,"Gerçek 3D mini oyunlar",UDim2.new(.32,0,.14,0),UDim2.new(.62,0,.20,0),23,C.CREAM,true)
	txt(h,"Refleks • hedef • parkur • hafıza • kaçış",UDim2.new(.32,0,.39,0),UDim2.new(.62,0,.18,0),14,C.MUTED,false)
	local p=button(h,"OYNA →",UDim2.new(.32,0,.67,0),UDim2.new(.34,0,0,56),true); p.Activated:Connect(function() show("Games") end)
	for _,d in ipairs({{"OYUNLAR",.04,.21,"Games"},{"LEADERBOARD",.27,.23,"Leaderboard"},{"STATS",.52,.18,"Stats"},{"AYAR",.72,.18,"Settings"}}) do
		local b=button(s,d[1],UDim2.new(d[2],0,.88,0),UDim2.new(d[3],0,0,42),false); b.Activated:Connect(function() show(d[4]) end)
	end
end

do
	local s=screens.Games; header(s,"OYUNLAR","Karta dokun ve 30 saniyelik round'u başlat.")
	local scroll=Instance.new("ScrollingFrame"); scroll.Position=UDim2.new(.04,0,.17,0); scroll.Size=UDim2.new(.92,0,.70,0); scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0; scroll.ScrollBarThickness=5; scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.Parent=s
	local grid=Instance.new("UIGridLayout"); grid.CellSize=UDim2.new(.48,0,0,118); grid.CellPadding=UDim2.new(.02,0,0,12); grid.Parent=scroll
	for i,g in ipairs(Games) do
		local card=Instance.new("TextButton"); card.Text=""; card.AutoButtonColor=false; card.BackgroundColor3=C.PANEL; card.BorderSizePixel=0; card.LayoutOrder=i; card.Parent=scroll; corner(card,16); stroke(card,.93)
		txt(card,string.format("%02d",i),UDim2.new(0,12,0,10),UDim2.fromOffset(52,42),19,C.ORANGE,true,true)
		txt(card,g.icon,UDim2.new(0,18,0,58),UDim2.fromOffset(40,35),20,C.CREAM,true,true)
		txt(card,g.name,UDim2.new(0,72,0,10),UDim2.new(1,-82,0,30),18,C.CREAM,true)
		txt(card,g.desc,UDim2.new(0,72,0,44),UDim2.new(1,-82,0,30),12,C.MUTED,false)
		txt(card,g.duration.."s RUN",UDim2.new(0,72,1,-30),UDim2.new(1,-82,0,20),11,C.ORANGE,true)
		card.Activated:Connect(function() Start:FireServer(g.id) end)
	end
	back(s)
end

do
	local s=screens.Leaderboard; header(s,"LEADERBOARD","Aktif sunucu skorları.")
	local out=panel(s,UDim2.new(.05,0,.20,0),UDim2.new(.90,0,.60,0))
	local l=txt(out,"Bir oyun seç.",UDim2.new(0,20,0,20),UDim2.new(1,-40,1,-40),17,C.CREAM,true)
	for i,g in ipairs(Games) do
		local b=button(s,tostring(i),UDim2.new(.05+((i-1)%5)*.18,0,.82+math.floor((i-1)/5)*.07,0),UDim2.fromOffset(48,40),false)
		b.Activated:Connect(function() Leaderboard:FireServer(g.id) end)
	end
	Leaderboard.OnClientEvent:Connect(function(data)
		if typeof(data)~="table" then return end
		local lines={}
		for _,e in ipairs(data) do table.insert(lines,string.format("#%02d   %s   %d",e.rank or 0,e.name or tostring(e.userId),e.score or 0)) end
		l.Text=#lines>0 and table.concat(lines,"\n") or "Henüz skor yok."
	end)
	back(s)
end

do
	local s=screens.Stats; header(s,"STATS","Profil ve session özeti.")
	local p=panel(s,UDim2.new(.08,0,.22,0),UDim2.new(.84,0,.38,0))
	txt(p,"10",UDim2.new(.08,0,.18,0),UDim2.new(.25,0,.45,0),48,C.ORANGE,true,true)
	txt(p,"∞",UDim2.new(.37,0,.18,0),UDim2.new(.25,0,.45,0),48,C.CREAM,true,true)
	txt(p,"30s",UDim2.new(.66,0,.18,0),UDim2.new(.25,0,.45,0),48,C.GREEN,true,true)
	txt(p,"OYUN",UDim2.new(.08,0,.65,0),UDim2.new(.25,0,.2,0),12,C.MUTED,true,true)
	txt(p,"SKOR",UDim2.new(.37,0,.65,0),UDim2.new(.25,0,.2,0),12,C.MUTED,true,true)
	txt(p,"ROUND",UDim2.new(.66,0,.65,0),UDim2.new(.25,0,.2,0),12,C.MUTED,true,true)
	back(s)
end

do
	local s=screens.Settings; header(s,"AYARLAR","Mobil ve masaüstü için otomatik ölçek.")
	local b=button(s,"SAFE AREA • 16:9 • PORTRAIT FALLBACK",UDim2.new(.08,0,.25,0),UDim2.new(.84,0,0,60),true)
	b.Activated:Connect(function() b.Text="RESPONSIVE • AKTİF" end); back(s)
end

local hud=Instance.new("Frame"); hud.Size=UDim2.fromScale(1,1); hud.BackgroundTransparency=1; hud.Visible=false; hud.Parent=stage
local top=panel(hud,UDim2.new(.04,0,.04,0),UDim2.new(.92,0,0,72))
local gameText=txt(top,"GAME",UDim2.new(0,16,0,8),UDim2.new(.35,0,0,28),16,C.CREAM,true)
local scoreText=txt(top,"0",UDim2.new(.37,0,0,8),UDim2.new(.18,0,0,28),22,C.CREAM,true,true)
local comboText=txt(top,"x1",UDim2.new(.58,0,0,8),UDim2.new(.12,0,0,28),16,C.ORANGE,true,true)
local timeText=txt(top,"30",UDim2.new(.76,0,0,8),UDim2.new(.18,0,0,28),16,C.GREEN,true,true)
local instruction=txt(hud,"TAP",UDim2.new(.08,0,.20,0),UDim2.new(.84,0,0,45),20,C.CREAM,true,true)
local tap=button(hud,"TAP!",UDim2.new(.10,0,.68,0),UDim2.new(.80,0,0,88),true); tap.TextSize=30
local count=txt(hud,"3",UDim2.new(.15,0,.35,0),UDim2.new(.70,0,0,120),76,C.ORANGE,true,true); count.Visible=false
local fx=Instance.new("Frame"); fx.Size=UDim2.fromScale(1,1); fx.BackgroundTransparency=1; fx.ZIndex=30; fx.Parent=hud
local flash=Instance.new("Frame"); flash.Size=UDim2.fromScale(1,1); flash.BackgroundTransparency=1; flash.BorderSizePixel=0; flash.ZIndex=31; flash.Parent=fx

local choiceFrame=Instance.new("Frame"); choiceFrame.BackgroundTransparency=1; choiceFrame.Position=UDim2.new(.12,0,.55,0); choiceFrame.Size=UDim2.new(.76,0,0,150); choiceFrame.Visible=false; choiceFrame.Parent=hud
local choiceLayout=Instance.new("UIGridLayout"); choiceLayout.CellSize=UDim2.new(.48,0,0,64); choiceLayout.CellPadding=UDim2.new(.02,0,0,10); choiceLayout.Parent=choiceFrame
local targetPreview=Instance.new("Frame"); targetPreview.AnchorPoint=Vector2.new(.5,.5); targetPreview.Position=UDim2.new(.5,0,.50,0); targetPreview.Size=UDim2.fromOffset(74,74); targetPreview.BackgroundColor3=C.PANEL2; targetPreview.BackgroundTransparency=.05; targetPreview.Visible=false; targetPreview.ZIndex=8; targetPreview.Parent=hud; corner(targetPreview,99); stroke(targetPreview,.75)
local targetLabel=txt(hud,"",UDim2.new(.5,-100,0,0),UDim2.fromOffset(200,28),13,C.CREAM,true,true); targetLabel.AnchorPoint=Vector2.new(.5,0); targetLabel.Position=UDim2.new(.5,0,.59,0); targetLabel.Visible=false; targetLabel.ZIndex=9

local choiceButtons={}
for i=1,4 do
	local b=Instance.new("TextButton"); b.Name="Choice"..i; b.Text=""; b.AutoButtonColor=false; b.BorderSizePixel=0; b.Visible=false; b.LayoutOrder=i; b.Parent=choiceFrame; corner(b,14); choiceButtons[i]=b
end

local currentId:string?=nil
local targetRound=false
local memoryInput=false

local function playLocalSfx(kind)
	-- Uses Roblox built-in sound assets; these can be replaced with project audio later.
	local ids={tap="rbxasset://sounds/button.wav",good="rbxasset://sounds/electronicpingshort.wav",bad="rbxasset://sounds/uuhhh.wav"}
	local id=ids[kind]
	if not id then return end
	local s=Instance.new("Sound"); s.SoundId=id; s.Volume=.32; s.Parent=SoundService
	SoundService:PlayLocalSound(s)
	task.delay(2,function() if s.Parent then s:Destroy() end end)
end

local function cameraShake(duration,intensity)
	local camera=workspace.CurrentCamera
	if not camera then return end
	local start=os.clock()
	while os.clock()-start<duration do
		local alpha=1-(os.clock()-start)/duration
		camera.CFrame=camera.CFrame*CFrame.new((math.random()-.5)*intensity*alpha,(math.random()-.5)*intensity*alpha,0)
		RunService.RenderStepped:Wait()
	end
end

local function flash(color)
	flash.BackgroundColor3=color; flash.BackgroundTransparency=.82
	TweenService:Create(flash,TweenInfo.new(.22),{BackgroundTransparency=1}):Play()
end

local function hideChoices()
	choiceFrame.Visible=false; targetPreview.Visible=false; targetLabel.Visible=false
	for i=1,4 do choiceButtons[i].Visible=false; choiceButtons[i].BackgroundTransparency=0 end
	targetRound=false; memoryInput=false
end

local function sendTap()
	if not currentId then return end
	playLocalSfx("tap")
	if currentId=="StackTower" then
		Action:FireServer(currentId,{kind="stack"})
	elseif currentId=="ReactionTest" then
		Action:FireServer(currentId,{kind="reaction"})
	end
end
tap.Activated:Connect(sendTap)

for i,b in ipairs(choiceButtons) do
	b.Activated:Connect(function()
		if not currentId then return end
		if currentId=="ColorRush" and targetRound then
			Action:FireServer(currentId,{kind="color",index=i})
		elseif currentId=="MemoryMatch" and memoryInput then
			Action:FireServer(currentId,{kind="memory",index=i})
		end
	end)
end

local function raycastTarget(screenPos)
	local camera=workspace.CurrentCamera
	if not camera then return end
	local ray=camera:ViewportPointToRay(screenPos.X,screenPos.Y)
	local params=RaycastParams.new()
	params.FilterType=Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances={player.Character}
	local hit=workspace:Raycast(ray.Origin,ray.Direction*120,params)
	if hit and hit.Instance and hit.Instance.Name:match("^Target_") then
		Action:FireServer("TargetRush",{kind="target",name=hit.Instance.Name})
	end
end

UserInputService.InputBegan:Connect(function(input,processed)
	if processed or not currentId then return end
	if currentId=="TargetRush" and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
		raycastTarget(input.Position)
	end
end)

World.OnClientEvent:Connect(function(data)
	if typeof(data)~="table" or data.state~="WorldReady" then return end
	local cam=workspace.CurrentCamera
	local char=player.Character
	local hum=char and char:FindFirstChildOfClass("Humanoid")
	if cam and data.origin then
		local origin=data.origin
		cam.CameraType=Enum.CameraType.Scriptable
		local start=origin+Vector3.new(0,26,42)
		cam.CFrame=CFrame.lookAt(start,origin+Vector3.new(0,3,0))
		task.delay(.38,function()
			local c=player.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
			if h and workspace.CurrentCamera then workspace.CurrentCamera.CameraType=Enum.CameraType.Custom; workspace.CurrentCamera.CameraSubject=h end
		end)
	end
end)

State.OnClientEvent:Connect(function(data)
	if typeof(data)~="table" then return end
	if data.state=="Started" then
		currentId=data.gameId; hideChoices()
		local g; for _,x in ipairs(Games) do if x.id==currentId then g=x break end end
		if not g then return end
		gameText.Text=string.upper(g.name); scoreText.Text="0"; comboText.Text="x1"; timeText.Text=tostring(g.duration)
		instruction.Text=g.desc; hud.Visible=true
		for _,s in pairs(screens) do s.Visible=false end
		count.Visible=true
		task.spawn(function()
			for _,n in ipairs({"3","2","1","GO!"}) do count.Text=n; if n=="GO!" then playLocalSfx("good") end; task.wait(n=="GO!" and .45 or .62) end
			count.Visible=false
		end)
	elseif data.state=="Objective" then
		instruction.Text=tostring(data.text or "PLAY")
		if data.value=="color" and data.colorIndex then
			targetRound=true; memoryInput=false; choiceFrame.Visible=true; targetPreview.Visible=true; targetLabel.Visible=true
			targetPreview.BackgroundColor3=data.color or C.PANEL2
			targetLabel.Text="HEDEF RENGİ"
			for i,b in ipairs(choiceButtons) do
				b.Visible=true; b.BackgroundColor3=({C.RED,C.BLUE,C.GREEN,C.YELLOW})[i] or C.PANEL2; b.Text="RENK "..i; b.TextColor3=C.WHITE
			end
			instruction.Text="HEDEF RENGİ SEÇ"
		elseif data.value=="memoryInput" then
			memoryInput=true; targetRound=false; choiceFrame.Visible=true
			for i,b in ipairs(choiceButtons) do b.Visible=true; b.Text="PAD "..i; b.BackgroundColor3=({C.CYAN,C.PURPLE,C.ORANGE,C.GREEN})[i] end
		else
			hideChoices()
		end
	elseif data.state=="MemoryShow" then
		memoryInput=false; targetPreview.Visible=false; targetLabel.Visible=false; choiceFrame.Visible=false
		instruction.Text="SIRAYI EZBERLE!"
		task.spawn(function()
			for _,index in ipairs(data.sequence or {}) do
				if choiceButtons[index] then
					choiceFrame.Visible=true
					for i,b in ipairs(choiceButtons) do b.Visible=true; b.Text=""; b.BackgroundColor3=({C.CYAN,C.PURPLE,C.ORANGE,C.GREEN})[i] end
					choiceButtons[index].BackgroundTransparency=.2
					task.wait(.38)
					choiceButtons[index].BackgroundTransparency=0
					task.wait(.12)
				end
			end
			choiceFrame.Visible=false
		end)
	elseif data.state=="MemoryStep" then
		instruction.Text=string.format("SIRA %d / %d",data.step or 0,data.total or 0)
	elseif data.state=="MemoryResult" then
		memoryInput=false; choiceFrame.Visible=false
		if data.correct then instruction.Text="HAFIZA TAMAM!"; playLocalSfx("good") else instruction.Text="YANLIŞ!"; playLocalSfx("bad"); flash(C.RED) end
	elseif data.state=="ColorResult" then
		if data.correct then instruction.Text="DOĞRU RENK!"; playLocalSfx("good") else instruction.Text="YANLIŞ RENK!"; playLocalSfx("bad"); flash(C.RED); cameraShake(.12,1.5) end
	elseif data.state=="Reaction" then
		if data.active then instruction.Text="⚡ TAP NOW!" ; playLocalSfx("good") elseif data.result=="GOOD" then instruction.Text=string.format("MÜKEMMEL %.0fms", (data.time or 0)*1000); playLocalSfx("good"); flash(C.GREEN); cameraShake(.1,1.2) elseif data.result=="EARLY" then instruction.Text="ERKEN!"; playLocalSfx("bad"); flash(C.RED) else instruction.Text="KAÇTI!"; playLocalSfx("bad"); end
	elseif data.state=="Hit" or data.state=="LavaHit" then
		instruction.Text=data.state=="Hit" and "ENGEL!" or "LAVA!"
		playLocalSfx("bad"); flash(C.RED); task.spawn(function() cameraShake(.16,2.3) end)
	elseif data.state=="StackMiss" then
		instruction.Text="BLOK KAÇTI!"; playLocalSfx("bad"); flash(C.RED)
	elseif data.state=="Checkpoint" then
		instruction.Text="CHECKPOINT "..tostring(data.value or ""); playLocalSfx("good"); flash(C.GREEN)
	elseif data.state=="FX" then
		if data.kind=="Good" then flash(C.GREEN) else flash(C.RED) end
	elseif data.state=="Score" then
		scoreText.Text=tostring(data.score or 0); comboText.Text="x"..tostring(data.multiplier or 1)
		TweenService:Create(scoreText,TweenInfo.new(.08),{TextSize=27}):Play()
		task.delay(.1,function() if scoreText.Parent then TweenService:Create(scoreText,TweenInfo.new(.1),{TextSize=22}):Play() end end)
	elseif data.state=="Time" then
		timeText.Text=tostring(data.time or 0)
		if (data.time or 0)<=5 then timeText.TextColor3=C.RED else timeText.TextColor3=C.GREEN end
	elseif data.state=="Finished" then
		hud.Visible=false; count.Visible=false; currentId=nil; hideChoices()
		local result=screens.GameOver:FindFirstChild("Result")
		if result and result:IsA("TextLabel") then result.Text=string.upper(data.gameName or "RUN").."\n"..string.format("%06d",data.score or 0) end
		show("GameOver")
	end
end)

do
	local s=screens.GameOver; header(s,"RUN BİTTİ","Skor server tarafından kaydedildi.")
	local p=panel(s,UDim2.new(.16,0,.24,0),UDim2.new(.68,0,.28,0))
	local r=txt(p,"RUN\n000000",UDim2.new(.05,0,.08,0),UDim2.new(.90,0,.84,0),34,C.CREAM,true,true); r.Name="Result"
	local again=button(s,"TEKRAR OYNA",UDim2.new(.16,0,.59,0),UDim2.new(.68,0,0,56),true); again.Activated:Connect(function() show("Games") end)
	local home=button(s,"HUB'A DÖN",UDim2.new(.16,0,.70,0),UDim2.new(.68,0,0,50),false); home.Activated:Connect(function() show("Home") end)
end

show("Boot")
task.delay(.9,function() if screens.Boot.Visible then show("Home") end end)
