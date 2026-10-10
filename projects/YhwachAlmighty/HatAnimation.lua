-- Smooth accessory-handle pose transitions for an authorized Roblox experience.
-- This animates an accessory already equipped on the local character; it does not reanimate a rig or bypass replication.
local TweenService = game:GetService("TweenService")

local HatAnimation = {}
HatAnimation.__index = HatAnimation

function HatAnimation.new()
	return setmetatable({ activeTween = nil, originalC0 = nil, activeWeld = nil }, HatAnimation)
end

local function findHandleWeld(character, accessoryName)
	local accessory = character:FindFirstChild(accessoryName)
	if not accessory or not accessory:IsA("Accessory") then
		return nil, nil
	end
	local handle = accessory:FindFirstChild("Handle")
	if not handle then return nil, nil end
	for _, descendant in ipairs(handle:GetDescendants()) do
		if descendant:IsA("Weld") or descendant:IsA("Motor6D") then
			return descendant, accessory
		end
	end
	return nil, accessory
end

function HatAnimation:Play(character, accessoryName, offset, duration)
	self:Stop()
	local weld = findHandleWeld(character, accessoryName)
	if not weld then
		return false, ("No Handle Weld/Motor6D found for accessory '%s'."):format(accessoryName)
	end
	self.activeWeld = weld
	self.originalC0 = weld.C0
	self.activeTween = TweenService:Create(
		weld,
		TweenInfo.new(duration or 0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{ C0 = self.originalC0 * offset }
	)
	self.activeTween:Play()
	return true
end

function HatAnimation:Stop()
	if self.activeTween then
		self.activeTween:Cancel()
		self.activeTween = nil
	end
	if self.activeWeld and self.originalC0 and self.activeWeld.Parent then
		TweenService:Create(
			self.activeWeld,
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{ C0 = self.originalC0 }
		):Play()
	end
	self.activeWeld = nil
	self.originalC0 = nil
end

return HatAnimation
