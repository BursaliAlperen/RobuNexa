-- ROBUNEXA // 2026 STUDDED UI
-- ONLY REQUIRED LOCAL SCRIPT
-- Modern Roblox-style mobile-first UI using the supplied Stud/Cartoon asset IDs.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local SoundService=game:GetService("SoundService")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")

local ASSET={
	Stud="rbxassetid://6927295847",
	Check="rbxassetid://134653892993002",
	X="rbxassetid://90632297073614",
	Arrow="rbxassetid://80502164243325",
	Gear="rbxassetid://75820707424884",
	Shop="rbxassetid://131542322606909",
	Gold="rbxassetid://74139630651516",
	Silver="rbxassetid://86596347754683",
	Bronze="rbxassetid://90960235662302",
	Crown="rbxassetid://138742650114410",
	Gift="rbxassetid://110739482515116",
}

local C={
	BG=Color3.fromRGB(10,12,16),
	BG2=Color3.fromRGB(17,20,26),
	PANEL=Color3.fromRGB(24,28,35),
	PANEL2=Color3.fromRGB(32,37,46),
	PANEL3=Color3.fromRGB(42,48,58),
	WHITE=Color3.fromRGB(247,248,250),
	MUTED=Color3.fromRGB(143,152,165),
	METAL=Color3.fromRGB(102,111,125),
	CREAM=Color3.fromRGB(250,220,160),
	ORANGE=Color3.fromRGB(245,130,30),
	RED=Color3.fromRGB(240,72,62),
	BLUE=Color3.fromRGB(65,145,240),
	YELLOW=Color3.fromRGB(255,210,65),
	GREEN=Color3.fromRGB(75,205,110),
	PURPLE=Color3.fromRGB(175,100,230),
}

local Games={
	{id="DodgeRun",title="DODGE RUN",sub="IMPACT COURSE",num="01",accent=C.RED,desc="Üç şeritli sprint. Hareketli çelik barlardan sıyrıl, kapıları geç ve combo kur."},
	{id="TargetRush",title="TARGET RUSH",sub="LOCK SYSTEM",num="02",accent=C.BLUE,desc="12 neon hedefi kilitle. Mobilde hedefe dokun; server hedefi doğrulasın."},
	{id="StackTower",title="STACK TOWER",sub="PRECISION FORGE",num="03",accent=C.ORANGE,desc="Hareketli bloğu tam hizala ve DROP. Her başarılı kat daha dar olur."},
	{id="CoinRush",title="COIN RUSH",sub="VAULT RUN",num="04",accent=C.YELLOW,desc="36 fiziksel coin'i topla. Zinciri koru ve combo çarpanını büyüt."},
	{id="FloorIsLava",title="FLOOR IS LAVA",sub="SURVIVAL GRID",num="05",accent=C.RED,desc="Yeşilde kal. Lava yükseliyor; yanlış adım seni güvenli noktaya yollar."},
}

local remotes=ReplicatedStorage:WaitForChild("RobuNexaRemotes",15)
if not remotes then return end
local Start=remotes:WaitForChild("Start",10)
local Action=remotes:WaitForChild("Action",10)
local State=remotes:WaitForChild("State",10)
local Exit=remotes:WaitForChild("Exit",10)
local World=remotes:WaitForChild("World",10)
local Leaderboard=remotes:WaitForChild("Leaderboard",10)
if not Start or not Action or not State or not Exit or not World or not Leaderboard then return end

local gui=Instance.new("ScreenGui")
gui.Name="RobuNexa2026UI"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=100
pcall(function() gui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets end)
gui.Parent=playerGui

local root=Instance.new("Frame")
root.Size=UDim2.fromScale(1,1)
root.BackgroundColor3=C.BG
root.BorderSizePixel=0
root.Parent=gui

local rootGradient=Instance.new("UIGradient")
rootGradient.Color=ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.fromRGB(13,16,22)),
	ColorSequenceKeypoint.new(.55,Color3.fromRGB(8,10,14)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(18,15,12))
})
rootGradient.Rotation=22
rootGradient.Parent=root

local stage=Instance.new("Frame")
stage.AnchorPoint=Vector2.new(.5,.5)
stage.Position=UDim2.fromScale(.5,.5)
stage.Size=UDim2.new(1,-18,1,-18)
stage.BackgroundTransparency=1
stage.Parent=root

local aspect=Instance.new("UIAspectRatioConstraint")
aspect.AspectRatio=16/9
aspect.DominantAxis=Enum.DominantAxis.Width
aspect.Parent=stage

local maxSize=Instance.new("UISizeConstraint")
maxSize.MaxSize=Vector2.new(1720,970)
maxSize.Parent=stage

local function updateLayout()
	local s=root.AbsoluteSize
	local portrait=s.Y>1 and s.X/s.Y<1.45
	aspect.Enabled=not portrait
	stage.Size=portrait and UDim2.new(1,-14,1,-14) or UDim2.new(1,-18,1,-18)
end
root:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout)
task.defer(updateLayout)

local function corner(p,r)
	local x=Instance.new("UICorner")
	x.CornerRadius=UDim.new(0,r)
	x.Parent=p
end

local function outline(p,t,col,thickness)
	local x=Instance.new("UIStroke")
	x.Color=col or C.METAL
	x.Transparency=t or .35
	x.Thickness=thickness or 1
	x.Parent=p
	return x
end

