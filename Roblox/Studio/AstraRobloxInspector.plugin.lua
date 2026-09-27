-- Astra Roblox Inspector: inspect first, diagnose second, fix only confirmed issues.
local HttpService=game:GetService("HttpService")
local ChangeHistoryService=game:GetService("ChangeHistoryService")
local ScriptEditorService=game:GetService("ScriptEditorService")
local ENDPOINT="https://astra-ai-studio.hatchable.site/api/roblox-diagnose"
local tb=plugin:CreateToolbar("Astra AI")
local btn=tb:CreateButton("Inspector","Astra inspect/fix","")
local info=DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float,true,true,460,620,340,440)
local ui=plugin:CreateDockWidgetPluginGui("AstraRobloxInspector",info);ui.Title="Astra AI — Inspect & Fix";ui.Enabled=false
local root=Instance.new("Frame");root.Size=UDim2.fromScale(1,1);root.BackgroundColor3=Color3.fromRGB(18,20,26);root.Parent=ui
local box=Instance.new("TextBox");box.Position=UDim2.new(0,10,0,10);box.Size=UDim2.new(1,-20,0,90);box.BackgroundColor3=Color3.fromRGB(28,31,40);box.TextColor3=Color3.new(1,1,1);box.TextWrapped=true;box.MultiLine=true;box.TextYAlignment=Enum.TextYAlignment.Top;box.Text="Projeyi A-Z incele; mevcut sistemi bozma; hataları bul ve sadece doğrulanmış hataları düzelt.";box.Parent=root
local scan=Instance.new("TextButton");scan.Position=UDim2.new(0,10,0,110);scan.Size=UDim2.new(.49,-5,0,36);scan.Text="1. İNCELE";scan.Parent=root
local fix=Instance.new("TextButton");fix.Position=UDim2.new(.51,10,0,110);fix.Size=UDim2.new(.49,-15,0,36);fix.Text="2. HATALARI BUL & FIX";fix.Parent=root
local status=Instance.new("TextLabel");status.Position=UDim2.new(0,10,0,152);status.Size=UDim2.new(1,-20,0,50);status.BackgroundTransparency=1;status.TextColor3=Color3.fromRGB(190,195,210);status.TextWrapped=true;status.Parent=root
local out=Instance.new("ScrollingFrame");out.Position=UDim2.new(0,10,0,210);out.Size=UDim2.new(1,-20,1,-220);out.AutomaticCanvasSize=Enum.AutomaticSize.Y;out.BackgroundColor3=Color3.fromRGB(12,14,18);out.Parent=root
local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,5);layout.Parent=out
local snapshot={};local scanned=false
local function line(t,c)local l=Instance.new("TextLabel");l.Size=UDim2.new(1,-10,0,0);l.AutomaticSize=Enum.AutomaticSize.Y;l.BackgroundTransparency=1;l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Top;l.TextSize=11;l.Font=Enum.Font.Code;l.TextColor3=c or Color3.new(1,1,1);l.Text=t;l.Parent=out end
local function clear()for _,x in ipairs(out:GetChildren())do if x:IsA("TextLabel")then x:Destroy()end end end
local function collect(r,d)if d>12 then return end;for _,o in ipairs(r:GetChildren())do if o:IsA("LuaSourceContainer")then local ok,s=pcall(function()return ScriptEditorService:GetEditorSource(o)end);table.insert(snapshot,{path=o:GetFullName(),source=ok and s or o.Source,className=o.ClassName})elseif #o:GetChildren()>0 then collect(o,d+1)end end end
local function inspect()snapshot={};for _,n in ipairs({"ReplicatedStorage","ServerScriptService","ServerStorage","StarterPlayer","StarterGui","Workspace"})do local ok,s=pcall(game.GetService,game,n);if ok then collect(s,0)end end;return #snapshot end
local function context()local p={};for _,s in ipairs(snapshot)do table.insert(p,"SCRIPT "..s.path.." ["..s.className.."]\n"..s.source:sub(1,12000))end;return table.concat(p,"\n\n")end
local function request()local ok,r=pcall(function()return HttpService:RequestAsync({Url=ENDPOINT,Method="POST",Headers={["Content-Type"]="application/json"},Body=HttpService:JSONEncode({prompt=box.Text,context=context()})})end);if not ok or not r.Success then error(tostring(r and r.StatusCode or r))end;return HttpService:JSONDecode(r.Body)end
local function findScript(path)local cur=game;for _,p in ipairs(string.split(path,"/"))do cur=cur:FindFirstChild(p)or(cur==game and game:GetService(p))end;return cur end
local function apply(a)
 if a.type=="update_script"then local s=findScript(a.path);if not s or not s:IsA("LuaSourceContainer")then error("Script bulunamadı: "..a.path)end;local old=s.Source;local new=a.source or"";if #new<20 or(#old>500 and #new<old*.2)then error("Şüpheli replacement reddedildi")end;ScriptEditorService:UpdateSourceAsync(s,function()return new end);return end
 if a.type=="create_script"then local p=game:GetService(a.service);if p:FindFirstChild(a.name)then error("Mevcut nesne korunuyor: "..a.name)end;local s=Instance.new(a.className or"ModuleScript");s.Name=a.name;s.Source=a.source or"";s.Parent=p;return end
 error("Desteklenmeyen işlem") end
btn.Click:Connect(function()ui.Enabled=not ui.Enabled end)
scan.MouseButton1Click:Connect(function()clear();local n=inspect();scanned=true;line("ÖN TARAMA: "..n.." script bulundu. HİÇBİR ŞEY DEĞİŞTİRİLMEDİ.",Color3.fromRGB(120,220,150));status.Text="Snapshot hazır. Şimdi AI analiz edip doğrulanmış hataları bulabilir."end)
fix.MouseButton1Click:Connect(function()
 if not scanned then status.Text="Önce 1. İNCELE.";return end
 fix.Active=false;clear();line("Mevcut proje analiz ediliyor — henüz değişiklik yok...")
 local ok,d=pcall(request);if not ok then line("HATA: "..tostring(d),Color3.fromRGB(255,100,100));fix.Active=true;return end
 line(d.message or"Analiz tamamlandı.")
 for _,x in ipairs(d.diagnostics or{})do line("["..tostring(x.severity).."] "..tostring(x.path or"").." — "..tostring(x.message),Color3.fromRGB(245,190,110))end
 local actions=d.actions or{};if #actions==0 then line("Doğrulanmış fix yok. Proje olduğu gibi bırakıldı.",Color3.fromRGB(170,190,210));fix.Active=true;return end
 ChangeHistoryService:SetWaypoint("Astra Before Safe Fix");local good=0
 for _,a in ipairs(actions)do local aok,e=pcall(apply,a);if aok then good+=1 else line("FIX REDDEDİLDİ: "..tostring(e),Color3.fromRGB(255,140,110))end end
 ChangeHistoryService:SetWaypoint("Astra After Safe Fix");line("Uygulanan güvenli fix: "..good.."/"..#actions,Color3.fromRGB(120,220,150));status.Text="Tamamlandı. Change History ile geri alınabilir.";fix.Active=true
end)