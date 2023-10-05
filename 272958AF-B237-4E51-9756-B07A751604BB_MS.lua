local _f = require(script.Parent)

local BitBuffer = _f.BitBuffer
local Persistence = {}
local Players = game:GetService("Players")
local datacache = {} --// DataCache (needs to be the first thing that happens)
--// DataCache Handler
Players.PlayerRemoving:Connect(function(plr)
	if datacache[plr.Name] then
		datacache[plr.Name] = nil
	end
end)

local function reportBadSaveString() end
local function safetyCheck(mainData, pcData)
	if select(2, mainData:gsub(';', ';')) ~= 3 then -- decline mismatched div counts
		return 1
	end
	local s, v = pcall(function()
		return select(2, mainData:match('^([^;]+);'):gsub('%-', '-')) == 4
	end)
	if not s or not v then
		return 2
	end
	if pcData then
		if pcData:find(',,') then
			return -1
		end
		local s, v = pcall(function()
			local buffer = BitBuffer.Create()
			buffer:FromBase64(pcData:match('^(.+);'))
			for _ = 1, 6+1+6 do buffer:ReadBool() end
			if buffer:ReadBool() then for _ = 1, buffer:ReadUnsigned(6) do if buffer:ReadBool() then buffer:ReadString() end end end
			if buffer:ReadBool() then for _ = 1, buffer:ReadUnsigned(6) do if buffer:ReadBool() then buffer:ReadUnsigned(6) end end end
			local nStoredPokemon = buffer:ReadUnsigned(11)
			local pokemonArrayString = pcData:match(';(.+)$')
			if nStoredPokemon == 0 and not pokemonArrayString then return true end
			return nStoredPokemon - select(2, pokemonArrayString:gsub(',', ',')) == 1
		end)
		if not s or not v then
			return -2
		end
	end
	return 0
end

local network = _f.Network--require(script.Parent.Parent.Network)

local BreamService = _f.BreamService
local DataStoreService = game:GetService("DataStoreService")

-- Player Data
local PlayerDataStore = BreamService:GetBream('PlayerDataV1')
local PCDataStore     = BreamService:GetBream('PCData')

local STRING_LEN_LIMIT = 259900

local offsetByPlayer = {}
local keysByPlayer = {}

reportBadSaveString = function(userId, data, errorNum)
	local errorTypes = {
		["-2"] = "pcData pokemon mismatch.",
		["-1"] = "Empty pokemon in pcData.",
		["1"] = "Div (;) mismatch.",
		["2"] = "Div2 (-) mismatch.",
	}
	_f.Logger:logError(game.Players:GetPlayerByUserId(userId), {
		ErrType = "Invalid/Bad Save String",
		Errors = errorTypes[tostring(errorNum)],  
	})
	debug(errorTypes[tostring(errorNum)])
	error(errorTypes[tostring(errorNum)])
end

function Persistence.SaveData(player, mainData, pcData, gamemode)
	if player.UserId < 1 then return false end -- guests cannot save
	local id = tostring(player.UserId)

	if gamemode == 'randomizer' then
		id = id..'_Random'
	end

	local check = safetyCheck(mainData, pcData)
	if check ~= 0 then
		reportBadSaveString(id, check>0 and mainData or pcData, check)
		return false
	end
	local l = pcData:len()
	local nReqKeys = math.ceil(l / STRING_LEN_LIMIT)
	local offset = 0
	if offsetByPlayer[player] and keysByPlayer[player] then
		if nReqKeys > offsetByPlayer[player] then
			offset = offsetByPlayer[player] + keysByPlayer[player] + 1
		end
	end
	for i = 1, nReqKeys do
		local si = STRING_LEN_LIMIT * (i-1) + 1
		local ei = math.min(l, STRING_LEN_LIMIT * i)
		local s, e = pcall(function() PCDataStore:SetAsync(id..'_'..(i+offset), pcData:sub(si, ei)) end)
		if not s then
			print('Error saving pc data:', e)
			return false
		end
	end
	local s, e = pcall(function() PlayerDataStore:SetAsync(id, offset..'['..nReqKeys..']'..mainData) end)
	if not s then
		print('Error saving player data:', e)
		return false
	end
	offsetByPlayer[player] = offset
	keysByPlayer[player] = nReqKeys
	return true
