--!strict
local U=require(script.Parent:WaitForChild("_Util"))
local M={}
function M.start(ctx)
	ctx.Jumps=0
	for i=1,14 do
		local x=((i-1)%4-1.5)*8; local z=(math.floor((i-1)/4)-1)*9
		U.Part(ctx.World,"JumpPlatform"..i,Vector3.new(6,.7,6),Vector3.new(x,2+(i%3)*2,z),Color3.fromRGB(245,130,30))
	end
	ctx.onAction=function(c,p) if p.Action=="jump" then ctx.Jumps+=1; U.Award(ctx,90) end end
	U.FinishLater(ctx,ctx.Game.Duration)
end
function M.cleanup() end
return M
