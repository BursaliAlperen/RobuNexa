--!strict
local GameConfig = {}

GameConfig.Theme = {
	Orange = Color3.fromRGB(245, 130, 30),
	Cream = Color3.fromRGB(250, 220, 160),
	Dark = Color3.fromRGB(45, 45, 50),
	White = Color3.fromRGB(255, 255, 255),
	Success = Color3.fromRGB(90, 210, 120),
	Danger = Color3.fromRGB(235, 75, 70),
}

GameConfig.MaxPerGame = 100000
GameConfig.ComboWindow = 1.25
GameConfig.SpeedRamp = 0.035
GameConfig.LeadboardLimit = 10

GameConfig.Games = {
	{Id="DodgeRun", Name="Dodge Run", Description="5 şeritte engellerden kaç.", Duration=45, MaxScore=10000, Theme="NeonTrack"},
	{Id="TargetRush", Name="Target Rush", Description="30 saniyede mümkün olduğunca çok hedefe dokun.", Duration=30, MaxScore=10000, Theme="TargetLab"},
	{Id="StackTower", Name="Stack Tower", Description="Bloğu tam hizaya getir ve kuleyi yükselt.", Duration=45, MaxScore=10000, Theme="SkyBlocks"},
	{Id="CoinRush", Name="Coin Rush", Description="30 saniyede coin yağmurunu topla.", Duration=30, MaxScore=10000, Theme="CoinCanyon"},
	{Id="JumpChallenge", Name="Jump Challenge", Description="Platformdan platforma zıpla.", Duration=45, MaxScore=10000, Theme="SkyGarden"},
	{Id="ReactionTest", Name="Reaction Test", Description="Yeşile döndüğü an dokun.", Duration=30, MaxScore=10000, Theme="SignalRoom"},
	{Id="ColorRush", Name="Color Rush", Description="Renk ve kelimeyi eşleştir.", Duration=30, MaxScore=10000, Theme="ColorGrid"},
	{Id="MemoryMatch", Name="Memory Match", Description="Kart çiftlerini bul.", Duration=60, MaxScore=10000, Theme="MemoryHall"},
	{Id="FallingPlatforms", Name="Falling Platforms", Description="Düşen platformlarda hayatta kal.", Duration=45, MaxScore=10000, Theme="CollapsePeak"},
	{Id="FloorIsLava", Name="Floor Is Lava", Description="Kızaran platformlardan kaç.", Duration=45, MaxScore=10000, Theme="LavaArena"},
}

function GameConfig.GetGame(id: string)
	for _, game in ipairs(GameConfig.Games) do
		if game.Id == id then return game end
	end
	return nil
end

return GameConfig
