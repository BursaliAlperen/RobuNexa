--!strict
local U=require(script.Parent:WaitForChild("_Util"))
local M={}
function M.start(ctx)
	local colors={Red=Color3.fromRGB(235,75,70),Green=Color3.fromRGB(80,205,115),Blue=Color3.fromRGB(70,140,235),Yellow=Color3.fromRGB(245,210,60)}
	ctx.Answer="Red"
	ctx.onAction=function(c,p)
		if p.Action=="color" and typeof(p.Value)=="string" then
			if p.Value==ctx.Answer then U.Award(ctx,120) else U.Miss(ctx) end
			local keys={"Red","Green","Blue","Yellow"}; ctx.Answer=keys[math.random(1,4)]
		end
	end
	for i,name in ipairs({"Red","Green","Blue","Yellow"}) do U.Part(ctx.World,name,Vector3.new(12,.7,8),Vector3.new((i-2.5)*14,1,0),colors[name]) end
	U.FinishLater(ctx,ctx.Game.Duration)
end
function M.cleanup() end
return M
