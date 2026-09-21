--!strict
local U=require(script.Parent:WaitForChild("_Util"))
local M={}
function M.start(ctx)
	ctx.Block=0; ctx.LastX=0
	for i=1,12 do U.Part(ctx.World,"TowerBase"..i,Vector3.new(8,.6,8),Vector3.new(0,i*.7-0.3,0),Color3.fromRGB(250,220,160)) end
	ctx.onAction=function(c,p)
		if p.Action=="place" then
			local x=typeof(p.Value)=="number" and p.Value or 0
			local delta=math.abs(x-ctx.LastX)
			if delta<=1.2 then U.Award(ctx,180); ctx.Block+=1; ctx.LastX=x else U.Miss(ctx) end
		end
	end
	U.FinishLater(ctx,ctx.Game.Duration)
end
function M.cleanup() end
return M
