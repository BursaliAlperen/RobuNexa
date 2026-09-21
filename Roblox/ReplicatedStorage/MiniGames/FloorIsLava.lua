--!strict
local U=require(script.Parent:WaitForChild("_Util"))
local M={}
function M.start(ctx)
	ctx.Safe=1
	for i=1,16 do
		local x=((i-1)%4-1.5)*9; local z=(math.floor((i-1)/4)-1.5)*9
		local p=U.Part(ctx.World,"LavaTile"..i,Vector3.new(7,.7,7),Vector3.new(x,2,z),Color3.fromRGB(250,220,160))
		task.delay(2+i*.7,function() if p.Parent then p.Color=Color3.fromRGB(235,75,70); p.Material=Enum.Material.Neon end end)
	end
	ctx.onAction=function(c,p)
		if p.Action=="safe" then U.Award(ctx,130) else U.Miss(ctx) end
	end
	U.FinishLater(ctx,ctx.Game.Duration)
end
function M.cleanup() end
return M