local function gradient(p,a,b,rotation)
	local g=Instance.new("UIGradient")
	g.Color=ColorSequence.new(a,b)
	g.Rotation=rotation or 90
	g.Parent=p
	return g
end

local function text(p,t,pos,size,fs,col,bold,center)
	local x=Instance.new("TextLabel")
	x.BackgroundTransparency=1
	x.Text=t
	x.TextColor3=col or C.WHITE
	x.Font=bold==false and Enum.Font.Gotham or Enum.Font.GothamBold
	x.TextSize=fs
	x.TextWrapped=true
	x.Position=pos
	x.Size=size
	x.TextXAlignment=center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
	x.TextYAlignment=Enum.TextYAlignment.Center
	x.Parent=p
	local u=Instance.new("UITextSizeConstraint")
	u.MinTextSize=math.max(10,math.floor(fs*.54))
	u.MaxTextSize=fs
	u.Parent=x
	return x
end

local function icon(p,id,pos,size,tint,transparency,z)
	local im=Instance.new("ImageLabel")
	im.BackgroundTransparency=1
	im.Image=id
	im.Position=pos
	im.Size=size
	im.ImageColor3=tint or C.WHITE
	im.ImageTransparency=transparency or 0
	im.ScaleType=Enum.ScaleType.Fit
	im.ZIndex=z or 5
	im.Parent=p
	return im
end

local function studTexture(p,transparency,tint)
	local im=Instance.new("ImageLabel")
	im.Name="StudTexture"
	im.BackgroundTransparency=1
	im.Size=UDim2.fromScale(1,1)
	im.Position=UDim2.fromScale(0,0)
	im.Image=ASSET.Stud
	im.ImageTransparency=transparency or .82
	im.ImageColor3=tint or C.WHITE
	im.ScaleType=Enum.ScaleType.Tile
	im.TileSize=UDim2.fromOffset(56,56)
	im.ZIndex=(p:IsA("GuiObject") and p.ZIndex or 1)+1
	im.Parent=p
	return im
end

local function studDot(p,pos,color,size)
	local d=Instance.new("Frame")
	d.AnchorPoint=Vector2.new(.5,.5)
	d.Position=pos
	d.Size=UDim2.fromOffset(size or 7,size or 7)
	d.BackgroundColor3=color or C.CREAM
	d.BorderSizePixel=0
	d.ZIndex=15
	d.Parent=p
	corner(d,100)
	outline(d,.55,C.WHITE,1)
	return d
end

local function panel(parent,pos,size,accent,withTexture)
	local p=Instance.new("Frame")
	p.Position=pos
	p.Size=size
	p.BackgroundColor3=C.PANEL
	p.BorderSizePixel=0
	p.ClipsDescendants=true
	p.Parent=parent
	corner(p,10)
	outline(p,.18,C.METAL,1)

	local stripe=Instance.new("Frame")
	stripe.Size=UDim2.new(0,4,1,0)
	stripe.BackgroundColor3=accent or C.ORANGE
	stripe.BorderSizePixel=0
	stripe.ZIndex=3
	stripe.Parent=p

	gradient(p,Color3.fromRGB(38,44,53),Color3.fromRGB(18,22,28),90)

	if withTexture~=false then
		studTexture(p,.88,accent or C.WHITE)
	end

	studDot(p,UDim2.new(0,11,0,11),C.CREAM,6)
	studDot(p,UDim2.new(1,-11,0,11),C.METAL,6)
	studDot(p,UDim2.new(0,11,1,-11),C.METAL,6)
	studDot(p,UDim2.new(1,-11,1,-11),C.CREAM,6)

	return p
end

local function iconButton(parent,labelText,assetId,pos,size,accent,selectedState)
	local b=Instance.new("TextButton")
	b.Text=""
	b.AutoButtonColor=false
	b.Active=true
	b.Position=pos
	b.Size=size
	b.BackgroundColor3=selectedState and C.PANEL3 or C.PANEL2
	b.BorderSizePixel=0
	b.Parent=parent
	corner(b,9)
	outline(b,selectedState and .12 or .42,selectedState and accent or C.METAL,selectedState and 1.5 or 1)
	studTexture(b,.9,accent)

	if assetId then
		icon(b,assetId,UDim2.new(.12,0,.17,0),UDim2.new(0,24,0,24),accent,.02,20)
	end

	text(b,labelText,UDim2.new(.23,0,.09,0),UDim2.new(.72,0,.82,0),12,C.WHITE,true,false)

	local normal=size
	b.Activated:Connect(function()
		TweenService:Create(b,TweenInfo.new(.06),{Size=UDim2.new(normal.X.Scale,normal.X.Offset-3,normal.Y.Scale,normal.Y.Offset-3)}):Play()
		task.delay(.07,function()
			if b.Parent then TweenService:Create(b,TweenInfo.new(.08),{Size=normal}):Play() end
		end)
	end)
	return b
end

