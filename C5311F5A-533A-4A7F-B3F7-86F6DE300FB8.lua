local scriptbin = script.Parent
local storage = game:GetService('ServerStorage')

-- Loader
repeat wait() until _G.FilesInitialized
-- SERVER LAUNCH PREP
-- move (specific) buildings to proper storage
--pcall(function() workspace.Museum.Parent = storage.Indoors.chunk19 end)
pcall(function() workspace.gym6.Parent = storage.MapChunks end)

-- move chunks to storage
for _, obj in pairs(workspace:GetChildren()) do
	if obj.Name:sub(1, 5) == 'chunk' and tonumber(obj.Name:sub(6)) then
		obj.Parent = storage.MapChunks
	end
end

-- fix regions
for _, r in pairs(storage.MapChunks.Regions:GetChildren()) do
	local chunk = storage.MapChunks:FindFirstChild(r.Name)
	if chunk then
		r.Parent = chunk
		r.Name = 'Regions'
	end
end

-- make spawn box invisible
for _, p in pairs(workspace.SpawnBox:GetChildren()) do
	pcall(function() p.Transparency = 1.0 end)
end

-- revert to legacy physics
local function applyOldPhysics(obj)
	for _, ch in pairs(obj:GetChildren()) do
		if ch:IsA('BasePart') then
			ch.CustomPhysicalProperties = PhysicalProperties.new(1, 0.3, 0.5)
		end
		applyOldPhysics(ch)
	end
end
applyOldPhysics(storage)

-- SERVER FRAMEWORK INSTALLATION
local moduleFolder = scriptbin:WaitForChild('ServerModules')
local frameworkModule = script:WaitForChild('SFramework')
frameworkModule.Parent = scriptbin

local _f = require(frameworkModule)
_f.Utilities = require(storage:WaitForChild('Utilities'))
_f.BitBuffer = require(storage:WaitForChild('Plugins'):WaitForChild('BitBuffer'))
_f.levelCap = 100
_f.currentweather = ''
--FOR EXTERNAL DATA
_f.savedData = {
	
	FFlag = {},
	MoveDesc = {},
	ItemDesc = {}
}
_f.lastDatastoreRequest = {
	FFlag = 0,
	MoveDesc = 0,
	ItemDesc = 0,
}
_f.ExternalDatastore = function(name, specificValue, splitToTable)
	local dataURLs = {
		FFlag = 'https://pastebin.com/raw/xetSYBnZ',
		MoveDesc = 'https://pastebin.com/raw/cVCSiEpm',
		ItemDesc = 'https://pastebin.com/raw/hV846Jk2',
	}
	local dividerKey = ';'
	local refreshRate = 60*5
	--[[
	TODO
		Make it return 'Error' if failed to grab Data
		Live Event flag: os.time(), event, true/false
	]]
	if _f.lastDatastoreRequest[name]+refreshRate <= os.time() then
		_f.lastDatastoreRequest[name] = os.time()
		pcall(function() _f.savedData[name] = game:GetService('HttpService'):JSONDecode(game:GetService('HttpService'):GetAsync(dataURLs[name])) end)
	end
	if specificValue then
		if type(specificValue) == 'table' then
			local returnTbl = {}
			for _, neededValue in pairs(specificValue) do
				pcall(function() returnTbl[neededValue] = string.split(_f.savedData[name][neededValue], dividerKey) end)
			end
			return returnTbl
		elseif splitToTable then
			return string.split(_f.savedData[name][specificValue], dividerKey)
		end	
		return _f.savedData[name][specificValue]
	end
	return _f.savedData[name]
end
--


_f.isDay = function() -- Night is from 17:50 to 06:30, inclusive
	local min = game:GetService('Lighting'):GetMinutesAfterMidnight()
	return min > 6.5*60 and min < (17+5/6)*60
end

