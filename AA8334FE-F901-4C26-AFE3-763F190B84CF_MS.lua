--[[--------- tbradm's modified Elo rating system ---------]--

  Was originally designed to be completely generic, however,
changes were made that caused that to no longer be the case:

+ metadata is stored about each rank increase; each day, over
  the space of a week, parts totalling half that increase are
  lost (to encourage continuous play)


Gold   Crown 11226822199 (offset lower)
Silver Crown 11226829292 (centered)
Bronze Crown 11226838798 (high but small so centered)


--[-------------------------------------------------------]]--

local _f = require(script.Parent)

local _debug = false
local function dprint(...) if _debug then print(...) end end


--local dataStores = game:GetService('DataStoreService')
local Utilities = _f.Utilities--require(game:GetService('ServerStorage'):WaitForChild('Utilities'))

local function resolveId(playerOrUserId)
	if type(playerOrUserId) == 'userdata' then
		playerOrUserId = playerOrUserId.UserId
	end
	if type(playerOrUserId) ~= 'number' and type(playerOrUserId) ~= 'string' then error('bad id', 2) end
	return tostring(playerOrUserId)
end

local elo = Utilities.class({
	className = 'EloRankingSystem',
	newPlayerRank = 800,
	rankLogScaleSpread = 400, -- not recommended to change this
	rankFloor = 100,
	kFactor = 32, -- can be number or function
	allowIncreaseOnLose = false,
	allowFloatingRanks = false, -- if true, stores to the nearest 1/100th
	--	rankTransformation -- optional function

}, function(name)
	local self = {
		metaStore = _f.safelyGetDataStore('EloMeta_'..name),
		rankStore = _f.safelyGetOrderedDataStore('EloRanks_'..name),
		rankCache = {},
		failedToLoad = {},
		playerRankChanged = Utilities.Signal()
	}

	local players = game:GetService('Players')
	self.playerRemoveCn = players.ChildRemoved:connect(function()
		local validIds = {}
		for _, p in pairs(players:GetChildren()) do
			pcall(function() validIds[tostring(p.UserId)] = true end)
		end
		for id in pairs(self.rankCache) do
			if not validIds[id] then
				self.rankCache[id] = nil
			end
		end
	end)

	return self
end)

function elo:getTopList(numberElements)
	local list -- formatted {[1] = {['key'] = idString, ['value'] = rank}, ...}
	pcall(function()
		list = self.rankStore:GetSortedAsync(false, numberElements):GetCurrentPage()
		if self.allowFloatingRanks then
			for _, entry in pairs(list) do
				entry.value = entry.value / 100
			end
		end
	end)
	return list or {}
end

function elo:getTransformedPlayerRank(id)
	if self.rankTransformation then
		return self.rankTransformation(self:getPlayerRank(id))
	end
	return self:getPlayerRank(id)
end

function elo:getPlayerRank(id)
	id = resolveId(id)
	local cachedRank = self.rankCache[id]
	if cachedRank then
		dprint('had rank for', id, 'cached:', cachedRank)
		return cachedRank
	end
	for _ = 1, 4 do
		local s, r = pcall(function() return self.rankStore:GetAsync(id) end)
		if s then
			dprint('got rank for', id, 'from store:', r)
			if r and self.allowFloatingRanks then
				r = r / 100
			end
			return r or self.newPlayerRank
		end
	end
	dprint(id, 'FAILED TO LOAD: prevent saving')
	self.failedToLoad[id] = true -- flag that indicates not to save changes
	return self.newPlayerRank
end

function elo:adjustRanks(id1, id2, winner) -- "winner" is expected to match one of the first two arguments, or is draw
	dprint('==============')
	dprint('elo adjustment')
	local rid1, rid2 = resolveId(id1), resolveId(id2)
	local rank1, rank2 = Utilities.Sync {
		function() return self:getPlayerRank(rid1) end,
		function() return self:getPlayerRank(rid2) end
	}
	local s1, s2 = .5, .5
	if winner == id1 then--or winner == 1 then
		s1, s2 = 1, 0
	elseif winner == id2 then--or winner == 2 then
		s1, s2 = 0, 1
	end
	local k1, k2
	local K = self.kFactor
	if type(K) == 'function' then
		k1, k2 = K(rank1, s1), K(rank2, s2)
	elseif type(K) == 'number' then
		k1, k2 = K, K
	else
		error('elo ranking system has bad K factor')
	end
	local q1 = 10^(rank1/self.rankLogScaleSpread)
	local q2 = 10^(rank2/self.rankLogScaleSpread)
	local e1 = q1 / (q1 + q2)
	local e2 = q2 / (q1 + q2)
	local newRank1 = rank1 + k1 * (s1 - e1)
	local newRank2 = rank2 + k2 * (s2 - e2)
	if not self.allowFloatingRanks then
		newRank1 = math.floor(newRank1+.5)
		newRank2 = math.floor(newRank2+.5)
	end
	if self.rankFloor then
		newRank1 = math.max(self.rankFloor, newRank1)
		newRank2 = math.max(self.rankFloor, newRank2)
	end
	dprint('player1:', rid1)
	dprint('rank:', rank1)
	dprint('s:', s1)
	dprint('K:', k1)
	dprint('expected:', e1)
	dprint('new rank:', newRank1)
	dprint('--------------')
	dprint('player2:', rid2)
	dprint('rank:', rank2)
	dprint('s:', s2)
	dprint('K:', k2)
	dprint('expected:', e2)
	dprint('new rank:', newRank2)
	local function updateRank(rid, oldRank, newRank, s)
		return function()
			if self.allowIncreaseOnLose or s ~= 0 or newRank < oldRank then
				self.rankCache[rid] = newRank
				if not self.failedToLoad[rid] then
					for i = 1, 4 do
						local s, r = pcall(function() self.rankStore:SetAsync(rid, self.allowFloatingRanks and math.floor(newRank * 100 + .5) or newRank) end)
						if s then break end
						if i == 4 then
							dprint('ALL FOUR SAVES FAILED:', r)
						end
					end
					-- record metadata
					pcall(function() self.metaStore:UpdateAsync(rid, function(t)
							if t then
								t = game:GetService('HttpService'):JSONDecode(t)
							else
								t = {}
							end
							if s == 1 then
								t.wins = (t.wins or 0) + 1
							elseif s == 0 then
								t.losses = (t.losses or 0) + 1
							else
								t.draws = (t.draws or 0) + 1
							end
							return game:GetService('HttpService'):JSONEncode(t)
						end) end)
				else
					dprint('FAILED TO LOAD FLAG DETECTED: SAVE PREVENTED')
				end
				return newRank - oldRank
			end
			dprint(rid, 'ATTEMPTED TO INCREASE ON A LOSS: PREVENTED')
			return 0
		end
	end
	local dr1, dr2 = Utilities.Sync { -- is the +/- swap some kind of thread issue that causes dr1<->dr2?
		updateRank(rid1, rank1, newRank1, s1),
		updateRank(rid2, rank2, newRank2, s2)
	}
	--	self.playerRankChanged:fire(rid1, newRank1)
	--	self.playerRankChanged:fire(rid2, newRank2)
	local t = self.rankTransformation
	if t then
		if dr1 ~= 0 then dr1 = t(newRank1) - t(rank1) end
		if dr2 ~= 0 then dr2 = t(newRank2) - t(rank2) end
	end
	dprint('==============')
	return dr1, dr2
end


function elo:destroy() -- probably won't be used
	self.rankCache = nil
	pcall(function() self.playerRemoveCn:disconnect() end)
	self.playerRemoveCn = nil
end


return elo