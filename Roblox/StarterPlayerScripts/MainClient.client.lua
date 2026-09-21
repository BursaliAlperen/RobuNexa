--!strict
-- ROBUNEXA SINGLE CLIENT
-- Put ONLY this LocalScript in:
-- StarterPlayer > StarterPlayerScripts > MainClient
--
-- It creates the entire Stage 2 UI itself.
-- It only talks to the single server bootstrap through ReplicatedStorage.RobuNexaRemotes.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local C = {
	BG = Color3.fromRGB(18,18,21),
	PANEL = Color3.fromRGB(31,30,34),
	PANEL2 = Color3.fromRGB(43,41,46),
	CREAM = Color3.fromRGB(250,220,160),
	ORANGE = Color3.fromRGB(245,130,30),
	WHITE = Color3.fromRGB(255,255,255),
	MUTED = Color3.fromRGB(140,132,122),
	GREEN = Color3.fromRGB(80,205,115),
	RED = Color3.fromRGB(235,75,70),
}

local Games = {
	{id="DodgeRun",name="Dodge Run",desc="Engellerden kaç!",icon="⚡",duration=30},
	{id="TargetRush",name="Target Rush",desc="Hedefleri vur!",icon="🎯",duration=30},
	{id="StackTower",name="Stack Tower",desc="Kuleyi yükselt!",icon="🏗",duration=30},
	{id="CoinRush",name="Coin Rush",desc="Coinleri topla!",icon="🪙",duration=30},
	{id="JumpChallenge",name="Jump Challenge",desc="Zıpla ve ilerle!",icon="⬆",duration=30},
	{id="ReactionTest",name="Reaction Test",desc="Refleksini test et!",icon="💥",duration=30},
	{id="ColorRush",name="Color Rush",desc="Doğru rengi bul!",icon="🎨",duration=30},
	{id="MemoryMatch",name="Memory Match",desc="Hafızanı kullan!",icon="🧠",duration=30},
	{id="FallingPlatforms",name="Falling Platforms",desc="Düşmeden ilerle!",icon="▦",duration=30},
	{id="FloorIsLava",name="Floor Is Lava",desc="Güvenli zemini bul!",icon="🔥",duration=30},
}

local remoteFolder = ReplicatedStorage:WaitForChild("RobuNexaRemotes", 15)
if not remoteFolder then
	warn("[RobuNexa] Server bootstrap not found.")
	return
end
local Start = remoteFolder:WaitForChild("Start", 10)
local Action = remoteFolder:WaitForChild("Action", 10)
local State = remoteFolder:WaitForChild("State", 10)
local Leaderboard = remoteFolder:WaitForChild("Leaderboard", 10)
local World = remoteFolder:WaitForChild("World", 10)
local World = remoteFolder:WaitForChild("World", 10)
if not Start or not Action or not State or not Leaderboard or not World then return end

local gui = Instance.new("ScreenGui")
gui.Name = "RobuNexaUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 50
pcall(function() gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets end)
gui.Parent = playerGui

local root = Instance.new("Frame")
root.Size = UDim2.fromScale(1,1)
root.BackgroundColor3 = C.BG
root.BorderSizePixel = 0
root.Parent = gui

local stage = Instance.new("Frame")
stage.AnchorPoint = Vector2.new(.5,.5)
stage.Position = UDim2.fromScale(.5,.5)
stage.Size = UDim2.new(1,-24,1,-24)
stage.BackgroundColor3 = C.BG
stage.BorderSizePixel = 0
stage.Parent = root

local aspect = Instance.new("UIAspectRatioConstraint")
aspect.AspectRatio = 16/9
aspect.DominantAxis = Enum.DominantAxis.Width
aspect.Parent = stage

local maxSize = Instance.new("UISizeConstraint")
maxSize.MaxSize = Vector2.new(1600,900)
maxSize.Parent = stage

local function layout()
	local v = root.AbsoluteSize
	local portrait = v.Y > 1 and v.X/v.Y < 1.45
	aspect.Enabled = not portrait
	stage.Size = portrait and UDim2.new(1,-20,1,-20) or UDim2.new(1,-24,1,-24)
end
root:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
task.defer(layout)

local function corner(p:Instance,r:number)
	local x=Instance.new("UICorner"); x.CornerRadius=UDim.new(0,r); x.Parent=p
end
local function stroke(p:Instance,t:number?)
	local x=Instance.new("UIStroke"); x.Color=C.WHITE; x.Transparency=t or .92; x.Thickness=1; x.Parent=p
