--!strict
local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local ScriptEditorService = game:GetService("ScriptEditorService")
local Selection = game:GetService("Selection")

local API = "https://roblox-forge-ai.hatchable.site"
local NOXERY = "https://api.noxery.net/v1/chat/completions"

local toolbar = plugin:CreateToolbar("Roblox Forge AI")
local button = toolbar:CreateButton("Forge AI", "Open Roblox Forge AI", "rbxassetid://14978048121", "Forge AI")
button.ClickableWhenViewportHidden = true

local widget = plugin:CreateDockWidgetPluginGuiAsync(
  "RobloxForgeAI",
  DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, false, false, 390, 620)
)
widget.Title = "Roblox Forge AI"
widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function mk(class, props)
  local o = Instance.new(class)
  for k,v in pairs(props) do o[k] = v end
  return o
end

local root = mk("Frame",{Parent=widget,Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(18,22,30),BorderSizePixel=0})
mk("UIPadding",{Parent=root,PaddingTop=12,PaddingBottom=12,PaddingLeft=12,PaddingRight=12})
local layout = mk("UIListLayout",{Parent=root,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder})

mk("TextLabel",{Parent=root,Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,Text="⚡ ROBLOX FORGE AI",TextColor3=Color3.fromRGB(240,244,255),TextSize=20,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=1})
mk("TextLabel",{Parent=root,Size=UDim2.new(1,0,0,34),BackgroundTransparency=1,Text="OAuth yok • Pair Code ile web → Studio",TextColor3=Color3.fromRGB(145,160,184),TextSize=11,Font=Enum.Font.Gotham,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=2})

local function field(label, placeholder, order)
  local box = mk("Frame",{Parent=root,Size=UDim2.new(1,0,0,58),BackgroundTransparency=1,LayoutOrder=order})
  mk("TextLabel",{Parent=box,Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text=label,TextColor3=Color3.fromRGB(150,166,192),TextSize=10,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
  return mk("TextBox",{Parent=box,Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,0,34),BackgroundColor3=Color3.fromRGB(11,15,22),BorderColor3=Color3.fromRGB(45,57,78),TextColor3=Color3.fromRGB(235,241,250),PlaceholderColor3=Color3.fromRGB(92,107,130),PlaceholderText=placeholder,TextSize=11,Font=Enum.Font.Code,ClearTextOnFocus=false})
end

local forgeKey = field("FORGE API KEY","rfa_live_...",3)
local robloxKey = field("ROBLOX OPEN CLOUD API KEY (opsiyonel)","Roblox x-api-key",4)
local noxeryKey = field("NOXERY API KEY","Noxery key",5)
local pairCode = field("PAIR CODE","Web sitesinden 6 haneli kod",6)
local model = field("MODEL","gpt-6-astra",7)

local row=mk("Frame",{Parent=root,Size=UDim2.new(1,0,0,38),BackgroundTransparency=1,LayoutOrder=8})
mk("UIListLayout",{Parent=row,FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,7)})
local connect=mk("TextButton",{Parent=row,Size=UDim2.new(0.5,-4,1,0),BackgroundColor3=Color3.fromRGB(79,108,255),TextColor3=Color3.new(1,1,1),Text="PAIR / CONNECT",TextSize=11,Font=Enum.Font.GothamBold})
local scan=mk("TextButton",{Parent=row,Size=UDim2.new(0.5,-4,1,0),BackgroundColor3=Color3.fromRGB(30,39,54),TextColor3=Color3.fromRGB(225,232,243),Text="SCAN",TextSize=11,Font=Enum.Font.GothamBold})
local status=mk("TextLabel",{Parent=root,Size=UDim2.new(1,0,0,28),BackgroundColor3=Color3.fromRGB(12,29,25),TextColor3=Color3.fromRGB(102,235,180),Text="● OFFLINE",TextSize=10,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=9})
mk("UIPadding",{Parent=status,PaddingLeft=10})
local log=mk("TextLabel",{Parent=root,Size=UDim2.new(1,0,0,150),BackgroundColor3=Color3.fromRGB(9,13,19),TextColor3=Color3.fromRGB(155,171,195),Text="Hazır.",TextSize=10,Font=Enum.Font.Code,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,LayoutOrder=10})
mk("UIPadding",{Parent=log,PaddingTop=8,PaddingBottom=8,PaddingLeft=8,PaddingRight=8})

local function say(s) log.Text = os.date("%H:%M:%S").."  "..tostring(s).."\\n"..log.Text end
local function save()
  plugin:SetSetting("forgeKey",forgeKey.Text); plugin:SetSetting("robloxKey",robloxKey.Text)
  plugin:SetSetting("noxeryKey",noxeryKey.Text); plugin:SetSetting("pairCode",string.upper(pairCode.Text))
  plugin:SetSetting("model",model.Text)
