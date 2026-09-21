--!strict
local U=require(script.Parent:WaitForChild("_Util"))
local M={}
function M.start(ctx)
	local lanes={-12,-6,0,6,12}; ctx.Lane=3
	for i,x in ipairs(lanes) do local p=U.Part(ctx.World,"Lane"..i,Vector3.new(4,.5,60),Vector3.new(x,1,0),Color3.fromRGB(250,220,160)); p.Material=Enum.Material.Plastic end
	local function spawn()
		local x=lanes[math.random(1,5)]; local z=math.random(-25,25); local o=U.Part(ctx.World,"Obstacle",Vector3.new(4,4,4),Vector3.new(x,3,z),Color3.fromRGB(245,130,30)); o:SetAttribute("Lane",table.find(lanes,x) or 3)
	end
	for i=1,12 do spawn() end
	ctx.onAction=function(c,p)
		if p.Action=="lane" and typeof(p.Value)=="number" then ctx.Lane=math.clamp(math.floor(p.Value),1,5); U.Award(ctx,50) end
	end
	U.FinishLater(ctx,ctx.Game.Duration)
end
function M.cleanup() end
return M
