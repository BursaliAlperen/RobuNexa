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
  "SukunaDomain.rbxm@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaDomain.rbxm",
  "SukunaFurnance.rbxm@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaFurnance.rbxm",
  "SukunaWorldSlash.rbxm@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaWorldSlash.rbxm",
  "SukunaRushFX.rbxm@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaRushFX.rbxm",
  "SukunaAwaken.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaAwaken.anim",
  "SukunaShrine.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaShrine.anim",
  "SukunaOpen.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaOpen.anim",
  "SukunaWorldCut.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaWorldCut.anim",
  "SukunaRush.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaRush.anim",
  "SukunaCamera.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SukunaCamera.anim",
 }
 local player = game:GetService("Players").LocalPlayer
 local UIS = game:GetService("UserInputService")
 local RunService = game:GetService("RunService")
 local ContextActionService = game:GetService("ContextActionService")
 local TweenService = game:GetService("TweenService")
 local Lighting = game:GetService("Lighting")
 local Debris = game:GetService("Debris")
 local activeFigure, root, humanoid, anims, effects
 local activeTrack, activeAnimator, activeAnimName, animationStartedAt
 local inputConn, updateConn
 local originalSpeed, originalFov, originalClock
 local spawned = {}
 local moveSine = 0
 local startupLaughUntil = 0
 local busy = false
 local keys = {Awaken="Z", Shrine="X", Furnance="C", WorldCut="V", Rush="B"}
 local abilityNames = {Awaken="Awaken", Shrine="Malevolent Shrine", WorldCut="Dismantle", Rush="Rush", Furnance="Fuuga"}

 local function findDeep(parent, name)
  return parent and parent:FindFirstChild(name, true)
 end
 local function getAssetPath(name)
  return AssetGetPathFromFilename(name)
 end
 local soundIds = {
  Laugh = "rbxassetid://137836523944133",
  Dismantle = "rbxassetid://81148579745420",
  Rush = "rbxassetid://140644642090775",
  Fuuga = "rbxassetid://81784387877244",
 }
 local function sound(name, parent)
  local asset = soundIds[name]
  if not asset then return end
  local s = Instance.new("Sound")
  s.Name = "Sukuna_" .. name
  s.SoundId = asset
  s.Volume = 1
  s.RollOffMaxDistance = 100
  s.Parent = parent or root or workspace
  -- Preload off-thread, then play only after Roblox reports the asset ready.
  task.spawn(function()
   local ok = pcall(function() game:GetService("ContentProvider"):PreloadAsync({s}) end)
   if ok and s.Parent then
    pcall(function() s:Play() end)
   else
    pcall(function() Util.Notify("Sukuna sound could not load: " .. name) end)
   end
  end)
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
  if not activeFigure then return end
  local sequence = anims and anims:FindFirstChild(name, true)
  stopAnimation()
  local fileName = animationFiles[name]
  local ok, track = false, nil
  if fileName then
   -- Match the dog moveset: read the already-cached .anim directly and fail
   -- fast if the asset is not ready, rather than freezing input for 12 seconds.
   local assetPath = getAssetPath(fileName)
   local exists = false
   pcall(function() exists = isfile(assetPath) end)
   if exists then
    ok, track = pcall(function() return AnimLib.Track.fromfile(assetPath) end)
   else
    ok, track = false, "asset did not finish downloading: " .. fileName
   end
   if not ok then
    pcall(function() Util.Notify("Sukuna animation load error (" .. name .. "): " .. tostring(track)) end)
   end
  end
  if (not ok or not track) and sequence and sequence:IsA("KeyframeSequence") then
   ok, track = pcall(function() return AnimLib.Track.frominstance(sequence) end)
  end
  if not ok or not track or not track.Keyframes or #track.Keyframes == 0 then
   pcall(function() Util.Notify("Sukuna animation missing: " .. name) end)
   return 0
  end
  local lastTime = 0
  for _, keyframe in ipairs(track.Keyframes) do
   local t = tonumber(keyframe.Time) or 0
   if t > lastTime then lastTime = t end
  end
  local duration = lastTime / math.max(0.1, speed or 1)
  activeTrack = track
  animationStartedAt = os.clock()
  activeAnimator = AnimLib.Animator.new()
  activeAnimator.rig = activeFigure
  activeAnimator.track = track
  activeAnimator.looped = looped == true
  activeAnimator.speed = speed or 1
  activeAnimName = name
  -- Release the animation controller after one-shot tracks so locomotion
  -- does not stay frozen on the last keyframe.
  if looped ~= true then
   task.delay(math.max(0.2, duration + 0.15), function()
    if activeAnimName == name and activeTrack == track then stopAnimation() end
   end)
  end
  return duration
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
  sound("Laugh")
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
  local duration = playAnimation("Awaken", 1.1, false) or 0
  -- Match the lockout to the actual animation length instead of a fixed 13s.
  task.delay(math.max(1.5, duration + 0.3), function()
   if humanoid and humanoid.Parent then humanoid.WalkSpeed = originalSpeed or 16 end
   if activeAnimName == "Awaken" then stopAnimation() end
   setBusy(false)
  end)
 end
 local function shrine()
  if busy then return end
  setBusy(true)
  sound("Dismantle")
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
  sound("Fuuga")
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
    sound("Fuuga")
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
  sound("Dismantle")
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
  sound("Rush")
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
  -- Startup sequence: Sukuna laugh first, then transition to Linked Sword idle.
  startupLaughUntil = os.clock() + 2.6
  if humanoid then
   humanoid.WalkSpeed = 0
  end
  task.defer(function()
   if activeFigure == figure then
    sound("Laugh")
    local duration = playAnimation("Awaken", 1.1, false) or 0
    task.delay(math.max(1.5, duration + 0.25), function()
     if activeFigure == figure then
      if activeAnimName == "Awaken" then stopAnimation() end
      if humanoid and humanoid.Parent then humanoid.WalkSpeed = originalSpeed or 16 end
     end
    end)
   end
  end)
  effects=Instance.new("Folder")
  effects.Name="SukunaEffectsRuntime"
  local function importModel(fileName)
   local assetPath=getAssetPath(fileName)
   local loadedOk, loaded=pcall(function() return game:GetObjects(getcustomasset(assetPath)) end)
   if loadedOk and loaded and loaded[1] then loaded[1].Parent=effects end
  end
  importModel("SukunaDomain.rbxm")
  importModel("SukunaFurnance.rbxm")
  importModel("SukunaWorldSlash.rbxm")
  importModel("SukunaRushFX.rbxm")
  if inputConn then inputConn:Disconnect() end
  -- BindAction's createTouchButton flag creates native mobile/virtual buttons.
  -- Position each button in a compact right-side cluster, and unbind on teardown.
  -- Keep Sukuna's touch buttons grouped at the top-right.
  local buttonPositions = {
   Awaken = UDim2.new(1, -250, 0, 90),
   Shrine = UDim2.new(1, -175, 0, 90),
   Furnance = UDim2.new(1, -100, 0, 90),
   WorldCut = UDim2.new(1, -250, 0, 165),
   Rush = UDim2.new(1, -175, 0, 165),
   Laugh = UDim2.new(1, -100, 0, 165),
  }
  for name, key in pairs(keys) do
   local bindName = "RobuNexa_Sukuna_" .. name
   ContextActionService:UnbindAction(bindName)
   ContextActionService:BindAction(bindName, function(_, state)
    if state == Enum.UserInputState.Begin then activate(name) end
    return Enum.ContextActionResult.Sink
   end, true, Enum.KeyCode[key])
   ContextActionService:SetTitle(bindName, abilityNames[name] or name)
   ContextActionService:SetPosition(bindName, buttonPositions[name])
  end
  -- ContextActionService handles both keyboard and touch input, preventing duplicate activations.
 end
 -- Linked Sword's joint pose helper must live in this module's scope;
 -- locals declared inside another moveset are not visible here.
 local function SetC0C1Joint(j, c0, c1, scale)
  local t = c0 * c1:Inverse()
  t += t.Position * (scale - 1)
  t = j.C0:Inverse() * t * j.C1
  j.Transform = t
 end
 local moveJoints = {r=CFrame.identity,n=CFrame.identity,rs=CFrame.identity,ls=CFrame.identity,rh=CFrame.identity,lh=CFrame.identity}
 local function applyLinkedSwordLocomotion(dt, figure)
  if not figure or busy or (activeAnimator and activeTrack) then return end
  local hum = figure:FindFirstChildOfClass("Humanoid")
  local rootPart = figure:FindFirstChild("HumanoidRootPart") or figure:FindFirstChild("Torso")
  local torso = figure:FindFirstChild("Torso")
  if not hum or not rootPart or not torso then return end
  local rj = rootPart:FindFirstChild("RootJoint")
  local nj = torso:FindFirstChild("Neck")
  local rsj = torso:FindFirstChild("Right Shoulder")
  local lsj = torso:FindFirstChild("Left Shoulder")
  local rhj = torso:FindFirstChild("Right Hip")
  local lhj = torso:FindFirstChild("Left Hip")
  moveSine += dt * 60
  local velocity = rootPart.AssemblyLinearVelocity.Magnitude
  local vy = rootPart.AssemblyLinearVelocity.Y
  local rt, nt, rst, lst, rht, lht
  local state = hum:GetState()
  if os.clock() < startupLaughUntil then
   -- Short procedural laugh beat at reanimation startup, then blend into Linked Sword idle.
   local phase = moveSine / 2.5
   rt=CFrame.new(-0.014,0.023,0.020)*CFrame.Angles(math.rad(-8+5*math.sin(phase*2)),0,math.rad(5*math.sin(phase)))
   nt=CFrame.new(0,1.499,0)*CFrame.Angles(math.rad(18+7*math.sin(phase*2)),math.rad(8*math.sin(phase)),math.rad(4*math.sin(phase*2)))
   rst=CFrame.new(1.35,0.22,0.08)*CFrame.Angles(math.rad(-58+8*math.sin(phase*2)),0,math.rad(18))
   lst=CFrame.new(-1.35,0.22,0.08)*CFrame.Angles(math.rad(-58-8*math.sin(phase*2)),0,math.rad(-18))
   rht=CFrame.new(0.5,-1.64,0)*CFrame.Angles(math.rad(-4),0,0)
   lht=CFrame.new(-0.5,-1.64,0)*CFrame.Angles(math.rad(4),0,0)
  elseif state == Enum.HumanoidStateType.Jumping then
   rt=CFrame.new(-0.014,0.023,0.020,1,0,0,0,0.965,0.258,0,-0.258,0.965)
   nt=CFrame.new(0.017,1.545,-0.003,0.999,0.007,-0.042,-0.011,0.996,-0.086,0.041,0.087,0.995)
   rst=CFrame.new(1.54,0.254,-0.521,0.89,-0.152,-0.429,-0.327,0.44,-0.835,0.317,0.884,0.341)
   lst=CFrame.new(-1.557,0.112,0.343,0.986,0.113,0.122,-0.158,0.861,0.481,-0.050,-0.494,0.867)
   rht=CFrame.new(0.566,-1.597,-0.481,0.999,-0.038,-0.009,0.039,0.943,0.328,-0.003,-0.328,0.944)
   lht=CFrame.new(-0.433,-1.959,0.005,1,0,0,0,0.965,0.258,0,-0.258,0.965)
  elseif state == Enum.HumanoidStateType.Freefall or vy < -1 and hum.FloorMaterial == Enum.Material.Air then
   rt=CFrame.new(-0.014,0.023,0.020,1,0,0,0,0.984,0.173,0,-0.173,0.984)
   nt=CFrame.new(0.015,1.552,-0.091,0.999,0.018,-0.038,-0.007,0.965,0.258,0.042,-0.258,0.965)
   rst=CFrame.new(1.44,0.051,-0.418,0.89,-0.076,-0.449,-0.298,0.647,-0.701,0.344,0.758,0.553)
   lst=CFrame.new(-1.557,0.141,0.332,0.986,0.113,0.122,-0.162,0.815,0.555,-0.036,-0.567,0.822)
   rht=CFrame.new(0.573,-1.805,-0.374,0.999,-0.037,0.013,0.039,0.981,-0.187,-0.006,0.188,0.982)
   lht=CFrame.new(-0.433,-1.951,0.175,1,0,0,0,0.984,0.173,0,-0.173,0.984)
  elseif hum.MoveDirection.Magnitude > 0.05 then
   local isRunning = hum.WalkSpeed >= 20
   local phase = moveSine / (isRunning and 4 or 6)
   local swing = isRunning and 1.35 or 1
   rt=CFrame.new(-0.014,0.023,0.020,1,0,0,0,1,0,0,0,1)*CFrame.Angles(isRunning and -0.28 or -0.2,math.rad(-5*math.cos(phase)),0)
   nt=CFrame.new(0,1.499,0,0.999,0,-0.042,0,1,0,0.042,0,0.999)
   rst=CFrame.new(1.668,0.125,0.167,0.975,-0.217,-0.034,0.22,0.967,0.121,0.006,-0.125,0.992)*CFrame.new(0,0,0.1*swing*math.cos(phase))*CFrame.Angles(math.rad(-15*swing*math.cos(phase)),0,0)
   lst=CFrame.new(-1.589,0.026,-0.146,0.986,0.166,-0.008,-0.166,0.981,-0.095,-0.008,0.095,0.995)*CFrame.new(0,0,-0.15*swing*math.cos(phase))*CFrame.Angles(math.rad(15*swing*math.cos(phase)),0,0)
   rht=CFrame.new(0.5,-1.64-0.4*swing*math.cos(phase),1.0*swing*math.sin(phase)/3)*CFrame.Angles(math.rad(-50*swing*math.sin(phase)),math.rad(-3),0)
   lht=CFrame.new(-0.5,-1.64+0.4*swing*math.cos(phase),-1.0*swing*math.sin(phase)/3)*CFrame.Angles(math.rad(50*swing*math.sin(phase)),math.rad(3),0)
  else
   local bob = 0.05*math.cos(moveSine/25)
   rt=CFrame.new(-0.014,0.023,0.020,0.866,0,-0.5,0,1,0,0.5,0,0.866)*CFrame.new(0,bob,0)
   nt=CFrame.new(0,1.499,0,0.886,0,0.462,0,1,0,-0.462,0,0.886)*CFrame.Angles(0.08*math.cos(moveSine/25),0,0)
   rst=CFrame.new(1.7,0.169,0.31,0.827,-0.251,-0.501,0.215,0.967,-0.13,0.517,0,0.855)
   lst=CFrame.new(-1.619,0.059,0,0.981,0.191,0,-0.191,0.981,0,0,0,1)
   rht=CFrame.new(0.649,-1.999,0,0.989,-0.143,0,0.143,0.989,0,0,0,1)*CFrame.new(0,-0.08*math.cos(moveSine/25),0)
   lht=CFrame.new(-0.5,-2,0,1,0,0,0,1,0,0,0,1)*CFrame.new(0,-0.08*math.cos(moveSine/25),0)
  end
  local alpha = math.exp(-16*dt)
  moveJoints.r=rt:Lerp(moveJoints.r,alpha); moveJoints.n=nt:Lerp(moveJoints.n,alpha)
  moveJoints.rs=rst:Lerp(moveJoints.rs,alpha); moveJoints.ls=lst:Lerp(moveJoints.ls,alpha)
  moveJoints.rh=rht:Lerp(moveJoints.rh,alpha); moveJoints.lh=lht:Lerp(moveJoints.lh,alpha)
  if rj then SetC0C1Joint(rj,moveJoints.r,CFrame.identity,figure:GetScale()) end
  if nj then SetC0C1Joint(nj,moveJoints.n,CFrame.identity,figure:GetScale()) end
  if rsj then SetC0C1Joint(rsj,moveJoints.rs,CFrame.identity,figure:GetScale()) end
  if lsj then SetC0C1Joint(lsj,moveJoints.ls,CFrame.identity,figure:GetScale()) end
  if rhj then SetC0C1Joint(rhj,moveJoints.rh,CFrame.identity,figure:GetScale()) end
  if lhj then SetC0C1Joint(lhj,moveJoints.lh,CFrame.identity,figure:GetScale()) end
 end
 m.Update = function(dt: number, figure: Model)
  activeFigure=figure
  if activeAnimator and activeTrack then
   local ok = pcall(function() activeAnimator:Step(os.clock() - (animationStartedAt or os.clock())) end)
   if not ok then stopAnimation() end
  else
   applyLinkedSwordLocomotion(dt, figure)
  end
 end
 m.Destroy = function(figure: Model?)
  if inputConn then inputConn:Disconnect(); inputConn=nil end
  for name in pairs(keys) do
   ContextActionService:UnbindAction("RobuNexa_Sukuna_" .. name)
  end
  stopAnimation()
  for _,obj in ipairs(spawned) do pcall(function() obj:Destroy() end) end
  table.clear(spawned)
  if effects then effects:Destroy(); effects=nil end
  if humanoid and humanoid.Parent then humanoid.WalkSpeed=originalSpeed or 16 end
  startupLaughUntil = 0
  activeFigure=nil; root=nil; humanoid=nil; anims=nil; effects=nil; busy=false
 end
 return m
end)
return modules
