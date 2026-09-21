--!strict
local U={}
function U.Award(ctx,base:number)
	ctx.Combo=(ctx.Combo or 0)+1
	ctx.Multiplier=math.min(5,1+math.floor((ctx.Combo-1)/5))
	ctx.Score=math.clamp((ctx.Score or 0)+math.floor(base*ctx.Multiplier),0,ctx.Game.MaxScore)
	ctx.Speed=1+ctx.Combo*.035
end
function U.Miss(ctx)
	ctx.Combo=0; ctx.Multiplier=1
end
function U.FinishLater(ctx,seconds:number)
	task.delay(seconds,function()
		if ctx and ctx.OnFinish then ctx.OnFinish(ctx.Score or 0,true) end
	end)
end
function U.Part(parent,name,size,pos,color,material)
	local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Position=pos; p.Anchored=true; p.Color=color; p.Material=material or Enum.Material.SmoothPlastic; p.Parent=parent; return p
end
return U