local function actionButton(parent,labelText,pos,size,accent,assetId)
	local b=Instance.new("TextButton")
	b.Text=""
	b.AutoButtonColor=false
	b.Active=true
	b.Position=pos
	b.Size=size
	b.BackgroundColor3=accent
	b.BorderSizePixel=0
	b.Parent=parent
	b.ClipsDescendants=true
	corner(b,10)
	outline(b,.15,C.WHITE,1)
	studTexture(b,.84,C.WHITE)
	studDot(b,UDim2.new(0,10,0,10),C.WHITE,6)
	studDot(b,UDim2.new(1,-10,0,10),C.METAL,6)
	studDot(b,UDim2.new(0,10,1,-10),C.METAL,6)
	studDot(b,UDim2.new(1,-10,1,-10),C.WHITE,6)

	if assetId then
		icon(b,assetId,UDim2.new(.06,0,.16,0),UDim2.new(0,28,0,28),C.WHITE,0,20)
		text(b,labelText,UDim2.new(.18,0,0,0),UDim2.new(.76,0,1,0),17,Color3.fromRGB(12,14,18),true,false)
	else
		text(b,labelText,UDim2.fromScale(0,0),UDim2.fromScale(1,1),17,Color3.fromRGB(12,14,18),true,true)
	end

	local normal=size
	b.Activated:Connect(function()
		TweenService:Create(b,TweenInfo.new(.06),{Size=UDim2.new(normal.X.Scale,normal.X.Offset-4,normal.Y.Scale,normal.Y.Offset-4)}):Play()
		task.delay(.07,function()
			if b.Parent then TweenService:Create(b,TweenInfo.new(.08),{Size=normal}):Play() end
		end)
	end)
	return b
end

local function backButton(parent,pos,size)
	local b=Instance.new("TextButton")
	b.Text=""
	b.AutoButtonColor=false
	b.Position=pos
	b.Size=size
	b.BackgroundColor3=C.PANEL2
	b.BorderSizePixel=0
	b.Parent=parent
	corner(b,8)
	outline(b,.35,C.METAL)
	studTexture(b,.9,C.WHITE)
	icon(b,ASSET.Arrow,UDim2.new(.07,0,.2,0),UDim2.new(0,22,0,22),C.CREAM)
	text(b,"BACK TO DECK",UDim2.new(.24,0,0,0),UDim2.new(.68,0,1,0),12,C.WHITE,true,false)
	return b
end

local function sfx()
	local s=Instance.new("Sound")
	s.SoundId="rbxasset://sounds/button.wav"
	s.Volume=.2
	s.Parent=SoundService
	SoundService:PlayLocalSound(s)
	task.delay(1.5,function() if s.Parent then s:Destroy() end end)
end

local function shake(duration,intensity)
	local camera=workspace.CurrentCamera
	if not camera then return end
	local start=os.clock()
	while os.clock()-start<duration do
		local a=1-(os.clock()-start)/duration
		camera.CFrame=camera.CFrame*CFrame.new((math.random()-.5)*intensity*a,(math.random()-.5)*intensity*a,0)
		RunService.RenderStepped:Wait()
	end
end

local function flash(color)
	local f=Instance.new("Frame")
	f.Size=UDim2.fromScale(1,1)
	f.BackgroundColor3=color
	f.BackgroundTransparency=.9
	f.BorderSizePixel=0
	f.ZIndex=60
	f.Parent=stage
	TweenService:Create(f,TweenInfo.new(.2),{BackgroundTransparency=1}):Play()
	task.delay(.25,function() if f.Parent then f:Destroy() end end)
end

local screens={}
for _,name in ipairs({"Boot","Home","Games","Leaderboard","Stats","Settings","GameOver"}) do
	local f=Instance.new("Frame")
	f.Name=name
	f.Size=UDim2.fromScale(1,1)
	f.BackgroundTransparency=1
	f.Visible=false
	f.Parent=stage
	screens[name]=f
end

local function show(name)
	for key,frame in pairs(screens) do
		frame.Visible=key==name
	end
end

local selected=Games[1]
local currentId=nil
local inRun=false
local cards={}
local stats={}
local detailTitle
local detailSub
local detailDesc
local startRun

-- BOOT
do
	local s=screens.Boot
	icon(s,ASSET.Crown,UDim2.new(.5,-42,0,100),UDim2.fromOffset(84,84),C.CREAM,0,20)
	text(s,"ROBUNEXA",UDim2.new(.1,0,.33,0),UDim2.new(.8,0,0,70),48,C.CREAM,true,true)
	text(s,"STUD LAB",UDim2.new(.1,0,.44,0),UDim2.new(.8,0,0,32),18,C.ORANGE,true,true)
	text(s,"5 PREMIUM-QUALITY RUNS • NO STORE • PURE GAMEPLAY",UDim2.new(.1,0,.50,0),UDim2.new(.8,0,0,28),12,C.MUTED,true,true)
	local load=panel(s,UDim2.new(.22,0,.63,0),UDim2.new(.56,0,0,18),C.ORANGE,true)
	local fill=Instance.new("Frame")
	fill.Size=UDim2.new(0,0,1,0)
	fill.BackgroundColor3=C.ORANGE
	fill.BorderSizePixel=0
	fill.ZIndex=12
	fill.Parent=load
	corner(fill,8)
	TweenService:Create(fill,TweenInfo.new(.95),{Size=UDim2.fromScale(1,1)}):Play()
end

