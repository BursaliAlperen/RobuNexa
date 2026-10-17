--!strict
local U=require(script.Parent:WaitForChild("_Util"))
local M={}
function M.start(ctx)
	ctx.Steps=0
	for i=1,18 do
		local x=((i-1)%3-1)*10; local z=(math.floor((i-1)/3)-2)*7
		local p=U.Part(ctx.World,"Falling"..i,Vector3.new(8,.7,6),Vector3.new(x,2,z),Color3.fromRGB(250,220,160))
		task.delay(1+(i*.45),function() if p.Parent then p.CanCollide=false; p.Transparency=.55 end end)
	end
	ctx.onAction=function(c,p) if p.Action=="jump" then ctx.Steps+=1; U.Award(ctx,100) end end
	U.FinishLater(ctx,ctx.Game.Duration)
end
function M.cleanup() end
return M
