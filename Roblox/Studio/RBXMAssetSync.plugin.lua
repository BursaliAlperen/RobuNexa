-- RobuNexa Studio RBXM cache validator.
-- This intentionally does not attempt to deserialize arbitrary GitHub .rbxm bytes.
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

local toolbar = plugin:CreateToolbar("RobuNexa")
local button = toolbar:CreateButton("Validate RBXM", "Validate imported RBXM cache", "")

local function validate()
	local root = ServerStorage:FindFirstChild("RBXMAssets") or ReplicatedStorage:FindFirstChild("RBXMAssets")
	if not root then
		warn("[RobuNexa] RBXM asset root missing. Import into ServerStorage/RBXMAssets.")
		return
	end

	local count = 0
	for _, moveset in ipairs(root:GetChildren()) do
		count += 1
		local skills = moveset:FindFirstChild("Skills")
		if skills then
			print(string.format("[RobuNexa] %s: %d skill entries", moveset.Name, #skills:GetChildren()))
		else
			print("[RobuNexa] " .. moveset.Name .. ": direct children will be treated as skills.")
		end
	end

	Selection:Set({root})
	ChangeHistoryService:SetWaypoint("RobuNexa RBXM validation")
	print("[RobuNexa] Validated " .. tostring(count) .. " moveset assets.")
end

button.Click:Connect(validate)
