--!strict
local DataStoreService=game:GetService("DataStoreService")
local Players=game:GetService("Players")
local store=DataStoreService:GetDataStore("MobileGameHub_v1")
local DataService={}
local cache:{[Player]:{[string]:any}}={}
local function retry(fn)
	local last
	for attempt=1,5 do
		local ok,result=pcall(fn)
		if ok then return true,result end
		last=result; task.wait(2^(attempt-1))
	end
	return false,last
end
function DataService.Load(player:Player)
	local ok,data=retry(function() return store:GetAsync("u_"..player.UserId) end)
	cache[player]=(ok and type(data)=="table" and data) or {Games={},BestScore=0}
	return cache[player]
end
function DataService.Get(player:Player) return cache[player] or DataService.Load(player) end
function DataService.Save(player:Player)
	local data=cache[player]; if not data then return false end
	local ok=retry(function() return store:UpdateAsync("u_"..player.UserId,function() return data end) end)
	return ok
end
function DataService.SetBest(player:Player,gameId:string,score:number)
	local data=DataService.Get(player); data.Games[gameId]=math.max(tonumber(data.Games[gameId]) or 0,score)
	data.BestScore=math.max(tonumber(data.BestScore) or 0,score)
end
Players.PlayerRemoving:Connect(function(p) DataService.Save(p); cache[p]=nil end)
return DataService
