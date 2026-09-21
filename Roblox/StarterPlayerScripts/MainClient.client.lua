-- ROBUNEXA // AAA STUDDED EDITION
-- ONLY REQUIRED LOCAL SCRIPT
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local SoundService=game:GetService("SoundService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local C={BG=Color3.fromRGB(12,14,18),PANEL=Color3.fromRGB(25,29,36),PANEL2=Color3.fromRGB(34,39,47),PANEL3=Color3.fromRGB(43,49,58),WHITE=Color3.fromRGB(245,247,250),MUTED=Color3.fromRGB(148,156,168),METAL=Color3.fromRGB(105,112,124),CREAM=Color3.fromRGB(250,220,160),ORANGE=Color3.fromRGB(245,130,30),RED=Color3.fromRGB(240,72,62),BLUE=Color3.fromRGB(65,145,240),YELLOW=Color3.fromRGB(255,210,65),GREEN=Color3.fromRGB(75,205,110)}
local Games={
 {id="DodgeRun",title="DODGE RUN",sub="IMPACT COURSE",num="01",accent=C.RED,desc="Üç şeritli sprint. Hareketli çelik barlardan sıyrıl, gate'leri geç ve combo kur."},
 {id="TargetRush",title="TARGET RUSH",sub="LOCK SYSTEM",num="02",accent=C.BLUE,desc="12 neon hedefi kilitle. Mobilde hedefe dokun; server hedefi doğrular."},
 {id="StackTower",title="STACK TOWER",sub="PRECISION FORGE",num="03",accent=C.ORANGE,desc="Hareketli bloğu tam hizala ve DROP. Her kat daha dar olur."},
 {id="CoinRush",title="COIN RUSH",sub="VAULT RUN",num="04",accent=C.YELLOW,desc="36 fiziksel coin'i topla. Zinciri koru, combo çarpanını büyüt."},
 {id="FloorIsLava",title="FLOOR IS LAVA",sub="SURVIVAL GRID",num="05",accent=C.RED,desc="Yeşilde kal. Lava yükseliyor; yanlış adım seni tekrar spawn'a yollar."}
}

local rem=RS:WaitForChild("RobuNexaRemotes",15); if not rem then return end
local Start=rem:WaitForChild("Start",10); local Action=rem:WaitForChild("Action",10); local State=rem:WaitForChild("State",10); local Exit=rem:WaitForChild("Exit",10); local World=rem:WaitForChild("World",10); local Leaderboard=rem:WaitForChild("Leaderboard",10)
if not Start or not Action or not State or not Exit or not World or not Leaderboard then return end

local gui=Instance.new("ScreenGui"); gui.Name="RobuNexaAAA"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.DisplayOrder=100; pcall(function() gui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets end); gui.Parent=pg
local root=Instance.new("Frame"); root.Size=UDim2.fromScale(1,1); root.BackgroundColor3=C.BG; root.BorderSizePixel=0; root.Parent=gui
local stage=Instance.new("Frame"); stage.AnchorPoint=Vector2.new(.5,.5); stage.Position=UDim2.fromScale(.5,.5); stage.Size=UDim2.new(1,-24,1,-24); stage.BackgroundTransparency=1; stage.Parent=root
local aspect=Instance.new("UIAspectRatioConstraint"); aspect.AspectRatio=16/9; aspect.DominantAxis=Enum.DominantAxis.Width; aspect.Parent=stage
local maxSize=Instance.new("UISizeConstraint"); maxSize.MaxSize=Vector2.new(1600,900); maxSize.Parent=stage
local function layout() local s=root.AbsoluteSize; local portrait=s.Y>1 and s.X/s.Y<1.45; aspect.Enabled=not portrait; stage.Size=portrait and UDim2.new(1,-14,1,-14) or UDim2.new(1,-24,1,-24) end
root:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout); task.defer(layout)

