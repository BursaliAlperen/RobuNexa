-- Sukuna moveset for RobuNexa / NAM.
-- Animations and VFX are loaded from the original Sukuna model bundle.
local modules = {}
local function AddModule(m) table.insert(modules, m) end

AddModule(function()
 local m = {}
 m.ModuleType = "MOVESET"
 m.Name = "Sukuna"
 m.Description = "King of Curses: Awaken, Malevolent Shrine, Furnance, World Cutting Slash and Rush Beatdown."
 m.Assets = {
  "Sukuna.rbxm@https://raw.githubusercontent.com/ian49972/RBXMS/main/Sukuna.rbxmx",
  "SukunaDomain.rbxm@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaDomain.rbxm",
  "SukunaWorldSlash.rbxm@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaWorldSlash.rbxm",
  "SukunaRushFX.rbxm@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaRushFX.rbxm",
  "SukunaAwaken.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaAwaken.anim",
  "SukunaShrine.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaShrine.anim",
  "SukunaOpen.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaOpen.anim",
  "SukunaWorldCut.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaWorldCut.anim",
  "SukunaRush.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaRush.anim",
  "SukunaCamera.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaCamera.anim",
  "SUKUNA.mp3@https://raw.githubusercontent.com/ian49972/smth/main/SUKUNA.mp3",
  "LAUGH.mp3@https://raw.githubusercontent.com/ian49972/smth/main/LAUGH.mp3",
  "ArrowExplode.mp3@https://raw.githubusercontent.com/ian49972/smth/main/ArrowExplode.mp3",
  "Furnance.mp3@https://raw.githubusercontent.com/ian49972/smth/main/Furnance.mp3",
  "HAHAHA.mp3@https://raw.githubusercontent.com/ian49972/smth/main/HAHAHA.mp3",
  "SLASH.mp3@https://raw.githubusercontent.com/ian49972/smth/main/SLASH.mp3",
 }
 local player = game:GetService("Players").LocalPlayer
 local UIS = game:GetService("UserInputService")
 local RunService = game:GetService("RunService")
 local TweenService = game:GetService("TweenService")
 local Lighting = game:GetService("Lighting")
 local Debris = game:GetService("Debris")
 local activeFigure, root, humanoid, bundle, anims, effects
 local activeTrack, activeAnimator, activeAnimName, animationStartedAt
 local inputConn, updateConn
 local originalSpeed, originalFov, originalClock
 local spawned = {}
 local busy = false
 local keys = {Awaken="Z", Shrine="X", Furnance="C", WorldCut="V", Rush="B"}
 local abilityNames = {Awaken="Awaken", Shrine="Malevolent Shrine", Furnance="Furnance", WorldCut="World Cutting Slash", Rush="Rush Beatdown"}

 local function findDeep(parent, name)
  return parent and parent:FindFirstChild(name, true)
 end
 local function getAssetPath(name)
  return AssetGetPathFromFilename(name)
 end
 local function sound(name, parent)
  local path = getAssetPath(name)
  local ok, asset = pcall(getcustomasset, path)
  if not ok or not asset then return end
  local s = Instance.new("Sound")
  s.SoundId = asset
  s.Volume = 1
  s.Parent = parent or root or workspace
  s:Play()
  Debris:AddItem(s, 30)
  return s
 end
 local function remember(obj, seconds)
  if obj then
   table.insert(spawned, obj)
   if seconds then Debris:AddItem(obj, seconds) end
  end
  return obj
 end
 local function stopAnimation()
  activeAnimator = nil
  activeTrack = nil
  activeAnimName = nil
  if activeFigure then
   for _, joint in ipairs(activeFigure:GetDescendants()) do
    if joint:IsA("Motor6D") then pcall(function() joint.Transform = CFrame.identity end) end
   end
  end
 end
 local animationFiles = {Awaken="SukunaAwaken.anim", Shrine="SukunaShrine.anim", Open="SukunaOpen.anim", WorldCut="SukunaWorldCut.anim", Rush="SukunaRush.anim"}
 local function playAnimation(name, speed, looped)
  if not activeFigure or not anims then return end
  local sequence = anims and anims:FindFirstChild(name, true)
  stopAnimation()
  local fileName = animationFiles[name]
  local ok, track = false, nil
  if fileName then ok, track = pcall(function() return AnimLib.Track.fromfile(getAssetPath(fileName)) end) end
  if (not ok or not track) and sequence and sequence:IsA("KeyframeSequence") then
   ok, track = pcall(function() return AnimLib.Track.frominstance(sequence) end)
  end
  if not ok or not track or not track.Keyframes or #track.Keyframes == 0 then
   pcall(function() Util.Notify("Sukuna animation missing: " .. name) end)
   return
  end
  if not ok or not track or not track.Keyframes or #track.Keyframes == 0 then return end
  activeTrack = track
  animationStartedAt = os.clock()
  activeAnimator = AnimLib.Animator.new()
  activeAnimator.rig = activeFigure
  activeAnimator.track = track
  activeAnimator.looped = looped == true
  activeAnimator.speed = speed or 1
  activeAnimName = name
 end
 local function cloneEffect(name, parentFolder, targetCF, seconds)
  local template = findDeep(parentFolder or effects, name)
  if not template then return nil end
  local obj = template:Clone()
  obj.Parent = workspace
  if obj:IsA("Model") then
   pcall(function() obj:PivotTo(targetCF or root.CFrame) end)
  elseif obj:IsA("BasePart") then
   obj.CFrame = targetCF or root.CFrame
  elseif obj:IsA("Attachment") then
   obj.Parent = root
  end
  for _, d in ipairs(obj:GetDescendants()) do
   if d:IsA("BasePart") then d.CanCollide = false; d.Massless = true end
   if d:IsA("ParticleEmitter") then d.Enabled = true end
  end
  return remember(obj, seconds or 8)
 end
 local function cameraShake(duration, strength)
  local cam = workspace.CurrentCamera
  if not cam then return end
  local start = os.clock()
  local conn
  conn = RunService.RenderStepped:Connect(function()
   if os.clock() - start >= duration then conn:Disconnect(); return end
   cam.CFrame = cam.CFrame * CFrame.Angles((math.random()-.5)*strength, (math.random()-.5)*strength, (math.random()-.5)*strength*.6)
  end)
 end
 local function setBusy(value)
  busy = value
  if value then originalSpeed = humanoid and humanoid.WalkSpeed or 16 end
 end
 local function awaken()
  if busy then return end
  setBusy(true)
  sound("LAUGH.mp3")
  local head = activeFigure:FindFirstChild("Head")
  if head and not head:FindFirstChild("SukunaFace") then
   local decal = Instance.new("Decal")
   decal.Name = "SukunaFace"
   decal.Texture = "rbxassetid://16324571117"
   decal.Face = Enum.NormalId.Front
   decal.Transparency = 1
   decal.Parent = head
   TweenService:Create(decal, TweenInfo.new(1), {Transparency=0}):Play()
   remember(decal, 45)
  end
  if humanoid then humanoid.WalkSpeed = 0 end
  playAnimation("Awaken", 1.1, false)
  task.delay(13, function()
   if humanoid and humanoid.Parent then humanoid.WalkSpeed = originalSpeed or 16 end
   stopAnimation()
   setBusy(false)
  end)
 end
 local function shrine()
  if busy then return end
  setBusy(true)
  sound("SUKUNA.mp3")
  playAnimation("Shrine", 1, false)
  local domain = findDeep(effects, "Domain")
  local front = root.CFrame * CFrame.new(0, 0, -25)
  local shrineModel = cloneEffect("MalevolentShrine", domain, front, 38)
  cloneEffect("FX", domain, front, 35)
  cloneEffect("GroundFX", domain, front * CFrame.new(0,-30,0), 35)
  cameraShake(3, .07)
  local oldClock = Lighting.ClockTime
  TweenService:Create(Lighting, TweenInfo.new(1.5), {ClockTime=0}):Play()
  task.delay(30, function()
   TweenService:Create(Lighting, TweenInfo.new(1.5), {ClockTime=oldClock or 14}):Play()
   stopAnimation()
   setBusy(false)
  end)
 end
 local function furnace()
  if busy then return end
  setBusy(true)
  sound("Furnance.mp3")
  if humanoid then humanoid.WalkSpeed = 0 end
  playAnimation("Open", 1.15, false)
  local furn = findDeep(effects, "Furnance")
  local left = cloneEffect("Left FireArm", furn, root.CFrame * CFrame.new(-1.4,0,-1), 7)
  local right = cloneEffect("Right FireArm", furn, root.CFrame * CFrame.new(1.4,0,-1), 7)
  cloneEffect("fireslap", furn, root.CFrame * CFrame.new(0,0,-2), 7)
  task.delay(2.5, function()
   if not root or not root.Parent then return end
   cameraShake(1.2, .12)
   local arrow = cloneEffect("Arrow", furn, root.CFrame * CFrame.new(0,0,-4), 2)
   local ground = cloneEffect("GroundFire", furn, root.CFrame * CFrame.new(0,-3,-5), 5)
   task.delay(1.5, function()
    if arrow then pcall(function() arrow:Destroy() end) end
    if ground then pcall(function() ground:Destroy() end) end
    local arrow2 = cloneEffect("Arrow2", furn, root.CFrame * CFrame.new(0,1,-8), 2)
    if arrow2 and arrow2:IsA("BasePart") then
     local bv=Instance.new("BodyVelocity"); bv.MaxForce=Vector3.new(1e8,1e8,1e8); bv.Velocity=root.CFrame.LookVector*120; bv.Parent=arrow2; Debris:AddItem(bv,1.5)
    end
    sound("ArrowExplode.mp3")
    cloneEffect("PreBeam", furn, root.CFrame * CFrame.new(0,0,-14), 2)
    cloneEffect("BeamCore", furn, root.CFrame * CFrame.new(0,8,-14), 7)
    cloneEffect("Floor", furn, root.CFrame * CFrame.new(0,-4,-14), 7)
    cloneEffect("Hitbox", furn, root.CFrame * CFrame.new(0,0,-14), 7)
   end)
  end)
  task.delay(10, function()
   stopAnimation()
   if humanoid and humanoid.Parent then humanoid.WalkSpeed = originalSpeed or 16 end
   setBusy(false)
  end)
 end
 local function worldCut()
  if busy then return end
  setBusy(true)
  sound("SLASH.mp3")
  if humanoid then humanoid.WalkSpeed = 0 end
  playAnimation("WorldCut", 1.5, false)
  local world = findDeep(effects, "WorldSlash")
  cloneEffect("Dust", world, nil, 3)
  task.delay(1.8, function()
   local slash = cloneEffect("Slash", world, root.CFrame * CFrame.new(0,2,-7), 8)
   if slash and slash:IsA("BasePart") then
    local bv=Instance.new("BodyVelocity"); bv.MaxForce=Vector3.new(1e8,1e8,1e8); bv.Velocity=root.CFrame.LookVector*200; bv.Parent=slash; Debris:AddItem(bv,1.2)
   end
  end)
  task.delay(5, function()
   stopAnimation()
   if humanoid and humanoid.Parent then humanoid.WalkSpeed = originalSpeed or 16 end
   setBusy(false)
  end)
 end
 local function rush()
  if busy then return end
  setBusy(true)
  sound("HAHAHA.mp3")
  playAnimation("Rush", 1.1, false)
  if humanoid then humanoid.WalkSpeed = 48 end
  cloneEffect("Slashes", findDeep(effects,"Rush"), nil, 4)
  task.delay(4, function()
   stopAnimation()
   if humanoid and humanoid.Parent then humanoid.WalkSpeed = originalSpeed or 16 end
   setBusy(false)
  end)
 end
 local actions = {Awaken=awaken, Shrine=shrine, Furnance=furnace, WorldCut=worldCut, Rush=rush}
 local function activate(name) local f=actions[name]; if f then f() end end

 m.Config = function(parent: GuiBase2d)
  local panel=Instance.new("Frame"); panel.Name="SukunaControls"; panel.BackgroundTransparency=1
  panel.Size=UDim2.new(1,0,0,42); panel.Parent=parent
  local layout=Instance.new("UIListLayout"); layout.FillDirection=Enum.FillDirection.Horizontal
  layout.HorizontalAlignment=Enum.HorizontalAlignment.Left; layout.VerticalAlignment=Enum.VerticalAlignment.Center
  layout.Padding=UDim.new(0,5); layout.Parent=panel
  for _,name in ipairs({"Awaken","Shrine","Furnance","WorldCut","Rush"}) do
   local button=Instance.new("TextButton"); button.Name=name.."Button"; button.Size=UDim2.new(0,100,0,34)
   button.BackgroundColor3=Color3.fromRGB(90,22,32); button.BorderSizePixel=0
   button.Text=abilityNames[name].." ["..keys[name].."]"; button.TextColor3=Color3.new(1,1,1)
   button.TextSize=12; button.Font=Enum.Font.GothamBold; button.TextWrapped=true; button.Parent=panel
   local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,8); corner.Parent=button
   button.Activated:Connect(function() activate(name) end)
  end
 end
 m.Init = function(figure: Model)
  activeFigure=figure; root=figure:FindFirstChild("HumanoidRootPart") or figure:FindFirstChild("Torso")
  humanoid=figure:FindFirstChildOfClass("Humanoid")
  originalSpeed=humanoid and humanoid.WalkSpeed or 16
  local path=getAssetPath("Sukuna.rbxm")
  local ok, objects=pcall(function() return game:GetObjects(getcustomasset(path)) end)
  if ok and objects and objects[1] then bundle=objects[1]; anims=findDeep(bundle,"Anims") end
  effects=Instance.new("Folder")
  effects.Name="SukunaEffectsRuntime"
  local function importModel(fileName)
   local assetPath=getAssetPath(fileName)
   local loadedOk, loaded=pcall(function() return game:GetObjects(getcustomasset(assetPath)) end)
   if loadedOk and loaded and loaded[1] then loaded[1].Parent=effects end
  end
  importModel("SukunaDomain.rbxm")
  importModel("SukunaWorldSlash.rbxm")
  importModel("SukunaRushFX.rbxm")
  local furnaceFolder=findDeep(bundle,"Furnance")
  if furnaceFolder then furnaceFolder:Clone().Parent=effects end
  if not anims then pcall(function() Util.Notify("Sukuna animation bundle failed to load; re-download assets and reload movesets.") end) end
  if inputConn then inputConn:Disconnect() end
  inputConn=UIS.InputBegan:Connect(function(input,processed)
   if processed then return end
   for name,key in pairs(keys) do if input.KeyCode.Name==key then activate(name); break end end
  end)
 end
 m.Update = function(dt: number, figure: Model)
  activeFigure=figure
  if activeAnimator and activeTrack then activeAnimator:Step(os.clock() - (animationStartedAt or os.clock())) end
 end
 m.Destroy = function(figure: Model?)
  if inputConn then inputConn:Disconnect(); inputConn=nil end
  stopAnimation()
  for _,obj in ipairs(spawned) do pcall(function() obj:Destroy() end) end
  table.clear(spawned)
  if bundle then bundle:Destroy(); bundle=nil end
  if effects then effects:Destroy(); effects=nil end
  if humanoid and humanoid.Parent then humanoid.WalkSpeed=originalSpeed or 16 end
  activeFigure=nil; root=nil; humanoid=nil; anims=nil; effects=nil; busy=false
 end
 return m
end)
return modules
