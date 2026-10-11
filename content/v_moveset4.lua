-- NAM Axeman cosmetic moveset
-- Local visual animation only. Does not alter server-owned rigs or damage other players.

cloneref = cloneref or function(o) return o end

local Players = cloneref(game:GetService("Players"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Player = Players.LocalPlayer

local modules = {}
local function AddModule(m)
	table.insert(modules, m)
end

AddModule(function()
	local m = {}
	m.ModuleType = "MOVESET"
	m.Name = "Nam Axeman"
	m.Description = "Cosmetic axeman moveset\nQ / round mobile button - Axe swing"
	m.Assets = {}

	local neckAccessoryIds = {
		["88886554182275"] = true,
		["90788603154080"] = true,
		["120111604252410"] = true,
		["128893482026011"] = true,
		["87291559615126"] = true,
	}
	local axeAccessoryId = "16471816474"

	local figure
	local rightShoulder
	local baseC0
	local attackStarted = 0
	local attackDuration = 0.38
	local inputConnection
	local characterConnection
	local gui
	local button
	local detectedAccessories = {}
	local alive = false

	local function matchesAssetId(value, id)
		return value ~= nil and string.find(tostring(value), id, 1, true) ~= nil
	end

	local function inspectAccessories(model)
		table.clear(detectedAccessories)
		if not model then return end
		for _, item in ipairs(model:GetChildren()) do
			if item:IsA("Accessory") then
				local handle = item:FindFirstChild("Handle")
				local fields = { item.Name }
				if handle then
					table.insert(fields, handle.Name)
					for _, child in ipairs(handle:GetDescendants()) do
						if child:IsA("SpecialMesh") then
							table.insert(fields, child.MeshId)
							table.insert(fields, child.TextureId)
						elseif child:IsA("MeshPart") then
							table.insert(fields, child.MeshId)
							table.insert(fields, child.TextureID)
						end
					end
					if handle:IsA("MeshPart") then
						table.insert(fields, handle.MeshId)
						table.insert(fields, handle.TextureID)
					end
				end
				for _, field in ipairs(fields) do
					for id in pairs(neckAccessoryIds) do
						if matchesAssetId(field, id) then
							detectedAccessories[id] = item
						end
					end
					if matchesAssetId(field, axeAccessoryId) then
						detectedAccessories[axeAccessoryId] = item
					end
				end
			end
		end
	end

	local function swing()
		if not alive or not rightShoulder then return end
		attackStarted = os.clock()
	end

	local function createMobileButton()
		local playerGui = Player:FindFirstChildOfClass("PlayerGui")
		if not playerGui then return end
		gui = Instance.new("ScreenGui")
		gui.Name = "NamAxemanControls"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.DisplayOrder = 30
		gui.Parent = playerGui

		button = Instance.new("TextButton")
		button.Name = "AxeSwing"
		button.AnchorPoint = Vector2.new(1, 1)
		button.Position = UDim2.new(1, -24, 1, -150)
		button.Size = UDim2.fromOffset(54, 54)
		button.BackgroundColor3 = Color3.fromRGB(42, 45, 54)
		button.BackgroundTransparency = 0.08
		button.Text = "AXE"
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextSize = 13
		button.Font = Enum.Font.GothamBold
		button.AutoButtonColor = true
		button.Visible = UserInputService.TouchEnabled
		button.Parent = gui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = button

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1.5
		stroke.Color = Color3.fromRGB(190, 190, 200)
		stroke.Parent = button

		button.Activated:Connect(swing)
	end

	m.Config = function(parent: GuiBase2d)
	end

	m.Init = function(newFigure: Model)
		m.Destroy(figure)
		figure = newFigure
		alive = true
		attackStarted = 0
		rightShoulder = figure and figure:FindFirstChild("Right Shoulder", true)
		baseC0 = rightShoulder and rightShoulder.C0 or nil
		inspectAccessories(figure)
		createMobileButton()

		inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
			if processed or not alive then return end
			if input.KeyCode == Enum.KeyCode.Q then
				swing()
			end
		end)

		characterConnection = Player.CharacterAdded:Connect(function(character)
			if alive then
				inspectAccessories(character)
			end
		end)
	end

	m.Update = function(dt: number, currentFigure: Model)
		if not alive or not rightShoulder or not baseC0 then return end
		local elapsed = os.clock() - attackStarted
		if attackStarted > 0 and elapsed < attackDuration then
			local alpha = math.clamp(elapsed / attackDuration, 0, 1)
			local angle = math.sin(alpha * math.pi) * math.rad(-105)
			local twist = math.sin(alpha * math.pi) * math.rad(18)
			rightShoulder.C0 = baseC0 * CFrame.Angles(angle, 0, twist)
		else
			rightShoulder.C0 = baseC0
			attackStarted = 0
		end
	end

	m.Destroy = function(oldFigure: Model?)
		alive = false
		if inputConnection then inputConnection:Disconnect(); inputConnection = nil end
		if characterConnection then characterConnection:Disconnect(); characterConnection = nil end
		if rightShoulder and baseC0 and rightShoulder.Parent then
			rightShoulder.C0 = baseC0
		end
		if gui then gui:Destroy(); gui = nil end
		button = nil
		figure = nil
		rightShoulder = nil
		baseC0 = nil
		table.clear(detectedAccessories)
		attackStarted = 0
	end

	return m
end)

return modules