end
local function txt(parent:Instance,text:string,pos:UDim2,size:UDim2,sz:number,color:Color3,bold:boolean?,center:boolean?)
	local x=Instance.new("TextLabel")
	x.BackgroundTransparency=1; x.Text=text; x.TextColor3=color; x.Font=bold==false and Enum.Font.Gotham or Enum.Font.GothamBold
	x.TextSize=sz; x.TextWrapped=true; x.Position=pos; x.Size=size
	x.TextXAlignment=center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
	x.TextYAlignment=Enum.TextYAlignment.Center; x.Parent=parent
	local c=Instance.new("UITextSizeConstraint"); c.MinTextSize=math.max(10,math.floor(sz*.55)); c.MaxTextSize=sz; c.Parent=x
	return x
end
local function panel(parent,pos,size,color?)
	local f=Instance.new("Frame"); f.Position=pos; f.Size=size; f.BackgroundColor3=color or C.PANEL; f.BorderSizePixel=0; f.Parent=parent
	corner(f,16); stroke(f,.93)
	for _,p in ipairs({Vector2.new(0,0),Vector2.new(1,0),Vector2.new(0,1),Vector2.new(1,1)}) do
		local s=Instance.new("Frame"); s.AnchorPoint=p; s.Position=UDim2.new(p.X,p.X==0 and 8 or -8,p.Y,p.Y==0 and 8 or -8); s.Size=UDim2.fromOffset(6,6); s.BackgroundColor3=C.CREAM; s.BackgroundTransparency=.78; s.BorderSizePixel=0; s.Parent=f; corner(s,99)
	end
	return f
end
local function button(parent,text,pos,size,primary?)
	local b=Instance.new("TextButton"); b.Text=text; b.AutoButtonColor=false; b.Active=true; b.Position=pos; b.Size=size; b.BackgroundColor3=primary and C.CREAM or C.PANEL2; b.TextColor3=primary and Color3.fromRGB(8,8,10) or C.CREAM; b.Font=Enum.Font.GothamBold; b.TextSize=18; b.BorderSizePixel=0; b.Parent=parent; corner(b,14); if not primary then stroke(b,.84) end
	b.Activated:Connect(function()
		TweenService:Create(b,TweenInfo.new(.08),{Size=UDim2.new(size.X.Scale,size.X.Offset-4,size.Y.Scale,size.Y.Offset-4)}):Play()
		task.delay(.09,function() if b.Parent then TweenService:Create(b,TweenInfo.new(.08),{Size=size}):Play() end end)
	end)
	return b
end

local screens={}
for _,n in ipairs({"Boot","Home","Games","Leaderboard","Stats","Settings","GameOver"}) do
	local f=Instance.new("Frame"); f.Name=n; f.Size=UDim2.fromScale(1,1); f.BackgroundTransparency=1; f.Visible=false; f.Parent=stage; screens[n]=f
end
local function show(n) for k,v in pairs(screens) do v.Visible=k==n end end

local function header(parent,title,sub)
	txt(parent,title,UDim2.new(0,30,0,18),UDim2.new(.75,0,0,46),30,C.CREAM,true)
	txt(parent,sub,UDim2.new(0,32,0,62),UDim2.new(.84,0,0,28),13,C.MUTED,false)
end
local function back(parent)
	local b=button(parent,"← HUB",UDim2.new(0,30,1,-58),UDim2.fromOffset(130,44),false)
	b.Activated:Connect(function() show("Home") end)
end

do
	local s=screens.Boot
	txt(s,"ROBUNEXA",UDim2.new(.1,0,.30,0),UDim2.new(.8,0,0,70),46,C.CREAM,true,true)
	txt(s,"MOBILE GAME HUB",UDim2.new(.1,0,.42,0),UDim2.new(.8,0,0,40),21,C.ORANGE,true,true)
	txt(s,"GitHub source • 10 mini oyun • mobile first",UDim2.new(.1,0,.51,0),UDim2.new(.8,0,0,32),14,C.MUTED,false,true)
	local p=panel(s,UDim2.new(.25,0,.63,0),UDim2.new(.5,0,0,8),C.PANEL2)
	local fill=Instance.new("Frame"); fill.Size=UDim2.new(0,0,1,0); fill.BackgroundColor3=C.ORANGE; fill.BorderSizePixel=0; fill.Parent=p; corner(fill,8)
	TweenService:Create(fill,TweenInfo.new(.8),{Size=UDim2.fromScale(1,1)}):Play()
end