end

function Persistence.LoadData(player, gamemode)
	local id = tostring(player.UserId)

	if gamemode == 'randomizer' then
		id = id..'_Random'
	end

	local s, d = pcall(function() 
		if not datacache[player.Name] then
			datacache[player.Name] = {}
		end
		if datacache[player.Name][id] then
			return datacache[player.Name][id]
		end
		return PlayerDataStore:GetAsync(id) 
	end)
	if not s then
		return false
	end
	if not d then return true end
	if not datacache[player.Name][id] then
		datacache[player.Name][id] = d	
	end
	local offset, nKeys, data = d:match('^(%d+)%[(%d+)%](.+)$')
	if not offset or not nKeys or not data then
		return true, d
	end
	offset, nKeys = tonumber(offset), tonumber(nKeys)
	offsetByPlayer[player] = offset
	keysByPlayer[player] = nKeys
	local pc
	for i = 1, nKeys do
		local s, d = pcall(function() 
			if not datacache[player.Name] then
				datacache[player.Name] = {}
			end
			if datacache[player.Name]['PC_'..id..'_'..tostring(i)] then
				return datacache[player.Name]['PC_'..id..'_'..tostring(i)]
			end
			return PCDataStore:GetAsync(id..'_'..(i+offset)) 
		end)
		if not s then
			return false
		end
		if not datacache[player.Name]['PC_'..id..'_'..tostring(i)] then
			datacache[player.Name]['PC_'..id..'_'..tostring(i)] = d	
		end
		pc = (pc or '') .. d
	end
	return true, data, pc
end

-- RO-Powers Autosave
do
	local ROPowerStore = DataStoreService:GetDataStore('ROPowerBackups')
	function Persistence.ROPowerSave(player, action, arg1)
		if action == 'save' then
			local success = pcall(function() ROPowerStore:SetAsync(tostring(player.UserId), arg1) end)
			return success
		elseif action == 'load' then
			local data
			local success = pcall(function() data = ROPowerStore:GetAsync(tostring(player.UserId)) end)
			return data
		end
		warn('Bad RO-Power Backup request ('..tostring(action)..')')
	end
end


-- BP Management (1 BP per battle between each player combo, per hour
do
	local BattledPlayers = BreamService:GetBream('PVPHourBattleHistoryV3')
	local BattleStreak = BreamService:GetBream('PVPWinStreak')

	local TIME_BETWEEN_BP_AWARDS = 60*60

	local Battle = _f.BattleEngine--require(script.Parent.BattleEngine)
	function Battle:PVPBattleAwardsBP(versusId)
		local s, lastTime = pcall(function() return BattledPlayers:GetAsync(versusId) end)
		if not s then
			if self.WIN_DEBUG then
				print('LANDO: Failed to get last time you\'ve battled this player:')
				print(lastTime)
				print('Defaulting to AwardBPEnabled')
			end
			--			print('cannot tell whether battled in last hour;', lastTime)
			return true--false -- WE DEFAULT TO TRUE CUZ BENEFIT OF THE DOUBT
		end
		local now = os.time()
		if lastTime and now-lastTime < TIME_BETWEEN_BP_AWARDS then
			if self.WIN_DEBUG then print('LANDO: You already battled this guy in the last hour, dingus.') end
			--			print(versusId, 'battled too recently')
			return false
		end
		--		if not lastTime then
		--			print('no previous battle recorded as', versusId)
		--		else
		--			print(now, lastTime)
		--		end
		pcall(function() BattledPlayers:SetAsync(versusId, now) end)
		if self.WIN_DEBUG then print('LANDO: This battle has properly been flagged to award BP.') end
		return true
	end

	function Battle:incrementStreak(userId)
		pcall(function() BattleStreak:IncrementAsync(tostring(userId), 1) end)
	end
	function Battle:resetStreak(userId)
		pcall(function() BattleStreak:SetAsync(tostring(userId), 0) end)
	end
	function Battle:getStreak(userId)
		local s, r = pcall(function() return BattleStreak:GetAsync(tostring(userId)) or 0 end)
		return s and r or 0
	end
end

return Persistence