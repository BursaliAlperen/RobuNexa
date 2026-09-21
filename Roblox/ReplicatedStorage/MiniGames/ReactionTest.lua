--!strict
local U=require(script.Parent:WaitForChild("_Util"))
local M={}
function M.start(ctx)
	ctx.Ready=false; ctx.Round=0
	local function round()
		if not ctx.World.Parent then return end
		ctx.Ready=false
		task.delay(math.random(10,25)/10,function() if ctx.World.Parent then ctx.Ready=true; ctx.Round+=1 end end)
	end
	ctx.onAction=function(c,p)
		if p.Action~="react" then return end
		if ctx.Ready then U.Award(ctx,220); round() else U.Miss(ctx) end
	end
	round(); U.FinishLater(ctx,ctx.Game.Duration)
end
function M.cleanup() end
return M
