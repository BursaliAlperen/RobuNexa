--!strict
local U=require(script.Parent:WaitForChild("_Util"))
local M={}
function M.start(ctx)
	ctx.Matches=0; ctx.Last=nil
	for i=1,12 do
		local p=U.Part(ctx.World,"Card"..i,Vector3.new(7,.6,7),Vector3.new(((i-1)%4-1.5)*9,2,(math.floor((i-1)/4)-1)*10),Color3.fromRGB(250,220,160)); p:SetAttribute("CardId",math.ceil(i/2))
	end
	ctx.onAction=function(c,p)
		if p.Action=="card" and typeof(p.Value)=="number" then
			local id=math.floor(p.Value)
			if ctx.Last==id then ctx.Matches+=1; U.Award(ctx,200); ctx.Last=nil else ctx.Last=id end
		end
	end
	U.FinishLater(ctx,ctx.Game.Duration)
end
function M.cleanup() end
return M