local function corner(p,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=p end
local function stroke(p,t,col) local x=Instance.new("UIStroke"); x.Color=col or C.METAL; x.Transparency=t or .4; x.Thickness=1; x.Parent=p end
local function grad(p,a,b) local g=Instance.new("UIGradient"); g.Color=ColorSequence.new(a,b); g.Rotation=90; g.Parent=p end
local function text(p,t,pos,size,fs,col,bold,center)
 local x=Instance.new("TextLabel"); x.BackgroundTransparency=1; x.Text=t; x.TextColor3=col or C.WHITE; x.Font=bold==false and Enum.Font.Gotham or Enum.Font.GothamBold; x.TextSize=fs; x.TextWrapped=true; x.Position=pos; x.Size=size; x.TextXAlignment=center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left; x.TextYAlignment=Enum.TextYAlignment.Center; x.Parent=p
 local u=Instance.new("UITextSizeConstraint"); u.MinTextSize=math.max(10,math.floor(fs*.55)); u.MaxTextSize=fs; u.Parent=x; return x
end
local function stud(p,pos,col,sz)
 local x=Instance.new("Frame"); x.AnchorPoint=Vector2.new(.5,.5); x.Position=pos; x.Size=UDim2.fromOffset(sz or 6,sz or 6); x.BackgroundColor3=col or C.CREAM; x.BorderSizePixel=0; x.ZIndex=10; x.Parent=p; corner(x,99); stroke(x,.65, C.WHITE); return x
end
local function panel(parent,pos,size,accent)
 local p=Instance.new("Frame"); p.Position=pos; p.Size=size; p.BackgroundColor3=C.PANEL; p.BorderSizePixel=0; p.Parent=parent; corner(p,8); stroke(p,.25,C.METAL); grad(p,Color3.fromRGB(34,39,47),Color3.fromRGB(20,24,30))
 local stripe=Instance.new("Frame"); stripe.Size=UDim2.new(0,4,1,0); stripe.BackgroundColor3=accent or C.ORANGE; stripe.BorderSizePixel=0; stripe.Parent=p; corner(stripe,8)
 stud(p,UDim2.new(0,10,0,10),C.CREAM); stud(p,UDim2.new(1,-10,0,10),C.METAL); stud(p,UDim2.new(0,10,1,-10),C.METAL); stud(p,UDim2.new(1,-10,1,-10),C.CREAM)
 return p
end
local function button(parent,t,pos,size,accent,primary)
 local b=Instance.new("TextButton"); b.Text=t; b.AutoButtonColor=false; b.Active=true; b.Position=pos; b.Size=size; b.BackgroundColor3=primary and (accent or C.CREAM) or C.PANEL2; b.TextColor3=primary and Color3.fromRGB(10,12,15) or C.WHITE; b.Font=Enum.Font.GothamBold; b.TextSize=17; b.BorderSizePixel=0; b.Parent=parent; corner(b,7); stroke(b,.35,primary and accent or C.METAL)
 stud(b,UDim2.new(0,7,0,7),primary and C.WHITE or C.CREAM,5); stud(b,UDim2.new(1,-7,0,7),primary and C.WHITE or C.METAL,5); stud(b,UDim2.new(0,7,1,-7),C.METAL,5); stud(b,UDim2.new(1,-7,1,-7),C.CREAM,5)
 local base=size; b.Activated:Connect(function() TweenService:Create(b,TweenInfo.new(.06),{Size=UDim2.new(base.X.Scale,base.X.Offset-4,base.Y.Scale,base.Y.Offset-3)}):Play(); task.delay(.07,function() if b.Parent then TweenService:Create(b,TweenInfo.new(.08),{Size=base}):Play() end end) end); return b
end
local screens={}; for _,n in ipairs({"Boot","Home","Games","Leaderboard","Stats","Settings","GameOver"}) do local f=Instance.new("Frame"); f.Name=n; f.Size=UDim2.fromScale(1,1); f.BackgroundTransparency=1; f.Visible=false; f.Parent=stage; screens[n]=f end
local function show(n) for k,v in pairs(screens) do v.Visible=(k==n) end end
local selected=Games[1]; local currentId=nil; local inRun=false; local cards={}

local function sfx() local s=Instance.new("Sound"); s.SoundId="rbxasset://sounds/button.wav"; s.Volume=.22; s.Parent=SoundService; SoundService:PlayLocalSound(s); task.delay(1.5,function() if s.Parent then s:Destroy() end end) end
local function shake(d,i) local cam=workspace.CurrentCamera; if not cam then return end; local st=os.clock(); while os.clock()-st<d do local a=1-(os.clock()-st)/d; cam.CFrame=cam.CFrame*CFrame.new((math.random()-.5)*i*a,(math.random()-.5)*i*a,0); RunService.RenderStepped:Wait() end end
local function flash(col) local f=Instance.new("Frame"); f.Size=UDim2.fromScale(1,1); f.BackgroundColor3=col; f.BackgroundTransparency=.88; f.BorderSizePixel=0; f.ZIndex=50; f.Parent=stage; TweenService:Create(f,TweenInfo.new(.22),{BackgroundTransparency=1}):Play(); task.delay(.25,function() if f.Parent then f:Destroy() end end) end

do
 local s=screens.Boot; text(s,"ROBUNEXA",UDim2.new(.08,0,.28,0),UDim2.new(.84,0,0,70),48,C.CREAM,true,true); text(s,"STUD LAB // AAA MINI GAMES",UDim2.new(.08,0,.41,0),UDim2.new(.84,0,0,34),16,C.ORANGE,true,true); text(s,"NO STORE • NO PAY-TO-WIN • PURE RUNS",UDim2.new(.08,0,.48,0),UDim2.new(.84,0,0,24),12,C.MUTED,true,true)
 local p=panel(s,UDim2.new(.25,0,.62,0),UDim2.new(.5,0,0,14),C.ORANGE); local f=Instance.new("Frame"); f.Size=UDim2.new(0,0,1,0); f.BackgroundColor3=C.ORANGE; f.BorderSizePixel=0; f.Parent=p; corner(f,6); TweenService:Create(f,TweenInfo.new(.9),{Size=UDim2.fromScale(1,1)}):Play()
end

do
 local s=screens.Home; text(s,"ROBUNEXA",UDim2.new(0,30,0,20),UDim2.new(.45,0,0,38),31,C.CREAM,true); text(s,"STUD LAB",UDim2.new(0,32,0,57),UDim2.new(.3,0,0,18),11,C.ORANGE,true)
 local profile=panel(s,UDim2.new(.63,0,.03,0),UDim2.new(.32,0,.11,0),C.BLUE); text(profile,string.upper(player.DisplayName),UDim2.new(0,20,0,8),UDim2.new(.8,0,0,24),14,C.WHITE,true); text(profile,"PLAYER // LOCAL RUNNER",UDim2.new(0,20,0,34),UDim2.new(.8,0,0,16),10,C.MUTED,false)
 local hero=panel(s,UDim2.new(.04,0,.17,0),UDim2.new(.92,0,.40,0),C.ORANGE); text(hero,"05",UDim2.new(.05,0,.12,0),UDim2.new(.2,0,.38,0),62,C.ORANGE,true,true); text(hero,"AAA RUNS",UDim2.new(.05,0,.55,0),UDim2.new(.2,0,.14,0),12,C.CREAM,true,true); text(hero,"THE COMMAND DECK",UDim2.new(.31,0,.12,0),UDim2.new(.58,0,.16,0),25,C.WHITE,true); text(hero,"Five handcrafted games. Studded command UI. Mobile-first.",UDim2.new(.31,0,.31,0),UDim2.new(.58,0,.18,0),14,C.MUTED,false)
 local play=button(hero,"DEPLOY RUN  →",UDim2.new(.31,0,.65,0),UDim2.new(.38,0,0,54),C.ORANGE,true); play.Activated:Connect(function() sfx(); show("Games") end)
 local q=panel(s,UDim2.new(.04,0,.62,0),UDim2.new(.92,0,.20,0),C.BLUE)
 local function nav(t,x,to) local b=button(q,t,UDim2.new(x,0,.34,0),UDim2.new(.21,0,.46,0),C.BLUE,false); b.Activated:Connect(function() sfx(); show(to) end) end
 nav("GAMES",.03,"Games"); nav("LEADERBOARD",.26,"Leaderboard"); nav("STATS",.49,"Stats"); nav("SETTINGS",.72,"Settings")
end

local detailTitle,detailSub,detailDesc,launch
do
 local s=screens.Games; text(s,"GAME SELECT // 05",UDim2.new(0,28,0,20),UDim2.new(.5,0,0,38),28,C.CREAM,true); text(s,"SELECT A RUN • MASTER THE SKILL",UDim2.new(0,30,0,57),UDim2.new(.7,0,0,20),11,C.MUTED,false)
 local list=Instance.new("ScrollingFrame"); list.Position=UDim2.new(.035,0,.15,0); list.Size=UDim2.new(.43,0,.72,0); list.BackgroundTransparency=1; list.BorderSizePixel=0; list.ScrollBarThickness=4; list.AutomaticCanvasSize=Enum.AutomaticSize.Y; list.Parent=s
 local gl=Instance.new("UIGridLayout"); gl.CellSize=UDim2.new(1,0,0,100); gl.CellPadding=UDim2.new(0,0,0,9); gl.Parent=list
 local det=panel(s,UDim2.new(.49,0,.15,0),UDim2.new(.475,0,.72,0),C.ORANGE); detailTitle=text(det,selected.title,UDim2.new(0,22,0,16),UDim2.new(.88,0,0,38),28,C.WHITE,true); detailSub=text(det,selected.sub,UDim2.new(0,24,0,53),UDim2.new(.85,0,0,20),11,C.ORANGE,true); detailDesc=text(det,selected.desc,UDim2.new(0,22,0,88),UDim2.new(.88,0,0,82),14,C.MUTED,false)
 local stats=panel(det,UDim2.new(.05,0,.47,0),UDim2.new(.9,0,.2,0),selected.accent); text(stats,"30",UDim2.new(.08,0,.12,0),UDim2.new(.25,0,.5,0),33,C.WHITE,true,true); text(stats,"SEC",UDim2.new(.08,0,.62,0),UDim2.new(.25,0,.18,0),10,C.MUTED,true,true); text(stats,"05",UDim2.new(.38,0,.12,0),UDim2.new(.25,0,.5,0),33,C.WHITE,true,true); text(stats,"GAMES",UDim2.new(.38,0,.62,0),UDim2.new(.25,0,.18,0),10,C.MUTED,true,true); text(stats,"∞",UDim2.new(.68,0,.12,0),UDim2.new(.2,0,.5,0),33,selected.accent,true,true); text(stats,"REPLAY",UDim2.new(.66,0,.62,0),UDim2.new(.28,0,.18,0),10,C.MUTED,true,true)
 launch=button(det,"START RUN  →",UDim2.new(.08,0,.74,0),UDim2.new(.84,0,0,56),C.ORANGE,true); launch.Activated:Connect(function() sfx(); Start:FireServer(selected.id) end)
 local back=button(s,"← COMMAND DECK",UDim2.new(.035,0,.89,0),UDim2.new(.43,0,0,42),C.BLUE,false); back.Activated:Connect(function() show("Home") end)
 for i,g in ipairs(Games) do
  local card=panel(list,UDim2.new(),UDim2.new(1,0,0,100),g.accent); card.LayoutOrder=i; local hit=Instance.new("TextButton"); hit.Text=""; hit.BackgroundTransparency=1; hit.Size=UDim2.fromScale(1,1); hit.Parent=card
  text(card,g.num,UDim2.new(0,18,0,13),UDim2.fromOffset(42,28),15,g.accent,true,true); text(card,g.title,UDim2.new(0,72,0,13),UDim2.new(.7,0,0,27),17,C.WHITE,true); text(card,g.sub,UDim2.new(0,72,0,43),UDim2.new(.7,0,0,20),10,C.MUTED,true); local mark=text(card,"PLAY",UDim2.new(.78,0,.34,0),UDim2.new(.16,0,0,22),10,g.accent,true,true); mark.Visible=i==1; cards[i]={frame=card,mark=mark}
  hit.Activated:Connect(function() selected=g; for j,info in ipairs(cards) do info.mark.Visible=j==i; info.frame.BackgroundColor3=j==i and C.PANEL3 or C.PANEL end; detailTitle.Text=g.title; detailSub.Text=g.sub; detailSub.TextColor3=g.accent; detailDesc.Text=g.desc; launch.BackgroundColor3=g.accent; sfx() end)
 end
end

do
 local s=screens.Leaderboard; text(s,"LEADERBOARD",UDim2.new(0,30,0,20),UDim2.new(.6,0,0,38),30,C.CREAM,true); text(s,"LIVE SERVER RANKINGS // NO STORE",UDim2.new(0,32,0,57),UDim2.new(.7,0,0,20),11,C.MUTED,false)
 local p=panel(s,UDim2.new(.07,0,.18,0),UDim2.new(.86,0,.60,0),C.BLUE); local list=text(p,"SELECT A GAME",UDim2.new(0,22,0,20),UDim2.new(1,-44,1,-40),17,C.WHITE,true)
 for i,g in ipairs(Games) do local b=button(s,string.format("%02d",i),UDim2.new(.08+(i-1)*.18,0,.81,0),UDim2.fromOffset(55,42),g.accent,false); b.Activated:Connect(function() Leaderboard:FireServer(g.id) end) end
 Leaderboard.OnClientEvent:Connect(function(data) local lines={}; for _,r in ipairs(data or {}) do table.insert(lines,string.format("#%02d  %s  %d",r.rank or 0,r.name or "RUNNER",r.score or 0)) end; list.Text=#lines>0 and table.concat(lines,"\n") or "NO LIVE SCORES YET." end)
 local b=button(s,"← COMMAND DECK",UDim2.new(.04,0,.89,0),UDim2.new(.28,0,0,42),C.BLUE,false); b.Activated:Connect(function() show("Home") end)
end

do
 local s=screens.Stats; text(s,"PROFILE",UDim2.new(0,30,0,20),UDim2.new(.6,0,0,38),30,C.CREAM,true); text(s,"FIVE GAME LOADOUT // LOCAL RUNNER",UDim2.new(0,32,0,57),UDim2.new(.7,0,0,20),11,C.MUTED,false)
 local p=panel(s,UDim2.new(.08,0,.2,0),UDim2.new(.84,0,.55,0),C.ORANGE); text(p,"05",UDim2.new(.08,0,.15,0),UDim2.new(.25,0,.3,0),54,C.ORANGE,true,true); text(p,"AAA RUNS",UDim2.new(.08,0,.44,0),UDim2.new(.25,0,.16,0),11,C.MUTED,true,true); text(p,"30s",UDim2.new(.38,0,.15,0),UDim2.new(.25,0,.3,0),54,C.WHITE,true,true); text(p,"PER ROUND",UDim2.new(.38,0,.44,0),UDim2.new(.25,0,.16,0),11,C.MUTED,true,true); text(p,"∞",UDim2.new(.68,0,.15,0),UDim2.new(.25,0,.3,0),54,C.GREEN,true,true); text(p,"REPLAY",UDim2.new(.68,0,.44,0),UDim2.new(.25,0,.16,0),11,C.MUTED,true,true); text(p,"LEARN FAST • MASTER SLOW • NO STORE",UDim2.new(.08,0,.72,0),UDim2.new(.84,0,.12,0),12,C.CREAM,true,true)
 local b=button(s,"← COMMAND DECK",UDim2.new(.04,0,.89,0),UDim2.new(.28,0,0,42),C.ORANGE,false); b.Activated:Connect(function() show("Home") end)
end

do
 local s=screens.Settings; text(s,"SETTINGS",UDim2.new(0,30,0,20),UDim2.new(.6,0,0,38),30,C.CREAM,true); text(s,"MOBILE FIRST // SAFE AREA // RESPONSIVE",UDim2.new(0,32,0,57),UDim2.new(.75,0,0,20),11,C.MUTED,false)
 local p=panel(s,UDim2.new(.08,0,.19,0),UDim2.new(.84,0,.53,0),C.BLUE); text(p,"LAYOUT",UDim2.new(0,24,0,22),UDim2.new(.3,0,0,24),13,C.MUTED,true); text(p,"16:9 LANDSCAPE",UDim2.new(0,24,0,53),UDim2.new(.5,0,0,25),18,C.WHITE,true); text(p,"PORTRAIT FALLBACK",UDim2.new(0,24,0,83),UDim2.new(.5,0,0,25),18,C.WHITE,true); text(p,"DEVICE SAFE AREA",UDim2.new(0,24,0,113),UDim2.new(.5,0,0,25),18,C.WHITE,true); text(p,"AAA RULE: BIG TOUCH TARGETS • SHORT LABELS • NO HIDDEN REQUIRED ACTION",UDim2.new(0,24,0,175),UDim2.new(.88,0,0,65),14,C.MUTED,false)
 local b=button(s,"← COMMAND DECK",UDim2.new(.04,0,.89,0),UDim2.new(.28,0,0,42),C.BLUE,false); b.Activated:Connect(function() show("Home") end)
end

local hud=Instance.new("Frame"); hud.Size=UDim2.fromScale(1,1); hud.BackgroundTransparency=1; hud.Visible=false; hud.Parent=stage
local top=panel(hud,UDim2.new(.035,0,.035,0),UDim2.new(.93,0,0,72),C.ORANGE)
local hudGame=text(top,"RUN",UDim2.new(0,20,0,8),UDim2.new(.3,0,0,28),15,C.WHITE,true); local hudScore=text(top,"000000",UDim2.new(.37,0,0,8),UDim2.new(.2,0,0,30),22,C.WHITE,true,true); local hudCombo=text(top,"x1",UDim2.new(.59,0,0,8),UDim2.new(.11,0,0,30),18,C.ORANGE,true,true); local hudTime=text(top,"30",UDim2.new(.74,0,0,8),UDim2.new(.13,0,0,30),18,C.GREEN,true,true)
local ex=button(top,"EXIT",UDim2.new(.87,0,.16,0),UDim2.new(.1,0,.68,0),C.RED,false); ex.Activated:Connect(function() if inRun then Exit:FireServer() end end)
local obj=panel(hud,UDim2.new(.16,0,.18,0),UDim2.new(.68,0,0,54),C.ORANGE); local objText=text(obj,"OBJECTIVE",UDim2.new(.04,0,0,6),UDim2.new(.92,0,0,40),16,C.WHITE,true,true)
local pb=Instance.new("Frame"); pb.Position=UDim2.new(.25,0,.87,0); pb.Size=UDim2.new(.5,0,0,7); pb.BackgroundColor3=C.PANEL3; pb.BorderSizePixel=0; pb.Parent=hud; corner(pb,6); local pf=Instance.new("Frame"); pf.Size=UDim2.new(0,0,1,0); pf.BackgroundColor3=C.ORANGE; pf.BorderSizePixel=0; pf.Parent=pb; corner(pf,6)
local cd=text(hud,"3",UDim2.new(.15,0,.32,0),UDim2.new(.7,0,0,110),82,C.ORANGE,true,true); cd.Visible=false
local hint=panel(hud,UDim2.new(.17,0,.73,0),UDim2.new(.66,0,0,64),C.BLUE); local hintText=text(hint,"MOVE / TOUCH / REACT",UDim2.new(.04,0,0,7),UDim2.new(.92,0,0,48),15,C.WHITE,true,true)
local drop=button(hud,"DROP",UDim2.new(.73,0,.75,0),UDim2.new(.21,0,0,70),C.ORANGE,true); drop.Visible=false
drop.Activated:Connect(function() if inRun and currentId=="StackTower" then sfx(); Action:FireServer("StackTower",{kind="stack"}) end end)

World.OnClientEvent:Connect(function(d)
 if typeof(d)~="table" or d.state~="WorldReady" then return end
 local cam=workspace.CurrentCamera; if cam and d.origin then cam.CameraType=Enum.CameraType.Scriptable; cam.CFrame=CFrame.lookAt(d.origin+Vector3.new(0,24,40),d.origin+Vector3.new(0,2,0)); task.delay(.42,function() local c=player.Character; local h=c and c:FindFirstChildOfClass("Humanoid"); if workspace.CurrentCamera and h then workspace.CurrentCamera.CameraType=Enum.CameraType.Custom; workspace.CurrentCamera.CameraSubject=h end end) end
end)

UIS.InputBegan:Connect(function(input,processed)
 if processed or not inRun or currentId~="TargetRush" then return end
 if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
  local cam=workspace.CurrentCamera; if not cam then return end
  local ray=cam:ViewportPointToRay(input.Position.X,input.Position.Y); local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={player.Character}
  local hit=workspace:Raycast(ray.Origin,ray.Direction*120,params)
  if hit and hit.Instance and hit.Instance.Name:match("^Target") then Action:FireServer("TargetRush",{kind="target",name=hit.Instance.Name}) end
 end
end)

State.OnClientEvent:Connect(function(d)
 if typeof(d)~="table" then return end
 if d.state=="Started" then
  for _,g in ipairs(Games) do if g.id==d.gameId then selected=g; break end end
  currentId=d.gameId; inRun=true; hud.Visible=true; drop.Visible=(currentId=="StackTower"); hudGame.Text=selected.title; hudScore.Text="000000"; hudCombo.Text="x1"; hudTime.Text=tostring(d.duration or 30); objText.Text="STANDBY"; hintText.Text=currentId=="DodgeRun" and "MOVE LEFT / RIGHT TO DODGE" or currentId=="TargetRush" and "TOUCH TARGETS IN THE WORLD" or currentId=="StackTower" and "DROP ON PERFECT ALIGNMENT" or currentId=="CoinRush" and "TOUCH COINS TO COLLECT" or "STAY GREEN / ESCAPE THE LAVA"; pf.Size=UDim2.new(0,0,1,0)
  for _,v in pairs(screens) do v.Visible=false end
  cd.Visible=true; task.spawn(function() for _,n in ipairs({"3","2","1","GO!"}) do cd.Text=n; cd.TextColor3=selected.accent; sfx(); task.wait(n=="GO!" and .45 or .62) end; cd.Visible=false end)
 elseif d.state=="Objective" then objText.Text=tostring(d.text or "OBJECTIVE")
 elseif d.state=="Score" then hudScore.Text=string.format("%06d",d.score or 0); hudCombo.Text="x"..tostring(d.multiplier or 1)
 elseif d.state=="Time" then hudTime.Text=tostring(d.time or 0); hudTime.TextColor3=(d.time or 0)<=5 and C.RED or C.GREEN
 elseif d.state=="Progress" then pf.Size=UDim2.new(math.clamp(d.value or 0,0,1),0,1,0)
 elseif d.state=="TargetHit" then objText.Text="TARGET LOCKED +30"; flash(C.BLUE); sfx()
 elseif d.state=="Hit" then objText.Text="IMPACT // COMBO RESET"; flash(C.RED); task.spawn(function() shake(.18,2.2) end)
 elseif d.state=="StackMiss" then objText.Text="STACK COLLAPSE"; flash(C.RED); task.spawn(function() shake(.16,2.4) end)
 elseif d.state=="Finished" then
  inRun=false; hud.Visible=false; drop.Visible=false; cd.Visible=false; local r=screens.GameOver:FindFirstChild("Result"); local b=screens.GameOver:FindFirstChild("Best"); if r and r:IsA("TextLabel") then r.Text=string.upper(d.gameName or "RUN").."\n"..string.format("%06d",d.score or 0) end; if b and b:IsA("TextLabel") then b.Text="BEST SCORE  "..string.format("%06d",d.best or d.score or 0) end; show("GameOver")
 end
end)

do
 local s=screens.GameOver; text(s,"RUN COMPLETE",UDim2.new(.18,0,.11,0),UDim2.new(.64,0,0,45),34,C.CREAM,true,true); text(s,"SCORE REPORT // STUD LAB",UDim2.new(.18,0,.19,0),UDim2.new(.64,0,0,22),11,C.MUTED,true,true)
 local p=panel(s,UDim2.new(.2,0,.28,0),UDim2.new(.6,0,.28,0),C.ORANGE); local r=text(p,"RUN\n000000",UDim2.new(.06,0,.1,0),UDim2.new(.88,0,.56,0),30,C.WHITE,true,true); r.Name="Result"; local b=text(p,"BEST SCORE 000000",UDim2.new(.06,0,.69,0),UDim2.new(.88,0,.16,0),12,C.ORANGE,true,true); b.Name="Best"
 local a=button(s,"RUN AGAIN",UDim2.new(.2,0,.63,0),UDim2.new(.6,0,0,55),C.ORANGE,true); a.Activated:Connect(function() show("Games") end)
 local h=button(s,"RETURN TO DECK",UDim2.new(.2,0,.73,0),UDim2.new(.6,0,0,48),C.BLUE,false); h.Activated:Connect(function() show("Home") end)
end

show("Boot"); task.delay(1,function() if screens.Boot.Visible then show("Home") end end)