do
	local s=screens.Home; header(s,"GAME HUB","Hızlı başla. Skorunu yükselt.")
	local h=panel(s,UDim2.new(.04,0,.18,0),UDim2.new(.92,0,.40,0))
	txt(h,"10",UDim2.new(.05,0,.12,0),UDim2.new(.2,0,.35,0),72,C.ORANGE,true)
	txt(h,"OYUN",UDim2.new(.05,0,.51,0),UDim2.new(.25,0,.15,0),16,C.CREAM,true)
	txt(h,"10 farklı kısa oyun",UDim2.new(.32,0,.16,0),UDim2.new(.62,0,.20,0),23,C.CREAM,true)
	txt(h,"Refleks • hafıza • kaçış • hedef • parkur",UDim2.new(.32,0,.40,0),UDim2.new(.62,0,.18,0),14,C.MUTED,false)
	local p=button(h,"OYNA →",UDim2.new(.32,0,.67,0),UDim2.new(.34,0,0,56),true); p.Activated:Connect(function() show("Games") end)
	local navY=.88
	for _,d in ipairs({{"OYUNLAR",.04,.21,"Games"},{"LEADERBOARD",.27,.23,"Leaderboard"},{"STATS",.52,.18,"Stats"},{"AYAR",.72,.18,"Settings"}}) do
		local b=button(s,d[1],UDim2.new(d[2],0,navY,0),UDim2.new(d[3],0,0,42),false); b.Activated:Connect(function() show(d[4]) end)
	end
end

do
	local s=screens.Games; header(s,"OYUNLAR","Bir karta dokun ve round'u başlat.")
	local scroll=Instance.new("ScrollingFrame"); scroll.Position=UDim2.new(.04,0,.17,0); scroll.Size=UDim2.new(.92,0,.70,0); scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0; scroll.ScrollBarThickness=5; scroll.ScrollBarImageColor3=C.ORANGE; scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.Parent=s
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
	local s=screens.Leaderboard; header(s,"LEADERBOARD","Sunucudan gelen skorlar.")
	local out=panel(s,UDim2.new(.05,0,.20,0),UDim2.new(.90,0,.60,0))
	local l=txt(out,"Bir oyun seç.",UDim2.new(0,20,0,20),UDim2.new(1,-40,1,-40),17,C.CREAM,true)
	for i,g in ipairs(Games) do
		local b=button(s,tostring(i),UDim2.new(.05+(i-1)%5*.18,0,.82+math.floor((i-1)/5)*.07,0),UDim2.fromOffset(48,40),false)
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
	local s=screens.Stats; header(s,"STATS","Bu sürümde temel profil istatistikleri.")
	local p=panel(s,UDim2.new(.08,0,.22,0),UDim2.new(.84,0,.35,0))
	txt(p,"10",UDim2.new(.08,0,.18,0),UDim2.new(.25,0,.45,0),48,C.ORANGE,true,true)
	txt(p,"OYUN",UDim2.new(.36,0,.18,0),UDim2.new(.25,0,.45,0),48,C.CREAM,true,true)
	txt(p,"∞",UDim2.new(.64,0,.18,0),UDim2.new(.25,0,.45,0),48,C.GREEN,true,true)
	txt(p,"OYUN SAYISI",UDim2.new(.08,0,.65,0),UDim2.new(.25,0,.2,0),12,C.MUTED,true,true)
	txt(p,"GLOBAL",UDim2.new(.36,0,.65,0),UDim2.new(.25,0,.2,0),12,C.MUTED,true,true)
	txt(p,"DENEME",UDim2.new(.64,0,.65,0),UDim2.new(.25,0,.2,0),12,C.MUTED,true,true)
	back(s)
end

do
	local s=screens.Settings; header(s,"AYARLAR","Temel oyun tercihleri.")
	local b=button(s,"MOBİL / 16:9 RESPONSIVE",UDim2.new(.08,0,.25,0),UDim2.new(.84,0,0,60),true)
	b.Activated:Connect(function() b.Text="SAFE AREA • AKTİF" end)
	back(s)
end

