--!strict
local DSS=game:GetService("DataStoreService")
local Config=require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("GameConfig"))
local LeaderboardService={}
local function retry(fn)
	local last
	for i=1,5 do local ok,r=pcall(fn); if ok then return true,r end last=r; task.wait(2^(i-1)) end
	return false,last
end
function LeaderboardService.Get(gameId:string)
	local store=DSS:GetOrderedDataStore("MGH_"..gameId)
	local ok,pages=retry(function() return store:GetSortedAsync(false,Config.LeadboardLimit) end)
	if not ok then return {} end
	local out={}
	for rank,e in ipairs(pages:GetCurrentPage()) do table.insert(out,{Rank=rank,UserId=e.key,Score=e.value}) end
	return out
end
function LeaderboardService.GetRank(gameId:string,userId:number)
	local store=DSS:GetOrderedDataStore("MGH_"..gameId)
	local ok,pages=retry(function() return store:GetSortedAsync(false,100) end)
	if not ok then return nil end
	local offset=0
	while pages do
		for i,e in ipairs(pages:GetCurrentPage()) do
			if tostring(e.key)==tostring(userId) then return offset+i end
		end
		if pages.IsFinished then break end
		local nextOk,nextPages=retry(function() pages:AdvanceToNextPageAsync(); return pages end)
		if not nextOk then break end
		offset+=100
		pages=nextPages
	end
	return nil
end
function LeaderboardService.Submit(gameId:string,userId:number,score:number)
	local store=DSS:GetOrderedDataStore("MGH_"..gameId)
	return retry(function() return store:UpdateAsync(tostring(userId),function(old) return math.max(tonumber(old) or 0,score) end) end)
end
return LeaderboardService