-- HOME
do
	local s=screens.Home
	text(s,"ROBUNEXA",UDim2.new(.035,0,.035,0),UDim2.new(.32,0,0,38),30,C.CREAM,true)
	text(s,"STUD LAB / COMMAND DECK",UDim2.new(.035,0,.095,0),UDim2.new(.42,0,0,20),10,C.ORANGE,true)

	local profile=panel(s,UDim2.new(.69,0,.028,0),UDim2.new(.275,0,.12,0),C.BLUE,true)
	local avatar=Instance.new("ImageLabel")
	avatar.Size=UDim2.fromOffset(44,44)
	avatar.Position=UDim2.new(0,14,0,13)
	avatar.BackgroundColor3=C.PANEL3
	avatar.BorderSizePixel=0
	avatar.Parent=profile
	corner(avatar,22)
	local thumb
	pcall(function()
		local url=Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)
		thumb=url
	end)
	if thumb then avatar.Image=thumb end
	outline(avatar,.1,C.CREAM,1)
	icon(profile,ASSET.Crown,UDim2.new(0,53,0,4),UDim2.fromOffset(22,22),C.CREAM,.02,20)
	text(profile,string.upper(player.DisplayName),UDim2.new(0,68,0,10),UDim2.new(.7,0,0,25),14,C.WHITE,true)
	text(profile,"LOCAL RUNNER • LV 01",UDim2.new(0,68,0,37),UDim2.new(.68,0,0,18),10,C.MUTED,false)

	local hero=panel(s,UDim2.new(.035,0,.17,0),UDim2.new(.93,0,.37,0),C.ORANGE,true)
	icon(hero,ASSET.Gift,UDim2.new(.06,0,.11,0),UDim2.fromOffset(42,42),C.ORANGE,.05,20)
	text(hero,"05",UDim2.new(.045,0,.30,0),UDim2.new(.21,0,.38,0),62,C.ORANGE,true,true)
	text(hero,"AAA RUNS",UDim2.new(.045,0,.64,0),UDim2.new(.21,0,.15,0),11,C.CREAM,true,true)
	text(hero,"THE COMMAND DECK",UDim2.new(.30,0,.11,0),UDim2.new(.62,0,.14,0),25,C.WHITE,true)
	text(hero,"Studded panels • strong iconography • big touch zones • fast transitions.",UDim2.new(.30,0,.29,0),UDim2.new(.62,0,.2,0),14,C.MUTED,false)
	local deploy=actionButton(hero,"DEPLOY RUN",UDim2.new(.30,0,.61,0),UDim2.new(.38,0,0,54),C.ORANGE,ASSET.Arrow)
	deploy.Activated:Connect(function() sfx(); show("Games") end)

	local quick=panel(s,UDim2.new(.035,0,.58,0),UDim2.new(.93,0,.23,0),C.BLUE,true)
	text(quick,"QUICK ACCESS",UDim2.new(.025,0,.06,0),UDim2.new(.3,0,0,22),11,C.MUTED,true)
	icon(quick,ASSET.Arrow,UDim2.new(.89,0,.04,0),UDim2.fromOffset(20,20),C.BLUE,.1,20)

	local b1=iconButton(quick,"GAMES",ASSET.Arrow,UDim2.new(.025,0,.30,0),UDim2.new(.20,0,.52,0),C.BLUE,true)
	local b2=iconButton(quick,"LEADERBOARD",ASSET.Gold,UDim2.new(.235,0,.30,0),UDim2.new(.24,0,.52,0),C.YELLOW,false)
	local b3=iconButton(quick,"COLLECTION",ASSET.Shop,UDim2.new(.485,0,.30,0),UDim2.new(.21,0,.52,0),C.ORANGE,false)
	local b4=iconButton(quick,"SETTINGS",ASSET.Gear,UDim2.new(.705,0,.30,0),UDim2.new(.20,0,.52,0),C.BLUE,false)
	b1.Activated:Connect(function() sfx(); show("Games") end)
	b2.Activated:Connect(function() sfx(); show("Leaderboard") end)
	b3.Activated:Connect(function() sfx(); show("Stats") end)
	b4.Activated:Connect(function() sfx(); show("Settings") end)
end

