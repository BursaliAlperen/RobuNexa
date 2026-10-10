-- AnimationLoadDiagnostics.client.lua
-- Place in StarterPlayer > StarterPlayerScripts in YOUR Roblox Studio experience.
-- Create ReplicatedStorage > AnimationCatalog and add Animation instances named:
-- CidOverdrive, SukunaAwakening, GojoAwakening, MaximumHollowPurple.
-- Set each Animation.AnimationId to a published Roblox animation asset ID.
-- This does not load local .anim files or affect third-party games/executors.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local catalog = ReplicatedStorage:WaitForChild("AnimationCatalog", 10)
if not catalog then
	warn("[AnimationDiagnostics] ReplicatedStorage.AnimationCatalog is missing.")
	return
end

local gui = Instance.new("ScreenGui")
gui.Name = "AnimationLoadDiagnostics"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local holder = Instance.new("Frame")
holder.Name = "Notifications"
holder.AnchorPoint = Vector2.new(1, 1)
holder.Position = UDim2.new(1, -16, 1, -16)
holder.Size = UDim2.fromOffset(300, 220)
holder.BackgroundTransparency = 1
holder.Parent = gui

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
layout.Padding = UDim.new(0, 8)
layout.Parent = holder

local seen = {}
local function notify(name, status, detail)
	local key = name .. ":" .. status
	if seen[key] then return end
	seen[key] = true

	local card = Instance.new("Frame")
	card.Name = "Notice_" .. name
	card.Size = UDim2.new(1, 0, 0, 54)
	card.BackgroundColor3 = status == "LOADED" and Color3.fromRGB(32, 105, 75)
		or status == "LOADING" and Color3.fromRGB(50, 67, 92)
		or Color3.fromRGB(130, 48, 48)
	card.BackgroundTransparency = 0.08
	card.BorderSizePixel = 0
	card.Parent = holder
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 9)

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(12, 5)
	title.Size = UDim2.new(1, -24, 0, 20)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Text = name .. "  •  " .. status
	title.Parent = card

	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Position = UDim2.fromOffset(12, 27)
	sub.Size = UDim2.new(1, -24, 0, 18)
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 11
	sub.TextTruncate = Enum.TextTruncate.AtEnd
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.TextColor3 = Color3.fromRGB(235, 235, 235)
	sub.Text = detail or ""
	sub.Parent = card

	task.delay(5, function()
		if card.Parent then
			local tween = TweenService:Create(card, TweenInfo.new(0.25), {
				BackgroundTransparency = 1,
				Position = card.Position + UDim2.fromOffset(12, 0),
			})
			for _, child in ipairs(card:GetChildren()) do
				if child:IsA("TextLabel") then
					TweenService:Create(child, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
				end
			end
			tween:Play()
			tween.Completed:Wait()
			card:Destroy()
		end
	end)
end

local function checkAnimation(item)
	if not item:IsA("Animation") then return end
	local name = item.Name
	notify(name, "LOADING", "Checking published animation asset…")

	local assetId = item.AnimationId
	if type(assetId) ~= "string" or assetId == "" or assetId == "rbxassetid://0" then
		notify(name, "ERROR", "AnimationId is empty; set a published asset ID.")
		return
	end

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid then
		notify(name, "ERROR", "Character Humanoid was not found.")
		return
	end
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local ok, result = pcall(function()
		return animator:LoadAnimation(item)
	end)
	if not ok or not result then
		notify(name, "ERROR", "LoadAnimation failed; check ID, ownership and permissions.")
		warn("[AnimationDiagnostics] Failed to load " .. name .. ": " .. tostring(result))
		return
	end

	result:Destroy()
	notify(name, "LOADED", "Asset accepted by Animator. Playback not tested.")
end

for _, item in ipairs(catalog:GetChildren()) do
	checkAnimation(item)
end

catalog.ChildAdded:Connect(function(item)
	task.wait()
	checkAnimation(item)
end)
