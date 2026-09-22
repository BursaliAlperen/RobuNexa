--!strict
local TweenService=game:GetService("TweenService")
local BattleUI={}

local function corner(parent:Instance,radius:number)
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,radius); c.Parent=parent
end
local function stroke(parent:Instance,color:Color3,thickness:number,transparency:number?)
    local s=Instance.new("UIStroke"); s.Color=color; s.Thickness=thickness; s.Transparency=transparency or 0; s.Parent=parent
end
local function text(parent:Instance,value:string,size:number,bold:boolean):TextLabel
    local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Text=value; t.TextColor3=Color3.fromRGB(245,245,250)
    t.TextSize=size; t.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham; t.Parent=parent; return t
end

function BattleUI.Build(gui:ScreenGui)
    local root=Instance.new("Frame"); root.Name="BattleHUD"; root.Size=UDim2.fromScale(1,1); root.BackgroundTransparency=1; root.Parent=gui
    local left=Instance.new("Frame"); left.Size=UDim2.fromOffset(86,250); left.Position=UDim2.new(0,8,0.5,-110); left.BackgroundTransparency=1; left.Parent=root

    local function leftButton(name:string,icon:string,y:number)
        local b=Instance.new("TextButton"); b.Name=name; b.Size=UDim2.fromOffset(76,72); b.Position=UDim2.fromOffset(0,y)
        b.BackgroundColor3=Color3.fromRGB(25,27,35); b.Text=""; b.Parent=left; corner(b,10); stroke(b,Color3.fromRGB(120,125,145),1,0.25)
        local i=text(b,icon,25,true); i.Size=UDim2.fromScale(1,0.55); i.Position=UDim2.fromScale(0,0.05)
        local l=text(b,name,11,true); l.Size=UDim2.fromScale(1,0.35); l.Position=UDim2.fromScale(0,0.58); return b
    end
    local command=leftButton("Komut Dosyaları","≡",0)
    local collection=leftButton("Koleksiyon","◆",78)
    local shop=leftButton("Mağaza","▣",156)

    local random=Instance.new("TextButton"); random.Size=UDim2.fromOffset(132,44); random.Position=UDim2.new(1,-142,0,154)
    random.BackgroundColor3=Color3.fromRGB(166,73,226); random.Text="Rastgele seçici"; random.TextColor3=Color3.new(1,1,1); random.Font=Enum.Font.GothamBold; random.TextSize=15; random.Parent=root; corner(random,8)

    local event=text(root,"Blood Moon  •  2x  •  81s",18,true); event.Size=UDim2.fromOffset(430,32); event.Position=UDim2.new(0.5,-215,0,78); event.TextXAlignment=Enum.TextXAlignment.Center; event.TextColor3=Color3.fromRGB(245,118,45)
    local feed=text(root,"Az önce yeniden canlandırma bastım.",15,true); feed.Size=UDim2.fromOffset(500,30); feed.Position=UDim2.new(0.5,-250,0,111); feed.TextXAlignment=Enum.TextXAlignment.Center; feed.TextColor3=Color3.fromRGB(255,116,35)

    local stats=Instance.new("Frame"); stats.Size=UDim2.fromOffset(180,74); stats.Position=UDim2.new(0,16,1,-92); stats.BackgroundTransparency=1; stats.Parent=root
    local kills=text(stats,"K  0",24,true); kills.Size=UDim2.fromOffset(90,34); kills.TextXAlignment=Enum.TextXAlignment.Left
    local cash=text(stats,"$  0",22,true); cash.Size=UDim2.fromOffset(110,32); cash.Position=UDim2.fromOffset(0,36); cash.TextColor3=Color3.fromRGB(255,194,45); cash.TextXAlignment=Enum.TextXAlignment.Left

    local chest=Instance.new("Frame"); chest.Size=UDim2.fromOffset(88,88); chest.Position=UDim2.new(1,-104,1,-112); chest.BackgroundColor3=Color3.fromRGB(28,30,38); chest.Parent=root; corner(chest,18); stroke(chest,Color3.fromRGB(140,145,160),1,0.2)
    local chestIcon=text(chest,"▣",30,true); chestIcon.Size=UDim2.fromScale(1,0.55); chestIcon.Position=UDim2.fromScale(0,0.05)
    local chestTimer=text(chest,"3:31",14,true); chestTimer.Size=UDim2.fromScale(1,0.28); chestTimer.Position=UDim2.fromScale(0,0.66)

    local lock=Instance.new("TextButton"); lock.Size=UDim2.fromOffset(56,56); lock.Position=UDim2.new(1,-172,1,-82); lock.BackgroundColor3=Color3.fromRGB(20,22,29); lock.Text="▣"; lock.TextColor3=Color3.fromRGB(240,240,245); lock.TextSize=26; lock.Parent=root; corner(lock,28); stroke(lock,Color3.fromRGB(180,185,200),1,0.3)

    local targetLayer=Instance.new("Folder"); targetLayer.Name="TargetLayer"; targetLayer.Parent=gui
    local skillLayer=Instance.new("Frame"); skillLayer.Size=UDim2.fromOffset(300,76); skillLayer.AnchorPoint=Vector2.new(0.5,1); skillLayer.Position=UDim2.new(0.5,0,1,-18); skillLayer.BackgroundTransparency=1; skillLayer.Parent=root
    local skills={}
    for index,key in ipairs({"Z","X","C","V"}) do
        local b=Instance.new("TextButton"); b.Name="Skill"..key; b.Size=UDim2.fromOffset(64,64); b.Position=UDim2.fromOffset((index-1)*72,0); b.BackgroundColor3=Color3.fromRGB(32,34,43)
        b.Text=key; b.TextColor3=Color3.new(1,1,1); b.TextSize=21; b.Font=Enum.Font.GothamBold; b.Parent=skillLayer; corner(b,32); stroke(b,Color3.fromRGB(100,105,125),1,0.15); skills[key]=b
    end

    local shift=Instance.new("TextButton"); shift.Size=UDim2.fromOffset(58,58); shift.Position=UDim2.new(1,-250,1,-92); shift.BackgroundColor3=Color3.fromRGB(26,28,35); shift.Text="⇄"; shift.TextColor3=Color3.fromRGB(235,235,240); shift.TextSize=24; shift.Font=Enum.Font.GothamBold; shift.Parent=root; corner(shift,29); stroke(shift,Color3.fromRGB(115,120,140),1,0.2)

    local function makeTarget(model:Model)
        local rootPart=model:FindFirstChild("HumanoidRootPart"); local humanoid=model:FindFirstChildOfClass("Humanoid"); if not rootPart or not humanoid then return end
        local billboard=Instance.new("BillboardGui"); billboard.Name="BattleTarget"; billboard.Adornee=rootPart; billboard.Size=UDim2.fromOffset(180,58); billboard.StudsOffset=Vector3.new(0,4.1,0); billboard.AlwaysOnTop=true; billboard.Parent=targetLayer
        local nameLabel=text(billboard,model.Name,13,true); nameLabel.Size=UDim2.new(1,0,0,24); nameLabel.TextXAlignment=Enum.TextXAlignment.Center
        local bar=Instance.new("Frame"); bar.Size=UDim2.new(1,-36,0,8); bar.Position=UDim2.fromOffset(18,27); bar.BackgroundColor3=Color3.fromRGB(50,50,55); bar.Parent=billboard; corner(bar,4)
        local fill=Instance.new("Frame"); fill.Size=UDim2.fromScale(1,1); fill.BackgroundColor3=Color3.fromRGB(65,225,80); fill.Parent=bar; corner(fill,4)
        humanoid.HealthChanged:Connect(function(h)
            local ratio=math.clamp(h/math.max(humanoid.MaxHealth,1),0,1); TweenService:Create(fill,TweenInfo.new(0.12),{Size=UDim2.fromScale(ratio,1)}):Play()
        end)
        humanoid.Died:Connect(function() task.delay(0.1,function() if billboard.Parent then billboard:Destroy() end end) end)
    end

    return {Root=root,Command=command,Collection=collection,Shop=shop,Random=random,Lock=lock,ShiftLock=shift,Skills=skills,Event=event,Feed=feed,Kills=kills,Cash=cash,ChestTimer=chestTimer,TargetLayer=targetLayer,MakeTarget=makeTarget}
end
return BattleUI