-- GAME SELECT
do
	local s=screens.Games
	text(s,"GAME SELECT",UDim2.new(.035,0,.03,0),UDim2.new(.45,0,0,36),29,C.CREAM,true)
	text(s,"05 RUNS • 30 SECOND ARCADE SESSIONS",UDim2.new(.035,0,.09,0),UDim2.new(.65,0,0,20),10,C.MUTED,true)

	local list=Instance.new("ScrollingFrame")
	list.Position=UDim2.new(.035,0,.15,0)
	list.Size=UDim2.new(.43,0,.70,0)
	list.BackgroundTransparency=1
	list.BorderSizePixel=0
	list.ScrollBarThickness=4
	list.ScrollBarImageColor3=C.ORANGE
	list.AutomaticCanvasSize=Enum.AutomaticSize.Y
	list.Parent=s

	local gl=Instance.new("UIGridLayout")
	gl.CellSize=UDim2.new(1,0,0,102)
	gl.CellPadding=UDim2.new(0,0,0,9)
	gl.Parent=list

	local det=panel(s,UDim2.new(.49,0,.15,0),UDim2.new(.475,0,.70,0),selected.accent,true)
	detailTitle=text(det,selected.title,UDim2.new(0,24,0,18),UDim2.new(.85,0,0,38),28,C.WHITE,true)
	detailSub=text(det,selected.sub,UDim2.new(0,26,0,55),UDim2.new(.85,0,0,18),11,selected.accent,true)
	detailDesc=text(det,selected.desc,UDim2.new(0,24,0,90),UDim2.new(.85,0,0,82),14,C.MUTED,false)

	local mini=panel(det,UDim2.new(.05,0,.48,0),UDim2.new(.90,0,.20,0),selected.accent,true)
	text(mini,"30",UDim2.new(.07,0,.11,0),UDim2.new(.25,0,.54,0),34,C.WHITE,true,true)
	text(mini,"SEC",UDim2.new(.07,0,.63,0),UDim2.new(.25,0,.18,0),10,C.MUTED,true,true)
	text(mini,"05",UDim2.new(.38,0,.11,0),UDim2.new(.25,0,.54,0),34,C.WHITE,true,true)
	text(mini,"GAMES",UDim2.new(.38,0,.63,0),UDim2.new(.25,0,.18,0),10,C.MUTED,true,true)
	icon(mini,ASSET.Crown,UDim2.new(.70,0,.12,0),UDim2.fromOffset(34,34),selected.accent,.03,20)
	text(mini,"REPLAY",UDim2.new(.64,0,.63,0),UDim2.new(.30,0,.18,0),10,C.MUTED,true,true)

	startRun=actionButton(det,"START RUN",UDim2.new(.08,0,.75,0),UDim2.new(.84,0,0,56),selected.accent,ASSET.Arrow)
	startRun.Activated:Connect(function() sfx(); Start:FireServer(selected.id) end)

	local back=backButton(s,UDim2.new(.035,0,.89,0),UDim2.new(.43,0,0,42))
	back.Activated:Connect(function() show("Home") end)

	for i,g in ipairs(Games) do
		local card=panel(list,UDim2.new(),UDim2.new(1,0,0,102),g.accent,true)
		card.LayoutOrder=i
		card.BackgroundColor3=C.PANEL
		local hit=Instance.new("TextButton")
		hit.Text=""
		hit.BackgroundTransparency=1
		hit.Size=UDim2.fromScale(1,1)
		hit.Parent=card

		text(card,g.num,UDim2.new(0,18,0,12),UDim2.fromOffset(42,28),15,g.accent,true,true)
		text(card,g.title,UDim2.new(0,72,0,12),UDim2.new(.68,0,0,28),17,C.WHITE,true)
		text(card,g.sub,UDim2.new(0,72,0,43),UDim2.new(.68,0,0,20),10,C.MUTED,true)
		local mark=icon(card,ASSET.Check,UDim2.new(.84,0,.30,0),UDim2.fromOffset(30,30),g.accent,0,25)
		mark.Visible=i==1
		cards[i]={frame=card,mark=mark}
		hit.Activated:Connect(function()
			selected=g
			for j,info in ipairs(cards) do
				info.mark.Visible=j==i
				info.frame.BackgroundColor3=j==i and C.PANEL3 or C.PANEL
			end
			detailTitle.Text=g.title
			detailSub.Text=g.sub
			detailSub.TextColor3=g.accent
			detailDesc.Text=g.desc
			startRun.BackgroundColor3=g.accent
			sfx()
		end)
	end
end

-- LEADERBOARD
do
	local s=screens.Leaderboard
	text(s,"LEADERBOARD",UDim2.new(.035,0,.03,0),UDim2.new(.5,0,0,36),29,C.CREAM,true)
	text(s,"LIVE RUNNER BOARD",UDim2.new(.035,0,.09,0),UDim2.new(.4,0,0,20),10,C.MUTED,true)
	local listPanel=panel(s,UDim2.new(.06,0,.17,0),UDim2.new(.88,0,.60,0),C.BLUE,true)
	text(listPanel,"SELECT A GAME",UDim2.new(.05,0,.06,0),UDim2.new(.75,0,0,30),18,C.WHITE,true)
	local rows=Instance.new("Frame")
	rows.Position=UDim2.new(.04,0,.17,0)
	rows.Size=UDim2.new(.92,0,.75,0)
	rows.BackgroundTransparency=1
	rows.Parent=listPanel

	local function renderLeaderboard(data)
		for _,child in ipairs(rows:GetChildren()) do child:Destroy() end
		if #data==0 then
			text(rows,"NO LIVE SCORES YET",UDim2.fromScale(0,0),UDim2.fromScale(1,1),18,C.MUTED,true,true)
			return
		end
		for i,row in ipairs(data) do
			local r=Instance.new("Frame")
			r.Size=UDim2.new(1,0,0,50)
			r.Position=UDim2.new(0,0,0,(i-1)*56)
			r.BackgroundColor3=i==1 and Color3.fromRGB(57,48,24) or C.PANEL2
			r.BorderSizePixel=0
			r.Parent=rows
			corner(r,7)
			local trophy=i==1 and ASSET.Gold or i==2 and ASSET.Silver or i==3 and ASSET.Bronze
			if trophy then icon(r,trophy,UDim2.new(0,10,0,7),UDim2.fromOffset(36,36),C.WHITE,.01,20) end
			text(r,string.format("#%02d",row.rank or i),UDim2.new(0,52,0,0),UDim2.fromOffset(44,50),13,C.MUTED,true,true)
			text(r,string.upper(row.name or "RUNNER"),UDim2.new(0,104,0,0),UDim2.new(.48,0,1,0),14,C.WHITE,true)
			text(r,string.format("%06d",row.score or 0),UDim2.new(.72,0,0,0),UDim2.new(.23,0,1,0),15,i==1 and C.YELLOW or C.CREAM,true,true)
		end
	end

	for i,g in ipairs(Games) do
		local tb=Instance.new("TextButton")
		tb.Text=string.format("%02d",i)
		tb.AutoButtonColor=false
		tb.Position=UDim2.new(.06+(i-1)*.18,0,.81,0)
		tb.Size=UDim2.fromOffset(55,42)
		tb.BackgroundColor3=C.PANEL2
		tb.TextColor3=g.accent
		tb.Font=Enum.Font.GothamBold
		tb.TextSize=13
		tb.BorderSizePixel=0
		tb.Parent=s
		corner(tb,8)
		outline(tb,.25,g.accent,1)
		tb.Activated:Connect(function() Leaderboard:FireServer(g.id) end)
	end

	Leaderboard.OnClientEvent:Connect(function(data)
		renderLeaderboard(typeof(data)=="table" and data or {})
	end)

	local back=backButton(s,UDim2.new(.035,0,.89,0),UDim2.new(.28,0,0,42))
	back.Activated:Connect(function() show("Home") end)
