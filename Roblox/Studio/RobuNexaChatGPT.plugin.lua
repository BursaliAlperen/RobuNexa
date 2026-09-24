-- RobuNexa ChatGPT Studio Assistant
local HttpService=game:GetService("HttpService")
local Selection=game:GetService("Selection")
local ChangeHistoryService=game:GetService("ChangeHistoryService")
local API_URL="https://api.noxery.net/v1/chat/completions"
local DEFAULT_MODEL="gpt-6-astra"
local BT=string.char(96)

local toolbar=plugin:CreateToolbar("RobuNexa AI")
local button=toolbar:CreateButton("RobuNexa AI","Open RobuNexa AI Studio Assistant","")
local widget=plugin:CreateDockWidgetPluginGui("RobuNexaAI",DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right,true,false,430,620,340,420))
widget.Title="RobuNexa AI"

local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 8);c.Parent=o end
local function pad(o,n)local p=Instance.new("UIPadding");p.PaddingTop=UDim.new(0,n);p.PaddingBottom=UDim.new(0,n);p.PaddingLeft=UDim.new(0,n);p.PaddingRight=UDim.new(0,n);p.Parent=o end

local root=Instance.new("Frame");root.Size=UDim2.fromScale(1,1);root.BackgroundColor3=Color3.fromRGB(20,20,23);root.BorderSizePixel=0;root.Parent=widget;pad(root,10)
local title=Instance.new("TextLabel");title.Size=UDim2.new(1,0,0,30);title.BackgroundTransparency=1;title.Text="RobuNexa AI";title.TextColor3=Color3.new(1,1,1);title.Font=Enum.Font.GothamBold;title.TextSize=20;title.TextXAlignment=Enum.TextXAlignment.Left;title.Parent=root
local sub=Instance.new("TextLabel");sub.Position=UDim2.fromOffset(0,29);sub.Size=UDim2.new(1,0,0,24);sub.BackgroundTransparency=1;sub.Text="Luau coding assistant • Noxery API";sub.TextColor3=Color3.fromRGB(150,150,160);sub.Font=Enum.Font.Gotham;sub.TextSize=12;sub.TextXAlignment=Enum.TextXAlignment.Left;sub.Parent=root

local keyBox=Instance.new("TextBox");keyBox.Position=UDim2.fromOffset(0,60);keyBox.Size=UDim2.new(1,0,0,34);keyBox.BackgroundColor3=Color3.fromRGB(31,31,36);keyBox.TextColor3=Color3.fromRGB(235,235,240);keyBox.PlaceholderText="Noxery API key (nox-...)";keyBox.Text=plugin:GetSetting("NoxeryApiKey") or "";keyBox.ClearTextOnFocus=false;keyBox.Font=Enum.Font.Code;keyBox.TextSize=13;keyBox.Parent=root;corner(keyBox,7)
local modelBox=Instance.new("TextBox");modelBox.Position=UDim2.fromOffset(0,101);modelBox.Size=UDim2.new(1,0,0,30);modelBox.BackgroundColor3=Color3.fromRGB(31,31,36);modelBox.TextColor3=Color3.fromRGB(235,235,240);modelBox.Text=plugin:GetSetting("NoxeryModel") or DEFAULT_MODEL;modelBox.ClearTextOnFocus=false;modelBox.Font=Enum.Font.Code;modelBox.TextSize=12;modelBox.Parent=root;corner(modelBox,7)
local promptBox=Instance.new("TextBox");promptBox.Position=UDim2.fromOffset(0,138);promptBox.Size=UDim2.new(1,0,0,105);promptBox.BackgroundColor3=Color3.fromRGB(27,27,31);promptBox.TextColor3=Color3.fromRGB(240,240,245);promptBox.PlaceholderText="Örn: Selected script'i incele ve bugları düzelt...";promptBox.MultiLine=true;promptBox.TextWrapped=true;promptBox.TextXAlignment=Enum.TextXAlignment.Left;promptBox.TextYAlignment=Enum.TextYAlignment.Top;promptBox.Font=Enum.Font.Code;promptBox.TextSize=13;promptBox.Parent=root;corner(promptBox,7);pad(promptBox,8)