local ExternalData = {
	FFlag = "https://pastebin.com/raw/4htftcYg",
}	
local http = game:GetService("HttpService")
local externalCache = {}
_f.getExternalData = function(Type, SpecificValue)

	local function catchError(fn, errMsg)
		local succ, err = pcall(fn)

		if not succ then
			errMsg = string.gsub(errMsg, "[error]", err)
			warn(errMsg)
			return true
		end
		return false
	end

	local link

	if ExternalData[Type] then
		link = ExternalData[Type]
	else
		warn("Invalid External Data Type")
		return
	end

	local data, errored

	errored = catchError(function(err)
		data = http:GetAsync(link)
	end, 'Couldn\'t fetch External Data "'..Type..'", ([error])')


	if not errored then
		errored = catchError(function(err)
			data = http:JSONDecode(data)
		end, 'Couldn\'t decode External Data "'..Type..'", ([error])')
	end

	if errored then
		if not externalCache[Type] then
			warn('Couldn\'t get external data for "'..Type..'"')
			return
		end
		data = externalCache[Type]
	else
		externalCache[Type] = data
	end	

	if data then
		if SpecificValue then
			if data[SpecificValue] ~= nil then
				local  l = string.len(SpecificValue)
				local val = data[SpecificValue]
				if string.lower(string.sub(SpecificValue, l-9, l)) == "multiplier" and tonumber(val) == 0 then
					val = 1
				end
				return val
			else
				warn('Invalid Specific Value for External Data "'..Type..'", specific value: "'..SpecificValue..'"')
			end
		else
			return data
		end
	end	
end


-- RANDOM POKE
local PokemonByNumber = {}
local numerator = 1
local bannedSpecies = {
	forme = {
		megac=true,negative=true,white=true,black=true,
		dawnwings=true,duskmane=true,mega=true,megax=true,
		megay=true,gmax=true,primal=true,ultra=true,
		haunted=true,nitro=true,nitrotwo=true,shop=true,
		disguise=true,zen=true,nitrothree=true,attack=true,
		megah=true,dark=true,koinao=true,troll=true,
		hallow=true,cap=true,prince=true,doggers=true,
		ash=true,multi=true,school=true,deku=true,
		zerotwo=true,blaze=true,megaz=true,shadow=true,
		crowned=true,galarzen=true,mimikinsbusted=true,megae=true,
		static=true
	},
	pokemon = {pajantom=true},
	formeOfPokemon = {
		vivillon=true,floette=true,arceus=true,silvally=true,
		minior=true,florges=true,cramorant=true,flabebe=true,
		calyrex=true,necrozma=true,kyurem=true,morpeko=true,
		magikarp=true,gyarados=true,
	},
}

----GET RANDOMIZER POSSIBLE POKES
_f.validSpecies = {['ho-oh']=true,['porygon-z']=true,['kommo-o']=true,['hakamo-o']=true,['jangmo-o']=true}

for _, data in pairs(require(game.ServerStorage.BattleData.Pokedex)) do	
	if not data.baseSpecies and data.species and not data.forme and not bannedSpecies['pokemon'][data.species] then --this makes it exclude formes because it checks through gifdata for it
		PokemonByNumber[tostring(numerator)] = {species=data.species,forme=nil}
		numerator += 1
	end
end
for name, data in pairs(require(game.ServerStorage.Data.GifData)._FRONT) do
	if string.find(name, '-') and not _f.validSpecies[string.lower(name)] then
		name = string.split(name, '-')
		if name and not bannedSpecies['formeOfPokemon'][string.lower(name[1])] and not bannedSpecies['forme'][string.lower(name[2])] then
			PokemonByNumber[tostring(numerator)] = {species=name[1],forme=name[2]}
			numerator += 1
		else
		end
	end
