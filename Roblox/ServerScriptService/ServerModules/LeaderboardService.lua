--!strict
local DSS=game:GetService("DataStoreService")
local Players=game:GetService("Players")
local GameConfig=require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("GameConfig"))
local LeaderboardService={}
local function retry(fn)
	local last
	for i=1,5 do local ok,r=pcall(fn); if ok then return true,r end last=r; task.wait(2^(i-1)) end
	return false,last
end
function LeaderboardService.Get(gameId:string)
	local store=DSS:GetOrderedDataStore("MGH_"..gameId)
	local ok,pages=retry(function() return store:GetSortedAsync(false,GameConfig.LeadboardLimit) end)
	if not ok then return {} end
	local out={}
	for rank,entry in ipairs(pages:GetCurrentPage()) do table.insert(out,{Rank=rank,UserId=entry.key,Score=entry.value}) end
	return out
end
function LeaderboardService.GetRank(gameId:string,userId:number)
	local store=DSS:GetOrderedDataStore("MGH_"..gameId)
	local ok,pages=retry(function() return store:GetSortedAsync(false,100) end)
	if not ok then return nil end
	for rank,e in ipairs(pages:GetCurrentPage()) do if tostring(e.key)==tostring(userId) then return rank end end
	return nil
end
function LeaderboardService.Submit(gameId:string,userId:number,score:number)
	local store=DSS:GetOrderedDataStore("MGH_"..gameId)
	return retry(function() return store:UpdateAsync(tostring(userId),function(old) return math.max(tonumber(old) or 0,score) end) end)
end
return LeaderboardService
