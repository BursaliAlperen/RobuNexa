--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local GuiService=game:GetService("GuiService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local function load(name)
	local ok,m=pcall(function() return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild(name,10)) end)
	if not ok then warn("[MainClient] "..name.." load failed: "..tostring(m)); return nil end
	return m
end
local Config=load("GameConfig"); local Theme=load("UITheme"); local Anim=load("Anim"); local Fx=load("FxKit"); local Remotes=load("Remotes")
if not Config or not Theme or not Anim or not Fx or not Remotes then return end
local gui=Instance.new("ScreenGui"); gui.Name="MobileGameHub"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=false; gui.DisplayOrder=50; gui.Parent=pg
local root=Instance.new("Frame"); root.Size=UDim2.fromScale(1,1); root.BackgroundColor3=Theme.Dark; root.Parent=gui
local inset=GuiService:GetGuiInset(); local pad=Instance.new("UIPadding"); pad.PaddingTop=UDim.new(0,inset.Y); pad.Parent=root
local screens={}
for _,n in ipairs({"Loading","Welcome","MainMenu","GameSelect","Leaderboard","Stats","Settings","GameOver"}) do local f=Instance.new("Frame"); f.Name=n; f.Size=UDim2.fromScale(1,1); f.BackgroundColor3=Theme.Dark; f.Visible=false; f.Parent=root; screens[n]=f end
local function show(name) for n,f in pairs(screens) do f.Visible=n==name end end
local function title(parent,text,y)
	local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Text=text; l.TextColor3=Theme.Cream; l.Font=Theme.Font; l.TextScaled=true; l.Size=UDim2.new(.9,0,0,60); l.Position=UDim2.new(.05,0,0,y); l.Parent=parent; return l
end
local function button(parent,text,pos,size)
	local b=Instance.new("TextButton"); b.Text=text; b.Position=pos; b.Size=size or UDim2.new(.9,0,0,56); b.TextScaled=true; b.Parent=parent; Theme.ApplyButton(b); Anim.Button(b); return b
end
title(screens.Loading,"MOBILE GAME HUB",60); title(screens.Loading,"10 oyun hazırlanıyor...",130)
title(screens.Welcome,"10 GAMES. ONE TAP.",55)
local w=Instance.new("TextLabel"); w.BackgroundTransparency=1; w.Text="Ücretsiz • reklamsız • Robux satışı yok\n10 saniyede öğren, skorunu yükselt."; w.TextColor3=Theme.Cream; w.TextScaled=true; w.Size=UDim2.new(.9,0,0,100); w.Position=UDim2.new(.05,0,0,130); w.Parent=screens.Welcome
local wb=button(screens.Welcome,"BAŞLA",UDim2.new(.05,0,0,270)); wb.Activated:Connect(function() show("MainMenu") end)
title(screens.MainMenu,"GAME HUB",40)
local pb=button(screens.MainMenu,"OYUNLAR",UDim2.new(.05,0,0,120)); pb.Activated:Connect(function() show("GameSelect") end)
local lb=button(screens.MainMenu,"LEADERBOARD",UDim2.new(.05,0,0,190)); lb.Activated:Connect(function() show("Leaderboard"); Remotes.RequestLeaderboard:FireServer({GameId=Config.Games[1].Id}) end)
local sb=button(screens.MainMenu,"STATS",UDim2.new(.05,0,0,260)); sb.Activated:Connect(function() show("Stats") end)
local setb=button(screens.MainMenu,"SETTINGS",UDim2.new(.05,0,0,330)); setb.Activated:Connect(function() show("Settings") end)
title(screens.GameSelect,"OYUN SEÇ",30)
for i,g in ipairs(Config.Games) do
	local x=.05+((i-1)%2)*.47; local y=110+math.floor((i-1)/2)*82
	local b=button(screens.GameSelect,g.Name,UDim2.new(x,0,0,y),UDim2.new(.43,0,0,64))
	local d=Instance.new("TextLabel"); d.BackgroundTransparency=1; d.Text=g.Description; d.TextColor3=Theme.Muted; d.TextScaled=true; d.Size=UDim2.new(1,-12,0,20); d.Position=UDim2.new(0,6,1,-24); d.Parent=b
	b.Activated:Connect(function() Remotes.RequestStart:FireServer({GameId=g.Id}) end)