local generate=Instance.new("TextButton");generate.Position=UDim2.fromOffset(0,251);generate.Size=UDim2.new(.49,-4,0,38);generate.BackgroundColor3=Color3.fromRGB(80,80,255);generate.TextColor3=Color3.new(1,1,1);generate.Text="GENERATE";generate.Font=Enum.Font.GothamBold;generate.TextSize=13;generate.Parent=root;corner(generate,7)
local fix=Instance.new("TextButton");fix.Position=UDim2.new(.51,4,0,251);fix.Size=UDim2.new(.49,-4,0,38);fix.BackgroundColor3=Color3.fromRGB(48,48,55);fix.TextColor3=Color3.new(1,1,1);fix.Text="FIX SELECTED";fix.Font=Enum.Font.GothamBold;fix.TextSize=13;fix.Parent=root;corner(fix,7)
local status=Instance.new("TextLabel");status.Position=UDim2.fromOffset(0,294);status.Size=UDim2.new(1,0,0,22);status.BackgroundTransparency=1;status.Text="Ready";status.TextColor3=Color3.fromRGB(145,145,155);status.Font=Enum.Font.Gotham;status.TextSize=11;status.TextXAlignment=Enum.TextXAlignment.Left;status.Parent=root
local output=Instance.new("TextBox");output.Position=UDim2.fromOffset(0,320);output.Size=UDim2.new(1,0,1,-404);output.BackgroundColor3=Color3.fromRGB(13,13,16);output.TextColor3=Color3.fromRGB(225,225,232);output.PlaceholderText="AI response / generated Luau";output.ClearTextOnFocus=false;output.MultiLine=true;output.TextWrapped=false;output.TextXAlignment=Enum.TextXAlignment.Left;output.TextYAlignment=Enum.TextYAlignment.Top;output.Font=Enum.Font.Code;output.TextSize=12;output.Parent=root;corner(output,7);pad(output,8)
local insert=Instance.new("TextButton");insert.Position=UDim2.new(0,0,1,-73);insert.Size=UDim2.new(.49,-4,0,34);insert.BackgroundColor3=Color3.fromRGB(45,145,90);insert.TextColor3=Color3.new(1,1,1);insert.Text="INSERT NEW SCRIPT";insert.Font=Enum.Font.GothamBold;insert.TextSize=11;insert.Parent=root;corner(insert,7)
local replace=Instance.new("TextButton");replace.Position=UDim2.new(.51,4,1,-73);replace.Size=UDim2.new(.49,-4,0,34);replace.BackgroundColor3=Color3.fromRGB(145,80,55);replace.TextColor3=Color3.new(1,1,1);replace.Text="REPLACE SELECTED";replace.Font=Enum.Font.GothamBold;replace.TextSize=11;replace.Parent=root;corner(replace,7)

local function selectedScript()
	for _,o in ipairs(Selection:Get()) do if o:IsA("Script") or o:IsA("LocalScript") or o:IsA("ModuleScript") then return o end end
end
local function extractCode(t)
	local p=BT..BT..BT
	return t:match(p.."lua%s*(.-)"..p) or t:match(p.."luau%s*(.-)"..p) or t:match(p.."%s*(.-)"..p) or t
end
local function requestAI(userPrompt,source)
	local key=keyBox.Text:gsub("%s+","")
	if key=="" then error("Noxery API key gerekli. nox-... key gir.") end
	plugin:SetSetting("NoxeryApiKey",key)
	plugin:SetSetting("NoxeryModel",modelBox.Text~="" and modelBox.Text or DEFAULT_MODEL)
	local system="You are RobuNexa AI, a senior Roblox Studio Luau engineer. Return production-ready Luau when code is requested. Use real Roblox APIs only. Prefer server-authoritative architecture. Never use loadstring, exploit loaders, or arbitrary downloaded code execution. Do not invent Roblox services or APIs. Preserve working behavior unless explicitly asked to change it. Keep dependencies minimal."
	local user=userPrompt
	if source and source~="" then user=user.."\n\nSELECTED SCRIPT SOURCE:\n"..BT..BT..BT.."lua\n"..source.."\n"..BT..BT..BT end
	local body={model=modelBox.Text~="" and modelBox.Text or DEFAULT_MODEL,messages={{role="system",content=system},{role="user",content=user}},max_completion_tokens=12000,temperature=.2,stream=false}
	local response=HttpService:RequestAsync({Url=API_URL,Method="POST",Headers={["Authorization"]="Bearer "..key,["Content-Type"]="application/json"},Body=HttpService:JSONEncode(body)})
	local data=HttpService:JSONDecode(response.Body)
	if not response.Success then local msg=data and data.error and data.error.message or response.StatusMessage;error("Noxery API "..tostring(response.StatusCode)..": "..tostring(msg)) end
	local content=data.choices and data.choices[1] and data.choices[1].message and data.choices[1].message.content
	if not content then error("AI yanıtı alınamadı.") end
	return content
end
local function run(prompt,includeSelected)
	status.Text="Thinking...";generate.Active=false;fix.Active=false
	local ok,result=pcall(function()local s=selectedScript();return requestAI(prompt,includeSelected and s and s.Source or nil)end)
	generate.Active=true;fix.Active=true
	if ok then output.Text=result;status.Text="Done" else output.Text=tostring(result);status.Text="Error" end
end
generate.MouseButton1Click:Connect(function()run(promptBox.Text~="" and promptBox.Text or "Roblox Studio için istediğim sistemi production-ready Luau olarak oluştur.",true)end)
fix.MouseButton1Click:Connect(function()if not selectedScript() then status.Text="Select a Script / LocalScript / ModuleScript";return end;run("Selected script'i analiz et. Bugları, güvenlik sorunlarını ve Roblox API kullanımını düzelt. Çalışan davranışı koru. Bana tamamen düzeltilmiş Luau kodunu ver.",true)end)
insert.MouseButton1Click:Connect(function()local code=extractCode(output.Text);if code=="" then status.Text="Output boş.";return end;local s=Instance.new("Script");s.Name="RobuNexaGenerated";s.Source=code;s.Parent=game:GetService("ServerScriptService");ChangeHistoryService:SetWaypoint("RobuNexa AI - Insert Script");Selection:Set({s});status.Text="Inserted into ServerScriptService" end)
replace.MouseButton1Click:Connect(function()local s=selectedScript();if not s then status.Text="Select a Script / LocalScript / ModuleScript";return end;local code=extractCode(output.Text);if code=="" then status.Text="Output boş.";return end;ChangeHistoryService:SetWaypoint("RobuNexa AI - Before Replace");s.Source=code;ChangeHistoryService:SetWaypoint("RobuNexa AI - Replace Selected");status.Text="Selected script replaced" end)
button.Click:Connect(function()widget.Enabled=not widget.Enabled;button:SetActive(widget.Enabled)end)
widget.Enabled=true;button:SetActive(true)
