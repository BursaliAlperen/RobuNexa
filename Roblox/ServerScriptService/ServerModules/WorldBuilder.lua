--!strict
local WorldBuilder = {}
local Workspace = game:GetService("Workspace")
local function part(parent:Instance, name:string, size:Vector3, cf:CFrame, color:Color3, material:Enum.Material?)
	local p=Instance.new("Part"); p.Name=name; p.Anchored=true; p.Size=size; p.CFrame=cf; p.Color=color; p.Material=material or Enum.Material.SmoothPlastic; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=parent
	return p
end
local function studs(parent:Instance, center:Vector3, size:Vector3, color:Color3)
	local model=Instance.new("Model"); model.Name="StudDetail"; model.Parent=parent
	local count=math.min(12, math.floor(size.X/2))
	for i=1,count do
		local x=-size.X/2+1+(i-1)*math.max(1,size.X/count)
		local s=part(model,"Stud",Vector3.new(.35,.16,.35),CFrame.new(center+Vector3.new(x,size.Y/2+.08,0)),color,Enum.Material.Plastic)
		s.Shape=Enum.PartType.Cylinder; s.Orientation=Vector3.new(0,0,0)
	end
end
function WorldBuilder.Build(gameDef, root:Folder)
	root:ClearAllChildren()
	local world=Instance.new("Model"); world.Name=gameDef.Id.."World"; world.Parent=root
	local orange=Color3.fromRGB(245,130,30); local cream=Color3.fromRGB(250,220,160); local dark=Color3.fromRGB(45,45,50)
	part(world,"Base",Vector3.new(72,2,72),CFrame.new(0,-1,0),dark,Enum.Material.Concrete)
	part(world,"NorthWall",Vector3.new(72,12,2),CFrame.new(0,5,-36),cream)
	part(world,"SouthWall",Vector3.new(72,12,2),CFrame.new(0,5,36),cream)
	part(world,"EastWall",Vector3.new(2,12,72),CFrame.new(36,5,0),orange)
	part(world,"WestWall",Vector3.new(2,12,72),CFrame.new(-36,5,0),orange)
	studs(world,Vector3.new(0,0,0),Vector3.new(68,2,68),cream)
	for i=1,10 do
		local x=((i-1)%5-2)*13; local z=(math.floor((i-1)/5)-.5)*18
		part(world,"Decor"..i,Vector3.new(5,1,5),CFrame.new(x,0,z),i%2==0 and orange or cream,Enum.Material.Plastic)
	end
	return world
end
return WorldBuilder