end

-- PROFILE / REWARDS
do
	local s=screens.Stats
	text(s,"PROFILE",UDim2.new(.035,0,.03,0),UDim2.new(.5,0,0,36),29,C.CREAM,true)
	text(s,"RUNNER IDENTITY • REWARD TRACK",UDim2.new(.035,0,.09,0),UDim2.new(.7,0,0,20),10,C.MUTED,true)

	local p=panel(s,UDim2.new(.06,0,.17,0),UDim2.new(.88,0,.26,0),C.ORANGE,true)
	icon(p,ASSET.Crown,UDim2.new(.04,0,.15,0),UDim2.fromOffset(52,52),C.CREAM,0,20)
	text(p,string.upper(player.DisplayName),UDim2.new(.16,0,.13,0),UDim2.new(.55,0,0,28),20,C.WHITE,true)
	text(p,"LOCAL RUNNER • LV 01",UDim2.new(.16,0,.49,0),UDim2.new(.55,0,0,22),11,C.MUTED,false)
	icon(p,ASSET.Gift,UDim2.new(.78,0,.14,0),UDim2.fromOffset(48,48),C.ORANGE,0,20)
	text(p,"DAILY DROP",UDim2.new(.71,0,.57,0),UDim2.new(.23,0,0,20),10,C.ORANGE,true,true)

	local reward=panel(s,UDim2.new(.06,0,.47,0),UDim2.new(.41,0,.30,0),C.YELLOW,true)
	icon(reward,ASSET.Gift,UDim2.new(.07,0,.12,0),UDim2.fromOffset(44,44),C.YELLOW,0,20)
	text(reward,"REWARD BOX",UDim2.new(.27,0,.10,0),UDim2.new(.64,0,0,26),17,C.WHITE,true)
	text(reward,"Keep playing the five runs to improve your local best scores.",UDim2.new(.08,0,.35,0),UDim2.new(.84,0,.26,0),12,C.MUTED,false)
	icon(reward,ASSET.Check,UDim2.new(.08,0,.70,0),UDim2.fromOffset(24,24),C.GREEN,0,20)
	text(reward,"READY",UDim2.new(.19,0,.68,0),UDim2.new(.28,0,0,24),12,C.GREEN,true)

	local collection=panel(s,UDim2.new(.53,0,.47,0),UDim2.new(.41,0,.30,0),C.BLUE,true)
	icon(collection,ASSET.Shop,UDim2.new(.07,0,.12,0),UDim2.fromOffset(44,44),C.BLUE,0,20)
	text(collection,"COLLECTION",UDim2.new(.27,0,.10,0),UDim2.new(.64,0,0,26),17,C.WHITE,true)
	text(collection,"Cosmetic-style lab panel reserved for future non-pay-to-win unlocks.",UDim2.new(.08,0,.35,0),UDim2.new(.84,0,.26,0),12,C.MUTED,false)
	icon(collection,ASSET.Crown,UDim2.new(.08,0,.69,0),UDim2.fromOffset(24,24),C.CREAM,0,20)
	text(collection,"LAB READY",UDim2.new(.19,0,.68,0),UDim2.new(.38,0,0,24),12,C.CREAM,true)

	local b=backButton(s,UDim2.new(.035,0,.89,0),UDim2.new(.28,0,0,42))
	b.Activated:Connect(function() show("Home") end)
end

-- SETTINGS
do
	local s=screens.Settings
	text(s,"SETTINGS",UDim2.new(.035,0,.03,0),UDim2.new(.5,0,0,36),29,C.CREAM,true)
	text(s,"DEVICE LAYOUT • FEEDBACK • SAFE AREA",UDim2.new(.035,0,.09,0),UDim2.new(.7,0,0,20),10,C.MUTED,true)
	local p=panel(s,UDim2.new(.06,0,.17,0),UDim2.new(.88,0,.60,0),C.BLUE,true)
	icon(p,ASSET.Gear,UDim2.new(.05,0,.08,0),UDim2.fromOffset(48,48),C.BLUE,0,20)
	text(p,"DISPLAY",UDim2.new(.15,0,.09,0),UDim2.new(.32,0,0,28),19,C.WHITE,true)

	local rowsY={.27,.44,.61}
	local labels={"16:9 LANDSCAPE","PORTRAIT FALLBACK","DEVICE SAFE AREA"}
	for i,name in ipairs(labels) do
		local r=Instance.new("Frame")
		r.Position=UDim2.new(.06,0,rowsY[i],0)
		r.Size=UDim2.new(.86,0,0,52)
		r.BackgroundColor3=C.PANEL2
		r.BorderSizePixel=0
		r.Parent=p
		corner(r,8)
		studTexture(r,.92,C.BLUE)
		text(r,name,UDim2.new(.05,0,0,0),UDim2.new(.68,0,1,0),13,C.WHITE,true)
		icon(r,ASSET.Check,UDim2.new(.88,0,.18,0),UDim2.fromOffset(30,30),C.GREEN,0,20)
	end

	local close=Instance.new("TextButton")
	close.Text=""
	close.AutoButtonColor=false
	close.BackgroundTransparency=1
	close.Position=UDim2.new(1,-52,0,14)
	close.Size=UDim2.fromOffset(38,38)
	close.Parent=s
	icon(close,ASSET.X,UDim2.fromScale(0,0),UDim2.fromScale(1,1),C.RED,0,20)
	close.Activated:Connect(function() show("Home") end)

	local b=backButton(s,UDim2.new(.035,0,.89,0),UDim2.new(.28,0,0,42))
	b.Activated:Connect(function() show("Home") end)