end
local function load()
  forgeKey.Text=tostring(plugin:GetSetting("forgeKey") or "")
  robloxKey.Text=tostring(plugin:GetSetting("robloxKey") or "")
  noxeryKey.Text=tostring(plugin:GetSetting("noxeryKey") or "")
  pairCode.Text=tostring(plugin:GetSetting("pairCode") or "")
  model.Text=tostring(plugin:GetSetting("model") or "gpt-6-astra")
end
load()

local function request(url, method, body, headers)
  local h=headers or {}; h["Content-Type"]="application/json"
  local res=HttpService:RequestAsync({Url=url,Method=method or "GET",Headers=h,Body=body and HttpService:JSONEncode(body) or nil})
  if not res.Success then error("HTTP "..tostring(res.StatusCode)..": "..tostring(res.StatusMessage)) end
  return res.Body=="" and {} or HttpService:JSONDecode(res.Body)
end

local function claim()
  save()
  if forgeKey.Text=="" or pairCode.Text=="" then error("Forge API Key + Pair Code gerekli.") end
  local userId=tostring(StudioService:GetUserId())
  local r=request(API.."/api/plugin/pair/claim","POST",{pair_code=pairCode.Text,forgeKey=forgeKey.Text,plugin_name="Roblox Forge AI Studio Plugin",roblox_user_id=userId})
  if not r.ok then error(r.error or "Pair başarısız.") end
  status.Text="● ONLINE · "..r.pair_code
  say("PAIR OK · Studio User "..userId)
end

local function heartbeat()
  local r=request(API.."/api/plugin/pair/heartbeat","POST",{pair_code=pairCode.Text,forgeKey=forgeKey.Text})
  if not r.ok then error(r.error or "Heartbeat başarısız.") end
end

local function jsonFromText(s)
  s=s:gsub("^<jsonfence>%s*",""):gsub("^<fence>%s*",""):gsub("%s*<endfence>$",""):match("^%s*(.-)%s*$")
  local ok,data=pcall(function() return HttpService:JSONDecode(s) end)
  if ok then return data end
  error("Noxery JSON döndürmedi.")
end

local function askNoxery(prompt)
  if noxeryKey.Text=="" then error("Noxery API Key gerekli.") end
  local system=[[
You are Roblox Forge AI inside Roblox Studio.
Return ONLY valid JSON, no markdown.
Schema: {"summary":"...","actions":[{"type":"create_folder|create_script|update_script|create_part|set_property|set_attribute|delete_instance","path":"Workspace/Foo","name":"Bar","className":"Script","source":"...","property":"Name","value":"...","attribute":"..."}]}
Use small verifiable actions. Never delete or overwrite unrelated content.
]]
  local body={model=model.Text~="" and model.Text or "gpt-6-astra",messages={{role="system",content=system},{role="user",content=prompt}},temperature=0.2}
  local r=request(NOXERY,"POST",body,{Authorization="Bearer "..noxeryKey.Text})
  local content=r.choices and r.choices[1] and r.choices[1].message and r.choices[1].message.content
  if not content then error("Noxery response boş.") end
  return jsonFromText(content)
end

local function resolve(path)
  local current=game
  for part in string.gmatch(path or "","[^/]+") do
    if part~="game" and part~="" then current=current:FindFirstChild(part) end
    if not current then return nil end
  end
  return current
end

local function makeParent(path)
  return resolve(path or "game") or game
end

local function setValue(inst, prop, value)
  if prop=="Name" then inst.Name=tostring(value)
  elseif prop=="Anchored" and inst:IsA("BasePart") then inst.Anchored=(value==true or tostring(value)=="true")
  elseif prop=="CanCollide" and inst:IsA("BasePart") then inst.CanCollide=(value==true or tostring(value)=="true")
  elseif prop=="Transparency" and inst:IsA("BasePart") then inst.Transparency=tonumber(value) or 0
  elseif prop=="Size" and inst:IsA("BasePart") then inst.Size=Vector3.new(tonumber(value.x) or 1,tonumber(value.y) or 1,tonumber(value.z) or 1)
  elseif prop=="Position" and inst:IsA("BasePart") then inst.Position=Vector3.new(tonumber(value.x) or 0,tonumber(value.y) or 0,tonumber(value.z) or 0)
  else error("Desteklenmeyen property: "..tostring(prop)) end
end

