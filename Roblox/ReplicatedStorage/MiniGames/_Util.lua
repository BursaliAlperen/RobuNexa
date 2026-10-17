--!strict
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Remotes=require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Remotes"))
local U={}
function U.Award(ctx,base:number)
	ctx.Combo=(ctx.Combo or 0)+1
	ctx.Multiplier=math.min(5,1+math.floor((ctx.Combo-1)/5))
	ctx.Score=math.clamp((ctx.Score or 0)+math.floor(base*ctx.Multiplier),0,ctx.Game.MaxScore)
	ctx.Speed=1+ctx.Combo*.035
	Remotes.GameStateChanged:FireClient(ctx.Player,{State="Score",Score=ctx.Score,Combo=ctx.Combo,Multiplier=ctx.Multiplier})
end
function U.Miss(ctx)
	ctx.Combo=0; ctx.Multiplier=1
	Remotes.GameStateChanged:FireClient(ctx.Player,{State="Score",Score=ctx.Score or 0,Combo=0,Multiplier=1})
end
function U.FinishLater(ctx,seconds:number)
	task.delay(seconds,function() if ctx.World and ctx.World.Parent and ctx.OnFinish then ctx.OnFinish(ctx.Score or 0,true) end end)
end
function U.Part(parent,name,size,pos,color,material)
	local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Position=pos; p.Anchored=true; p.Color=color; p.Material=material or Enum.Material.SmoothPlastic; p.Parent=parent; return p
end
return U