end

-- RUN HUD
local hud=Instance.new("Frame")
hud.Size=UDim2.fromScale(1,1)
hud.BackgroundTransparency=1
hud.Visible=false
hud.Parent=stage

local top=panel(hud,UDim2.new(.03,0,.03,0),UDim2.new(.94,0,0,74),C.ORANGE,true)
local hudGame=text(top,"RUN",UDim2.new(.04,0,.08,0),UDim2.new(.29,0,.40,0),15,C.WHITE,true)
local hudScore=text(top,"000000",UDim2.new(.36,0,.08,0),UDim2.new(.19,0,.40,0),22,C.WHITE,true,true)
local hudCombo=text(top,"x1",UDim2.new(.57,0,.08,0),UDim2.new(.12,0,.40,0),18,C.ORANGE,true,true)
local hudTime=text(top,"30",UDim2.new(.72,0,.08,0),UDim2.new(.12,0,.40,0),18,C.GREEN,true,true)
local exit=Instance.new("TextButton")
exit.Text=""
exit.AutoButtonColor=false
exit.Position=UDim2.new(.87,0,.14,0)
exit.Size=UDim2.new(.095,0,.72,0)
exit.BackgroundColor3=C.PANEL2
exit.BorderSizePixel=0
exit.Parent=top
corner(exit,8)
outline(exit,.3,C.RED)
icon(exit,ASSET.X,UDim2.new(.10,0,.18,0),UDim2.fromOffset(24,24),C.RED,0,20)
text(exit,"EXIT",UDim2.new(.43,0,0,0),UDim2.new(.50,0,1,0),11,C.WHITE,true,false)
exit.Activated:Connect(function() if inRun then Exit:FireServer() end end)

local obj=panel(hud,UDim2.new(.14,0,.17,0),UDim2.new(.72,0,0,56),C.ORANGE,true)
local objText=text(obj,"OBJECTIVE",UDim2.new(.04,0,0,6),UDim2.new(.92,0,0,42),16,C.WHITE,true,true)

local progressBack=Instance.new("Frame")
progressBack.Position=UDim2.new(.24,0,.87,0)
progressBack.Size=UDim2.new(.52,0,0,8)
progressBack.BackgroundColor3=C.PANEL3
progressBack.BorderSizePixel=0
progressBack.Parent=hud
corner(progressBack,6)
local progressFill=Instance.new("Frame")
progressFill.Size=UDim2.new(0,0,1,0)
progressFill.BackgroundColor3=C.ORANGE
progressFill.BorderSizePixel=0
progressFill.Parent=progressBack
corner(progressFill,6)

local countdown=text(hud,"3",UDim2.new(.15,0,.32,0),UDim2.new(.7,0,0,110),82,C.ORANGE,true,true)
countdown.Visible=false

local hint=panel(hud,UDim2.new(.14,0,.72,0),UDim2.new(.48,0,0,64),C.BLUE,true)
local hintText=text(hint,"MOVE / TOUCH / REACT",UDim2.new(.04,0,0,7),UDim2.new(.92,0,0,48),14,C.WHITE,true,true)

local drop=actionButton(hud,"DROP",UDim2.new(.66,0,.715,0),UDim2.new(.20,0,0,70),C.ORANGE,ASSET.Arrow)
drop.Visible=false
drop.Activated:Connect(function()
	if inRun and currentId=="StackTower" then
		sfx()
		Action:FireServer("StackTower",{kind="stack"})
	end
end)

World.OnClientEvent:Connect(function(d)
	if typeof(d)~="table" or d.state~="WorldReady" then return end
	local camera=workspace.CurrentCamera
	if camera and d.origin then
		camera.CameraType=Enum.CameraType.Scriptable
		camera.CFrame=CFrame.lookAt(d.origin+Vector3.new(0,24,40),d.origin+Vector3.new(0,2,0))
		task.delay(.42,function()
			local char=player.Character
			local hum=char and char:FindFirstChildOfClass("Humanoid")
			if workspace.CurrentCamera and hum then
				workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
				workspace.CurrentCamera.CameraSubject=hum
			end
		end)
	end
end)