end
-----
_f.randomizePoke = function(max)
	local Pokes = {}
	local maxID = numerator-1
	if not max then max = 1 end
	for i = 1, max do  
		local forme = nil
		local Pokemon
		local gifData 
		local gifData2
		while true do
			Pokemon = PokemonByNumber[tostring(math.random(1, maxID))]
			--Should I check for shinies also?
			gifData = _f.Database.GifData._FRONT[Pokemon.species..(Pokemon.forme and '-'..Pokemon.forme or '')]
			gifData2 = _f.Database.GifData._BACK[Pokemon.species..(Pokemon.forme and '-'..Pokemon.forme or '')]
			if (Pokemon.species and not bannedSpecies['pokemon'][string.lower(Pokemon.species)]) and gifData and gifData2 then
				break
			end
		end
		if Pokemon.forme and not bannedSpecies['forme'][string.lower(Pokemon.forme)] then
			forme = Pokemon.forme
		end
		table.insert(Pokes, {Pokemon.species, forme})
	end
	return Pokes	
end

local function install(module, name)
	if name then module.Name = name end
	--debug('Installing', module.Name)		
	module.Parent = frameworkModule
	_f[module.Name] = require(module)
end

do -- FirebaseService
	_f.FirebaseService = require(moduleFolder['FirebaseService'])
	moduleFolder['FirebaseService'].Parent = frameworkModule
end

do-- Feb 9, 2017: kinda mad that I have to write this workaround
	local Firebases = _f.FirebaseService
	local stores = game:GetService("DataStoreService")
	local errorText = 'Place has to be opened with Edit button to access DataStores'
	local errorText2 = 'You must publish this place to the web to access DataStore.'
	local efunc = function() error(errorText) end
	local fakeDataStore = {
		GetAsync = efunc,
		SetAsync = efunc,
		UpdateAsync = efunc,
		IncrementAsync = efunc,
		OnUpdate = function() end
	}
	_f.safelyGetDataStore = function(n, s)
		local ds
		local s, r = pcall(function() ds = Firebases:GetFirebase(n, s) end)
		if not s then
			if r == errorText or r:find(errorText2) then
				return fakeDataStore
			else
				error(r)
			end
		end
		return ds
	end
	_f.safelyGetOrderedDataStore = function(n, s)
		local ds
		local s, r = pcall(function() ds = stores:GetOrderedDataStore(n, s) end)
		if not s then
			if r == errorText or r:find(errorText2) then
				return fakeDataStore
			else
				error(r)
			end
		end
		return ds
	end
end

-- install the modules that are expected to be pre-installed or installed in particular order
for _, name in pairs({'Connection', 'Context', 'DataService',
	'Elo', 'BattleEngine'}) do -- BattleEngine just has to be installed before DataPersistence, and Elo before BattleEngine
	install(moduleFolder[name])
end

-- install the usable items
install(storage.src.UsableItemsServer, 'UsableItems')

-- misc installs
_f.PBStamps = require(storage.RuntimeModules.PBStamps){Utilities = _f.Utilities}
_f.RouletteSpinner = require(storage.RuntimeModules.RouletteSpinner){Utilities = _f.Utilities}

-- install all other modules
for _, module in pairs(moduleFolder:GetChildren()) do
	if module:IsA('ModuleScript') then
		install(module)
	end
end



-- Third Party
pcall(function()
	local _RB = require(storage.ThirdParty.RorianBraviary)
	_f.Connection:bindFunction('RorianBraviary', _RB.handleClientRequest)
end)


-- Load models
local insertService = game:GetService('InsertService')
local function safeLoadModel(groupAssetId, testAssetId)
	local assetId = (game.CreatorId == 1 and testAssetId or groupAssetId)
	while true do
		local success = false
		pcall(function()
			local loadedModel = insertService:LoadAsset(assetId)
			if loadedModel then
				success = true
				for _, m in pairs(loadedModel:GetChildren()) do
					if m:IsA('Model') then
						m.Parent = storage.Models
					end
				end
			end
		end)
		if success then break end
		wait(.5)
	end
end
wait()
spawn(function() safeLoadModel(656180015, 656169938) end) -- Heatran
wait(.25)