end
local back=button(screens.GameSelect,"← HUB",UDim2.new(.05,0,1,-70),UDim2.new(.28,0,0,54)); back.Activated:Connect(function() show("MainMenu") end)
title(screens.Leaderboard,"TOP 10",30)
local lbt=Instance.new("TextLabel"); lbt.BackgroundTransparency=1; lbt.Text="Yükleniyor..."; lbt.TextColor3=Theme.Cream; lbt.TextScaled=true; lbt.Size=UDim2.new(.9,0,0,320); lbt.Position=UDim2.new(.05,0,0,105); lbt.Parent=screens.Leaderboard
local lbb=button(screens.Leaderboard,"← HUB",UDim2.new(.05,0,1,-70),UDim2.new(.28,0,0,54)); lbb.Activated:Connect(function() show("MainMenu") end)
title(screens.Stats,"İSTATİSTİKLER",30)
local st=Instance.new("TextLabel"); st.BackgroundTransparency=1; st.Text="Skorların kaydediliyor."; st.TextColor3=Theme.Cream; st.TextScaled=true; st.Size=UDim2.new(.9,0,0,220); st.Position=UDim2.new(.05,0,0,110); st.Parent=screens.Stats
local stb=button(screens.Stats,"← HUB",UDim2.new(.05,0,1,-70),UDim2.new(.28,0,0,54)); stb.Activated:Connect(function() show("MainMenu") end)
title(screens.Settings,"AYARLAR",30)
local sound=true; local sdb=button(screens.Settings,"SES: AÇIK",UDim2.new(.05,0,0,120)); sdb.Activated:Connect(function() sound=not sound; sdb.Text="SES: "..(sound and "AÇIK" or "KAPALI") end)
local seb=button(screens.Settings,"← HUB",UDim2.new(.05,0,1,-70),UDim2.new(.28,0,0,54)); seb.Activated:Connect(function() show("MainMenu") end)
title(screens.GameOver,"RUN BİTTİ",45)
local res=Instance.new("TextLabel"); res.BackgroundTransparency=1; res.TextColor3=Theme.Cream; res.TextScaled=true; res.Size=UDim2.new(.9,0,0,120); res.Position=UDim2.new(.05,0,0,125); res.Parent=screens.GameOver
local again=button(screens.GameOver,"TEKRAR",UDim2.new(.05,0,0,280)); again.Activated:Connect(function() show("GameSelect") end)
local oh=button(screens.GameOver,"HUB",UDim2.new(.05,0,0,350)); oh.Activated:Connect(function() show("MainMenu") end)
local hud=Instance.new("Frame"); hud.Name="GameHUD"; hud.Size=UDim2.fromScale(1,1); hud.BackgroundTransparency=1; hud.Visible=false; hud.Parent=gui
local score=Instance.new("TextLabel"); score.BackgroundTransparency=1; score.TextColor3=Theme.Cream; score.Font=Enum.Font.GothamBlack; score.TextScaled=true; score.Size=UDim2.new(.5,0,0,60); score.Position=UDim2.new(.25,0,0,35); score.Text="0"; score.Parent=hud
local combo=score:Clone(); combo.Position=UDim2.new(.25,0,0,88); combo.Text="x1"; combo.Parent=hud
local tap=button(hud,"TAP!",UDim2.new(.1,0,1,-135),UDim2.new(.8,0,0,72))
local cd=Instance.new("TextLabel"); cd.BackgroundTransparency=1; cd.TextColor3=Theme.Orange; cd.Font=Enum.Font.GothamBlack; cd.TextScaled=true; cd.Size=UDim2.new(.8,0,0,130); cd.Position=UDim2.new(.1,0,.38,0); cd.Visible=false; cd.Parent=hud
local current=nil
local function payload()
	if not current then return {Action="tap"} end
	local id=current.Id
	if id=="DodgeRun" then return {Action="lane",Value=math.random(1,5)}
	elseif id=="StackTower" then return {Action="place",Value=math.random(-10,10)/10}
	elseif id=="ColorRush" then return {Action="color",Value="Red"}
	elseif id=="MemoryMatch" then return {Action="card",Value=math.random(1,6)}
	elseif id=="ReactionTest" then return {Action="react"}
	elseif id=="CoinRush" then return {Action="coin"}
	elseif id=="JumpChallenge" or id=="FallingPlatforms" then return {Action="jump"}
	elseif id=="FloorIsLava" then return {Action="safe"}
	else return {Action="tapTarget"} end
end
tap.Activated:Connect(function()
	if current then Remotes.RequestAction:FireServer(payload()); Fx.Punch(workspace.CurrentCamera); Fx.Popup(gui,"+!",UDim2.fromScale(.4,.48),Theme.Orange) end
end)
local function countdown()
	cd.Visible=true
	for _,n in ipairs({"3","2","1","GO!"}) do cd.Text=n; TweenService:Create(cd,TweenInfo.new(.18,Enum.EasingStyle.Back),{TextTransparency=0}):Play(); task.wait(n=="GO!" and .4 or 1) end
	cd.Visible=false
end
Remotes.GameStateChanged.OnClientEvent:Connect(function(p)
	if typeof(p)~="table" or typeof(p.State)~="string" then return end
	if p.State=="Started" then current=Config.GetGame(p.GameId); hud.Visible=true; score.Text="0"; combo.Text="x1"; task.spawn(countdown)
	elseif p.State=="Finished" then hud.Visible=false; res.Text="SKOR\n"..tostring(math.floor(tonumber(p.Score) or 0)); show("GameOver"); current=nil end
end)
Remotes.LeaderboardResult.OnClientEvent:Connect(function(p)
	if typeof(p)~="table" or typeof(p.Top)~="table" then return end
	local lines={}; for _,e in ipairs(p.Top) do table.insert(lines,string.format("#%d  %s  %d",e.Rank,tostring(e.UserId),tonumber(e.Score) or 0)) end
	table.insert(lines,"\nSenin rank: "..tostring(p.Rank or "-")); lbt.Text=table.concat(lines,"\n")
end)
show("Loading"); task.delay(.8,function() show("Welcome") end)
