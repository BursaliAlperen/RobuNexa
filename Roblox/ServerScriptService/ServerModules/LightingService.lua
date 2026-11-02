--!strict
local Lighting=game:GetService("Lighting")
local LightingService={}
local themes={
	NeonTrack={Ambient=Color3.fromRGB(35,28,25),OutdoorAmbient=Color3.fromRGB(80,55,40),FogColor=Color3.fromRGB(45,35,30),FogEnd=180},
	TargetLab={Ambient=Color3.fromRGB(35,35,35),OutdoorAmbient=Color3.fromRGB(80,70,55),FogColor=Color3.fromRGB(60,55,45),FogEnd=150},
	SkyBlocks={Ambient=Color3.fromRGB(45,55,70),OutdoorAmbient=Color3.fromRGB(100,120,140),FogColor=Color3.fromRGB(150,180,210),FogEnd=220},
	CoinCanyon={Ambient=Color3.fromRGB(70,45,25),OutdoorAmbient=Color3.fromRGB(120,80,40),FogColor=Color3.fromRGB(160,110,55),FogEnd=190},
	SkyGarden={Ambient=Color3.fromRGB(40,65,50),OutdoorAmbient=Color3.fromRGB(110,140,105),FogColor=Color3.fromRGB(120,170,145),FogEnd=220},
	SignalRoom={Ambient=Color3.fromRGB(25,30,35),OutdoorAmbient=Color3.fromRGB(55,65,75),FogColor=Color3.fromRGB(40,50,60),FogEnd=130},
	ColorGrid={Ambient=Color3.fromRGB(45,40,55),OutdoorAmbient=Color3.fromRGB(90,80,110),FogColor=Color3.fromRGB(70,60,90),FogEnd=170},
	MemoryHall={Ambient=Color3.fromRGB(55,45,35),OutdoorAmbient=Color3.fromRGB(95,80,65),FogColor=Color3.fromRGB(90,75,60),FogEnd=170},
	CollapsePeak={Ambient=Color3.fromRGB(50,50,55),OutdoorAmbient=Color3.fromRGB(100,100,110),FogColor=Color3.fromRGB(85,85,95),FogEnd=150},
	LavaArena={Ambient=Color3.fromRGB(70,25,15),OutdoorAmbient=Color3.fromRGB(120,45,20),FogColor=Color3.fromRGB(110,35,20),FogEnd=140},
}
function LightingService.Apply(gameDef)
	local t=themes[gameDef.Theme] or themes.NeonTrack
	Lighting.Ambient=t.Ambient; Lighting.OutdoorAmbient=t.OutdoorAmbient; Lighting.FogColor=t.FogColor; Lighting.FogEnd=t.FogEnd
	local a=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere"); a.Name="GameAtmosphere"; a.Density=.28; a.Offset=.1; a.Color=t.FogColor; a.Decay=t.FogColor; a.Parent=Lighting
	local cc=Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect"); cc.Name="GameColorCorrection"; cc.TintColor=Color3.new(1,1,1); cc.Saturation=.05; cc.Contrast=.08; cc.Parent=Lighting
end
return LightingService
