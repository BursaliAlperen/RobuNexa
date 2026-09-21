--!strict
local U=require(script.Parent:WaitForChild("_Util"))
local M={}
function M.start(ctx)
	ctx.Hits=0
	for i=1,12 do
		local a=math.rad(i*30); local p=U.Part(ctx.World,"Target"..i,Vector3.new(4,.5,4),Vector3.new(math.cos(a)*20,2,math.sin(a)*20),Color3.fromRGB(245,130,30)); p:SetAttribute("Target",true)
	end
	ctx.onAction=function(c,p) if p.Action=="tapTarget" then ctx.Hits+=1; U.Award(ctx,100) end end
	U.FinishLater(ctx,ctx.Game.Duration)
end
function M.cleanup() end
return M
