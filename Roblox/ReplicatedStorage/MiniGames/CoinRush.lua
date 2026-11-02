--!strict
local U=require(script.Parent:WaitForChild("_Util"))
local M={}
function M.start(ctx)
	for i=1,30 do
		local a=math.random()*math.pi*2; local r=math.random(5,28)
		local p=U.Part(ctx.World,"Coin"..i,Vector3.new(1.2,.3,1.2),Vector3.new(math.cos(a)*r,2,math.sin(a)*r),Color3.fromRGB(250,220,160),Enum.Material.Neon)
		p.Shape=Enum.PartType.Cylinder; p.Orientation=Vector3.new(90,0,0)
	end
	ctx.onAction=function(c,p) if p.Action=="coin" then U.Award(ctx,75) end end
	U.FinishLater(ctx,ctx.Game.Duration)
end
function M.cleanup() end
return M