UserInputService.InputBegan:Connect(function(input,processed)
	if processed or not inRun or currentId~="TargetRush" then return end
	if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
		local camera=workspace.CurrentCamera
		if not camera then return end
		local ray=camera:ViewportPointToRay(input.Position.X,input.Position.Y)
		local params=RaycastParams.new()
		params.FilterType=Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances={player.Character}
		local hit=workspace:Raycast(ray.Origin,ray.Direction*120,params)
		if hit and hit.Instance and hit.Instance.Name:match("^Target") then
			Action:FireServer("TargetRush",{kind="target",name=hit.Instance.Name})
		end
	end
end)

State.OnClientEvent:Connect(function(d)
	if typeof(d)~="table" then return end

	if d.state=="Started" then
		for _,g in ipairs(Games) do
			if g.id==d.gameId then
				selected=g
				break
			end
		end
		currentId=d.gameId
		inRun=true
		hud.Visible=true
		drop.Visible=currentId=="StackTower"
		hudGame.Text=selected.title
		hudScore.Text="000000"
		hudCombo.Text="x1"
		hudTime.Text=tostring(d.duration or 30)
		objText.Text="STANDBY"
		hintText.Text=currentId=="DodgeRun" and "MOVE LEFT / RIGHT TO DODGE" or currentId=="TargetRush" and "TOUCH TARGETS IN THE WORLD" or currentId=="StackTower" and "DROP ON PERFECT ALIGNMENT" or currentId=="CoinRush" and "TOUCH COINS TO COLLECT" or "STAY GREEN / ESCAPE THE LAVA"
		progressFill.Size=UDim2.new(0,0,1,0)
		for _,v in pairs(screens) do v.Visible=false end
		countdown.Visible=true
		task.spawn(function()
			for _,n in ipairs({"3","2","1","GO!"}) do
				countdown.Text=n
				countdown.TextColor3=selected.accent
				sfx()
				task.wait(n=="GO!" and .45 or .62)
			end
			countdown.Visible=false
		end)

	elseif d.state=="Objective" then
		objText.Text=tostring(d.text or "OBJECTIVE")

	elseif d.state=="Score" then
		hudScore.Text=string.format("%06d",d.score or 0)
		hudCombo.Text="x"..tostring(d.multiplier or 1)
		TweenService:Create(hudScore,TweenInfo.new(.07),{TextSize=28}):Play()
		task.delay(.1,function() if hudScore.Parent then TweenService:Create(hudScore,TweenInfo.new(.12),{TextSize=22}):Play() end end)

	elseif d.state=="Time" then
		hudTime.Text=tostring(d.time or 0)
		hudTime.TextColor3=(d.time or 0)<=5 and C.RED or C.GREEN

	elseif d.state=="Progress" then
		progressFill.Size=UDim2.new(math.clamp(d.value or 0,0,1),0,1,0)

	elseif d.state=="TargetHit" then
		objText.Text="TARGET LOCKED +30"
		flash(C.BLUE)
		sfx()

	elseif d.state=="Hit" then
		objText.Text="IMPACT // COMBO RESET"
		flash(C.RED)
		task.spawn(function() shake(.18,2.2) end)

	elseif d.state=="StackMiss" then
		objText.Text="STACK COLLAPSE"
		flash(C.RED)
		task.spawn(function() shake(.16,2.4) end)

	elseif d.state=="Finished" then
		inRun=false
		hud.Visible=false
		drop.Visible=false
		countdown.Visible=false
		local result=screens.GameOver:FindFirstChild("Result")
		local best=screens.GameOver:FindFirstChild("Best")
		if result and result:IsA("TextLabel") then
			result.Text=string.upper(d.gameName or "RUN").."\n"..string.format("%06d",d.score or 0)
		end
		if best and best:IsA("TextLabel") then
			best.Text="BEST SCORE  "..string.format("%06d",d.best or d.score or 0)
		end
		show("GameOver")
	end
end)

-- GAME OVER
do
	local s=screens.GameOver
	icon(s,ASSET.Crown,UDim2.new(.5,-26,0,44),UDim2.fromOffset(52,52),C.CREAM,0,20)
	text(s,"RUN COMPLETE",UDim2.new(.18,0,.15,0),UDim2.new(.64,0,0,45),34,C.CREAM,true,true)
	text(s,"SCORE REPORT // STUD LAB",UDim2.new(.18,0,.22,0),UDim2.new(.64,0,0,22),11,C.MUTED,true,true)
	local report=panel(s,UDim2.new(.20,0,.30,0),UDim2.new(.60,0,.25,0),C.ORANGE,true)
	local result=text(report,"RUN\n000000",UDim2.new(.07,0,.09,0),UDim2.new(.86,0,.58,0),30,C.WHITE,true,true)
	result.Name="Result"
	local best=text(report,"BEST SCORE 000000",UDim2.new(.08,0,.71,0),UDim2.new(.84,0,.15,0),12,C.ORANGE,true,true)
	best.Name="Best"
	local again=actionButton(s,"RUN AGAIN",UDim2.new(.20,0,.62,0),UDim2.new(.60,0,0,55),C.ORANGE,ASSET.Arrow)
	again.Activated:Connect(function() sfx(); show("Games") end)
	local home=iconButton(s,"RETURN TO DECK",ASSET.X,UDim2.new(.20,0,.72,0),UDim2.new(.60,0,0,48),C.BLUE,false)
	home.Activated:Connect(function() sfx(); show("Home") end)
end

show("Boot")
task.delay(1,function()
	if screens.Boot.Visible then show("Home") end
end)