local hud=Instance.new("Frame"); hud.Size=UDim2.fromScale(1,1); hud.BackgroundTransparency=1; hud.Visible=false; hud.Parent=stage
local top=panel(hud,UDim2.new(.04,0,.04,0),UDim2.new(.92,0,0,72))
local gameText=txt(top,"GAME",UDim2.new(0,16,0,8),UDim2.new(.42,0,0,28),16,C.CREAM,true)
local scoreText=txt(top,"0",UDim2.new(.43,0,0,8),UDim2.new(.18,0,0,28),22,C.CREAM,true,true)
local comboText=txt(top,"x1",UDim2.new(.65,0,0,8),UDim2.new(.12,0,0,28),16,C.ORANGE,true,true)
local timeText=txt(top,"30",UDim2.new(.80,0,0,8),UDim2.new(.15,0,0,28),16,C.GREEN,true,true)
local instruction=txt(hud,"TAP",UDim2.new(.08,0,.20,0),UDim2.new(.84,0,0,45),20,C.CREAM,true,true)
local tap=button(hud,"TAP!",UDim2.new(.10,0,.66,0),UDim2.new(.80,0,0,90),true); tap.TextSize=30
local count=txt(hud,"3",UDim2.new(.15,0,.37,0),UDim2.new(.70,0,0,120),76,C.ORANGE,true,true); count.Visible=false
local currentId:string?=nil
local objectiveText=instruction

local function sendAction()
	if not currentId then return end
	Action:FireServer(currentId, {kind="tap", value=math.random(1,10)})
end
tap.Activated:Connect(sendAction)

World.OnClientEvent:Connect(function(data)
	if typeof(data)~="table" then return end
	if data.state=="WorldReady" then
		-- The server has built the selected game arena. Camera is returned to the character.
		local character=player.Character
		local hum=character and character:FindFirstChildOfClass("Humanoid")
		local camera=workspace.CurrentCamera
		if hum and camera then camera.CameraType=Enum.CameraType.Custom; camera.CameraSubject=hum end
	end
end)

World.OnClientEvent:Connect(function(data)
	if typeof(data)=="table" and data.state=="WorldReady" then
		local char=player.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); local cam=workspace.CurrentCamera
		if hum and cam then cam.CameraType=Enum.CameraType.Custom; cam.CameraSubject=hum end
	end
end)

State.OnClientEvent:Connect(function(data)
	if typeof(data)~="table" then return end
	if data.state=="Started" then
		currentId=data.gameId
		local g
		for _,x in ipairs(Games) do if x.id==currentId then g=x break end end
		if not g then return end
		gameText.Text=string.upper(g.name); instruction.Text=g.desc; scoreText.Text="0"; comboText.Text="x1"; timeText.Text=tostring(g.duration)
		hud.Visible=true; for _,s in pairs(screens) do s.Visible=false end
		count.Visible=true
		task.spawn(function()
			for _,n in ipairs({"3","2","1","GO!"}) do count.Text=n; task.wait(n=="GO!" and .4 or .7) end
			count.Visible=false
		end)
	elseif data.state=="Objective" then
		instruction.Text=tostring(data.text or "PLAY")
	elseif data.state=="Hit" then
		instruction.Text="DİKKAT! ENGEL!"
	elseif data.state=="Reaction" then
		if data.active then instruction.Text="⚡ TAP NOW!" elseif data.result=="GOOD" then instruction.Text="MÜKEMMEL!" else instruction.Text="GEÇ KALDIN / ERKEN!" end
	elseif data.state=="Score" then
		scoreText.Text=tostring(data.score or 0); comboText.Text="x"..tostring(data.multiplier or 1)
	elseif data.state=="Time" then
		timeText.Text=tostring(data.time or 0)
	elseif data.state=="Finished" then
		hud.Visible=false; count.Visible=false; currentId=nil
		local result=screens.GameOver:FindFirstChild("Result")
		if result and result:IsA("TextLabel") then result.Text=string.upper(data.gameName or "RUN").."\n"..string.format("%06d",data.score or 0) end
		show("GameOver")
	end
end)

do
	local s=screens.GameOver; header(s,"RUN BİTTİ","Skorun server tarafından işlendi.")
	local p=panel(s,UDim2.new(.16,0,.24,0),UDim2.new(.68,0,.28,0))
	local r=txt(p,"RUN\n000000",UDim2.new(.05,0,.08,0),UDim2.new(.90,0,.84,0),34,C.CREAM,true,true); r.Name="Result"
	local again=button(s,"TEKRAR OYNA",UDim2.new(.16,0,.59,0),UDim2.new(.68,0,0,56),true); again.Activated:Connect(function() show("Games") end)
	local home=button(s,"HUB'A DÖN",UDim2.new(.16,0,.70,0),UDim2.new(.68,0,0,50),false); home.Activated:Connect(function() show("Home") end)
end

show("Boot")
task.delay(.9,function() if screens.Boot.Visible then show("Home") end end)
