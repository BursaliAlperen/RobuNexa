-- update force 2

cloneref = cloneref or function(o) return o end

local Debris = cloneref(game:GetService("Debris"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local GuiService = cloneref(game:GetService("GuiService"))
local HttpService = cloneref(game:GetService("HttpService"))
local TextService = cloneref(game:GetService("TextService"))
local TweenService = cloneref(game:GetService("TweenService"))
local TextChatService = cloneref(game:GetService("TextChatService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local ContextActionService = cloneref(game:GetService("ContextActionService"))

local Player = Players.LocalPlayer

local function SetC0C1Joint(j, c0, c1, scale)
	local t = c0 * c1:Inverse()
	t += t.Position * (scale - 1)
	t = j.C0:Inverse() * t * j.C1
	j.Transform = t
end

local modules = {}
local function AddModule(m)
	table.insert(modules, m)
end

AddModule(function()
	local m = {}
	m.ModuleType = "MOVESET"
	m.Name = "Minigun"
	m.InternalName = "IAMBULLETPROOF"
	m.Description = "now in the latest color: AKAI!!\nLet's Go! Goodbye!\nM1 - Shoot"
	m.Assets = {}

	m.Notifications = true
	m.Sounds = true
	m.UseSword = false
	m.BooletsPerSec = 60
	m.NoShells = false
	m.HowBadIsAim = 1
	m.ShakeValue = 1
	m.Flipped = false
	m.Config = function(parent: GuiBase2d)
		Util_CreateSwitch(parent, "Text thing", m.Notifications).Changed:Connect(function(val)
			m.Notifications = val
		end)
		Util_CreateSwitch(parent, "Sounds", m.Sounds).Changed:Connect(function(val)
			m.Sounds = val
		end)
		Util_CreateText(parent, "Use the sword instead of the gun!", 12, Enum.TextXAlignment.Center)
		Util_CreateSwitch(parent, "Gun = Sword", m.UseSword).Changed:Connect(function(val)
			m.UseSword = val
		end)
		Util_CreateText(parent, "for optimisation reasons, you can only fire max 20 bullets in a frame", 12, Enum.TextXAlignment.Center)
		Util_CreateSlider(parent, "Bullets Per Second", m.BooletsPerSec, 5, 240, 1).Changed:Connect(function(val)
			m.BooletsPerSec = val
		end)
		Util_CreateSwitch(parent, "Fire the whole bullet", m.NoShells).Changed:Connect(function(val)
			m.NoShells = val
		end)
		Util_CreateSlider(parent, "Fire Spread", m.HowBadIsAim, 0, 1, 0).Changed:Connect(function(val)
			m.HowBadIsAim = val
		end)
		Util_CreateSlider(parent, "Shake Amount", m.ShakeValue, 0, 1, 0).Changed:Connect(function(val)
			m.ShakeValue = val
		end)
		Util_CreateSwitch(parent, "Flip Gun", m.Flipped).Changed:Connect(function(val)
			m.Flipped = val
		end)
	end
	m.LoadConfig = function(save: any)
		m.Notifications = not save.NoTextType
		m.Sounds = not save.Muted
		m.UseSword = not not save.UseSword
		m.BooletsPerSec = save.BooletsPerSec or m.BooletsPerSec
		m.NoShells = not not save.NoShells
		m.HowBadIsAim = save.HowBadIsAim or m.HowBadIsAim
		m.ShakeValue = save.ShakeValue or m.ShakeValue
		m.Flipped = not not m.Flipped
	end
	m.SaveConfig = function()
		return {
			NoTextType = not m.Notifications,
			Muted = not m.Sounds,
			UseSword = m.UseSword,
			BooletsPerSec = m.BooletsPerSec,
			NoShells = m.NoShells,
			HowBadIsAim = m.HowBadIsAim,
			ShakeValue = m.ShakeValue,
			Flipped = m.Flipped,
		}
	end

	local start = 0
	local hum, root, torso
	local scale = 1
	local rcp = RaycastParams.new()
	rcp.FilterType = Enum.RaycastFilterType.Exclude
	rcp.IgnoreWater = true
	local function PhysicsRaycast(origin, direction)
		rcp.RespectCanCollide = true
		return workspace:Raycast(origin, direction, rcp)
	end
	local function ShootRaycast(origin, direction)
		rcp.RespectCanCollide = false
		return workspace:Raycast(origin, direction, rcp)
	end
	local mouse = Player:GetMouse()
	local mouselock = false
	local function MouseHit()
		local Camera = workspace.CurrentCamera
		local ray = mouse.UnitRay
		if mouselock and Camera then
			local pos = Camera.ViewportSize * Vector2.new(0.5, 0.3)
			ray = Camera:ViewportPointToRay(pos.X, pos.Y, 1e-6)
		end
		local dist = 2000
		local raycast = ShootRaycast(ray.Origin, ray.Direction * dist)
		if raycast then
			return raycast.Position
		end
		return ray.Origin + ray.Direction * dist
	end
	local function notify(message)
		if not m.Notifications then return end
		if not root or not torso then return end
		local dialog = torso:FindFirstChild("NOTIFICATION")
		if dialog then
			dialog:Destroy()
		end
		dialog = Instance.new("BillboardGui", torso)
		dialog.Size = UDim2.new(50 * scale, 0, 2 * scale, 0)
		dialog.StudsOffset = Vector3.new(0, 5 * scale, 0)
		dialog.Adornee = torso
		dialog.Name = "NOTIFICATION"
		local text = Instance.new("TextLabel", dialog)
		text.BackgroundTransparency = 1
		text.BorderSizePixel = 0
		text.Text = ""
		text.Font = Enum.Font.Fantasy
		text.TextScaled = true
		text.TextStrokeTransparency = 0
		text.Size = UDim2.new(1, 0, 1, 0)
		text.TextColor3 = Color3.fromRGB(255, 50, 50)
		text.TextStrokeColor3 = Color3.new(0, 0, 0)
		task.spawn(function()
			local function update()
				text.Position = UDim2.new(math.random() * 0.05 * (2 / 50), 0, 0, math.random() * 0.05)
			end
			local cps = 30
			local t = os.clock()
			local ll = 0
			repeat
				task.wait()
				local l = math.floor((os.clock() - t) * cps)
				if l > ll then
					ll = l
				end
				update()
				text.Text = string.sub(message, 1, l)
			until ll >= #message
			text.Text = message
			t = os.clock()
			repeat
				task.wait()
				update()
			until os.clock() - t > 1
			t = os.clock()
			repeat
				task.wait()
				local a = os.clock() - t
				text.Position = UDim2.new(0, math.random(-45, 45) + math.random(-a, a) * 100, 0, math.random(-5, 5) + math.random(-a, a) * 40)
				text.TextTransparency = a
				text.TextStrokeTransparency = a
			until os.clock() - t > 1
			dialog:Destroy()
		end)
	end
	local function randomdialog(arr)
		notify(arr[math.random(1, #arr)])
	end
	local function CreateSound(id, pitch, extra)
		if not m.Sounds then return end
		if not torso then return end
		local parent = torso
		if typeof(id) == "Instance" then
			parent = id
			id, pitch = pitch, extra
		end
		pitch = pitch or 1
		local sound = Instance.new("Sound")
		sound.Name = tostring(id)
		sound.SoundId = "rbxassetid://" .. id
		sound.Volume = 1
		sound.Pitch = pitch
		sound.EmitterSize = 100
		sound.Parent = parent
		sound:Play()
		sound.Ended:Connect(function()
			sound:Destroy()
		end)
	end
	local function AimTowards(target)
		if not root then return end
		if flight then return end
		local tcf = CFrame.lookAt(root.Position, target)
		local _,off,_ = root.CFrame:ToObjectSpace(tcf):ToEulerAngles(Enum.RotationOrder.YXZ)
		root.AssemblyAngularVelocity = Vector3.new(0, off, 0) * 60
	end
	local chatconn
	local attacking = false
	local joints = {
		r = CFrame.identity,
		n = CFrame.identity,
		rs = CFrame.identity,
		ls = CFrame.identity,
		rh = CFrame.identity,
		lh = CFrame.identity,
		sw = CFrame.identity,
	}
	local gun = {}
	local bullet = {}
	local mousedown = false
	local uisbegin, uisend
	local dancereact = false
	local state = 0
	local statetime = 0
	local sndshoot, sndspin
	local ROOTC0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), 0, math.rad(180))
	local NECKC0 = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(-90), 0, math.rad(180))
	local RIGHTSHOULDERC0 = CFrame.new(-0.5, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
	local LEFTSHOULDERC0 = CFrame.new(0.5, 0, 0) * CFrame.Angles(0, math.rad(-90), 0)
	local rng = Random.new(math.random(-65536, 65536))
	local shells = {}
	local timingwalk1, timingwalk2 = 0, 0

	m.Init = function(figure)
		start = os.clock()
		state = 0
		timingwalk1, timingwalk2 = 0, 0
		hum = figure:FindFirstChild("Humanoid")
		root = figure:FindFirstChild("HumanoidRootPart")
		torso = figure:FindFirstChild("Torso")
		if not hum then return end
		if not root then return end
		if not torso then return end
		SetOverrideMovesetMusic("rbxassetid://1843497734", "CHAOS: INTENSE HYBRID ROCK", 1)
		randomdialog({
			"I have arrived.",
			"Order is restored.",
			"The anomaly will be corrected.",
		})
		if math.random(5) == 1 then
			task.delay(2, function()
				for _=1, 3 do
					notify("AUGUST 12TH 2036.")
					task.wait(2)
					notify("THE HEAT DEATH OF THE UNIVERSE.")
					task.wait(1.5)
				end
			end)
		else
			task.delay(2, randomdialog, {
				"Your time ends now.",
				"Your existence will be denied.",
				"You dare delay me?",
				"Thy death is now."
			})
		end
		gun = {
			Group = "Gun",
			Limb = "Right Arm",
			Offset = CFrame.identity
		}
		bullet = {
			Group = "Bullet",
			CFrame = CFrame.identity
		}
		table.insert(HatReanimator.HatCFrameOverride, gun)
		table.insert(HatReanimator.HatCFrameOverride, bullet)
		shells = {}
		mousedown = false
		if uisbegin then
			uisbegin:Disconnect()
		end
		if uisend then
			uisend:Disconnect()
		end
		local currentclick = nil
		uisbegin = UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				mousedown = true
				mouselock = false
				currentclick = input
			end
		end)
		ContextActionService:BindAction("NAM_MGShoot", function(_, state, input)
			if state == Enum.UserInputState.Begin then
				mousedown = true
				mouselock = true
				currentclick = input
			end
		end, true)
		ContextActionService:SetTitle("NAM_MGShoot", "M1")
		ContextActionService:SetPosition("NAM_MGShoot", UDim2.new(1, -130, 1, -130))
		uisend = UserInputService.InputEnded:Connect(function(input, gpe)
			if input == currentclick then
				mousedown = false
				currentclick = nil
			end
		end)
		if chatconn then
			chatconn:Disconnect()
		end
		chatconn = OnPlayerChatted.Event:Connect(function(plr, msg)
			if plr == Player then
				notify(msg)
			end
		end)
		hum.WalkSpeed = 13 * figure:GetScale()
	end
	m.Update = function(dt: number, figure: Model)
		local t = os.clock() - start
		scale = figure:GetScale()
		isdancing = not not figure:GetAttribute("IsDancing")
		rcp.FilterDescendantsInstances = {figure, Player.Character}
		
		-- get vii
		hum = figure:FindFirstChild("Humanoid")
		root = figure:FindFirstChild("HumanoidRootPart")
		torso = figure:FindFirstChild("Torso")
		if not hum then return end
		if not root then return end
		if not torso then return end
		
		-- joints
		local rt, nt, rst, lst, rht, lht = CFrame.identity, CFrame.identity, CFrame.identity, CFrame.identity, CFrame.identity, CFrame.identity
		local gunoff = CFrame.new(0, -0.5, 0.3) * CFrame.Angles(math.rad(90), 0, 0)
		
		local timingsine = t * 80 -- timing from original
		local onground = hum:GetState() == Enum.HumanoidStateType.Running
		
		-- animations
		if m.Flipped then
			gunoff *= CFrame.Angles(0, math.pi, 0)
		end
		local torsovelocity = root.Velocity.Magnitude
		local torsovelocityy = root.Velocity.Y
		local animationspeed = 11
		if state == 0 then
			if onground then
				if torsovelocity < 1 then
					rt = ROOTC0 * CFrame.new(0, 0.1, 0.05 * math.cos(timingsine / 60)) * CFrame.Angles(math.rad(-10), math.rad(10), math.rad(-40))
					nt = NECKC0 * CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-5.5 * math.sin(timingsine / 60)), math.rad(10), math.rad(40))
					rst = CFrame.new(1.5, 0.4, 0) * CFrame.Angles(math.rad(30), math.rad(40), 0) * RIGHTSHOULDERC0
					lst = CFrame.new(-0.3, 0.3, -0.8) * CFrame.Angles(math.rad(150), math.rad(-70), math.rad(40)) * LEFTSHOULDERC0
					rht = CFrame.new(1, -1 - 0.05 * math.cos(timingsine / 60), -0.01) * CFrame.Angles(math.rad(-20), math.rad(87), 0) * CFrame.Angles(math.rad(-7), 0, 0)
					lht = CFrame.new(-1, -1 - 0.05 * math.cos(timingsine / 60), -0.01) * CFrame.Angles(math.rad(-12), math.rad(-75), 0) * CFrame.Angles(math.rad(-7), 0, 0)
				else
					animationspeed = 18.5
					local tw1 = hum.MoveDirection * root.CFrame.LookVector
					local tw2 = hum.MoveDirection * root.CFrame.RightVector
					local lv = tw1.X + tw1.Z
					local rv = tw2.X + tw2.Z
					local d = (hum:GetMoveVelocity().Magnitude / scale) / 8
					timingwalk1 += dt * 80 * d / 18
					timingwalk2 += dt * 80 * d / 10
					local walk = math.cos(timingwalk1)
					local walk2 = math.sin(timingwalk1)
					local walk3 = math.cos(timingwalk2)
					local walk4 = math.sin(timingwalk2)
					local rh = CFrame.new(lv/10 * walk, 0, 0) * CFrame.Angles(math.sin(rv/5) * walk, 0, math.sin(-lv/2) * walk)
					local lh = CFrame.new(-lv/10 * walk, 0, 0) * CFrame.Angles(math.sin(rv/5) * walk, 0, math.sin(-lv/2) * walk)
					rt = ROOTC0 * CFrame.new(0, 0.1, -0.185 + 0.055 * walk3 + -walk4 / 8) * CFrame.Angles(math.rad((lv - lv/5 * walk3) * 10), math.rad((-rv + rv/5 * walk4) * 5), math.rad(-40))
					nt = NECKC0 * CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-2 * math.sin(timingsine / 10)), 0, math.rad(40))
					rst = CFrame.new(1.5, 0.4, 0) * CFrame.Angles(math.rad(30), math.rad(40), math.rad(0)) * RIGHTSHOULDERC0
					lst = CFrame.new(-0.3, 0.3, -0.8) * CFrame.Angles(math.rad(150), math.rad(-70), math.rad(40)) * LEFTSHOULDERC0
					rht = CFrame.new(1, -1 + 0.2 * walk2, -0.5) * CFrame.Angles(0, math.rad(120), 0) * rh * CFrame.Angles(0, 0, math.rad(-5 * walk))
					lht = CFrame.new(-1.3, -0.8 - 0.2 * walk2, -0.05) * CFrame.Angles(0, math.rad(-50), 0) * lh * CFrame.Angles(math.rad(-5), 0, math.rad(-5 * walk))
				end
			else
				if torsovelocityy > -1 then
					rt = ROOTC0
					nt = NECKC0 * CFrame.new(0, 0, 0.1) * CFrame.Angles(math.rad(-20), 0, 0)
					rst = CFrame.new(1.5, 0.5, 0.2) * CFrame.Angles(math.rad(-20), 0, math.rad(-15)) * RIGHTSHOULDERC0
					lst = CFrame.new(-1.5, 0.5, 0.2) * CFrame.Angles(math.rad(-20), 0, math.rad(15)) * LEFTSHOULDERC0
					rht = CFrame.new(1, -.5, -0.5) * CFrame.Angles(math.rad(-15), math.rad(80), 0) * CFrame.Angles(math.rad(-4), 0, 0)
					lht = CFrame.new(-1, -1, 0) * CFrame.Angles(math.rad(-10), math.rad(-80), 0) * CFrame.Angles(math.rad(-4), 0, 0)
				else
					rt = ROOTC0 * CFrame.Angles(math.rad(15), 0, 0)
					nt = NECKC0 * CFrame.new(0, 0, 0.1) * CFrame.Angles(math.rad(20), 0, 0)
					rst = CFrame.new(1.5, 0.5, 0) * CFrame.Angles(math.rad(-10), 0, math.rad(25)) * RIGHTSHOULDERC0
					lst = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(math.rad(-10), 0, math.rad(-25)) * LEFTSHOULDERC0
					rht = CFrame.new(1, -.5, -0.5) * CFrame.Angles(math.rad(-15), math.rad(80), 0) * CFrame.Angles(math.rad(-4), 0, 0)
					lht = CFrame.new(-1, -1, 0) * CFrame.Angles(math.rad(-10), math.rad(-80), 0) * CFrame.Angles(math.rad(-4), 0, 0)
				end
			end
			bullet.CFrame = root.CFrame + Vector3.new(0, -8, 0) * scale
			if mousedown and not isdancing then
				state = 1
				statetime = os.clock()
				CreateSound(4473138327)
				hum.WalkSpeed = 0
				randomdialog({
					"Order is restored.",
					"The anomaly will be corrected.",
					"Your existence will be no more.",
					"You dare delay me?",
					"Your time ends now.",
					"I am bulletproof.",
				})
			end
		elseif state == 1 then
			animationspeed = 4
			AimTowards(MouseHit())
			rt = ROOTC0 * CFrame.new(0, 0.1, 0.1 * math.cos(timingsine / 35)) * CFrame.Angles(0, 0, math.rad(-40))
			nt = NECKC0 * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(40))
			rst = CFrame.new(1.5, 0.4, 0) * CFrame.Angles(math.rad(-17), math.rad(40), 0) * RIGHTSHOULDERC0
			lst = CFrame.new(-0.3, 0.3, -0.8) * CFrame.Angles(math.rad(100), math.rad(-70), math.rad(30)) * LEFTSHOULDERC0
			rht = CFrame.new(1, -1 - 0.1 * math.cos(timingsine / 35), -0.01) * CFrame.Angles(0, math.rad(87), 0) * CFrame.Angles(math.rad(-4), 0, 0)
			lht = CFrame.new(-1, -1 - 0.1 * math.cos(timingsine / 35), -0.01) * CFrame.Angles(0, math.rad(-75), 0) * CFrame.Angles(math.rad(-4), 0, 0)
			local hole = root.CFrame * CFrame.new(1.5, -1, -3)
			hole = HatReanimator.GetAttachmentCFrame(gun.Group .. "Attachment") or hole
			bullet.CFrame = hole
			if os.clock() - statetime > 0.5 then
				state = 2
				statetime = os.clock()
				if m.Sounds then
					if sndshoot then
						sndshoot:Destroy()
					end
					sndshoot = Instance.new("Sound", root)
					sndshoot.SoundId = "rbxassetid://146830885"
					sndshoot.Volume = 5
					sndshoot.Looped = true
					sndshoot.Playing = true
					if sndspin then
						sndspin:Destroy()
					end
					sndspin = Instance.new("Sound", root)
					sndspin.SoundId = "rbxassetid://2028334518"
					sndspin.Volume = 2.5
					sndspin.Looped = true
					sndspin.Playing = true
				end
			end
		elseif state == 2 then
			local hit = MouseHit()
			AimTowards(hit)
			rt = ROOTC0 * CFrame.new(0, 0.1, 0.1 * math.cos(timingsine / 35)) * CFrame.Angles(0, 0, math.rad(-40))
			nt = NECKC0 * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(40))
			rst = CFrame.new(1.5, 0.4, 0) * CFrame.Angles(math.rad(-17), math.rad(40), 0) * RIGHTSHOULDERC0
			lst = CFrame.new(-0.3, 0.3, -0.8) * CFrame.Angles(math.rad(100), math.rad(-70), math.rad(30)) * LEFTSHOULDERC0
			rht = CFrame.new(1, -1 - 0.1 * math.cos(timingsine / 35), -0.01) * CFrame.Angles(0, math.rad(87), 0) * CFrame.Angles(math.rad(-4), 0, 0)
			lht = CFrame.new(-1, -1 - 0.1 * math.cos(timingsine / 35), -0.01) * CFrame.Angles(0, math.rad(-75), 0) * CFrame.Angles(math.rad(-4), 0, 0)
			local hole = root.CFrame * CFrame.new(1.5, -1, -3)
			hole = HatReanimator.GetAttachmentCFrame(gun.Group .. "Attachment") or hole
			local shots = math.min((os.clock() - statetime) * m.BooletsPerSec, 24)
			while shots > 1 do
				shots -= 1
				local dir = (hit - hole.Position).Unit
				if dir == dir then
					dir *= 45
					dir += rng:NextUnitVector() * m.HowBadIsAim * math.random(5, 75) / 10
					dir = dir.Unit
				else
					dir = Vector3.zAxis
				end
				local cast = ShootRaycast(hole.Position, dir * 4096)
				if cast then
					hit = cast.Position
					local part = cast.Instance
					if part and part.Parent and part.Parent.Parent then
						local hum = part.Parent:FindFirstChildOfClass("Humanoid") or part.Parent.Parent:FindFirstChildOfClass("Humanoid")
						if hum and hum.RootPart and not hum.RootPart:IsGrounded() then
							ReanimateFling(hum.Parent)
						end
					end
				else
					hit = hole.Position + dir * 4096
				end
				local shootfx = Instance.new("Part", workspace)
				shootfx.Name = RandomString()
				shootfx.Anchored = true
				shootfx.CanCollide = false
				shootfx.CanTouch = false
				shootfx.CanQuery = false
				shootfx.Color = Color3.new(1, 0, 0)
				shootfx.CastShadow = false
				shootfx.Material = "Neon"
				shootfx.Size = Vector3.new(1, 1, 1)
				shootfx.Transparency = 0
				shootfx.CFrame = CFrame.lookAt(hole.Position:Lerp(hit, 0.5), hit)
				local shootfxm = Instance.new("SpecialMesh", shootfx)
				shootfxm.MeshType = "Brick"
				shootfxm.Scale = Vector3.new(0.1, 0.1, (hit - hole.Position).Magnitude)
				local ti = TweenInfo.new(5 / 60, Enum.EasingStyle.Linear)
				TweenService:Create(shootfx, ti, {Transparency = 1}):Play()
				TweenService:Create(shootfxm, ti, {Scale = Vector3.new(0.05, 0.05, (hit - hole.Position).Magnitude)}):Play()
				Debris:AddItem(shootfx, 0.5)
				if not m.NoShells then
					local shell = Instance.new("Part", workspace)
					shell.Name = RandomString()
					shell.Anchored = true
					shell.CanCollide = false
					shell.CanTouch = false
					shell.CanQuery = false
					shell.Color = Color3.new(1, 0.5, 0.5)
					shell.CastShadow = false
					shell.Material = "Neon"
					shell.Size = Vector3.new(0.1, 0.1, 0.1)
					shell.Shape = Enum.PartType.Ball
					shell.Transparency = 0.5
					shell.CFrame = HatReanimator.GetAttachmentCFrame("RightGripAttachment") or (root.CFrame * CFrame.new(1.5, -1, 0))
					shell.Velocity = root.Velocity + root.CFrame.RightVector * 30 + Vector3.new(math.random(-5, 5), 15, math.random(-5, 5))
					local a0 = Instance.new("Attachment", shell)
					a0.CFrame = CFrame.new(0, 0.05, 0)
					local a1 = Instance.new("Attachment", shell)
					a1.CFrame = CFrame.new(0, -0.05, 0)
					local b = Instance.new("Trail", shell)
					b.Attachment0 = a0
					b.Attachment1 = a1
					b.Brightness = 1
					b.LightEmission = 0.8
					b.LightInfluence = 0
					b.Color = ColorSequence.new(Color3.new(1, 0.25, 0.25))
					b.Transparency = NumberSequence.new(0.5)
					b.Lifetime = 5
					b.FaceCamera = true
					Debris:AddItem(shell, 10)
					table.insert(shells, {shell, 4})
					if #shells > 96 then
						local removed = table.remove(shells, 1)
						if removed and removed[1] then
							removed[1].Transparency = 1
						end
					end
				end
				hum.CameraOffset += rng:NextUnitVector() * 0.1 * m.ShakeValue
			end
			local bulletstate = (os.clock() // 0.05) % 2
			if bulletstate == 0 then
				bullet.CFrame = hole
				bullet.LastHit = nil
			else
				if not bullet.LastHit then
					local dir = hit - hole.Position
					if dir.Magnitude > 256 then
						dir = dir.Unit * 256
					end
					bullet.LastHit = hole.Position + dir
				end
				bullet.CFrame = CFrame.new(bullet.LastHit) * CFrame.Angles(math.random() * math.pi * 2, math.random() * math.pi * 2, math.random() * math.pi * 2)
			end
			statetime = os.clock() - shots / m.BooletsPerSec
			if not mousedown or isdancing then
				state = 0
				CreateSound(4498806901)
				CreateSound(4473119880)
				hum.WalkSpeed = 13 * scale
				if sndshoot then
					sndshoot:Destroy()
					sndshoot = nil
				end
				if sndspin then
					sndspin:Destroy()
					sndspin = nil
				end
				randomdialog({
					"Obstacle neutralized.",
					"Your time stops here.",
					"The anomaly has been corrected.",
					"Goodbye, mere mortal.",
				})
			end
		end
		
		-- shells
		local grav = Vector3.new(0, -workspace.Gravity, 0)
		for i,v in shells do
			local pos, vel = v[1].Position, v[1].Velocity
			local newpos, newvel = pos + vel * dt + (grav * dt * dt * 0.5), vel + grav * dt
			local hit = PhysicsRaycast(pos, newpos - pos)
			if hit then
				newpos = hit.Position + hit.Normal * 0.01
				newvel += hit.Normal * hit.Normal:Dot(newvel) * -2
				newvel += rng:NextUnitVector() * newvel.Magnitude * Vector3.new(1, 0, 1)
				newvel *= 0.5
			end
			v[1].Position, v[1].Velocity = newpos, newvel
			v[2] -= dt
			if v[2] <= 0 then
				v[1].Transparency = 1
				table.remove(shells, i)
			end
		end
		
		-- joints
		local rj = root:FindFirstChild("RootJoint")
		local nj = torso:FindFirstChild("Neck")
		local rsj = torso:FindFirstChild("Right Shoulder")
		local lsj = torso:FindFirstChild("Left Shoulder")
		local rhj = torso:FindFirstChild("Right Hip")
		local lhj = torso:FindFirstChild("Left Hip")
		
		-- interpolation
		local alpha = math.exp(-animationspeed * dt)
		joints.r = rt:Lerp(joints.r, alpha)
		joints.n = nt:Lerp(joints.n, alpha)
		joints.rs = rst:Lerp(joints.rs, alpha)
		joints.ls = lst:Lerp(joints.ls, alpha)
		joints.rh = rht:Lerp(joints.rh, alpha)
		joints.lh = lht:Lerp(joints.lh, alpha)
		joints.sw = gunoff:Lerp(joints.sw, alpha)
		
		-- apply transforms
		SetC0C1Joint(rj, joints.r, ROOTC0, scale)
		SetC0C1Joint(nj, joints.n, CFrame.new(0, -0.5, 0) * CFrame.Angles(math.rad(-90), 0, math.rad(180)), scale)
		SetC0C1Joint(rsj, joints.rs, CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), scale)
		SetC0C1Joint(lsj, joints.ls, CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), scale)
		SetC0C1Joint(rhj, joints.rh, CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), scale)
		SetC0C1Joint(lhj, joints.lh, CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), scale)
		
		-- gun
		if m.UseSword then
			gun.Group = "Sword"
		else
			gun.Group = "Gun"
		end
		gun.Offset = joints.sw
		gun.Disable = not not isdancing
		
		-- dance reactions
		if isdancing and not dancereact then
			notify("Let's Go!")
		end
		dancereact = isdancing
	end
	m.Destroy = function(figure: Model?)
		ContextActionService:UnbindAction("NAM_MGShoot")
		if uisbegin then
			uisbegin:Disconnect()
			uisbegin = nil
		end
		if uisend then
			uisend:Disconnect()
			uisbegin = nil
		end
		if chatconn then
			chatconn:Disconnect()
			chatconn = nil
		end
		root, torso, hum = nil, nil, nil
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "MOVESET"
	m.Name = "AK-47"
	m.InternalName = "WHATCOMESBEFORE47"
	m.Description = "\"what comes before 47?\"\n\"AK.\"\nrecreation of genesis' AK-47. lerps made by @scripterguy_1000, reiterations by mamalalanam\nM1 - Shoot"
	m.Assets = {}

	m.Sounds = true
	m.UseSword = false
	m.BooletsPerSec = 10
	m.Config = function(parent: GuiBase2d)
		Util_CreateSwitch(parent, "Sounds", m.Sounds).Changed:Connect(function(val)
			m.Sounds = val
		end)
		Util_CreateText(parent, "Use the sword instead of the gun!", 12, Enum.TextXAlignment.Center)
		Util_CreateSwitch(parent, "Gun = Sword", m.UseSword).Changed:Connect(function(val)
			m.UseSword = val
		end)
		Util_CreateText(parent, "for optimisation reasons, you can only fire max 20 bullets in a frame", 12, Enum.TextXAlignment.Center)
		Util_CreateSlider(parent, "Bullets Per Second", m.BooletsPerSec, 5, 240, 1).Changed:Connect(function(val)
			m.BooletsPerSec = val
		end)
	end
	m.LoadConfig = function(save: any)
		m.Sounds = not save.Muted
		m.UseSword = not not save.UseSword
		m.BooletsPerSec = save.BooletsPerSec or m.BooletsPerSec
	end
	m.SaveConfig = function()
		return {
			Muted = not m.Sounds,
			UseSword = m.UseSword,
			BooletsPerSec = m.BooletsPerSec,
		}
	end

	local start = 0
	local hum, root, torso
	local scale = 1
	local rcp = RaycastParams.new()
	rcp.FilterType = Enum.RaycastFilterType.Exclude
	rcp.IgnoreWater = true
	local function PhysicsRaycast(origin, direction)
		rcp.RespectCanCollide = true
		return workspace:Raycast(origin, direction, rcp)
	end
	local function ShootRaycast(origin, direction)
		rcp.RespectCanCollide = false
		return workspace:Raycast(origin, direction, rcp)
	end
	local mouse = Player:GetMouse()
	local mouselock = false
	local function MouseHit()
		local Camera = workspace.CurrentCamera
		local ray = mouse.UnitRay
		if mouselock and Camera then
			local pos = Camera.ViewportSize * Vector2.new(0.5, 0.3)
			ray = Camera:ViewportPointToRay(pos.X, pos.Y, 1e-6)
		end
		local dist = 2000
		local raycast = ShootRaycast(ray.Origin, ray.Direction * dist)
		if raycast then
			return raycast.Position
		end
		return ray.Origin + ray.Direction * dist
	end
	local function CreateSound(id, pitch, extra)
		if not m.Sounds then return end
		if not torso then return end
		local parent = torso
		if typeof(id) == "Instance" then
			parent = id
			id, pitch = pitch, extra
		end
		pitch = pitch or 1
		local sound = Instance.new("Sound")
		sound.Name = tostring(id)
		sound.SoundId = "rbxassetid://" .. id
		sound.Volume = 1
		sound.Pitch = pitch
		sound.EmitterSize = 100
		sound.Parent = parent
		sound:Play()
		sound.Ended:Connect(function()
			sound:Destroy()
		end)
	end
	local function AimTowards(target)
		if not root then return end
		if flight then return end
		local tcf = CFrame.lookAt(root.Position, target)
		local _,off,_ = root.CFrame:ToObjectSpace(tcf):ToEulerAngles(Enum.RotationOrder.YXZ)
		root.AssemblyAngularVelocity = Vector3.new(0, off, 0) * 60
	end
	local chatconn
	local attacking = false
	local joints = {
		r = CFrame.identity,
		n = CFrame.identity,
		rs = CFrame.identity,
		ls = CFrame.identity,
		rh = CFrame.identity,
		lh = CFrame.identity,
		sw = CFrame.identity,
	}
	local gun = {}
	local bullet = {}
	local mousedown = false
	local uisbegin, uisend
	local state = 0
	local statetime = 0
	local timingwalk = 0
	local footsteps = nil

	m.Init = function(figure)
		start = os.clock()
		state = 0
		timingwalk1, timingwalk2 = 0, 0
		hum = figure:FindFirstChild("Humanoid")
		root = figure:FindFirstChild("HumanoidRootPart")
		torso = figure:FindFirstChild("Torso")
		if not hum then return end
		if not root then return end
		if not torso then return end
		gun = {
			Group = "Gun",
			Limb = "Right Arm",
			Offset = CFrame.identity
		}
		bullet = {
			Group = "Bullet",
			CFrame = CFrame.identity
		}
		table.insert(HatReanimator.HatCFrameOverride, gun)
		table.insert(HatReanimator.HatCFrameOverride, bullet)
		mousedown = false
		if uisbegin then
			uisbegin:Disconnect()
		end
		if uisend then
			uisend:Disconnect()
		end
		local currentclick = nil
		uisbegin = UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				mousedown = true
				mouselock = false
				currentclick = input
			end
		end)
		ContextActionService:BindAction("NAM_AKShoot", function(_, state, input)
			if state == Enum.UserInputState.Begin then
				mousedown = true
				mouselock = true
				currentclick = input
			end
		end, true)
		ContextActionService:SetTitle("NAM_AKShoot", "M1")
		ContextActionService:SetPosition("NAM_AKShoot", UDim2.new(1, -130, 1, -130))
		uisend = UserInputService.InputEnded:Connect(function(input, gpe)
			if input == currentclick then
				mousedown = false
				currentclick = nil
			end
		end)
		hum.WalkSpeed = 16 * figure:GetScale()
		footsteps = Instance.new("Sound", root)
		footsteps.SoundId = "rbxassetid://4776173570"
		footsteps.Volume = 1
		footsteps.Pitch = 1.25
		footsteps.Looped = true
	end
	m.Update = function(dt: number, figure: Model)
		local t = os.clock() - start
		scale = figure:GetScale()
		isdancing = not not figure:GetAttribute("IsDancing")
		rcp.FilterDescendantsInstances = {figure, Player.Character}
		
		-- get vii
		hum = figure:FindFirstChild("Humanoid")
		root = figure:FindFirstChild("HumanoidRootPart")
		torso = figure:FindFirstChild("Torso")
		if not hum then return end
		if not root then return end
		if not torso then return end
		
		-- joints
		local rt, nt, rst, lst, rht, lht = CFrame.identity, CFrame.identity, CFrame.identity, CFrame.identity, CFrame.identity, CFrame.identity
		local gunoff = CFrame.new(0, -1, 0.3) * CFrame.Angles(math.rad(190), math.rad(180), 0)
		
		local timingsine = t * 60
		local onground = hum:GetState() == Enum.HumanoidStateType.Running
		
		-- animations
		local torsovelocity = root.Velocity.Magnitude
		local torsovelocityy = root.Velocity.Y
		local animationspeed = 16
		local sin30 = math.sin(timingsine / 30)
		if onground then
			if torsovelocity < 1 then
				footsteps.Playing = false
				rt = CFrame.new(0, 0.05 * sin30, 0) * CFrame.Angles(-1.5707963267948966, 0, 3.141592653589793)
				nt = CFrame.new(0, 1, 0) * CFrame.Angles(-1.5707963267948966, 0, 3.141592653589793)
				rst = CFrame.new(0.6, 0.45 + 0.1 * sin30, 0.2) * CFrame.Angles(0, 2.356194490192345, 1.0471975511965976)
				lst = CFrame.new(-0.8, 0.45 + 0.1 * sin30, -0.3) * CFrame.Angles(0, -2.2689280275926285, -0.8726646259971648)
				rht = CFrame.new(1, -1 - 0.05 * sin30, 0.1) * CFrame.Angles(0, 1.3962634015954636, 0)
				lht = CFrame.new(-1, -1 - 0.05 * sin30, 0.1) * CFrame.Angles(0, -1.3089969389957472, 0)
			else
				footsteps.Playing = true
				local d = (hum:GetMoveVelocity().Magnitude / scale) / 16
				local rw = root.CFrame.RightVector:Dot(hum.MoveDirection) * d
				local lw = root.CFrame.LookVector:Dot(hum.MoveDirection) * d
				timingwalk += dt * d
				rt = CFrame.new(0, 0.05 * math.sin(timingwalk * 20), 0) * CFrame.Angles(math.rad(-90 - lw * 10), math.rad(rw * 10), math.rad(180))
				nt = CFrame.new(0, 1, 0) * CFrame.Angles(-1.5707963267948966, 0, 3.141592653589793)
				rst = CFrame.new(0.6, 0.45 + 0.05 * math.sin((timingwalk + 0.5) * 20), 0.2) * CFrame.Angles(0, 2.356194490192345, 1.0471975511965976)
				lst = CFrame.new(-0.8, 0.45 + 0.05 * math.sin((timingwalk + 0.5) * 20), -0.3) * CFrame.Angles(0, -2.2689280275926285, -0.8726646259971648)
				rht = CFrame.new(1 + 0.1 * math.sin((timingwalk - 0.5) * 10) * rw, -1 - 0.05 * math.sin(timingwalk * 20), 0.1 + 0.1 * math.sin((timingwalk - 0.5) * 10) * lw) * CFrame.Angles(0, 1.5707963267948966 - 0.2 * rw, -0.17453292519943295 + 1.0471975511965976 * math.sin((timingwalk + 1) * 10))
				lht = CFrame.new(-1 + 0.1 * math.sin((timingwalk - 0.5) * 10) * rw, -1 - 0.05 * math.sin(timingwalk * 20), 0.1 + 0.1 * math.sin((timingwalk - 0.5) * 10) * lw) * CFrame.Angles(0, -1.5707963267948966 - 0.2 * rw, 0.17453292519943295 + 1.0471975511965976 * math.sin((timingwalk + 1) * 10))
			end
		else
			footsteps.Playing = false
			rt = CFrame.Angles(-1.5707963267948966 + math.clamp(torsovelocityy, -50, 50) * 0.004, 0, 3.141592653589793)
			nt = CFrame.new(0, 1, 0) * CFrame.Angles(-1.6580627893946132, 0, 3.141592653589793)
			rst = CFrame.new(0.6, 0.5, -0.1) * CFrame.Angles(0.08, 0, 0) * CFrame.Angles(0, 2.356194490192345, 1.0471975511965976)
			lst = CFrame.new(-0.8, 0.5, -0.6) * CFrame.Angles(0.08, 0, 0) * CFrame.Angles(0, -2.2689280275926285, -0.8726646259971648)
			rht = CFrame.new(1.1, -0.9, -0.2) * CFrame.Angles(0, 1.5707963267948966, -0.3490658503988659)
			lht = CFrame.new(-1.1, -0.8, -1) * CFrame.Angles(0, -1.4835298641951802, 0.5235987755982988)
		end
		if state == 0 then
			bullet.CFrame = root.CFrame + Vector3.new(0, -8, 0) * scale
			if mousedown and not isdancing then
				state = 1
				statetime = os.clock()
			end
		elseif state == 1 then
			local hit = MouseHit()
			AimTowards(hit)
			footsteps.Playing = false
			rst = CFrame.new(0.6, 0.05 * sin30, 0.1) * CFrame.Angles(0, 1.7453292519943295, 1.7453292519943295)
			lst = CFrame.new(-0.4, 0.5 + 0.05 * sin30, -0.7) * CFrame.Angles(0, -2.6179938779914944, -1.3962634015954636)
			local hole = root.CFrame * CFrame.new(1.5, 0.2, -3)
			hole = HatReanimator.GetAttachmentCFrame(gun.Group .. "Attachment") or hole
			local dir = (hit - hole.Position).Unit
			if dir == dir then
				dir = dir.Unit
			else
				dir = Vector3.zAxis
			end
			local cast = ShootRaycast(hole.Position, dir * 4096)
			if cast then
				hit = cast.Position
				local part = cast.Instance
				if part and part.Parent and part.Parent.Parent then
					local hum = part.Parent:FindFirstChildOfClass("Humanoid") or part.Parent.Parent:FindFirstChildOfClass("Humanoid")
					if hum and hum.RootPart and not hum.RootPart:IsGrounded() then
						ReanimateFling(part.Parent)
					end
				end
			else
				hit = hole.Position + dir * 4096
			end
			local shots = math.min((os.clock() - statetime) * m.BooletsPerSec, 24)
			while shots > 1 do
				shots -= 1
				local ti = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
				local shootfx = Instance.new("Part", workspace)
				shootfx.Name = RandomString()
				shootfx.Anchored = true
				shootfx.CanCollide = false
				shootfx.CanTouch = false
				shootfx.CanQuery = false
				shootfx.Color = Color3.new(1, 1, 0)
				shootfx.CastShadow = false
				shootfx.Material = "Neon"
				shootfx.Size = Vector3.zero
				shootfx.Transparency = 0
				shootfx.CFrame = CFrame.Angles(math.random() * math.pi * 2, math.random() * math.pi * 2, math.random() * math.pi * 2) + hole.Position
				TweenService:Create(shootfx, ti, {Transparency = 1, Size = Vector3.new(2, 2, 2)}):Play()
				CreateSound(shootfx, 2476570846, 0.95 + math.random() * 0.1)
				Debris:AddItem(shootfx, 0.5)
				shootfx = Instance.new("Part", workspace)
				shootfx.Name = RandomString()
				shootfx.Anchored = true
				shootfx.CanCollide = false
				shootfx.CanTouch = false
				shootfx.CanQuery = false
				shootfx.Color = Color3.new(1, 1, 0)
				shootfx.CastShadow = false
				shootfx.Material = "Neon"
				shootfx.Size = Vector3.zero
				shootfx.Transparency = 0
				shootfx.CFrame = CFrame.Angles(math.random() * math.pi * 2, math.random() * math.pi * 2, math.random() * math.pi * 2) + hit
				TweenService:Create(shootfx, ti, {Transparency = 1, Size = Vector3.new(2, 2, 2)}):Play()
				CreateSound(shootfx, 4427231299, 0.9 + math.random() * 0.2)
				Debris:AddItem(shootfx, 0.5)
				local shootline = Instance.new("Part", workspace)
				shootline.Name = RandomString()
				shootline.Anchored = true
				shootline.CanCollide = false
				shootline.CanTouch = false
				shootline.CanQuery = false
				shootline.Color = Color3.new(1, 1, 0)
				shootline.CastShadow = false
				shootline.Material = "Neon"
				shootline.Size = Vector3.new(1, 1, 1)
				shootline.Transparency = 0
				shootline.CFrame = CFrame.lookAt(hole.Position:Lerp(hit, 0.5), hit)
				local shootlinem = Instance.new("SpecialMesh", shootline)
				shootlinem.MeshType = "Brick"
				shootlinem.Scale = Vector3.new(0.1, 0.1, (hit - hole.Position).Magnitude)
				TweenService:Create(shootline, ti, {Transparency = 1}):Play()
				TweenService:Create(shootlinem, ti, {Scale = Vector3.new(0.5, 0.5, (hit - hole.Position).Magnitude)}):Play()
				Debris:AddItem(shootline, 0.5)
				joints.rs += Vector3.new(0, 0, 0.1)
				joints.ls += Vector3.new(0, 0, 0.1)
			end
			local bulletstate = (os.clock() // 0.05) % 2
			if bulletstate == 0 then
				bullet.CFrame = hole
				bullet.LastHit = nil
			else
				if not bullet.LastHit then
					local dir = hit - hole.Position
					if dir.Magnitude > 256 then
						dir = dir.Unit * 256
					end
					bullet.LastHit = hole.Position + dir
				end
				bullet.CFrame = CFrame.new(bullet.LastHit) * CFrame.Angles(math.random() * math.pi * 2, math.random() * math.pi * 2, math.random() * math.pi * 2)
			end
			statetime = os.clock() - shots / m.BooletsPerSec
			if not mousedown or isdancing then
				state = 0
				hum.WalkSpeed = 16 * scale
			end
		end
		
		-- joints
		local rj = root:FindFirstChild("RootJoint")
		local nj = torso:FindFirstChild("Neck")
		local rsj = torso:FindFirstChild("Right Shoulder")
		local lsj = torso:FindFirstChild("Left Shoulder")
		local rhj = torso:FindFirstChild("Right Hip")
		local lhj = torso:FindFirstChild("Left Hip")
		
		-- interpolation
		local alpha = math.exp(-animationspeed * dt)
		joints.r = rt:Lerp(joints.r, alpha)
		joints.n = nt:Lerp(joints.n, alpha)
		joints.rs = rst:Lerp(joints.rs, alpha)
		joints.ls = lst:Lerp(joints.ls, alpha)
		joints.rh = rht:Lerp(joints.rh, alpha)
		joints.lh = lht:Lerp(joints.lh, alpha)
		joints.sw = gunoff:Lerp(joints.sw, alpha)
		
		-- apply transforms
		SetC0C1Joint(rj, joints.r, CFrame.Angles(-1.57, 0, 3.14), scale)
		SetC0C1Joint(nj, joints.n, CFrame.new(0, -0.5, 0) * CFrame.Angles(math.rad(-90), 0, math.rad(180)), scale)
		SetC0C1Joint(rsj, joints.rs, CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), scale)
		SetC0C1Joint(lsj, joints.ls, CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), scale)
		SetC0C1Joint(rhj, joints.rh, CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), scale)
		SetC0C1Joint(lhj, joints.lh, CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), scale)
		
		-- gun
		if m.UseSword then
			gun.Group = "Sword"
		else
			gun.Group = "Gun"
		end
		gun.Offset = joints.sw
		gun.Disable = not not isdancing
	end
	m.Destroy = function(figure: Model?)
		ContextActionService:UnbindAction("NAM_AKShoot")
		if uisbegin then
			uisbegin:Disconnect()
			uisbegin = nil
		end
		if uisend then
			uisend:Disconnect()
			uisbegin = nil
		end
		root, torso, hum = nil, nil, nil
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "MOVESET"
	m.Name = "Sin Dragon"
	m.InternalName = "SINEWAVETREXDINOSAR"
	m.Description = "sin dragon if he was CHINESE\nnow in the latest color: MURASAKI!!\nor, you can change the color yourself!\nM1 - Punches\nZ - Barrage (cancellable)\nX - Smash Down!\nC - Firin ma lazar (cancellable)\nG - Roarrrr!!"
	m.Assets = {"SinDragonTheme.mp3", "SinDragonIntro.anim", "SinDragonImpactFrame1.png", "SinDragonImpactFrame2.png", "SinDragonImpactFrame3.png", "SinDragonImpactFrame4.png", "SinDragonImpactFrame5.png"}

	m.Notifications = true
	m.Sounds = true
	m.ShakeValue = 1
	m.SkipIntro = false
	m.AltIntro = false
	m.ClientsideDragon = true
	m.HitboxDebug = false
	m.NoCooldown = false
	m.BlastCharge = 150
	m.BlastDuration = 200
	m.RoarDuration = 300
	m.Config = function(parent: GuiBase2d)
		Util_CreateSwitch(parent, "Text thing", m.Notifications).Changed:Connect(function(val)
			m.Notifications = val
		end)
		Util_CreateSwitch(parent, "Sounds", m.Sounds).Changed:Connect(function(val)
			m.Sounds = val
		end)
		Util_CreateSlider(parent, "Shake Amount", m.ShakeValue, 0, 1, 0).Changed:Connect(function(val)
			m.ShakeValue = val
		end)
		Util_CreateText(parent, "Skip the intro of Sin Dragon just like for Genesis FE", 12, Enum.TextXAlignment.Center)
		Util_CreateSwitch(parent, "Skip Intro", m.SkipIntro).Changed:Connect(function(val)
			m.SkipIntro = val
		end)
		Util_CreateText(parent, "make the intro lock in (impact frames drawn by mamalalanam ofc)", 12, Enum.TextXAlignment.Center)
		Util_CreateSwitch(parent, "Alternate Intro", m.AltIntro).Changed:Connect(function(val)
			m.AltIntro = val
		end)
		Util_CreateSwitch(parent, "Clientside Dragon Model", m.ClientsideDragon).Changed:Connect(function(val)
			m.ClientsideDragon = val
		end)
		Util_CreateSwitch(parent, "Hitbox Visual", m.HitboxDebug).Changed:Connect(function(val)
			m.HitboxDebug = val
		end)
		Util_CreateSeparator(parent)
		Util_CreateText(parent, "Random configs for the non-programmers that want to tweak the moveset >:D", 15, Enum.TextXAlignment.Center)
		Util_CreateText(parent, "No cooldowns, lets you spam attacks. Lag warning though!", 12, Enum.TextXAlignment.Center)
		Util_CreateSwitch(parent, "Turbo mode", m.NoCooldown).Changed:Connect(function(val)
			m.NoCooldown = val
		end)
		Util_CreateText(parent, "the configs below are in ticks, where 1 tick is 60th of a second!", 12, Enum.TextXAlignment.Center)
		Util_CreateSlider(parent, "Laser Charge", m.BlastCharge, 10, 150, 1).Changed:Connect(function(val)
			m.BlastCharge = val
		end)
		Util_CreateSlider(parent, "Laser Duration", m.BlastDuration, 30, 300, 1).Changed:Connect(function(val)
			m.BlastDuration = val
		end)
		Util_CreateSlider(parent, "Roar Duration", m.RoarDuration, 60, 600, 1).Changed:Connect(function(val)
			m.RoarDuration = val
		end)
	end
	m.LoadConfig = function(save: any)
		m.Notifications = not save.NoTextType
		m.Sounds = not save.Muted
		m.ShakeValue = save.ShakeValue or m.ShakeValue
		m.SkipIntro = not not save.SkipIntro
		m.AltIntro = not not save.AltIntro
		m.ClientsideDragon = not save.NoClientsideDragon
		m.HitboxDebug = not not save.HitboxDebug
		m.NoCooldown = not not save.NoCooldown
		m.BlastCharge = save.BlastCharge or m.BlastCharge
		m.BlastDuration = save.BlastDuration or m.BlastDuration
		m.RoarDuration = save.RoarDuration or m.RoarDuration
	end
	m.SaveConfig = function()
		return {
			NoTextType = not m.Notifications,
			Muted = not m.Sounds,
			ShakeValue = m.ShakeValue,
			SkipIntro = m.SkipIntro,
			AltIntro = m.AltIntro,
			NoClientsideDragon = not m.ClientsideDragon,
			HitboxDebug = m.HitboxDebug,
			NoCooldown = m.NoCooldown,
			BlastCharge = m.BlastCharge,
			BlastDuration = m.BlastDuration,
			RoarDuration = m.RoarDuration,
		}
	end

	local start = 0
	local hum, root, torso
	local maincolor = Color3.new(0.385, 0.146, 0.820)
	local rcp = RaycastParams.new()
	rcp.FilterType = Enum.RaycastFilterType.Exclude
	rcp.IgnoreWater = true
	local function PhysicsRaycast(origin, direction)
		rcp.RespectCanCollide = true
		return workspace:Raycast(origin, direction, rcp)
	end
	local function ShootRaycast(origin, direction)
		rcp.RespectCanCollide = false
		return workspace:Raycast(origin, direction, rcp)
	end
	local mouse = Player:GetMouse()
	local function MouseHit()
		local ray = mouse.UnitRay
		local dist = 2000
		local raycast = ShootRaycast(ray.Origin, ray.Direction * dist)
		if raycast then
			return raycast.Position
		end
		return ray.Origin + ray.Direction * dist
	end
	local function notify(message, cps)
		if not m.Notifications then return end
		if not root or not torso then return end
		local dialog = torso:FindFirstChild("NOTIFICATION")
		if dialog then
			dialog:Destroy()
		end
		dialog = Instance.new("BillboardGui", torso)
		dialog.Size = UDim2.new(50 * scale, 0, 2 * scale, 0)
		dialog.StudsOffset = Vector3.new(0, 5 * scale, 5 * scale)
		dialog.Adornee = torso
		dialog.Name = "NOTIFICATION"
		local text = Instance.new("TextLabel", dialog)
		text.BackgroundTransparency = 1
		text.BorderSizePixel = 0
		text.Text = ""
		text.Font = Enum.Font.Garamond
		text.TextScaled = true
		text.TextStrokeTransparency = 0
		text.Size = UDim2.new(1, 0, 1, 0)
		text.TextColor3 = maincolor
		text.TextStrokeColor3 = Color3.new(0, 0, 0)
		task.spawn(function()
			local function update()
				text.Position = UDim2.new(math.random() * 0.05 * (2 / 50), 0, 0, math.random() * 0.05)
			end
			if cps then
				cps = #message / cps
			else
				cps = 20
			end
			local t = os.clock()
			local ll = 0
			repeat
				task.wait()
				local l = math.floor((os.clock() - t) * cps)
				if l > ll then
					ll = l
				end
				update()
				text.Text = string.sub(message, 1, l)
			until ll >= #message
			text.Text = message
			t = os.clock()
			repeat
				task.wait()
				update()
			until os.clock() - t > 1
			t = os.clock()
			repeat
				task.wait()
				local a = os.clock() - t
				text.Position = UDim2.new(0, math.random(-45, 45) + math.random(-a, a) * 100, 0, math.random(-5, 5) + math.random(-a, a) * 40)
				text.TextTransparency = a
				text.TextStrokeTransparency = a
			until os.clock() - t > 1
			dialog:Destroy()
		end)
	end
	local function randomdialog(arr, cps)
		notify(arr[math.random(1, #arr)], cps)
	end
	local function CreateSound(id, pitch, extra)
		if not m.Sounds then return end
		if not torso then return end
		local parent = torso
		if typeof(id) == "Instance" then
			parent = id
			id, pitch = pitch, extra
		end
		pitch = pitch or 1
		local sound = Instance.new("Sound")
		sound.Name = tostring(id)
		sound.SoundId = "rbxassetid://" .. id
		sound.Volume = 1
		sound.Pitch = pitch
		sound.EmitterSize = 100
		sound.Parent = parent
		sound:Play()
		sound.Ended:Connect(function()
			sound:Destroy()
		end)
	end
	local function sincosPerlin(seed, x)
		local sum = 0
		local amplitude = 1.0
		local frequency = 1.0
		for octave = 1, 6 do
			local baseIndex = (octave - 1) * 3 + 1
			local freq = seed[baseIndex + 0]
			local phase = seed[baseIndex + 1]
			local ampMult = seed[baseIndex + 2]
			local wave
			if octave % 2 == 1 then
				wave = math.sin(x * frequency * freq + phase)
			else
				wave = math.cos(x * frequency * freq + phase)
			end
			sum = sum + wave * amplitude * ampMult
			amplitude = amplitude * 0.51
			frequency = frequency * 2.17
		end
		return sum
	end
	local sincosseed1 = {1.03, 0.8, 1.00, 2.09, 4.2, 0.51, 4.28, 1.4, 0.26, 8.41, 5.9, 0.13, 15.2, 3.1, 0.065, 24.1, 7.3, 0.033}
	local sincosseed2 = {0.98, 2.1, 1.00, 2.16, 5.7, 0.49, 4.39, 0.9, 0.25, 8.94, 6.4, 0.125, 14.8, 2.8, 0.063, 23.7, 8.6, 0.032}
	local sincosseed3 = {1.05, 6.3, 0.99, 2.04, 1.8, 0.52, 4.51, 7.2, 0.27, 9.12, 3.5, 0.135, 16.3, 0.4, 0.068, 25.9, 4.7, 0.034}
	local sincosseed4 = {1.00, 3.9, 1.00, 2.22, 0.5, 0.50, 4.18, 8.1, 0.24, 8.76, 4.6, 0.12, 15.7, 1.9, 0.06, 24.4, 6.2, 0.03}
	local sincosseed5 = {0.96, 1.2, 1.00, 2.27, 6.8, 0.48, 4.62, 2.7, 0.245, 9.38, 7.5, 0.122, 17.1, 3.8, 0.061, 26.3, 0.7, 0.031}
	local sincosseed6 = {1.02, 4.6, 0.99, 2.11, 3.3, 0.51, 4.34, 9.4, 0.26, 8.59, 1.6, 0.13, 14.9, 5.2, 0.066, 23.8, 2.5, 0.033}
	local chatconn
	local joints = {
		r = CFrame.identity,
		n = CFrame.identity,
		rs = CFrame.identity,
		ls = CFrame.identity,
		rh = CFrame.identity,
		lh = CFrame.identity,
		dh = CFrame.identity,
		dl = CFrame.identity,
		dr = CFrame.identity,
	}
	local rng = Random.new(math.random(-65536, 65536))
	local attacking = false
	local dancereact = {}
	local dragonhead = {}
	local dragonclawl = {}
	local dragonclawr = {}
	local dragonheadm = table.concat({
		"14125138528, 14124704530, 1.62502, -3.875, -7.62939e-06, 0, 0, 1, 0, 1, 0, -1, 0, 0",
		"14124079275, 14124325282, 0, -4.375, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1|17201999027, 81729827287328, 0, -4, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1",
		"17201999027, 138410453456308, 0, -3.875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1|13455103072, 13455284034, 0, -4, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1",
		"14119894735, 14119897721, 0, -3.625, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1",
		"3302576131, 3302568684, 0, -4, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1",
		"136491922265650, 138228578975518, -0.25, -4.125, -1.12499, 0, 0, -1, 0, 1, 0, 1, 0, 0",
		"76446501643738, 138228578975518, -0.25, -4.125, 1.12499, 0, 0, -1, 0, 1, 0, 1, 0, 0",
		"",
		"",
		"",
	}, "|")
	local dragonclawlm = table.concat({
		"14500656581, 14500658147, -0.274017, -0.416981, -6.76048, -0.465541, -0.340719, -0.816812, -0.196175, 0.939693, -0.280166, 0.863011, 0.029809, -0.504306",
		"10238612290, 10238476193, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1",
		"119976677482426, 127102957606543, -0.416983, -0.600983, -7.26048, -0.196175, 0.939694, -0.280167, 0.465542, 0.340719, 0.816813, 0.863009, 0.0298086, -0.504306",
		"",
	}, "|")
	local dragonclawrm = table.concat({
		"14500686852, 14500688203, 0.274033, -0.417015, -6.7605, -0.46554, 0.34072, 0.816813, 0.196172, 0.939692, -0.28017, -0.863012, 0.0298058, -0.504304",
		"10238680852, 10238474353, 6.34478, -3.14286, 1.96631, 0.819152, 0.32899, 0.469846, -0.573576, 0.469846, 0.67101, 0, -0.819152, 0.573577",
		"117309169372490, 127102957606543, -0.0829811, 0.274033, -7.26051, -0.196172, -0.939692, 0.28017, -0.46554, 0.34072, 0.816812, -0.863012, 0.0298054, -0.504304",
		"",
	}, "|")
	local insts = {}
	local state = 0
	local statetime = 0
	local statem1 = 0
	local lastfx = 0
	local animationinstant = false
	local ROOTC0 = CFrame.Angles(-1.57, 0, 3.14)
	local NECKC0 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
	local NECKC1 = CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
	local LHC0 = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
	local LHC1 = CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
	local RHC0 = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)
	local RHC1 = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)
	local OFF_DragonClawL = CFrame.new(-6.74455023, 0.843135834, 3.31332064, 0.866820872, 0.000393055088, -0.498619556, 0.129048944, -0.966104209, 0.223582461, -0.481630623, -0.258152217, -0.837489963)
	local OFF_DragonClawR = CFrame.new(6.65693045, 1.66835713, 2.9684639, 0.866025746, 0.129405379, 0.482963592, -3.67555799e-06, -0.965926409, 0.258817136, 0.499999553, -0.224144042, -0.836516559)
	local OFF_DragonHead = CFrame.new(-2.22326851, -3.5562191, -0.038143158, 0, 0, 1, 0, 1, 0, -1, 0, 0)
	local footsteps = nil
	local bullet = {}
	local bulletstate = {Vector3.zero, Vector3.zero, 0}
	local gunaura = {}
	local gunaurastate = {Vector3.zero, 0}
	local function SetBulletState(hole, target)
		local dist = (target - hole).Magnitude
		bulletstate[1] = hole
		if dist > 256 then
			bulletstate[2] = hole + (target - hole).Unit * 256
		else
			bulletstate[2] = target
		end
		bulletstate[3] = os.clock()
	end
	local function SetGunauraState(target, ticks)
		gunaurastate[1] = target
		gunaurastate[2] = ticks or 3
	end

	local function createhatmap(mlist, tbl)
		table.clear(tbl)
		for _,v in string.split(mlist, "|") do
			if #v > 0 then
				local w = string.split(v, ",")
				if #w == 14 then
					local ref = {
						MeshId = w[1]:gsub("^%s*(.-)%s*$", "%1"), TextureId = w[2]:gsub("^%s*(.-)%s*$", "%1"),
						C0 = CFrame.identity,
						C1 = CFrame.new(
							tonumber(w[3]),
							tonumber(w[4]),
							tonumber(w[5]),
							tonumber(w[6]),
							tonumber(w[7]),
							tonumber(w[8]),
							tonumber(w[9]),
							tonumber(w[10]),
							tonumber(w[11]),
							tonumber(w[12]),
							tonumber(w[13]),
							tonumber(w[14])
						),
					}
					table.insert(HatReanimator.HatCFrameOverride, ref)
					table.insert(tbl, ref)
				end
			end
		end
	end
	local function sethatmaplimbname(tbl, limbname)
		for _,v in tbl do
			v.Limb = limbname
		end
	end
	local function sethatmapcframe(tbl, cf)
		for _,v in tbl do
			v.C0 = cf
		end
	end

	local function CreatePart(transparency, brickcolor, size)
		local p = Instance.new("Part")
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Massless = true
		p.CastShadow = false
		if brickcolor == "Alder" then
			p.Color = maincolor
		else
			p.BrickColor = BrickColor.new(brickcolor)
		end
		p.Transparency = transparency
		p.Name = RandomString()
		p.Size = size
		p.Material = Enum.Material.Neon
		p.Parent = workspace
		return p
	end
	local function CreateMesh(class, part, meshtype, meshid, offset, scale)
		local m = Instance.new(class) 
		m.Parent = part
		if class == "SpecialMesh" then
			m.MeshType = meshtype
			if meshid then
				m.MeshId = "rbxassetid://" .. meshid
			end
		end
		m.Offset = offset
		m.Scale = scale
		return m
	end
	local function MagicCircle(brickcolor, pos, ssize, esize, delay)
		local p = CreatePart(0, brickcolor, Vector3.one * 0.5)
		p.CFrame = CFrame.new(pos)
		local m = CreateMesh("SpecialMesh", p, "Sphere", nil, Vector3.zero, ssize)
		local ticks = 1 / delay
		TweenService:Create(p, TweenInfo.new(ticks / 60, Enum.EasingStyle.Linear), {
			Transparency = 1,
		}):Play()
		TweenService:Create(m, TweenInfo.new(ticks / 60, Enum.EasingStyle.Linear), {
			Scale = ssize + esize * ticks,
		}):Play()
		Debris:AddItem(p, ticks / 60)
	end
	local function MagicCircle2(brickcolor, pos, ssize, esize, delay)
		local p = CreatePart(0.9, brickcolor, Vector3.one * 0.5)
		p.CFrame = CFrame.new(pos)
		local m = CreateMesh("SpecialMesh", p, "Sphere", nil, Vector3.zero, ssize)
		local ticks = 1 / delay
		TweenService:Create(p, TweenInfo.new(ticks / 60, Enum.EasingStyle.Linear), {
			Transparency = 1,
		}):Play()
		TweenService:Create(m, TweenInfo.new(ticks / 60, Enum.EasingStyle.Linear), {
			Scale = ssize + esize * ticks,
		}):Play()
		Debris:AddItem(p, ticks / 60)
	end
	local function MagicRing(brickcolor, pos, ssize, esize)
		local p = CreatePart(0, brickcolor, Vector3.one * 0.5)
		p.CFrame = CFrame.Angles(math.random() * math.pi * 2, math.random() * math.pi * 2, math.random() * math.pi * 2) + pos
		local m = CreateMesh("SpecialMesh", p, "FileMesh", 3270017, Vector3.zero, ssize)
		local ticks = 1 / 0.03
		TweenService:Create(p, TweenInfo.new(ticks / 60, Enum.EasingStyle.Linear), {
			Transparency = 1,
		}):Play()
		TweenService:Create(m, TweenInfo.new(ticks / 60, Enum.EasingStyle.Linear), {
			Scale = ssize + esize * ticks,
		}):Play()
		Debris:AddItem(p, ticks / 60)
	end
	local function BlastEffect(brickcolor, pos, ssize, esize)
		local p = CreatePart(0, brickcolor, Vector3.one * 0.5)
		p.CFrame = CFrame.Angles(0, math.random() * math.pi * 2, 0) + pos
		local m = CreateMesh("SpecialMesh", p, "FileMesh", 20329976, Vector3.zero, ssize)
		local ticks = 1 / 0.05
		TweenService:Create(p, TweenInfo.new(ticks / 60, Enum.EasingStyle.Linear), {
			Transparency = 1,
		}):Play()
		TweenService:Create(m, TweenInfo.new(ticks / 60, Enum.EasingStyle.Linear), {
			Scale = ssize + esize * ticks,
		}):Play()
		Debris:AddItem(p, ticks / 60)
	end
	local function MagicBlock(brickcolor, pos, ssize, esize, delay)
		local p = CreatePart(0, brickcolor, Vector3.one * 0.5)
		p.CFrame = CFrame.new(pos)
		local m = CreateMesh("BlockMesh", p, nil, nil, Vector3.zero, ssize)
		local ticks = 1 / delay
		TweenService:Create(p, TweenInfo.new(ticks / 60, Enum.EasingStyle.Linear), {
			Transparency = 1,
		}):Play()
		TweenService:Create(m, TweenInfo.new(ticks / 60, Enum.EasingStyle.Linear), {
			Scale = ssize + esize * ticks,
		}):Play()
		task.spawn(function()
			while p:IsDescendantOf(workspace) do
				p.CFrame *= CFrame.Angles(math.random(0, 360), math.random(0, 360), math.random(0, 360))
				task.wait()
			end
		end)
		Debris:AddItem(p, ticks / 60)
	end

	local function Attack(position, radius, ispunch)
		if m.HitboxDebug then
			local hitvis = Instance.new("Part")
			hitvis.Name = RandomString()
			hitvis.CastShadow = false
			hitvis.Material = Enum.Material.ForceField
			hitvis.Anchored = true
			hitvis.CanCollide = false
			hitvis.CanTouch = false
			hitvis.CanQuery = false
			hitvis.Shape = Enum.PartType.Ball
			hitvis.Color = Color3.new(1, 1, 1)
			hitvis.Size = Vector3.one * radius * 2
			hitvis.CFrame = CFrame.new(position)
			hitvis.Parent = workspace
			Debris:AddItem(hitvis, 1)
		end
		local hithrp = {}
		local parts = workspace:GetPartBoundsInRadius(position, radius)
		for _,part in parts do
			if part.Parent then
				local hum2 = part.Parent:FindFirstChildOfClass("Humanoid")
				if hum2 and hum2.RootPart and not hum2.RootPart:IsGrounded() then
					if hum2 == hum then continue end
					if hum2.Parent == Player.Character then continue end
					hithrp[hum2.RootPart] = true
					if ReanimateFling(hum2.Parent) then
						if math.random() < 0.1 then
							notify(hum2.Parent.Name .. " just tried to mess with my remotes.")
						end
					end
				end
			end
		end
		if ispunch then
			for root,exist in hithrp do
				if exist then
					CreateSound(root, 386946017, 0.8 + math.random() * 0.4)
					MagicCircle("Alder", root.Position, Vector3.one, Vector3.one, 0.05)
				end
			end
		end
	end
	local function PunchingPart(part, duration)
		if not root or not hum or not torso then return end
		local rootu = root
		local e = os.clock() + duration
		local old = part.CFrame.Position
		while os.clock() < e do
			task.wait()
			if not rootu:IsDescendantOf(workspace) then return end
			local new = part.CFrame.Position
			local mag = (old - new).Magnitude
			if mag >= 2 then
				local mid = (old + new) / 2
				local x = CreatePart(0, "Alder", Vector3.new(0.2, mag, 0.2))
				x.CFrame = CFrame.lookAt(mid, new) * CFrame.Angles(math.pi / 2, 0, 0)
				Instance.new("BlockMesh", x).Scale = Vector3.new(1, 1, 1)
				local m = Instance.new("CylinderMesh", x)
				m.Scale = Vector3.new(20 * scale, 1, 20 * scale)
				old = new
				task.spawn(function()
					local dur = 0.16
					local s = os.clock()
					while true do
						task.wait()
						if os.clock() > s + dur then break end
						local a = (os.clock() - s) / dur
						x.Transparency = a
						local b = 1 - a * a
						m.Scale = Vector3.new(20 * scale * b, 1, 20 * scale * b)
					end
					x:Destroy()
				end)
			end
			Attack(new, 3 * scale, true)
		end
	end
	local function AttackOne()
		if attacking and not m.NoCooldown then return end
		if not root or not hum or not torso then return end
		if isdancing then return end
		local rootu = root
		attacking = true
		local typ = statem1
		statem1 = (statem1 + 1) % 3
		randomdialog({
			"Rah!", "Wah!", "Yah!", "Ha!", "Ho!",
		})
		task.spawn(function()
			if typ == 0 then
				task.spawn(PunchingPart, insts.ClawLPart, 0.36)
				animationOverride = function(timingsine, rt, nt, rst, lst, rht, lht, drhead, drleft, drrite)
					rt = ROOTC0 * CFrame.Angles(math.rad(-5), 0, 0)
					nt = NECKC0 * CFrame.Angles(math.rad(5), 0, math.rad(10))
					rst = CFrame.new(1, 0.5, -0.5) * CFrame.Angles(0.5, 1.8, 1.5)
					lst = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(math.rad(2), math.rad(25), math.rad(-15))
					drhead = CFrame.new(0, 6, 7) * CFrame.Angles(math.rad(-5), 0, 0)
					drleft = CFrame.new(-3, 1, 2) * CFrame.Angles(math.rad(90), 0, 0)
					drrite = CFrame.identity
					return rt, nt, rst, lst, rht, lht, drhead, drleft, drrite
				end
				task.wait(0.2)
				if not rootu:IsDescendantOf(workspace) then return end
				CreateSound(231917758)
				CreateSound(159972643)
				animationOverride = function(timingsine, rt, nt, rst, lst, rht, lht, drhead, drleft, drrite)
					rt = ROOTC0 * CFrame.Angles(math.rad(10), 0, math.rad(20))
					nt = NECKC0 * CFrame.Angles(0, 0, math.rad(-20))
					rst = CFrame.new(1, 0.5, -0.5) * CFrame.Angles(80, 1.8, 1.5)
					lst = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(math.rad(2), math.rad(25), math.rad(-15))
					drhead = CFrame.new(0, 6, 7) * CFrame.Angles(math.rad(-5), 0, 0)
					drleft = CFrame.new(-4, 1, -8) * CFrame.Angles(math.rad(-85), 0, 0)
					drrite = CFrame.identity
					return rt, nt, rst, lst, rht, lht, drhead, drleft, drrite
				end
				task.wait(0.16)
			end
			if typ == 1 then
				task.spawn(PunchingPart, insts.ClawRPart, 0.36)
				animationOverride = function(timingsine, rt, nt, rst, lst, rht, lht, drhead, drleft, drrite)
					rt = ROOTC0 * CFrame.Angles(0, 0, math.rad(20))
					nt = NECKC0 * CFrame.Angles(0, 0, math.rad(-20))
					rst = CFrame.new(1, 0.5, -0.5) * CFrame.Angles(math.rad(-2), math.rad(-25), math.rad(15))
					lst = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(-30, 0, -20)
					drhead = CFrame.new(0, 6, 7) * CFrame.Angles(math.rad(-5), 0, 0)
					drleft = CFrame.identity
					drrite = CFrame.new(-5, 1, -5) * CFrame.Angles(0, 0, math.rad(20))
					return rt, nt, rst, lst, rht, lht, drhead, drleft, drrite
				end
				task.wait(0.2)
				if not rootu:IsDescendantOf(workspace) then return end
				CreateSound(231917758)
				CreateSound(159972627)
				animationOverride = function(timingsine, rt, nt, rst, lst, rht, lht, drhead, drleft, drrite)
					rt = ROOTC0 * CFrame.Angles(0, 0, math.rad(-20))
					nt = NECKC0 * CFrame.Angles(0, 0, math.rad(20))
					rst = CFrame.new(1, 0.5, -0.5) * CFrame.Angles(math.rad(-2), math.rad(-25), math.rad(15))
					lst = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(-30, 0, 20)
					drhead = CFrame.new(0, 6, 7) * CFrame.Angles(math.rad(-5), 0, 0)
					drleft = CFrame.identity
					drrite = CFrame.new(10, 1, -5) * CFrame.Angles(0, math.rad(-80), math.rad(20))
					return rt, nt, rst, lst, rht, lht, drhead, drleft, drrite
				end
				task.wait(0.16)
			end
			if typ == 2 then
				task.spawn(PunchingPart, insts.ClawLPart, 0.53)
				animationOverride = function(timingsine, rt, nt, rst, lst, rht, lht, drhead, drleft, drrite)
					rt = ROOTC0 * CFrame.Angles(math.rad(10), 0, 0)
					nt = NECKC0
					rst = CFrame.new(1, 0.5, -0.5) * CFrame.Angles(0.5, -1.3, -0.1)
					lst = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(math.rad(2), math.rad(25), math.rad(-15))
					drhead = CFrame.new(0, 6, 7) * CFrame.Angles(math.rad(-5), 0, 0)
					drleft = CFrame.new(3, 7, -1) * CFrame.Angles(math.rad(20), 0, math.rad(-120))
					drrite = CFrame.identity
					return rt, nt, rst, lst, rht, lht, drhead, drleft, drrite
				end
				task.wait(0.2)
				if not rootu:IsDescendantOf(workspace) then return end
				CreateSound(231917758)
				CreateSound(159882477)
				animationOverride = function(timingsine, rt, nt, rst, lst, rht, lht, drhead, drleft, drrite)
					rt = ROOTC0 * CFrame.Angles(math.rad(-5), 0, 0)
					nt = NECKC0 * CFrame.Angles(math.rad(5), 0, 0)
					rst = CFrame.new(1, 0.5, -0.5) * CFrame.Angles(2, -1.3, 0.1)
					lst = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(math.rad(2), math.rad(25), math.rad(-15))
					drhead = CFrame.new(0, 6, 7) * CFrame.Angles(math.rad(-5), 0, 0)
					drleft = CFrame.new(2, 4, -3) * CFrame.Angles(math.rad(120), 0, math.rad(-120))
					drrite = CFrame.identity
					return rt, nt, rst, lst, rht, lht, drhead, drleft, drrite
				end
				task.wait(0.33)
			end
			if not rootu:IsDescendantOf(workspace) then return end
			animationOverride = nil
			attacking = false
			hum.WalkSpeed = 50 * scale
		end)
	end
	local barraging = false
	local function Mudada()
		if barraging then
			barraging = false
		end
		if attacking and not m.NoCooldown then return end
		if not root or not hum or not torso then return end
		if isdancing then return end
		local rootu = root
		attacking = true
		barraging = true
		notify("SUNLIGHTO YELLO OVERDRIVNAM")
		local sound = Instance.new("Sound", root)
		sound.SoundId = "rbxassetid://624164065"
		sound.Volume = 3
		sound.EmitterSize = 100
		sound:Play()
		hum.WalkSpeed = 16 * scale
		task.spawn(function()
			task.spawn(PunchingPart, insts.ClawLPart, 0.2)
			task.spawn(PunchingPart, insts.ClawRPart, 0.2)
			animationOverride = function(timingsine, rt, nt, rst, lst, rht, lht, drhead, drleft, drrite)
				rt = ROOTC0 * CFrame.Angles(math.rad(5), 0, 0)
				nt = NECKC0 * CFrame.Angles(math.rad(20), 0, 0)
				rst = CFrame.new(1.5, 1, 0) * CFrame.Angles(math.rad(90), math.rad(90), 0)
				lst = CFrame.new(-1.5, 1, 0) * CFrame.Angles(math.rad(90), math.rad(-90), 0)
				rht = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				lht = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				drhead = CFrame.new(0, 6, 7) * CFrame.Angles(math.rad(-20), 0, 0)
				drleft = CFrame.new(4, 2, 10)
				drrite = CFrame.new(-4, 2, 10)
				return rt, nt, rst, lst, rht, lht, drhead, drleft, drrite
			end
			task.wait(0.2)
			if not rootu:IsDescendantOf(workspace) then
				barraging = false
				return
			end
			if not barraging then
				animationOverride = nil
				attacking = false
				sound:Destroy()
				return
			end
			local bar = -1
			animationOverride = function(timingsine, rt, nt, rst, lst, rht, lht, drhead, drleft, drrite)
				rt = ROOTC0 * CFrame.Angles(math.rad(5), 0, 0)
				nt = NECKC0 * CFrame.Angles(math.rad(20), 0, 0)
				rst = CFrame.new(1.5, 1, -bar * 2) * CFrame.Angles(math.rad(90), math.rad(90), 0)
				lst = CFrame.new(-1.5, 1, bar * 2) * CFrame.Angles(math.rad(90), math.rad(-90), 0)
				rht = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				lht = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				drhead = CFrame.new(math.random(-5, 5) / 10, math.random(55, 65) / 10, math.random(65, 75) / 10) * CFrame.Angles(math.rad(-20), 0, 0)
				drleft = CFrame.new(math.random(-13, 10), math.random(-4, 8), -bar * 20)
				drrite = CFrame.new(math.random(-10, 13), math.random(-4, 8), bar * 20)
				return rt, nt, rst, lst, rht, lht, drhead, drleft, drrite
			end
			CreateSound(159882584)
			for _=1, 80 do
				task.spawn(PunchingPart, insts.ClawLPart, 0.08)
				task.spawn(PunchingPart, insts.ClawRPart, 0.08)
				CreateSound(231917758)
				task.wait(0.08)
				if not rootu:IsDescendantOf(workspace) then
					barraging = false
					return
				end
				if not barraging then
					animationOverride = nil
					attacking = false
					sound:Destroy()
					return
				end
				bar = -bar
			end
			barraging = false
			animationOverride = nil
			attacking = false
			sound:Destroy()
			hum.WalkSpeed = 50 * scale
		end)
	end
	local function SmashDown()
		if attacking and not m.NoCooldown then return end
		if not root or not hum or not torso then return end
		if isdancing then return end
		local rootu = root
		attacking = true
		randomdialog({
			"Dodge this!", "Watch your step!", "Smash down!", "Sin Dragon smash!",
		})
		hum.WalkSpeed = 0
		task.spawn(function()
			task.spawn(PunchingPart, insts.ClawLPart, 0.41)
			task.spawn(PunchingPart, insts.ClawRPart, 0.41)
			animationOverride = function(timingsine, rt, nt, rst, lst, rht, lht, drhead, drleft, drrite)
				rt = ROOTC0 * CFrame.Angles(math.rad(-5), 0, 0)
				nt = NECKC0 * CFrame.Angles(math.rad(20), 0, 0)
				rst = CFrame.new(1.5, 1, 0) * CFrame.Angles(math.rad(180), 0, 0)
				lst = CFrame.new(-1.5, 1, 0) * CFrame.Angles(math.rad(180), 0, 0)
				rht = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				lht = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				drhead = CFrame.new(0, 6, 7) * CFrame.Angles(math.rad(50), 0, 0)
				drleft = CFrame.new(4, 30, 10) * CFrame.Angles(math.rad(35), 0, math.rad(-90))
				drrite = CFrame.new(-4, 30, 10) * CFrame.Angles(math.rad(35), 0, math.rad(90))
				return rt, nt, rst, lst, rht, lht, drhead, drleft, drrite
			end
			task.wait(0.2)
			if not rootu:IsDescendantOf(workspace) then return end
			CreateSound(231917758)
			CreateSound(159882584)
			animationOverride = function(timingsine, rt, nt, rst, lst, rht, lht, drhead, drleft, drrite)
				rt = ROOTC0 * CFrame.Angles(math.rad(5), 0, 0)
				nt = NECKC0 * CFrame.Angles(math.rad(20), 0, 0)
				rst = CFrame.new(1.5, 1, 0) * CFrame.Angles(math.rad(90), 0, 0)
				lst = CFrame.new(-1.5, 1, 0) * CFrame.Angles(math.rad(90), 0, 0)
				rht = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				lht = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				drhead = CFrame.new(0, 6, 7) * CFrame.Angles(math.rad(-10), 0, 0)
				drleft = CFrame.new(4, 6, -10) * CFrame.Angles(math.rad(-35), 0, math.rad(-90))
				drrite = CFrame.new(-4, 6, -10) * CFrame.Angles(math.rad(-35), 0, math.rad(90))
				return rt, nt, rst, lst, rht, lht, drhead, drleft, drrite
			end
			task.wait(0.2)
			if not rootu:IsDescendantOf(workspace) then return end
			animationOverride = nil
			attacking = false
			hum.WalkSpeed = 50 * scale
			local looky = rootu.CFrame * CFrame.new(Vector3.new(0, -2.5, -10) * scale)
			for i=0, 9 do
				local ref = CreatePart(1, "Alder", Vector3.zero)
				ref.CFrame = looky * CFrame.new(0, 0, -10 * i)
				BlastEffect("White", ref.Position, Vector3.new(1, 0.2, 1), Vector3.new(1, 0, 1))
				BlastEffect("White", ref.Position, Vector3.new(5, 1, 0.5), Vector3.new(0.1, 2, 0.1))
				Attack(ref.Position, 8, true)
				CreateSound(ref, 178452221)
				CreateSound(ref, 192410084)
				Debris:AddItem(ref, 2)
				SetGunauraState(ref.Position)
				task.wait(0.08)
				if not rootu:IsDescendantOf(workspace) then return end
			end
		end)
	end
	local firingmalazar = false
	local function FirinLaser()
		if firingmalazar then
			firingmalazar = false
		end
		if attacking and not m.NoCooldown then return end
		if not root or not hum or not torso then return end
		if isdancing then return end
		local rootu = root
		attacking = true
		firingmalazar = true
		randomdialog({
			"IMMA FIRIN MA LAZAR", "Kame... hame...",
		})
		hum.WalkSpeed = 16
		task.spawn(function()
			animationOverride = function(timingsine, rt, nt, rst, lst, rht, lht, drhead, drleft, drrite)
				rt = ROOTC0
				nt = NECKC0 * CFrame.Angles(math.rad(20), 0, 0)
				rst = CFrame.new(1.2, 0.5, 0.5) * CFrame.Angles(math.rad(80), 0, math.rad(70))
				lst = CFrame.new(-1.2, 0.5, 0.5) * CFrame.Angles(math.rad(80), 0, math.rad(-70))
				rht = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				lht = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				drhead = CFrame.new(0, 6, 7) * CFrame.Angles(math.rad(50), 0, 0)
				drleft = CFrame.new(4, 0, 0) * CFrame.Angles(0, math.rad(-30), 0)
				drrite = CFrame.new(-4, 0, 0) * CFrame.Angles(0, math.rad(30), 0)
				return rt, nt, rst, lst, rht, lht, drhead, drleft, drrite
			end
			task.wait(0.08)
			if not rootu:IsDescendantOf(workspace) then
				firingmalazar = false
				return
			end
			animationinstant = true
			for _=1, 5 do
				local blast = Instance.new("Part")
				blast.Size = Vector3.one
				blast.Color = maincolor
				blast.Material = "Neon"
				blast.Anchored = false
				blast.CanCollide = false
				blast.CanQuery = false
				blast.CanTouch = false
				blast.Transparency = 1
				blast.Name = RandomString()
				local weld = Instance.new("Weld", blast)
				weld.Part0 = insts.HeadPart
				weld.Part1 = blast
				weld.C0 = CFrame.new(-8 * scale, 0, 0)
				weld.C1 = CFrame.fromEulerAnglesXYZ(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
				local m = Instance.new("BlockMesh", blast)
				m.Scale = Vector3.new(6, 6, 6)
				blast.Parent = workspace
				TweenService:Create(blast, TweenInfo.new(0.16, Enum.EasingStyle.Linear), {
					Transparency = 0.2
				}):Play()
				task.spawn(function()
					while firingmalazar do
						weld.C1 *= CFrame.fromEulerAnglesXYZ(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
						task.wait()
					end
					TweenService:Create(blast, TweenInfo.new(0.33, Enum.EasingStyle.Linear), {
						Transparency = 1
					}):Play()
					task.wait(0.33)
					blast:Destroy()
				end)
			end
			local sound = Instance.new("Sound", insts.HeadPart)
			sound.SoundId = "rbxassetid://864314263"
			sound.Volume = 1
			sound.EmitterSize = 100
			sound:Play()
			animationOverride = function(timingsine, rt, nt, rst, lst, rht, lht, drhead, drleft, drrite)
				rt = ROOTC0
				nt = NECKC0 * CFrame.Angles(math.rad(20), 0, 0)
				rst = CFrame.new(1.2, 0.5, 0.5) * CFrame.Angles(math.rad(80), 0, math.rad(70))
				lst = CFrame.new(-1.2, 0.5, 0.5) * CFrame.Angles(math.rad(80), 0, math.rad(-70))
				rht = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				lht = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				drhead = CFrame.new(math.random(-5, 5) / 10, math.random(55, 65) / 10, math.random(65, 75) / 10) * CFrame.Angles(math.rad(50), 0, 0)
				drleft = CFrame.new(4, 0, 0) * CFrame.Angles(0, math.rad(-30), 0)
				drrite = CFrame.new(-4, 0, 0) * CFrame.Angles(0, math.rad(30), 0)
				return rt, nt, rst, lst, rht, lht, drhead, drleft, drrite
			end
			local ticks = os.clock() + m.BlastCharge / 60
			while os.clock() < ticks and firingmalazar do
				if os.clock() > lastfx then
					lastfx = os.clock() + 1 / 600
					MagicRing("Alder", insts.HeadPart.CFrame * Vector3.new(-8 * scale, 0, 0), Vector3.new(20, 20, 2), Vector3.new(-1, -1, 0))
				end
				SetGunauraState(insts.HeadPart.CFrame * Vector3.new(-8 * scale, 0, 0))
				task.wait()
				if not rootu:IsDescendantOf(workspace) then
					firingmalazar = false
					return
				end
			end
			if not firingmalazar then
				animationOverride = nil
				attacking = false
				animationinstant = false
				hum.WalkSpeed = 50 * scale
				TweenService:Create(sound, TweenInfo.new(0.33, Enum.EasingStyle.Linear), {
					Volume = 0
				}):Play()
				Debris:AddItem(sound, 0.33)
				return
			end
			animationOverride = function(timingsine, rt, nt, rst, lst, rht, lht, drhead, drleft, drrite)
				rt = ROOTC0
				nt = NECKC0 * CFrame.Angles(math.rad(20), 0, 0)
				rst = CFrame.new(1.2, 0.5, 0.5) * CFrame.Angles(math.rad(80), 0, math.rad(70))
				lst = CFrame.new(-1.2, 0.5, 0.5) * CFrame.Angles(math.rad(80), 0, math.rad(-70))
				rht = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				lht = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				drhead = CFrame.new(math.random(-1, 1), math.random(5, 7), math.random(6, 8)) * CFrame.Angles(math.rad(-5), 0, 0)
				drleft = CFrame.new(4, 0, 0) * CFrame.Angles(0, math.rad(-30), 0)
				drrite = CFrame.new(-4, 0, 0) * CFrame.Angles(0, math.rad(30), 0)
				return rt, nt, rst, lst, rht, lht, drhead, drleft, drrite
			end
			task.wait(0.08)
			if not rootu:IsDescendantOf(workspace) then
				firingmalazar = false
				return
			end
			sound:Destroy()
			CreateSound(insts.HeadPart, 1906350651, 0.75)
			sound = Instance.new("Sound", insts.HeadPart)
			sound.SoundId = "rbxassetid://122892602795552"
			sound.Looped = true
			sound.Volume = 1
			sound:Play()
			local blast = Instance.new("Part")
			blast.Color = maincolor
			blast.Material = "Neon"
			blast.Anchored = false
			blast.CanCollide = false
			blast.CanQuery = false
			blast.CanTouch = false
			blast.Name = RandomString()
			local mesh = Instance.new("BlockMesh", blast)
			mesh.Scale = Vector3.new(5, 5, 1)
			blast.Parent = workspace
			ticks = os.clock() + m.BlastDuration / 60
			while os.clock() < ticks and firingmalazar do
				local hole = insts.HeadPart.CFrame * Vector3.new(-8 * scale, 0, 0)
				local hit = MouseHit()
				blast.Size = Vector3.new(1, 1, (hit - hole).Magnitude)
				blast.CFrame = CFrame.lookAt((hit + hole) / 2, hit)
				if os.clock() > lastfx then
					lastfx = os.clock() + 1 / 60
					MagicBlock("Alder", hit, Vector3.one, Vector3.one * 6, 0.1)
					Attack(hit, 10, false)
				end
				SetBulletState(insts.HeadPart.CFrame * Vector3.new(-8 * scale, 0, 0), hit)
				SetGunauraState(insts.HeadPart.CFrame * Vector3.new(-8 * scale, 0, 0))
				task.wait()
				if not rootu:IsDescendantOf(workspace) then
					firingmalazar = false
					return
				end
			end
			if firingmalazar then
				firingmalazar = false
			end
			TweenService:Create(sound, TweenInfo.new(0.33, Enum.EasingStyle.Linear), {
				Volume = 0
			}):Play()
			TweenService:Create(blast, TweenInfo.new(0.33, Enum.EasingStyle.Linear), {
				Transparency = 1
			}):Play()
			task.wait(0.33)
			sound:Destroy()
			blast:Destroy()
			animationinstant = false
			animationOverride = nil
			attacking = false
			hum.WalkSpeed = 50 * scale
		end)
	end
	local function RawrX3()
		if attacking and not m.NoCooldown then return end
		if not root or not hum or not torso then return end
		if isdancing then return end
		local rootu = root
		attacking = true
		randomdialog({
			"ROARRRRRRR", "RAAAAHHHHHHHH",
		})
		hum.WalkSpeed = 16
		task.spawn(function()
			animationOverride = function(timingsine, rt, nt, rst, lst, rht, lht, drhead, drleft, drrite)
				rt = ROOTC0
				nt = NECKC0 * CFrame.Angles(math.rad(20), 0, 0)
				rst = CFrame.new(1.2, 0.5, 0.5) * CFrame.Angles(math.rad(80), 0, math.rad(70))
				lst = CFrame.new(-1.2, 0.5, 0.5) * CFrame.Angles(math.rad(80), 0, math.rad(-70))
				rht = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				lht = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				drhead = CFrame.new(0, 6, 7) * CFrame.Angles(math.rad(50), 0, 0)
				drleft = CFrame.new(4, 0, 0) * CFrame.Angles(0, math.rad(-30), 0)
				drrite = CFrame.new(-4, 0, 0) * CFrame.Angles(0, math.rad(30), 0)
				return rt, nt, rst, lst, rht, lht, drhead, drleft, drrite
			end
			task.wait(0.08)
			if not rootu:IsDescendantOf(workspace) then
				return
			end
			animationinstant = true
			animationOverride = function(timingsine, rt, nt, rst, lst, rht, lht, drhead, drleft, drrite)
				rt = ROOTC0
				nt = NECKC0 * CFrame.Angles(math.rad(20), 0, 0)
				rst = CFrame.new(1.2, 0.5, 0.5) * CFrame.Angles(math.rad(80), 0, math.rad(70))
				lst = CFrame.new(-1.2, 0.5, 0.5) * CFrame.Angles(math.rad(80), 0, math.rad(-70))
				rht = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				lht = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				drhead = CFrame.new(math.random(-5, 5) / 10, math.random(55, 65) / 10, math.random(65, 75) / 10) * CFrame.Angles(math.rad(50), 0, 0)
				drleft = CFrame.new(4, 0, 0) * CFrame.Angles(0, math.rad(-30), 0)
				drrite = CFrame.new(-4, 0, 0) * CFrame.Angles(0, math.rad(30), 0)
				return rt, nt, rst, lst, rht, lht, drhead, drleft, drrite
			end
			for _=1, 3 do CreateSound(150829983, 0.9) end
			local ticks = os.clock() + m.RoarDuration / 60
			while os.clock() < ticks do
				if os.clock() > lastfx then
					lastfx = os.clock() + 1 / 60
					BlastEffect("White", root.CFrame * Vector3.new(0, -2 * scale, 0), Vector3.new(1, 0.2, 1), Vector3.new(2, 0, 2))
					Attack(root.Position, 30, false)
				end
				task.wait()
				if not rootu:IsDescendantOf(workspace) then
					return
				end
			end
			animationinstant = false
			animationOverride = nil
			attacking = false
			hum.WalkSpeed = 50 * scale
		end)
	end

	local animator = nil
	m.Init = function(figure)
		start = os.clock()
		attacking = true
		state = 0
		statetime = 0
		if m.SkipIntro then
			state = 3
			attacking = false
		elseif m.AltIntro then
			state = 4
		end
		if m.AltIntro and not m.SkipIntro then
			SetOverrideMovesetMusic("", "Silence", 1)
		else
			SetOverrideMovesetMusic(AssetGetContentId("SinDragonTheme.mp3"), "Radiarc - Chaos Arranged", 1)
		end
		statem1 = 0
		animationinstant = false
		animationOverride = nil
		scale = figure:GetScale()
		hum = figure:FindFirstChild("Humanoid")
		root = figure:FindFirstChild("HumanoidRootPart")
		torso = figure:FindFirstChild("Torso")
		if not hum then return end
		if not root then return end
		if not torso then return end
		randomdialog({
			"I'm not just sinful. I am SIN himself.",
			"Hey big guy, you hungry today? Let's beat up some fresh meat.",
			"Time to commit some sins. Are you ready, buddy?",
		})
		createhatmap(dragonheadm, dragonhead)
		createhatmap(dragonclawlm, dragonclawl)
		createhatmap(dragonclawrm, dragonclawr)
		sethatmaplimbname(dragonhead, "HumanoidRootPart")
		sethatmaplimbname(dragonclawl, "HumanoidRootPart")
		sethatmaplimbname(dragonclawr, "HumanoidRootPart")
		sethatmapcframe(dragonhead, CFrame.new(0, 0, 0))
		sethatmapcframe(dragonclawl, CFrame.new(0, 0, 0))
		sethatmapcframe(dragonclawr, CFrame.new(0, 0, 0))
		bullet = {
			Group = "Bullet",
			CFrame = CFrame.identity
		}
		gunaura = {
			Group = "GunAura",
			CFrame = CFrame.identity
		}
		table.insert(HatReanimator.HatCFrameOverride, bullet)
		table.insert(HatReanimator.HatCFrameOverride, gunaura)
		joints.dh = CFrame.new(0, -16, 0)
		joints.dl = CFrame.new(0, -16, 0)
		joints.dr = CFrame.new(0, -16, 0)
		ContextActionService:BindAction("NAM_SDPunch", function(_, state, _)
			if state == Enum.UserInputState.Begin then
				AttackOne()
			end
		end, true, Enum.UserInputType.MouseButton1)
		ContextActionService:SetTitle("NAM_SDPunch", "M1")
		ContextActionService:SetPosition("NAM_SDPunch", UDim2.new(1, -130, 1, -130))
		ContextActionService:BindAction("NAM_SDMudad", function(_, state, _)
			if state == Enum.UserInputState.Begin then
				Mudada()
			end
		end, true, Enum.KeyCode.Z)
		ContextActionService:SetTitle("NAM_SDMudad", "Z")
		ContextActionService:SetPosition("NAM_SDMudad", UDim2.new(1, -180, 1, -130))
		ContextActionService:BindAction("NAM_SDSmash", function(_, state, _)
			if state == Enum.UserInputState.Begin then
				SmashDown()
			end
		end, true, Enum.KeyCode.X)
		ContextActionService:SetTitle("NAM_SDSmash", "X")
		ContextActionService:SetPosition("NAM_SDSmash", UDim2.new(1, -230, 1, -130))
		ContextActionService:BindAction("NAM_SDLazer", function(_, state, _)
			if state == Enum.UserInputState.Begin then
				FirinLaser()
			end
		end, true, Enum.KeyCode.C)
		ContextActionService:SetTitle("NAM_SDLazer", "C")
		ContextActionService:SetPosition("NAM_SDLazer", UDim2.new(1, -130, 1, -180))
		ContextActionService:BindAction("NAM_SDRawrr", function(_, state, _)
			if state == Enum.UserInputState.Begin then
				RawrX3()
			end
		end, true, Enum.KeyCode.G)
		ContextActionService:SetTitle("NAM_SDRawrr", "G")
		ContextActionService:SetPosition("NAM_SDRawrr", UDim2.new(1, -180, 1, -180))
		if chatconn then
			chatconn:Disconnect()
		end
		chatconn = OnPlayerChatted.Event:Connect(function(plr, msg)
			if plr == Player then
				notify(msg)
			end
		end)
		hum.WalkSpeed = 0
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = false
		animator.speed = 1
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("SinDragonIntro.anim"))

		local function CreateStuffUtil(class, parent, name, properties)
			local o = Instance.new(class)
			for k, v in (properties or {}) do o[k] = v end
			o.Name = name
			o.Parent = parent
			return o
		end

		insts.ClawL = CreateStuffUtil("Model", figure, "sin dragon claw L")
		insts.ClawR = CreateStuffUtil("Model", figure, "sin dragon claw R")
		insts.Head = CreateStuffUtil("Model", figure, "sin dragon head")
		insts.ClawLPart = CreatePart(1, "Really Black", Vector3.new(2, 2, 1))
		insts.ClawLPart.Name = "Handle"
		insts.ClawLPart.Anchored = false
		insts.ClawRPart = CreatePart(1, "Really Black", Vector3.new(2, 2, 1))
		insts.ClawRPart.Name = "Handle"
		insts.ClawRPart.Anchored = false
		insts.HeadPart = CreatePart(1, "Really Black", Vector3.new(1, 3, 3))
		insts.HeadPart.Name = "Handle"
		insts.HeadPart.Anchored = false
		insts.ClawLPart.Parent = insts.ClawL
		insts.ClawRPart.Parent = insts.ClawR
		insts.HeadPart.Parent = insts.Head
		insts.ClawLModel = CreateStuffUtil("Model", figure, "client model")
		insts.ClawRModel = CreateStuffUtil("Model", figure, "client model")
		insts.HeadModel = CreateStuffUtil("Model", figure, "client model")

		local lol = CreateStuffUtil("Part", insts.ClawLModel, "Claw", {BrickColor = BrickColor.new("Really black"), Size = Vector3.new(5, 7, 5), CanCollide = false, Massless = true})
		CreateStuffUtil("SpecialMesh", lol, "Mesh", {Offset = Vector3.new(0, 0, -1), Scale = Vector3.new(25, 25, 25), MeshId = "rbxassetid://92052865", MeshType = Enum.MeshType.FileMesh})
		CreateStuffUtil("Weld", lol, "Weld", {Part0 = lol, Part1 = insts.ClawLPart, C0 = CFrame.new(0, 0, 0, 0, -1, 0, 0, 0, 1, -1, 0, 0), C1 = CFrame.new(0, 0, 3, 1, 0, 0, 0, -1, 0, 0, 0, -1)})
		lol = CreateStuffUtil("Part", insts.ClawRModel, "Claw", {BrickColor = BrickColor.new("Really black"), Size = Vector3.new(5, 7, 5), CanCollide = false, Massless = true})
		CreateStuffUtil("SpecialMesh", lol, "Mesh", {Offset = Vector3.new(0, 0, -1), Scale = Vector3.new(25, 25, 25), MeshId = "rbxassetid://92053026", MeshType = Enum.MeshType.FileMesh})
		CreateStuffUtil("Weld", lol, "Weld", {Part0 = lol, Part1 = insts.ClawRPart, C0 = CFrame.new(0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0), C1 = CFrame.new(0, 0, 3, 1, 0, 0, 0, -1, 0, 0, 0, -1)})
		lol = CreateStuffUtil("Part", insts.HeadModel, "DragonHead", {BrickColor = BrickColor.new("Really black"), Material = Enum.Material.SmoothPlastic, Size = Vector3.new(1, 1, 1), CanCollide = false, Massless = true})
		CreateStuffUtil("SpecialMesh", lol, "Mesh", {Scale = Vector3.new(5, 5, 5), MeshId = "rbxassetid://420164161", MeshType = Enum.MeshType.FileMesh})
		CreateStuffUtil("Weld", lol, "Weld", {Part0 = lol, Part1 = insts.HeadPart, C1 = CFrame.new(-4, 0, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)})
		lol = CreateStuffUtil("Part", insts.HeadModel, "EyePart", {Color = maincolor, Material = Enum.Material.Neon, Size = Vector3.new(1, 1, 1), CanCollide = false, Massless = true})
		CreateStuffUtil("SpecialMesh", lol, "Mesh", {Scale = Vector3.new(1, 1, 2), MeshType = Enum.MeshType.Sphere})
		CreateStuffUtil("Weld", lol, "Weld", {Part0 = lol, Part1 = insts.HeadPart, C1 = CFrame.new(-4, 3, 2.5, 0, 0, 1, 0, 1, 0, -1, 0, 0)})
		lol = CreateStuffUtil("Part", insts.HeadModel, "EyePart", {Color = maincolor, Material = Enum.Material.Neon, Size = Vector3.new(1, 1, 1), CanCollide = false, Massless = true})
		CreateStuffUtil("SpecialMesh", lol, "Mesh", {Scale = Vector3.new(1, 1, 2), MeshType = Enum.MeshType.Sphere})
		CreateStuffUtil("Weld", lol, "Weld", {Part0 = lol, Part1 = insts.HeadPart, C1 = CFrame.new(-4, 3, -2.5, 0, 0, 1, 0, 1, 0, -1, 0, 0)})
		lol = CreateStuffUtil("Part", insts.HeadModel, "EyePartBlack", {BrickColor = BrickColor.new("Really black"), Material = Enum.Material.Neon, Size = Vector3.new(1, 1, 1), CanCollide = false, Massless = true})
		CreateStuffUtil("SpecialMesh", lol, "Mesh", {Scale = Vector3.new(0.9, 0.9, 0.5), MeshType = Enum.MeshType.Sphere})
		CreateStuffUtil("Weld", lol, "Weld", {Part0 = lol, Part1 = insts.HeadPart, C1 = CFrame.new(-4.5, 3, 2.5, 0, 0, 1, 0, 1, 0, -1, 0, 0)})
		lol = CreateStuffUtil("Part", insts.HeadModel, "EyePartBlack", {BrickColor = BrickColor.new("Really black"), Material = Enum.Material.Neon, Size = Vector3.new(1, 1, 1), CanCollide = false, Massless = true})
		CreateStuffUtil("SpecialMesh", lol, "Mesh", {Scale = Vector3.new(0.9, 0.9, 0.5), MeshType = Enum.MeshType.Sphere})
		CreateStuffUtil("Weld", lol, "Weld", {Part0 = lol, Part1 = insts.HeadPart, C1 = CFrame.new(-4.5, 3, -2.5, 0, 0, 1, 0, 1, 0, -1, 0, 0)})

		local smoke = CreateStuffUtil("ParticleEmitter", nil, "Smoke", {
			Color = ColorSequence.new(Color3.new(0.5, 0, 1)),
			Lifetime = NumberRange.new(1),
			Acceleration = Vector3.new(0, 20, 0),
			EmissionDirection = "Front",
			Size = NumberSequence.new(1, 0),
			Speed = NumberRange.new(10),
			LightEmission = 1,
			Rate = 500,
			Rotation = NumberRange.new(0, 360),
			RotSpeed = NumberRange.new(150),
			Texture = "rbxasset://textures/particles/smoke_main.dds",
			Enabled = m.SkipIntro,
		})
		lol = smoke:Clone()
		lol.Parent = insts.ClawLPart
		lol = smoke:Clone()
		lol.Parent = insts.ClawRPart
		lol = smoke
		lol.Parent = insts.HeadPart
		lol.EmissionDirection = "Right"
		lol.Rate = 1000

		insts.ClawL:ScaleTo(scale)
		insts.ClawR:ScaleTo(scale)
		insts.Head:ScaleTo(scale)

		insts.ClawLWeld = CreateStuffUtil("Weld", insts.ClawLPart, "Weld", {Part0 = root, Part1 = insts.ClawLPart, C1 = OFF_DragonClawL + OFF_DragonClawL.Position * (scale - 1)})
		insts.ClawRWeld = CreateStuffUtil("Weld", insts.ClawRPart, "Weld", {Part0 = root, Part1 = insts.ClawRPart, C1 = OFF_DragonClawR + OFF_DragonClawR.Position * (scale - 1)})
		insts.HeadWeld = CreateStuffUtil("Weld", insts.HeadPart, "Weld", {Part0 = root, Part1 = insts.HeadPart, C1 = OFF_DragonHead + OFF_DragonHead.Position * (scale - 1)})

		lol = Instance.new("PointLight", torso)
		lol.Color = maincolor
		lol.Brightness = 5
		lol.Range = 15
		lol.Enabled = false
		lol.Name = "Lighting"

		footsteps = Instance.new("Sound", torso)
		footsteps.SoundId = "rbxassetid://142665235"
		footsteps.Looped = true
		footsteps.Pitch = 1
		footsteps.Volume = 0.4

		-- haha get it
		insts.ImpactFrame = CreateStuffUtil("Frame", HiddenGui, "impact frames", {Position = UDim2.fromScale(0, 0), Size = UDim2.fromOffset(2, 20), BorderSizePixel = 0, Visible = true, ClipsDescendants = true})
		insts.ImpactFrame1 = CreateStuffUtil("ImageLabel", insts.ImpactFrame, "impact frame 1", {BackgroundTransparency = 1, Image = AssetGetContentId("SinDragonImpactFrame1.png"), Visible = true, Size = UDim2.fromScale(1, 0.2), ZIndex = 5})
		insts.ImpactFrame2 = CreateStuffUtil("ImageLabel", insts.ImpactFrame, "impact frame 2", {BackgroundTransparency = 1, Image = AssetGetContentId("SinDragonImpactFrame2.png"), Visible = true, Size = UDim2.fromScale(1, 0.4), ZIndex = 4})
		insts.ImpactFrame3 = CreateStuffUtil("ImageLabel", insts.ImpactFrame, "impact frame 3", {BackgroundTransparency = 1, Image = AssetGetContentId("SinDragonImpactFrame3.png"), Visible = true, Size = UDim2.fromScale(1, 0.6), ZIndex = 3})
		insts.ImpactFrame4 = CreateStuffUtil("ImageLabel", insts.ImpactFrame, "impact frame 4", {BackgroundTransparency = 1, Image = AssetGetContentId("SinDragonImpactFrame4.png"), Visible = true, Size = UDim2.fromScale(1, 0.8), ZIndex = 2})
		insts.ImpactFrame5 = CreateStuffUtil("ImageLabel", insts.ImpactFrame, "impact frame 5", {BackgroundTransparency = 1, Image = AssetGetContentId("SinDragonImpactFrame5.png"), Visible = true, Size = UDim2.fromScale(1, 1), ZIndex = 1})
		insts.ImpactFrame6 = CreateStuffUtil("TextLabel", insts.ImpactFrame, "sin dragon", {BackgroundTransparency = 1, TextScaled = true, Text = "SIN DRAGON", Font = Enum.Font.Antique, TextColor3 = maincolor, Visible = true, Size = UDim2.fromScale(1, 0.3), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ClipsDescendants = true})
	end
	m.Update = function(dt: number, figure: Model)
		local t = os.clock() - start
		scale = figure:GetScale()
		isdancing = not not figure:GetAttribute("IsDancing")
		rcp.FilterDescendantsInstances = {figure, Player.Character}
		
		-- get vii
		hum = figure:FindFirstChild("Humanoid")
		root = figure:FindFirstChild("HumanoidRootPart")
		torso = figure:FindFirstChild("Torso")
		if not hum then return end
		if not root then return end
		if not torso then return end
		
		-- joints
		local rt, nt, rst, lst, rht, lht = CFrame.identity, CFrame.identity, CFrame.identity, CFrame.identity, CFrame.identity, CFrame.identity
		local drhead = CFrame.identity
		local drleft = CFrame.identity
		local drrite = CFrame.identity
		
		local timingsine = t * 60 -- timing from original
		local onground = hum:GetState() == Enum.HumanoidStateType.Running
		
		-- animations
		local animationspeed = 21.4
		if state < 3 then
			attacking = true
			hum.WalkSpeed = 0
			animationspeed = 99999
			rt = ROOTC0
			nt = NECKC0 * CFrame.Angles(math.rad(-20), 0, 0)
			rst = CFrame.new(1.2, 0.5, 0.5) * CFrame.Angles(math.rad(80), 0, math.rad(70))
			lst = CFrame.new(-1.2, 0.5, 0.5) * CFrame.Angles(math.rad(80), 0, math.rad(-70))
			rht = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
			lht = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
			drhead = CFrame.new(0, -16, 0)
			drleft = CFrame.new(0, -16, 0)
			drrite = CFrame.new(0, -16, 0)
			if state == 0 then
				-- calling the dragon
				animationspeed = 21.4
				if timingsine - statetime < 80 then
					rt = ROOTC0
					nt = NECKC0 * CFrame.Angles(math.rad(20), 0, 0)
					rst = CFrame.new(1.4, 0.5, -0.2) * CFrame.Angles(math.rad(20), 0, math.rad(-4))
					lst = CFrame.new(-1.4, 0.5, -0.2) * CFrame.Angles(math.rad(20), 0, math.rad(4))
					rht = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
					lht = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
				end
				if timingsine - statetime > 100 then
					state = 1
					statetime = 100
					CreateSound(136007472)
				end
			end
			if state == 1 then
				-- summoning the dragon
				local o = timingsine - statetime
				if o >= 30 and o <= 60 then
					if os.clock() > lastfx then
						lastfx = os.clock() + 1 / 60
						MagicRing("Alder", root.CFrame * (Vector3.new(0, 9, 7) * scale), Vector3.new(60, 60, 6) * scale, Vector3.new(-3, -3, 0) * scale)
						MagicRing("Alder", root.CFrame * (Vector3.new(-12, 0, 0) * scale), Vector3.new(20, 20, 2) * scale, Vector3.new(-1, -1, 0) * scale)
						MagicRing("Alder", root.CFrame * (Vector3.new(12, 0, 0) * scale), Vector3.new(20, 20, 2) * scale, Vector3.new(-1, -1, 0) * scale)
					end
				end
				if o > 240 then
					state = 2
					statetime = 340
					CreateSound(233096557, 1)
					CreateSound(233091205, 1)
					for _=1, 3 do CreateSound(150829983, 0.9) end
					MagicCircle("Alder", root.CFrame * (Vector3.new(0, 9, 7) * scale), Vector3.new(20, 20, 20) * scale, Vector3.one * scale, 0.01)
					MagicCircle("Alder", root.CFrame * (Vector3.new(-12, 0, 0) * scale), Vector3.new(10, 10, 10) * scale, Vector3.one * scale, 0.01)
					MagicCircle("Alder", root.CFrame * (Vector3.new(12, 0, 0) * scale), Vector3.new(10, 10, 10) * scale, Vector3.one * scale, 0.01)
					torso.Lighting.Enabled = true
					insts.ClawLPart.Smoke.Enabled = true
					insts.ClawRPart.Smoke.Enabled = true
					insts.HeadPart.Smoke.Enabled = true
				end
			end
			if state == 2 then
				-- summon roar
				drhead = CFrame.new(math.random(-5, 5) / 10, math.random(55, 65) / 10, math.random(65, 75) / 10) * CFrame.Angles(math.rad(50), 0, 0)
				drleft = CFrame.new(4, 0, 0) * CFrame.Angles(0, math.rad(-30), 0)
				drrite = CFrame.new(-4, 0, 0) * CFrame.Angles(0, math.rad(30), 0)
				if timingsine - statetime > 300 then
					state = 3
					statetime = timingsine
					attacking = false
				end
			end
		elseif state == 3 then
			-- regular
			if not attacking and not isdancing then
				hum.WalkSpeed = 50 * scale
			end
			if animationinstant then
				animationspeed = 99999
			end
			if onground then
				if root.Velocity.Magnitude > 2 then
					footsteps.Playing = true
					rt = ROOTC0 * CFrame.new(0, 0, 0.1 * math.cos(timingsine / 2.5)) * CFrame.Angles(math.rad(20 + math.cos(timingsine / 2.5)), 0, 0)
					nt = NECKC0 * CFrame.Angles(math.rad(-11.5 + 4.3 * math.cos(timingsine / 2.5)), 0, 0)
					rst = CFrame.new(1.5, 0.5, 0) * CFrame.Angles(math.rad(-40), 0, math.rad(24))
					lst = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(math.rad(-40), 0, math.rad(-24))
					rht = CFrame.new(1, -1 - 0.1 * math.cos(timingsine / 5), -0.5 * math.cos(timingsine / 5)) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(-5), 0, math.rad(70 * math.cos(timingsine / 5)))
					lht = CFrame.new(-1, -1 + 0.1 * math.cos(timingsine / 5), 0.5 * math.cos(timingsine / 5)) * CFrame.Angles(0, math.rad(-90), 0) * CFrame.Angles(math.rad(-5), 0, math.rad(70 * math.cos(timingsine / 5)))
					drhead = CFrame.new(0, 6, 7) * CFrame.Angles(math.rad(-5), 0, 0)
					drleft = CFrame.new(4 - 0.5 * math.cos(timingsine / 30), 0, 0 -0.5 * math.cos(timingsine / 30)) * CFrame.Angles(math.rad(math.cos(timingsine / 30)), math.rad(-60), math.rad(-math.cos(timingsine / 30)))
					drrite  = CFrame.new(-4 + 0.5 * math.cos(timingsine / 36), 0, 0.5 * math.cos(timingsine / 36)) * CFrame.Angles(math.rad(-3 * math.cos(timingsine / 36)), math.rad(60), math.rad(-3 * math.cos(timingsine / 36)))
				else
					footsteps.Playing = false
					local timingsine = timingsine * 0.5
					rt = ROOTC0 * CFrame.Angles(math.rad(6), 0, 0)
					nt = NECKC0 * CFrame.Angles(math.rad(3 + 3 * math.cos(timingsine / 36)), 0, 0)
					rst = CFrame.new(1.5, 0.5, 0) * CFrame.Angles(math.rad(10), 0, math.rad(16 - 6 * math.cos(timingsine / 28)))
					lst = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(math.rad(10), 0, math.rad(-16 + 6 * math.cos(timingsine / 28)))
					rht = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(-5), 0, math.rad(16))
					lht = CFrame.new(-1, -1.1, 0) * CFrame.Angles(0, math.rad(-90), 0) * CFrame.Angles(math.rad(-5), 0, math.rad(24))
					drhead = CFrame.new(-math.cos(timingsine / 40), 6 - 0.5 * math.cos(timingsine / 20), 7) * CFrame.Angles(math.rad(-5 + 5 * math.cos(timingsine / 20)), 0, 0)
					drleft = CFrame.new(4 - math.cos(timingsine / 30), 0, -math.cos(timingsine / 30)) * CFrame.Angles(math.rad(8 * math.cos(timingsine / 30)), 0, math.rad(-8 * math.cos(timingsine / 30)))
					drrite = CFrame.new(-4 + math.cos(timingsine / 36), 0, math.cos(timingsine / 36)) * CFrame.Angles(math.rad(-12 * math.cos(timingsine / 36)), 0, math.rad(-12 * math.cos(timingsine / 36)))
				end
			else
				if root.Velocity.Y > -1 then
					footsteps.Playing = false
					rt = ROOTC0
					nt = NECKC0 * CFrame.Angles(math.rad(-11.5), 0, 0)
					rst = CFrame.new(1.5, 0.5, 0) * CFrame.Angles(math.rad(-14.3), 0, math.rad(28.6))
					lst = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(math.rad(-14.3), 0, math.rad(-28.6))
					rht = CFrame.new(1, -1, -0.75) * CFrame.Angles(math.rad(-28.6), math.rad(90), 0)
					lht = CFrame.new(-1, -1, -0.3) * CFrame.Angles(math.rad(-28.6), math.rad(-90), 0)
					drhead = CFrame.new(-1 * math.cos(timingsine / 40), 6 - 0.5 * math.cos(timingsine / 20), 7) * CFrame.Angles(math.rad(-5 + 5 * math.cos(timingsine / 20)), 0, 0)
					drleft = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(20), math.rad(20), 0)
					drrite = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(20), math.rad(-20), 0)
				else
					footsteps.Playing = false
					rt = ROOTC0
					nt = NECKC0 * CFrame.Angles(math.rad(17.2), 0, 0)
					rst = CFrame.new(1.5, 0.5, 0) * CFrame.Angles(math.rad(5.7), 0, math.rad(57.3))
					lst = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(math.rad(5.7), 0, math.rad(-57.3))
					rht = CFrame.new(1, -1, 0) * CFrame.Angles(math.rad(34.4), math.rad(90), 0)
					lht = CFrame.new(-1, -1, 0) * CFrame.Angles(math.rad(-45.8), math.rad(-90), 0)
					drhead = CFrame.new(-1 * math.cos(timingsine / 40), 6 - 0.5 * math.cos(timingsine / 20), 7)
					drleft = CFrame.new(-4, -1, 0) * CFrame.Angles(math.rad(20), math.rad(-10), 0)
					drrite = CFrame.new(4, -1, 0) * CFrame.Angles(math.rad(20), math.rad(10), 0)
				end
			end
		else
			ReanimCamera.Scriptable = true
			attacking = true
			hum.WalkSpeed = 0
			animationspeed = 99999
			rt = ROOTC0
			nt = NECKC0 * CFrame.Angles(math.rad(-20), 0, 0)
			rst = CFrame.new(1.2, 0.5, 0.5) * CFrame.Angles(math.rad(80), 0, math.rad(70))
			lst = CFrame.new(-1.2, 0.5, 0.5) * CFrame.Angles(math.rad(80), 0, math.rad(-70))
			rht = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
			lht = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0) * CFrame.Angles(math.rad(-2.5), 0, 0)
			drhead = CFrame.new(0, -16, 0)
			drleft = CFrame.new(0, -16, 0)
			drrite = CFrame.new(0, -16, 0)
			local o = timingsine / 60
			if state == 4 and o > 0 then
				state = 5
				CreateSound(99564490958733)
			elseif state == 5 and o > 0.6 then
				state = 6
				CreateSound(9113541700, 0.9 + math.random() * 0.1)
			elseif state == 6 and o > 0.9 then
				state = 7
				CreateSound(121238985608899)
			elseif state == 7 and o > 1.53 then
				state = 8
				CreateSound(9113541700, 0.9 + math.random() * 0.1)
			elseif state == 8 and o > 1.9 then
				state = 9
				CreateSound(132090367979537)
			elseif state == 9 and o > 3.17 then
				state = 10
				CreateSound(137269250717966, 0.8)
			elseif state == 10 and o > 4.5 then
				state = 11
				CreateSound(136007472, 0.8)
			elseif state == 11 and o > 7 + (5 / 24) then
				state = 12
				CreateSound(233096557, 1)
				CreateSound(233091205, 1)
				for _=1, 3 do CreateSound(150829983, 0.9) end
				torso.Lighting.Enabled = true
				insts.ClawLPart.Smoke.Enabled = true
				insts.ClawRPart.Smoke.Enabled = true
				insts.HeadPart.Smoke.Enabled = true
			elseif state == 12 and o > 12.5 then
				state = 13
				SetOverrideMovesetMusic(AssetGetContentId("SinDragonTheme.mp3"), "Radiarc - Chaos Arranged", 1)
			elseif state == 13 and o > 16 then
				state = 3
				statetime = timingsine
				attacking = false
				ReanimCamera.Scriptable = false
			end
			if o < 1.9 then
				local a = TweenService:GetValue(o, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local b = CFrame.Angles(-0.78 * math.cos(timingsine / 30), 0.1 * math.sin(timingsine / 8), 0.3 * math.sin(timingsine / 20))
				ReanimCamera.CFrame = root.CFrame * CFrame.new(0, 0.5, -5) * CFrame.Angles(0, math.pi, 0) * b:Lerp(CFrame.Angles(math.rad(-10), 0, 0), a)
				ReanimCamera.FieldOfView = 70
			elseif o < 4.5 then
				local a = TweenService:GetValue((o - 1.9) / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
				ReanimCamera.CFrame = root.CFrame * (CFrame.new(0, 0.5, -5) * CFrame.Angles(math.rad(10), 0, 0)):Lerp(CFrame.new(0, 5.5, -50), a) * CFrame.Angles(0, math.pi, 0)
				ReanimCamera.FieldOfView = 70
			elseif o < 7 + (5 / 24) then
				local a = TweenService:GetValue((o - 4.5) / 1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				ReanimCamera.CFrame = root.CFrame * CFrame.new(0, 5.5, -50) * CFrame.Angles(0, math.pi, 0)
				ReanimCamera.FieldOfView = 70 - 40 * a
			elseif o < 12 then
				local a = TweenService:GetValue(o - (7 + (5 / 24)), Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				ReanimCamera.CFrame = root.CFrame * CFrame.new(0, 5.5, -50):Lerp(CFrame.new(
					sincosPerlin(sincosseed1, o * 2) * 0.05,
					5.5 + sincosPerlin(sincosseed2, o * 2) * 0.05,
					-20 + sincosPerlin(sincosseed3, o * 2) * 0.05
				) * CFrame.Angles(
					sincosPerlin(sincosseed4, o * 2) * 0.05,
					sincosPerlin(sincosseed5, o * 2) * 0.05,
					0.05 + sincosPerlin(sincosseed6, o * 2) * 0.05
				), a) * CFrame.Angles(0, math.pi, 0)
				ReanimCamera.FieldOfView = 30 + 50 * a
			end
			local if1 = UDim2.fromScale(0, 0)
			local if2 = UDim2.fromScale(1, 1)
			local Camera = workspace.CurrentCamera
			if Camera then
				local top = -insts.ImpactFrame.AbsolutePosition
				local topy = GuiService.TopbarInset.Height
				local hi1 = Camera:WorldToViewportPoint(root.CFrame * Vector3.new(34, 25.5, -4))
				local hi2 = Camera:WorldToViewportPoint(root.CFrame * Vector3.new(-34, -10.5, -4))
				if1 = UDim2.fromOffset(hi1.X + top.X, hi1.Y + top.Y - topy)
				if2 = UDim2.fromOffset(hi2.X + top.X, hi2.Y + top.Y - topy)
			end
			if2 -= if1
			insts.ImpactFrame1.Position, insts.ImpactFrame1.Size = if1, if2
			insts.ImpactFrame2.Position, insts.ImpactFrame2.Size = if1, if2
			insts.ImpactFrame3.Position, insts.ImpactFrame3.Size = if1, if2
			insts.ImpactFrame4.Position, insts.ImpactFrame4.Size = if1, if2
			insts.ImpactFrame5.Position, insts.ImpactFrame5.Size = if1, if2
			if o < 7 then
				insts.ImpactFrame.Size = UDim2.fromOffset(2, 10)
			elseif o < 7 + (1 / 24) then
				insts.ImpactFrame.Size = UDim2.fromScale(1, 1)
				insts.ImpactFrame.Visible = true
				insts.ImpactFrame.BackgroundColor3 = Color3.new(1, 1, 1)
				insts.ImpactFrame1.Visible = true
				insts.ImpactFrame2.Visible = false
				insts.ImpactFrame3.Visible = false
				insts.ImpactFrame4.Visible = false
				insts.ImpactFrame5.Visible = false
				insts.ImpactFrame6.Visible = false
			elseif o < 7 + (2 / 24) then
				insts.ImpactFrame.Size = UDim2.fromScale(1, 1)
				insts.ImpactFrame.Visible = true
				insts.ImpactFrame.BackgroundColor3 = Color3.new(0, 0, 0)
				insts.ImpactFrame1.Visible = false
				insts.ImpactFrame2.Visible = true
				insts.ImpactFrame3.Visible = false
				insts.ImpactFrame4.Visible = false
				insts.ImpactFrame5.Visible = false
				insts.ImpactFrame6.Visible = false
			elseif o < 7 + (3 / 24) then
				insts.ImpactFrame.Size = UDim2.fromScale(1, 1)
				insts.ImpactFrame.Visible = true
				insts.ImpactFrame.BackgroundColor3 = Color3.new(1, 1, 1)
				insts.ImpactFrame1.Visible = false
				insts.ImpactFrame2.Visible = false
				insts.ImpactFrame3.Visible = true
				insts.ImpactFrame4.Visible = false
				insts.ImpactFrame5.Visible = false
				insts.ImpactFrame6.Visible = false
			elseif o < 7 + (4 / 24) then
				insts.ImpactFrame.Size = UDim2.fromScale(1, 1)
				insts.ImpactFrame.Visible = true
				insts.ImpactFrame.BackgroundColor3 = Color3.new(0, 0, 0)
				insts.ImpactFrame1.Visible = false
				insts.ImpactFrame2.Visible = false
				insts.ImpactFrame3.Visible = false
				insts.ImpactFrame4.Visible = true
				insts.ImpactFrame5.Visible = false
				insts.ImpactFrame6.Visible = false
			elseif o < 7 + (5 / 24) then
				insts.ImpactFrame.Size = UDim2.fromScale(1, 1)
				insts.ImpactFrame.Visible = true
				insts.ImpactFrame.BackgroundColor3 = Color3.new(1, 1, 1)
				insts.ImpactFrame1.Visible = false
				insts.ImpactFrame2.Visible = false
				insts.ImpactFrame3.Visible = false
				insts.ImpactFrame4.Visible = false
				insts.ImpactFrame5.Visible = true
				insts.ImpactFrame6.Visible = false
			elseif o < 12 then
				insts.ImpactFrame.Visible = false
			elseif o < 12.5 then
				insts.ImpactFrame.Size = UDim2.fromScale(1, 1)
				insts.ImpactFrame.Visible = true
				insts.ImpactFrame.BackgroundColor3 = Color3.new(0, 0, 0)
				insts.ImpactFrame1.Visible = false
				insts.ImpactFrame2.Visible = false
				insts.ImpactFrame3.Visible = false
				insts.ImpactFrame4.Visible = false
				insts.ImpactFrame5.Visible = false
				insts.ImpactFrame6.Visible = false
			elseif o < 15 then
				insts.ImpactFrame.Size = UDim2.fromScale(1, 1)
				insts.ImpactFrame.Visible = true
				insts.ImpactFrame.BackgroundColor3 = Color3.new(0, 0, 0)
				insts.ImpactFrame1.Visible = false
				insts.ImpactFrame2.Visible = false
				insts.ImpactFrame3.Visible = false
				insts.ImpactFrame4.Visible = false
				insts.ImpactFrame5.Visible = false
				insts.ImpactFrame6.Visible = true
			else
				insts.ImpactFrame.Size = UDim2.fromScale(1, 1)
				insts.ImpactFrame.Visible = o - 15 < 1
				insts.ImpactFrame.BackgroundColor3 = Color3.new(0, 0, 0)
				insts.ImpactFrame.BackgroundTransparency = o - 15
				insts.ImpactFrame1.Visible = false
				insts.ImpactFrame2.Visible = false
				insts.ImpactFrame3.Visible = false
				insts.ImpactFrame4.Visible = false
				insts.ImpactFrame5.Visible = false
				insts.ImpactFrame6.Visible = true
				insts.ImpactFrame6.TextTransparency = o - 15
			end
			if o >= 7.1 then
				drhead = CFrame.new(math.random(-5, 5) / 10, math.random(55, 65) / 10, math.random(65, 75) / 10) * CFrame.Angles(math.rad(50), 0, 0)
				drleft = CFrame.new(4, 0, 0) * CFrame.Angles(0, math.rad(-30), 0)
				drrite = CFrame.new(-4, 0, 0) * CFrame.Angles(0, math.rad(30), 0)
			end
			if o >= 4.5 and o <= 5 then
				if os.clock() > lastfx then
					lastfx = os.clock() + 1 / 60
					MagicRing("Alder", root.CFrame * (Vector3.new(0, 9, 7) * scale), Vector3.new(60, 60, 6) * scale, Vector3.new(-3, -3, 0) * scale)
					MagicRing("Alder", root.CFrame * (Vector3.new(-12, 0, 0) * scale), Vector3.new(20, 20, 2) * scale, Vector3.new(-1, -1, 0) * scale)
					MagicRing("Alder", root.CFrame * (Vector3.new(12, 0, 0) * scale), Vector3.new(20, 20, 2) * scale, Vector3.new(-1, -1, 0) * scale)
				end
			end
			if o >= 7.1 and o <= 12 then
				if os.clock() > lastfx then
					lastfx = os.clock() + 1 / 15
					MagicCircle2("Really black", root.CFrame * (Vector3.new(0, 9, 7) * scale), Vector3.zero, Vector3.one * 5 * scale, 0.03)
					BlastEffect("White", root.CFrame * Vector3.new(0, -2 * scale, 0), Vector3.new(1, 0.2, 1), Vector3.new(2, 0, 2))
				end
			end
			animator:Step(o)
		end
		if animationOverride then
			rt, nt, rst, lst, rht, lht, drhead, drleft, drrite = animationOverride(timingsine, rt, nt, rst, lst, rht, lht, drhead, drleft, drrite)
		end
		
		-- joints
		local rj = root:FindFirstChild("RootJoint")
		local nj = torso:FindFirstChild("Neck")
		local rsj = torso:FindFirstChild("Right Shoulder")
		local lsj = torso:FindFirstChild("Left Shoulder")
		local rhj = torso:FindFirstChild("Right Hip")
		local lhj = torso:FindFirstChild("Left Hip")
		
		-- interpolation
		local alpha = math.exp(-animationspeed * dt)
		joints.r = rt:Lerp(joints.r, alpha)
		joints.n = nt:Lerp(joints.n, alpha)
		joints.rs = rst:Lerp(joints.rs, alpha)
		joints.ls = lst:Lerp(joints.ls, alpha)
		joints.rh = rht:Lerp(joints.rh, alpha)
		joints.lh = lht:Lerp(joints.lh, alpha)
		joints.dh = drhead:Lerp(joints.dh, alpha)
		joints.dl = drleft:Lerp(joints.dl, alpha)
		joints.dr = drrite:Lerp(joints.dr, alpha)
		
		-- dance reactions
		if isdancing then
			local name = figure:GetAttribute("DanceInternalName")
			if name == "RAGDOLL" then
				dancereact.Ragdoll = dancereact.Ragdoll or 0
				if t - dancereact.Ragdoll > 1 then
					randomdialog({
						"HELP ME BIG GUYYYY",
						"WHAATTATTTT THIS ISNT CANONNNNNNNN",
						"TS AINT MEEEE DAWHGGGGG :skull:",
						"BUDDYYYYYYY :sob: HELLEPPPLDLP",
						"AKSJSKKWWSJKSKSKSSKKAKASSKKAKSK",
					}, 1.25)
				end
				dancereact.Ragdoll = t
			elseif name == "ASSUME" then
				dancereact.Assumption = dancereact.Assumption or 0
				if t - dancereact.Assumption > 60 then
					notify("They think they got me? They're all making... assumptions!")
				end
				dancereact.Assumption = t
			elseif name == "KEMUSAN" then
				dancereact.SocialCredits = dancereact.SocialCredits or 0
				if t - dancereact.SocialCredits > 1 then
					task.spawn(function()
						local root = root
						notify("jian qi jiang hu en yuan", 1)
						task.wait(1.7)
						if not root:IsDescendantOf(workspace) then return end
						notify("fu xiu zhao ming yue", 1)
						task.wait(1.7)
						if not root:IsDescendantOf(workspace) then return end
						notify("xi feng ye lua hua xie", 1)
						task.wait(1.7)
						if not root:IsDescendantOf(workspace) then return end
						notify("zhen dao jian nan mian", 1)
						task.wait(1.7)
						if not root:IsDescendantOf(workspace) then return end
						notify("ru wei shan he guo ke", 1)
						task.wait(1.7)
						if not root:IsDescendantOf(workspace) then return end
						notify("que zong chang tan shang li bie", 1)
						task.wait(1.7)
						if not root:IsDescendantOf(workspace) then return end
						notify("bin ru shuang yi bei nong lie", 1)
					end)
				end
				dancereact.SocialCredits = t
			else
				dancereact.any = dancereact.any or 0
				if t - dancereact.any > 1 then
					randomdialog({
						"Watch this, big guy. Match my vibe.",
						"Check out these moves!",
						"I may be sinful, but I am a smooth sinful guy.",
						"They cannot try to copy me.",
					})
				end
				dancereact.any = t
			end
			local rt = rj:GetAttribute("Transform") or CFrame.identity
			local nt = nj:GetAttribute("Transform") or CFrame.identity
			local rst = rsj:GetAttribute("Transform") or CFrame.identity
			local lst = lsj:GetAttribute("Transform") or CFrame.identity
			--local rt = CFrame.identity
			--local nt = CFrame.identity
			--local rst = CFrame.identity
			--local lst = CFrame.identity
			local dscale = 4
			local dtorso = CFrame.new(-math.cos(timingsine / 40), 4 - 0.5 * math.cos(timingsine / 20), 6) * ROOTC0 * (rt + rt.Position * 2) * ROOTC0:Inverse()
			local dhead = dtorso * CFrame.new(0, 2 * dscale, 0) * ROOTC0 * (nt + nt.Position * 2) * ROOTC0:Inverse() * CFrame.new(0, 1 * dscale, 0)
			local dlarm = dtorso * CFrame.new(-2 * dscale, 1 * dscale, 0) * CFrame.Angles(0, -1.57, 0) * (lst + lst.Position * 2) * CFrame.Angles(0, 1.57, 0) * CFrame.new(-1 * dscale, -1 * dscale, 0)
			local drarm = dtorso * CFrame.new(2 * dscale, 1 * dscale, 0) * CFrame.Angles(0, 1.57, 0) * (rst + rst.Position * 2) * CFrame.Angles(0, -1.57, 0) * CFrame.new(1 * dscale, -1 * dscale, 0)
			joints.dh = dhead * CFrame.new(0, 0, 2 * scale) * CFrame.Angles(0, -1.57, 0) * OFF_DragonHead
			joints.dl = dlarm * CFrame.new(3 * scale, -1 * scale, 0) * CFrame.Angles(1.57, 0, 0) * OFF_DragonClawL
			joints.dr = drarm * CFrame.new(-3 * scale, -1 * scale, 0) * CFrame.Angles(1.57, 0, 0) * OFF_DragonClawR
		end
		
		-- apply transforms
		if state <= 3 then
			SetC0C1Joint(rj, joints.r, ROOTC0, scale)
			SetC0C1Joint(nj, joints.n, CFrame.new(0, -0.5, 0) * CFrame.Angles(math.rad(-90), 0, math.rad(180)), scale)
			SetC0C1Joint(rsj, joints.rs, CFrame.new(0, 0.5, 0), scale)
			SetC0C1Joint(lsj, joints.ls, CFrame.new(0, 0.5, 0), scale)
			SetC0C1Joint(rhj, joints.rh, CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), scale)
			SetC0C1Joint(lhj, joints.lh, CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), scale)
		end
		sethatmapcframe(dragonhead, joints.dh)
		sethatmapcframe(dragonclawl, joints.dl)
		sethatmapcframe(dragonclawr, joints.dr)
		insts.HeadWeld.C0 = joints.dh + joints.dh.Position * (scale - 1)
		insts.ClawLWeld.C0 = joints.dl + joints.dl.Position * (scale - 1)
		insts.ClawRWeld.C0 = joints.dr + joints.dr.Position * (scale - 1)

		-- bullet and aura
		if bulletstate[3] < os.clock() - 0.5 then
			bullet.CFrame = root.CFrame + Vector3.new(0, -12 * scale, 0)
		else
			local pos = (os.clock() // 0.05) % 2
			if pos == 0 then
				bullet.CFrame = CFrame.Angles(math.random() * math.pi * 2, math.random() * math.pi * 2, math.random() * math.pi * 2) + bulletstate[1]
			else
				bullet.CFrame = CFrame.Angles(math.random() * math.pi * 2, math.random() * math.pi * 2, math.random() * math.pi * 2) + bulletstate[2]
			end
		end
		if gunaurastate[2] > 0 then
			gunaurastate[2] -= 1
			local angle = (timingsine * 600) % (math.pi * 2)
			gunaura.CFrame = (root.CFrame.Rotation * CFrame.Angles(-math.pi / 2, angle, 0)) + gunaurastate[1]
		else
			gunaura.CFrame = root.CFrame + Vector3.new(0, -12 * scale, 0)
		end
		
		-- client model appearance
		local transp = m.ClientsideDragon and 0 or 1
		for _,v in insts.ClawLModel:GetChildren() do
			if v:IsA("BasePart") then v.Transparency = transp end
		end
		for _,v in insts.ClawRModel:GetChildren() do
			if v:IsA("BasePart") then v.Transparency = transp end
		end
		for _,v in insts.HeadModel:GetChildren() do
			if v:IsA("BasePart") then v.Transparency = transp end
		end
	end
	m.Destroy = function(figure: Model?)
		ContextActionService:UnbindAction("NAM_SDPunch")
		ContextActionService:UnbindAction("NAM_SDMudad")
		ContextActionService:UnbindAction("NAM_SDSmash")
		ContextActionService:UnbindAction("NAM_SDLazer")
		ContextActionService:UnbindAction("NAM_SDRawrr")
		if chatconn then
			chatconn:Disconnect()
			chatconn = nil
		end
		root, torso, hum = nil, nil, nil
		for _,v in insts do v:Destroy() end
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "MOVESET"
	m.Name = "Linked Sword"
	m.InternalName = "SORETROGUY"
	m.Description = "Linked Sword\nM1 - Sword combo only"
	m.Assets = {}

	m.Notifications = true
	m.Sounds = true
	m.NoCooldown = false
	m.IgnoreDancing = false
	m.HitboxDebug = false
	m.Config = function(parent: GuiBase2d)
		Util_CreateSwitch(parent, "Dialog", m.Notifications).Changed:Connect(function(val)
			m.Notifications = val
		end)
		Util_CreateSwitch(parent, "Sounds", m.Sounds).Changed:Connect(function(val)
			m.Sounds = val
		end)
		Util_CreateSwitch(parent, "No Cooldown", m.NoCooldown).Changed:Connect(function(val)
			m.NoCooldown = val
		end)
		Util_CreateSwitch(parent, "Ignore Dancing", m.IgnoreDancing).Changed:Connect(function(val)
			m.IgnoreDancing = val
		end)
		Util_CreateSwitch(parent, "Hitbox Visual", m.HitboxDebug).Changed:Connect(function(val)
			m.HitboxDebug = val
		end)
	end
	m.LoadConfig = function(save: any)
		m.Notifications = not save.Blind
		m.Sounds = not save.Muted
		m.NoCooldown = not not save.NoCooldown
		m.IgnoreDancing = not not save.IgnoreDancing
		m.HitboxDebug = not not save.HitboxDebug
	end
	m.SaveConfig = function()
		return {
			Blind = not m.Notifications,
			Muted = not m.Sounds,
			NoCooldown = m.NoCooldown,
			IgnoreDancing = m.IgnoreDancing,
			HitboxDebug = m.HitboxDebug,
		}
	end

	local start = 0
	local hum, root, torso
	local isdancing = false
	local rcp = RaycastParams.new()
	rcp.FilterType = Enum.RaycastFilterType.Exclude
	rcp.IgnoreWater = true
	local function PhysicsRaycast(origin, direction)
		rcp.RespectCanCollide = true
		return workspace:Raycast(origin, direction, rcp)
	end
	local function ShootRaycast(origin, direction)
		rcp.RespectCanCollide = false
		return workspace:Raycast(origin, direction, rcp)
	end
	local mouse = Player:GetMouse()
	local function CreateSound(id, pitch, extra)
		if not m.Sounds then return end
		if not torso then return end
		local parent = torso
		local volume = extra or 1
		if typeof(id) == "Instance" then
			parent = id
			id, pitch = pitch, extra
			volume = 1
		end
		pitch = pitch or 1
		local sound = Instance.new("Sound")
		sound.Name = tostring(id)
		sound.SoundId = id:find("://") and id or "rbxassetid://" .. id
		sound.Volume = volume
		sound.Pitch = pitch
		sound.Parent = parent
		sound.EmitterSize = 300
		sound:Play()
		sound.Ended:Connect(function()
			sound:Destroy()
		end)
	end
	local function Attack(cf, size)
		if m.HitboxDebug then
			local hitvis = Instance.new("Part")
			hitvis.Name = RandomString() -- built into Uhhhhhh
			hitvis.CastShadow = false
			hitvis.Material = Enum.Material.ForceField
			hitvis.Anchored = true
			hitvis.CanCollide = false
			hitvis.CanTouch = false
			hitvis.CanQuery = false
			hitvis.Shape = Enum.PartType.Block
			hitvis.Color = Color3.new(0, 0, 0)
			hitvis.Size = size
			hitvis.CFrame = cf
			hitvis.Parent = workspace
			Debris:AddItem(hitvis, 1)
		end
		local hashmap = {}
		local parts = workspace:GetPartBoundsInBox(cf, size)
		for _,part in parts do
			if part.Parent then
				local hum = part.Parent:FindFirstChildOfClass("Humanoid")
				if hum and hum.RootPart and not hum.RootPart:IsGrounded() then
					if ReanimateFling(part.Parent) then
						hashmap[hum.RootPart] = true
					end
				end
			end
		end
		local hitstuff = {}
		for k,_ in hashmap do
			table.insert(hitstuff, k)
		end
		return hitstuff
	end
	local function notify(message)
		if not m.Notifications then return end
		if not root or not torso then return end
		local dialog = torso:FindFirstChild("NOTIFICATION")
		if dialog then
			dialog:Destroy()
		end
		dialog = Instance.new("BillboardGui", torso)
		dialog.Size = UDim2.new(50 * scale, 0, 2 * scale, 0)
		dialog.StudsOffset = Vector3.new(0, 5 * scale, 0)
		dialog.Adornee = torso
		dialog.Name = "NOTIFICATION"
		local text = Instance.new("TextLabel", dialog)
		text.BackgroundTransparency = 1
		text.BorderSizePixel = 0
		text.Text = ""
		text.Font = "Cartoon"
		text.TextScaled = true
		text.TextStrokeTransparency = 0
		text.TextStrokeColor3 = Color3.new(0, 0, 0)
		text.Size = UDim2.new(1, 0, 1, 0)
		text.ZIndex = 0
		text.TextColor3 = Color3.new(1, 1, 1)
		task.spawn(function()
			local cps = 20
			local t = os.clock()
			local ll = 0
			repeat
				task.wait()
				local l = math.floor((os.clock() - t) * cps)
				if l > ll then
					ll = l
					if math.random(3) == 1 then
						CreateSound("rbxasset://sounds/plasticplastic.ogg")
					else
						CreateSound("rbxasset://sounds/plasticplastic" .. math.random(2, 3) .. ".ogg")
					end
				end
				text.Text = string.sub(message, 1, l)
			until ll >= #message or dialog.Parent ~= torso
			text.Text = message
			t = os.clock()
			repeat
				task.wait()
			until os.clock() - t > 2
			t = os.clock()
			repeat
				task.wait()
				local a = os.clock() - t
				text.TextTransparency = a
				text.TextStrokeTransparency = a
			until os.clock() - t > 1
			dialog:Destroy()
		end)
	end
	local function randomdialog(arr)
		notify(arr[math.random(1, #arr)])
	end
	local chatconn
	local joints = {
		r = CFrame.identity,
		n = CFrame.identity,
		rs = CFrame.identity,
		ls = CFrame.identity,
		rh = CFrame.identity,
		lh = CFrame.identity,
		sw = CFrame.identity,
	}
	local sword = {}
	local attacking = false
	local timingsine = 0
	local animationOverride = nil
	local swordoff = CFrame.new(0, 1, 0) * CFrame.Angles(0, math.rad(90), 0)
	local lerps = {
		idle = function(timingsine, rt, nt, rst, lst, rht, lht)
			rt = CFrame.new(-0.014, 0.023, 0.020, 0.866, 0, -0.5, 0, 1, 0, 0.5, 0, 0.866) * CFrame.new(0, 0.05 * math.cos(timingsine / 25), 0)
			nt = CFrame.new(0, 1.499, 0, 0.886, 0, 0.462, 0, 1, 0, -0.462, 0, 0.886) * CFrame.Angles(0.08 * math.cos(timingsine / 25), 0, 0)
			rst = CFrame.new(1.7, 0.169, 0.31, 0.827, -0.251, -0.501, 0.215, 0.967, -0.13, 0.517, 0, 0.855) * CFrame.Angles(math.rad(2 * math.cos(timingsine / 25)), 0, 0)
			lst = CFrame.new(-1.619, 0.059, 0, 0.981, 0.191, 0, -0.191, 0.981, 0, 0, 0, 1) * CFrame.Angles(0, 0, math.rad(-2 * math.cos(timingsine / 25)))
			rht = CFrame.new(0.649, -1.999, 0, 0.989, -0.143, 0, 0.143, 0.989, 0, 0, 0, 1) * CFrame.new(0, -0.08 * math.cos(timingsine / 25), 0) * CFrame.Angles(0, 0, 0.01 * math.cos(timingsine / 25))
			lht = CFrame.new(-0.5, -2, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.new(0, -0.08 * math.cos(timingsine / 25), 0)
			return rt, nt, rst, lst, rht, lht, 16
		end,
		walk = function(timingsine, rt, nt, rst, lst, rht, lht)
			rt = CFrame.new(-0.014, 0.023, 0.020, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.Angles(-0.2, math.rad(-10 * math.cos(timingsine / 6)/2), 0)
			nt = CFrame.new(0, 1.499, 0, 0.999, 0, -0.042, 0, 1, 0, 0.042, 0, 0.999)
			rst = CFrame.new(1.668, 0.125, 0.167, 0.975, -0.217, -0.034, 0.22, 0.967, 0.121, 0.006, -0.125, 0.992) * CFrame.new(0, 0, 0.2 * math.cos(timingsine / 6)/2) * CFrame.Angles(math.rad(-30 * math.cos(timingsine / 6)/2), 0, 0)
			lst = CFrame.new(-1.589, 0.026, -0.146, 0.986, 0.166, -0.008, -0.166, 0.981, -0.095, -0.008, 0.095, 0.995) * CFrame.new(0, 0, -0.3 * math.cos(timingsine / 6)/2) * CFrame.Angles(math.rad(30 * math.cos(timingsine / 6)/2), 0, 0)
			rht = CFrame.new(0.5, -1.64 - 0.8 * math.cos(timingsine / 6) / 2, 2 * math.sin(timingsine / 6) / 3) * CFrame.Angles(math.rad(-50 * math.sin(timingsine / 6)), math.rad(-3), 0)
			lht = CFrame.new(-0.5, -1.64 + 0.8 * math.cos(timingsine / 6) / 2, - 2 * math.sin(timingsine / 6) / 3) * CFrame.Angles(math.rad(50 * math.sin(timingsine / 6)), math.rad(3), 0)
			return rt, nt, rst, lst, rht, lht, 16
		end,
		jump = function(timingsine, rt, nt, rst, lst, rht, lht)
			rt = CFrame.new(-0.014, 0.023, 0.020, 1, 0, 0, 0, 0.965, 0.258, 0, -0.258, 0.965)
			nt = CFrame.new(0.017, 1.545, -0.003, 0.999, 0.007, -0.042, -0.011, 0.996, -0.086, 0.041, 0.087, 0.995)
			rst = CFrame.new(1.54, 0.254, -0.521, 0.89, -0.152, -0.429, -0.327, 0.44, -0.835, 0.317, 0.884, 0.341)
			lst = CFrame.new(-1.557, 0.112, 0.343, 0.986, 0.113, 0.122, -0.158, 0.861, 0.481, -0.050, -0.494, 0.867)
			rht = CFrame.new(0.566, -1.597, -0.481, 0.999, -0.038, -0.009, 0.039, 0.943, 0.328, -0.003, -0.328, 0.944)
			lht = CFrame.new(-0.433, -1.959, 0.005, 1, 0, 0, 0, 0.965, 0.258, 0, -0.258, 0.965)
			return rt, nt, rst, lst, rht, lht, 16
		end,
		fall = function(timingsine, rt, nt, rst, lst, rht, lht)
			rt = CFrame.new(-0.014, 0.023, 0.020, 1, 0, 0, 0, 0.984, 0.173, 0, -0.173, 0.984)
			nt = CFrame.new(0.015, 1.552, -0.091, 0.999, 0.018, -0.038, -0.007, 0.965, 0.258, 0.042, -0.258, 0.965)
			rst = CFrame.new(1.44, 0.051, -0.418, 0.89, -0.076, -0.449, -0.298, 0.647, -0.701, 0.344, 0.758, 0.553)
			lst = CFrame.new(-1.557, 0.141, 0.332, 0.986, 0.113, 0.122, -0.162, 0.815, 0.555, -0.036, -0.567, 0.822)
			rht = CFrame.new(0.573, -1.805, -0.374, 0.999, -0.037, 0.013, 0.039, 0.981, -0.187, -0.006, 0.188, 0.982)
			lht = CFrame.new(-0.433, -1.951, 0.175, 1, 0, 0, 0, 0.984, 0.173, 0, -0.173, 0.984)
			return rt, nt, rst, lst, rht, lht, 16
		end,
		sword1 = function(timingsine, rt, nt, rst, lst, rht, lht)
			rt = CFrame.new(-0.014, 0.023, 0.020, 0, 0, 1, 0, 1, 0, -1, 0, 0)
			nt = CFrame.new(0, 1.499, 0, 0.462, 0, -0.886, 0, 1, 0, 0.886, 0, 0.462)
			rst = CFrame.new(1.599, 0.488, -0.46, 0.695, -0.716, 0.044, 0.047, -0.016, -0.998, 0.716, 0.696, 0.022)
			lst = CFrame.new(-1.804, 0.308, 0.006, 0.864, 0.492, 0.101, -0.498, 0.865, 0.047, -0.064, -0.091, 0.993)
			rht = CFrame.new(0.45, -1.874, 0.242, 0.938, 0.182, -0.292, -0.024, 0.881, 0.471, 0.343, -0.434, 0.832)
			lht = CFrame.new(-0.463, -2, -0.403, 0.766, 0, -0.642, 0, 1, 0, 0.642, 0, 0.766)
			return rt, nt, rst, lst, rht, lht, 16
		end,
		sword2 = function(timingsine, rt, nt, rst, lst, rht, lht)
			rt = CFrame.new(-0.014, 0.023, 0.020, 0, 0, 1, 0, 1, 0, -1, 0, 0)
			nt = CFrame.new(0, 1.499, 0, 0.462, 0, -0.886, 0, 1, 0, 0.886, 0, 0.462)
			rst = CFrame.new(1.599, 0.488, -0.46, 0.695, -0.716, 0.044, 0.047, -0.016, -0.998, 0.716, 0.696, 0.022)
			lst = CFrame.new(-1.804, 0.308, 0.006, 0.864, 0.492, 0.101, -0.498, 0.865, 0.047, -0.064, -0.091, 0.993)
			rht = CFrame.new(0.45, -1.874, 0.242, 0.938, 0.182, -0.292, -0.024, 0.881, 0.471, 0.343, -0.434, 0.832)
			lht = CFrame.new(-0.463, -2, -0.403, 0.766, 0, -0.642, 0, 1, 0, 0.642, 0, 0.766)
			return rt, nt, rst, lst, rht, lht, 16
		end,
		sword3 = function(timingsine, rt, nt, rst, lst, rht, lht)
			rt = CFrame.new(0.199, 0, -0.062, 0.5, 0, 0.866, 0, 1, 0, -0.866, 0, 0.5)
			nt = CFrame.new(0, 1.499, 0, 0.866, 0, -0.499, 0, 1, 0, 0.499, 0, 0.866)
			rst = CFrame.new(0.93, 0.25, -1.281, -0.038, 0.569, -0.821, -0.998, 0.006, 0.051, 0.034, 0.822, 0.568)
			lst = CFrame.new(-1.602, 0.027, -0.076, 0.014, 0.129, 0.991, 0.224, 0.965, -0.129, -0.974, 0.224, -0.014)
			rht = CFrame.new(0.624, -1.999, -0.012, 0.707, 0, -0.707, 0, 1, 0, 0.707, 0, 0.707)
			lht = CFrame.new(-0.482, -1.999, -0.129, 0.707, 0, 0.707, 0, 1, 0, -0.707, 0, 0.707)
			return rt, nt, rst, lst, rht, lht, 16
		end,
		sword4 = function(timingsine, rt, nt, rst, lst, rht, lht)
			rt = CFrame.new(0.366, 0, -0.414, 0.258, 0, 0.965, 0, 1, 0, -0.965, 0, 0.258)
			nt = CFrame.new(0, 1.499, 0, 0.342, 0, -0.939, 0, 1, 0, 0.939, 0, 0.342)
			rst = CFrame.new(0.055, 1.357, -1.17, 0.785, 0.559, 0.265, 0.545, -0.827, 0.13, 0.293, 0.042, -0.955)
			lst = CFrame.new(-1.602, 0.027, -0.076, 0.014, 0.129, 0.991, 0.224, 0.965, -0.129, -0.974, 0.224, -0.014)
			rht = CFrame.new(0.624, -1.999, -0.012, 0.707, 0, -0.707, 0, 1, 0, 0.707, 0, 0.707)
			lht = CFrame.new(-0.482, -1.999, -0.129, 0.707, 0, 0.707, 0, 1, 0, -0.707, 0, 0.707)
			return rt, nt, rst, lst, rht, lht, 16
		end,
		sword5 = function(timingsine, rt, nt, rst, lst, rht, lht)
			rt = CFrame.new(0.366, -0.2, -0.414, 0.582, 0.271, 0.766, -0.422, 0.906, 0, -0.694, -0.323, 0.642)
			nt = CFrame.new(-0.231, 1.547, -0.051, 0.851, -0.422, -0.309, 0.397, 0.906, -0.144, 0.342, 0, 0.939)
			rst = CFrame.new(-0.090, 1.165, -1.088, -0.077, 0.583, 0.808, 0.727, -0.521, 0.446, 0.681, 0.622, -0.384)
			lst = CFrame.new(-1.612, 0.036, 0.314, -0.455, 0.169, 0.873, 0.034, 0.984, -0.172, -0.889, -0.048, -0.454)
			rht = CFrame.new(1.211, -1.348, -0.183, 0.851, -0.252, -0.459, 0.397, 0.882, 0.252, 0.342, -0.397, 0.851)
			lht = CFrame.new(0.058, -1.958, 0.369, 0.64, -0.422, 0.64, 0.298, 0.906, 0.298, -0.707, 0, 0.707)
			return rt, nt, rst, lst, rht, lht, 16
		end,
		sword6 = function(timingsine, rt, nt, rst, lst, rht, lht)
			rt = CFrame.new(0.366, -1.199, -0.414, 0.582, -0.412, 0.7, -0.422, 0.582, 0.694, -0.694, -0.7, 0.165)
			nt = CFrame.new(0.112, 1.566, 0.254, 0.577, 0.099, -0.81, -0.213, 0.976, -0.031, 0.787, 0.191, 0.585)
			rst = CFrame.new(1.968, 0.746, -0.185, 0.076, -0.997, 0.006, 0.879, 0.064, -0.47, 0.469, 0.041, 0.882)
			lst = CFrame.new(-1.881, 0.136, 0.177, -0.455, 0.778, 0.432, 0.703, 0.612, -0.36, -0.545, 0.139, -0.826)
			rht = CFrame.new(0.901, -1.146, -0.653, 0.851, 0.19, -0.488, -0.006, 0.935, 0.352, 0.524, -0.296, 0.798)
			lht = CFrame.new(-0.83, -2.071, -0.233, 0.784, 0.075, -0.615, -0.147, 0.986, -0.067, 0.601, 0.143, 0.785)
			return rt, nt, rst, lst, rht, lht, 16
		end,
		sword7 = function(timingsine, rt, nt, rst, lst, rht, lht)
			rt = CFrame.new(-0.014, 0.023, 0.020, 0.573, 0, -0.819, 0, 1, 0, 0.819, 0, 0.573)
			nt = CFrame.new(0, 1.499, 0, 0.608, -0.069, 0.79, 0, 0.996, 0.087, -0.793, -0.052, 0.605)
			rst = CFrame.new(2.056, 0.769, 0.067, -0.311, -0.945, -0.092, 0.945, -0.298, -0.13, 0.095, -0.128, 0.987)
			lst = CFrame.new(-0.411, 0.158, -0.878, 0.25, -0.87, 0.422, 0.96, 0.276, 0, -0.116, 0.406, 0.906)
			rht = CFrame.new(0.657, -1.999, -0.128, 0.896, -0.092, 0.432, 0.143, 0.985, -0.086, -0.418, 0.139, 0.897)
			lht = CFrame.new(-0.494, -2.064, 0.151, 0.924, -0.032, 0.38, -0.003, 0.995, 0.093, -0.381, -0.087, 0.92)
			return rt, nt, rst, lst, rht, lht, 16
		end,
		sword8 = function(timingsine, rt, nt, rst, lst, rht, lht)
			rt = CFrame.new(-0.014, 0.023, 0.020, 0.642, 0, 0.766, 0, 1, 0, -0.766, 0, 0.642)
			nt = CFrame.new(0, 1.499, 0, 0.609, 0, -0.792, 0, 1, 0, 0.792, 0, 0.609)
			rst = CFrame.new(1.735, 0.521, -0.798, 0.809, -0.584, 0.048, 0.032, -0.038, -0.998, 0.585, 0.81, -0.011)
			lst = CFrame.new(-1.859, 0.325, -0.117, 0.896, 0.442, 0.032, -0.407, 0.849, -0.333, -0.175, 0.285, 0.942)
			rht = CFrame.new(0.425, -2.070, 0.092, 0.94, -0.024, 0.34, -0.024, 0.989, 0.141, -0.34, -0.141, 0.929)
			lht = CFrame.new(-0.614, -2, -0.011, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			return rt, nt, rst, lst, rht, lht, 16
		end,

	}
	local function CreatePart(cf, size, color, material, transp, reflec)
		local rng = Instance.new("Part", workspace)
		rng.Anchored = true
		rng.CanCollide = false
		rng.CanTouch = false
		rng.CanQuery = false
		rng.CastShadow = false
		rng.Name = RandomString()
		rng.Material = material or "Neon"
		rng.Color = color or Color3.new(1, 0, 0)
		rng.Size = size
		rng.Transparency = transp or 0
		rng.Reflectance = reflec or 0
		rng.TopSurface = 0
		rng.BottomSurface = 0
		rng.CFrame = cf
		return rng
	end
	local function MagicSphere(size, ticks, cf, color, grow, move, transp)
		grow = grow or Vector3.zero
		move = move or Vector3.zero
		transp = transp or 0
		local part = CreatePart(cf, Vector3.one, color, nil, transp)
		local mesh = Instance.new("SpecialMesh", part)
		mesh.MeshType = "Sphere"
		mesh.Scale = size
		mesh.Offset = Vector3.zero
		task.spawn(function()
			local elapsed = 0
			local lifetime = ticks / 60
			while elapsed < lifetime do
				local dt = task.wait()
				elapsed += dt
				mesh.Scale = size + grow * elapsed * 60
				mesh.Offset = move * elapsed * 60
				part.Transparency = (1 - transp) * (elapsed / lifetime) + transp
			end
			part:Destroy()
		end)
		return part
	end
	local function SliceEffect(targets)
		for _,v in targets do
			CreateSound(v, "851453784")
			for _=1, 5 do
				MagicSphere(Vector3.new(1, 0, 0.1), 10, v.CFrame * CFrame.Angles(math.random() * math.pi * 2, math.random() * math.pi * 2, math.random() * math.pi * 2), Color3.new(1, 1, 1), Vector3.new(2, 0.01, 0.1))
			end
		end
	end
	local function MeleeHitbox(part, dur, cf, size)
		task.spawn(function()
			local s = os.clock()
			repeat task.wait()
				SliceEffect(Attack(part.CFrame * cf, size))
			until os.clock() - s > dur
		end)
	end
	local function CreateForce(part, vel, dur)
		task.spawn(function()
			local s = os.clock()
			repeat
				local dt = task.wait()
				part.Position += vel * dt
			until os.clock() - s > dur
		end)
	end
	local LinkedSword_index = 0
	local function LinkedSword()
		if not m.IgnoreDancing then
			if isdancing then return end
		end
		if attacking and not m.NoCooldown then return end
		if not root or not hum or not torso then return end
		local rootu = root
		attacking = true
		local lol = LinkedSword_index
		LinkedSword_index = (LinkedSword_index + 1) % 3
		task.spawn(function()
			if lol == 0 then
				CreateSound("12222216", 1, 2)
				animationOverride = lerps.sword1
				task.wait(0.16)
				if not rootu:IsDescendantOf(workspace) then
					animationOverride = nil
					attacking = false
					return
				end
				MeleeHitbox(rootu, 0.08, CFrame.new(1 * scale, 0, -3 * scale), Vector3.new(7, 5, 6) * scale)
				animationOverride = lerps.sword2
				swordoff = CFrame.new(0.5, 0.5, 0) * CFrame.Angles(math.rad(-5), 0, math.rad(-90))
				task.wait(0.08)
				if not rootu:IsDescendantOf(workspace) then
					animationOverride = nil
					attacking = false
					return
				end
				swordoff = CFrame.new(0, 0.5, 0) * CFrame.Angles(0, math.rad(30), 0)
				task.wait(0.08)
				if not rootu:IsDescendantOf(workspace) then
					animationOverride = nil
					attacking = false
					return
				end
			end
			if lol == 1 then
				CreateSound("12222216", 1, 2)
				animationOverride = lerps.sword3
				task.wait(0.08)
				if not rootu:IsDescendantOf(workspace) then
					animationOverride = nil
					attacking = false
					return
				end
				animationOverride = lerps.sword4
				task.wait(0.08)
				if not rootu:IsDescendantOf(workspace) then
					animationOverride = nil
					attacking = false
					return
				end
				MeleeHitbox(rootu, 0.08, CFrame.new(-1 * scale, 0, -3 * scale), Vector3.new(7, 5, 6) * scale)
				animationOverride = lerps.sword5
				task.wait(0.08)
				if not rootu:IsDescendantOf(workspace) then
					animationOverride = nil
					attacking = false
					return
				end
				animationOverride = lerps.sword6
				task.wait(0.08)
				if not rootu:IsDescendantOf(workspace) then
					animationOverride = nil
					attacking = false
					return
				end
			end
			if lol == 2 then
				animationOverride = lerps.sword7
				task.wait(0.16)
				if not rootu:IsDescendantOf(workspace) then
					animationOverride = nil
					attacking = false
					return
				end
				CreateSound("12222208", 1, 2)
				MeleeHitbox(rootu, 0.2, CFrame.new(0, 0, -4 * scale), Vector3.new(5, 5, 8) * scale)
				CreateForce(rootu, rootu.CFrame.LookVector * 24, 0.2)
				animationOverride = lerps.sword8
				swordoff = CFrame.new(0.5, 0.5, 0) * CFrame.Angles(math.rad(-5), 0, math.rad(-90))
				task.wait(0.2)
				if not rootu:IsDescendantOf(workspace) then
					animationOverride = nil
					attacking = false
					return
				end
			end
			animationOverride = nil
			attacking = false
		end)
	end
	m.Init = function(figure)
		start = os.clock()
		timingsine = 0
		attacking = false
		freezemove = false
		animationOverride = nil
		hum = figure:FindFirstChild("Humanoid")
		root = figure:FindFirstChild("HumanoidRootPart")
		torso = figure:FindFirstChild("Torso")
		if not hum then return end
		if not root then return end
		if not torso then return end
		sword = {
			Group = "Sword",
			Limb = "Right Arm",
			Offset = CFrame.identity
		}
		table.insert(HatReanimator.HatCFrameOverride, sword)
		-- Use the first accessory actually worn on the back, regardless of its display name.
		-- This avoids requiring the accessory to be called "Sword", "Blade", or "Katana".
		local function IsBackAccessory(accessory)
			local handle = accessory:FindFirstChild("Handle")
			if not handle then return false end
			for _, descendant in handle:GetDescendants() do
				if descendant:IsA("Attachment") then
					local name = descendant.Name:lower()
					if name == "bodybackattachment" or name == "backattachment"
						or name == "waistbackattachment" or name == "capeattachment" then
						return true
					end
				end
			end
			local weld = handle:FindFirstChild("AccessoryWeld")
			if weld and weld:IsA("Weld") and weld.Part1 == torso then
				-- R6 back accessories are normally welded behind the torso (local Z offset).
				return math.abs(weld.C1.Position.Z) >= 0.25
			end
			return false
		end
		local backAccessoryFound = false
		for _, accessory in figure:GetChildren() do
			if not backAccessoryFound and accessory:IsA("Accessory") and IsBackAccessory(accessory) then
				local handle = accessory:FindFirstChild("Handle")
				local mesh = handle and handle:FindFirstChildWhichIsA("SpecialMesh")
				local override = {
					Name = accessory.Name,
					Limb = "Right Arm",
					C0 = CFrame.new(0, -0.65, 0) * CFrame.Angles(math.rad(90), 0, math.rad(90)),
					C1 = CFrame.identity,
				}
				if handle then
					if mesh then override.MeshId = mesh.MeshId end
					if handle:IsA("MeshPart") then override.MeshId = handle.MeshId end
					if mesh then
						override.TextureId = mesh.TextureId
					elseif handle:IsA("MeshPart") then
						override.TextureId = handle.TextureID
					end
				end
				table.insert(HatReanimator.HatCFrameOverride, override)
				backAccessoryFound = true
			end
		end
		ContextActions:BindAction("Uhhhhhh_LSSword", function(_, state, _)
			if state == Enum.UserInputState.Begin then LinkedSword() end
		end, true, Enum.UserInputType.MouseButton1)
		ContextActions:SetTitle("Uhhhhhh_LSSword", "M1")
		ContextActions:SetPosition("Uhhhhhh_LSSword", UDim2.new(1, -130, 1, -130))
		if chatconn then
			chatconn:Disconnect()
		end
		chatconn = OnPlayerChatted.Event:Connect(function(plr, msg)
			if plr == Player then
				notify(msg)
			end
		end)
	end
	m.Update = function(dt: number, figure: Model)
		local t = os.clock() - start
		scale = figure:GetScale()
		isdancing = not not figure:GetAttribute("IsDancing")
		rcp.FilterDescendantsInstances = {figure, Player.Character}
		
		-- get vii
		hum = figure:FindFirstChild("Humanoid")
		root = figure:FindFirstChild("HumanoidRootPart")
		torso = figure:FindFirstChild("Torso")
		if not hum then return end
		if not root then return end
		if not torso then return end
		
		local onground = hum:GetState() == Enum.HumanoidStateType.Running
		if freezemove then
			hum.WalkSpeed = 0
			hum.JumpPower = 0
		else
			hum.WalkSpeed = 13 * scale
			hum.JumpPower = 60 * scale
		end
		
		-- animations
		timingsine += dt * 60
		local torsovelocity = root.Velocity.Magnitude / scale
		local torsovelocityy = root.Velocity.Y / scale
		local animationFunc = nil
		if animationOverride then
			animationFunc = animationOverride
		else
			swordoff = CFrame.new(0, 1, 0) * CFrame.Angles(0, math.rad(90), 0)
			if onground then
				if torsovelocity > 1 then
					animationFunc = lerps.walk
				else
					animationFunc = lerps.idle
				end
			else
				if torsovelocityy < -1 then
					animationFunc = lerps.fall
				else
					animationFunc = lerps.jump
				end
			end
		end
		local rt, nt, rst, lst, rht, lht, animationspeed = animationFunc(timingsine)
		
		-- joints
		local rj = root:FindFirstChild("RootJoint")
		local nj = torso:FindFirstChild("Neck")
		local rsj = torso:FindFirstChild("Right Shoulder")
		local lsj = torso:FindFirstChild("Left Shoulder")
		local rhj = torso:FindFirstChild("Right Hip")
		local lhj = torso:FindFirstChild("Left Hip")
		
		-- interpolation
		local alpha = math.exp(-animationspeed * dt)
		joints.r = rt:Lerp(joints.r, alpha)
		joints.n = nt:Lerp(joints.n, alpha)
		joints.rs = rst:Lerp(joints.rs, alpha)
		joints.ls = lst:Lerp(joints.ls, alpha)
		joints.rh = rht:Lerp(joints.rh, alpha)
		joints.lh = lht:Lerp(joints.lh, alpha)
		joints.sw = swordoff:Lerp(joints.sw, alpha)
		
		-- apply transforms
		SetC0C1Joint(rj, joints.r, CFrame.identity, scale)
		SetC0C1Joint(nj, joints.n, CFrame.identity, scale)
		SetC0C1Joint(rsj, joints.rs, CFrame.identity, scale)
		SetC0C1Joint(lsj, joints.ls, CFrame.identity, scale)
		SetC0C1Joint(rhj, joints.rh, CFrame.identity, scale)
		SetC0C1Joint(lhj, joints.lh, CFrame.identity, scale)
		
		-- sword
		sword.Offset = joints.sw:Inverse() * CFrame.Angles(1.57, 0, 1.57)
		sword.Disable = not not isdancing or freezemove
		

	end
	m.Destroy = function(figure: Model?)
		ContextActions:UnbindAction("Uhhhhhh_LSSword")
		root, torso, hum = nil, nil, nil
	end
	return m
end)

return modules
