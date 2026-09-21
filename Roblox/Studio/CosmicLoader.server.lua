--!strict
-- RobuNexa Cosmic runtime loader
-- Put this Script in ServerScriptService.
-- Game Settings > Security > Allow HTTP Requests = ON.
-- NOTE: This reconstructs only data present in the decoded manifests.

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BASE = "https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/Roblox/Studio/"
local SOURCES = {
	CosmicG = BASE .. "CosmicG_VFX_decoded.txt",
	Cosmic = BASE .. "Cosmic_VFX_decoded.txt",
}

local function fetch(url: string): string
	local ok, result = pcall(function()
		return HttpService:GetAsync(url, false)
	end)
	if not ok then error("[RobuNexa] HTTP failed: " .. tostring(result)) end
	if type(result) ~= "string" or #result < 10 then
		error("[RobuNexa] Empty GitHub response")
	end
	return result
end

local function trim(s: string): string
	return s:gsub("^%s+", ""):gsub("%s+$", "")
end

local function parseValue(s: string): any
	s = trim(s)
	local n = s:match("^f64=([%-%d%.eE]+)")
	if n then return tonumber(n) end

	local vector = s:match("^%(([^)]+)%)")
	if vector then
		local values = {}
		for x in vector:gmatch("[%-%d%.eE]+") do
			table.insert(values, tonumber(x))
		end
		if #values == 3 then
			return Vector3.new(values[1], values[2], values[3])
		elseif #values == 2 then
			return Vector2.new(values[1], values[2])
		end
	end

	local quoted = s:match('^"(.*)"$')
	if quoted then return quoted end
	if s == "true" then return true end
	if s == "false" then return false end

	local number = tonumber(s)
	if number ~= nil then return number end
	return s
end

local function makeInstance(className: string, name: string): Instance
	local ok, object = pcall(function()
		return Instance.new(className)
	end)

	if not ok or not object then
		warn("[RobuNexa] Unsupported class: " .. className .. " -> Folder fallback")
		object = Instance.new("Folder")
		object:SetAttribute("RobuNexaOriginalClass", className)
	end

	object.Name = (name ~= "" and name ~= "?") and name or className
	object:SetAttribute("RobuNexaSourceClass", className)
	return object
end

local function uniqueName(parent: Instance, desired: string): string
	if not parent:FindFirstChild(desired) then return desired end
	local i = 2
	while parent:FindFirstChild(desired .. "_" .. i) do i += 1 end
	return desired .. "_" .. i
end

local function parseHeader(line: string)
	local indent = #(line:match("^%s*") or "")
	local className, name = line:match("^%s*%[([^%]]+)%]%s*(.*)$")
	if not className then return nil end
	name = trim(name or "")
	if name == "" or name == "?" then name = className end
	return indent, className, name
end

local function buildManifest(source: string, rootName: string)
	local root = Instance.new("Folder")
	root.Name = rootName

	local stack = {{indent = -1, instance = root}}
	local currentAttributeObject: Instance? = nil
	local created = 0

	for _, line in ipairs(string.split(source, "\n")) do
		if line:match("^%s*%[") then
			local parsed = {parseHeader(line)}
			if parsed[1] ~= nil then
				local indent = parsed[1]
				local className = parsed[2]
				local name = parsed[3]

				while #stack > 0 and indent <= stack[#stack].indent do
					table.remove(stack)
				end

				local parent = stack[#stack].instance
				local object = makeInstance(className, uniqueName(parent, name))
				object.Parent = parent

				table.insert(stack, {indent = indent, instance = object})
				currentAttributeObject = object
				created += 1
			end

		elseif line:match("^%s*ATTRIBUTES") then
			currentAttributeObject = stack[#stack] and stack[#stack].instance or root

		elseif line:match("^%s*%- ") and currentAttributeObject then
			local attrName, attrType, value = line:match(
				"^%s*%-%s+([%w_]+)%s+<([^>]+)>%s*=%s*(.*)$"
			)

			if attrName and value then
				local parsed = parseValue(value)
				local ok = pcall(function()
					currentAttributeObject:SetAttribute(attrName, parsed)
				end)

				if not ok then
					currentAttributeObject:SetAttribute(
						"RobuNexaDecoded_" .. attrName,
						tostring(value)
					)
				end

				currentAttributeObject:SetAttribute(
					"RobuNexaDecodedType_" .. attrName,
					attrType
				)
			end
		end
	end

	return root, created
end

local function install(name: string, url: string): number
	print("[RobuNexa] Downloading " .. name .. "...")
	local source = fetch(url)

	local old = ReplicatedStorage:FindFirstChild(name)
	if old then old:Destroy() end

	local root, count = buildManifest(source, name)
	root.Parent = ReplicatedStorage

	print("[RobuNexa] " .. name .. " ready: " .. count .. " Instances")
	return count
end

print("[RobuNexa] Cosmic runtime loader starting...")

local total = 0
for name, url in pairs(SOURCES) do
	local ok, count = pcall(function()
		return install(name, url)
	end)

	if ok then
		total += count
	else
		warn("[RobuNexa] " .. name .. " failed: " .. tostring(count))
	end
end

print("[RobuNexa] Cosmic runtime loader finished. Total: " .. total)