local function applyAction(a)
  local typ=a.type
  if typ=="create_folder" then
    local x=Instance.new("Folder"); x.Name=a.name or "ForgeFolder"; x.Parent=makeParent(a.path); return x:GetFullName()
  elseif typ=="create_script" then
    local cls=a.className or "Script"; if cls~="Script" and cls~="LocalScript" and cls~="ModuleScript" then cls="Script" end
    local x=Instance.new(cls); x.Name=a.name or "ForgeScript"; x.Parent=makeParent(a.path)
    ScriptEditorService:UpdateSourceAsync(x,function() return tostring(a.source or "") end); return x:GetFullName()
  elseif typ=="update_script" then
    local x=resolve(a.path); if not x or not x:IsA("LuaSourceContainer") then error("Script bulunamadı: "..tostring(a.path)) end
    ScriptEditorService:UpdateSourceAsync(x,function() return tostring(a.source or "") end); return x:GetFullName()
  elseif typ=="create_part" then
    local x=Instance.new("Part"); x.Name=a.name or "ForgePart"; x.Size=Vector3.new(4,1,4); x.Anchored=true; x.Parent=makeParent(a.path)
    if a.position then x.Position=Vector3.new(tonumber(a.position.x) or 0,tonumber(a.position.y) or 0,tonumber(a.position.z) or 0) end
    return x:GetFullName()
  elseif typ=="set_property" then
    local x=resolve(a.path); if not x then error("Instance bulunamadı: "..tostring(a.path)) end; setValue(x,a.property,a.value); return x:GetFullName().."."..tostring(a.property)
  elseif typ=="set_attribute" then
    local x=resolve(a.path); if not x then error("Instance bulunamadı: "..tostring(a.path)) end; x:SetAttribute(tostring(a.attribute),a.value); return x:GetFullName()
  elseif typ=="delete_instance" then
    local x=resolve(a.path); if not x or x==game or x==workspace then error("Silme engellendi: "..tostring(a.path)) end
    local full=x:GetFullName(); x:Destroy(); return "DELETED "..full
  end
  error("Bilinmeyen action: "..tostring(typ))
end

local function executePrompt(id,prompt)
  say("PLAN · Prompt alındı")
  local plan=askNoxery(prompt.."\\nÖnce analiz et, sonra küçük ve doğrulanabilir action listesi üret. Mevcut sistemi gereksiz yere silme.")
  local actions=plan.actions or {}
  say("PLAN "..tostring(#actions).." ACTION")
  local results={}
  for i,a in ipairs(actions) do
    say(string.format("ACTION %03d/%03d · %s",i,#actions,tostring(a.type)))
    local ok,res=pcall(applyAction,a)
    if not ok then
      say("ACTION FAILED · "..tostring(res))
      request(API.."/api/plugin/complete","POST",{pair_code=pairCode.Text,forgeKey=forgeKey.Text,command_id=id,status="error",error=tostring(res),result={step=i,total=#actions}})
      return
    end
    results[#results+1]=res; say("ACTION SUCCESS · "..tostring(res))
  end
  request(API.."/api/plugin/complete","POST",{pair_code=pairCode.Text,forgeKey=forgeKey.Text,command_id=id,status="completed",result={summary=plan.summary,actions=results,total=#actions}})
  say("FORGE COMPLETE "..tostring(#actions).."/"..tostring(#actions))
end

local running=false
local function poll()
  if running or pairCode.Text=="" or forgeKey.Text=="" then return end
  running=true
  task.spawn(function()
    local ok,err=pcall(function()
      heartbeat()
      local r=request(API.."/api/plugin/command?pair_code="..HttpService:UrlEncode(pairCode.Text).."&forgeKey="..HttpService:UrlEncode(forgeKey.Text),"GET")
      if r.command then executePrompt(tostring(r.command.id),tostring(r.command.prompt)) end
    end)
    if not ok then status.Text="● ERROR"; say("ERROR · "..tostring(err)) end
    running=false
  end)
end

connect.MouseButton1Click:Connect(function()
  local ok,err=pcall(claim)
  if not ok then status.Text="● ERROR"; say("PAIR ERROR · "..tostring(err)) end
end)
scan.MouseButton1Click:Connect(function()
  local sel=Selection:Get(); local names={}
  for _,x in ipairs(sel) do names[#names+1]=x:GetFullName() end
  say("SCAN · Selection: "..(#names>0 and table.concat(names,", ") or "none"))
end)
button.Click:Connect(function() widget.Enabled=not widget.Enabled end)
plugin.Unloading:Connect(function() running=false end)

task.spawn(function()
  while true do
    task.wait(3)
    if widget.Enabled then poll() end
  end
end)

say("Ready · Web sitesinden Pair Code üretip buraya gir.")
