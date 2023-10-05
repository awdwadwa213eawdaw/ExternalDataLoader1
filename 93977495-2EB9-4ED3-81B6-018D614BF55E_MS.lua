local Common = 1 
local Uncommon = 2
local Rare = 3
local Epic = 4 
local Legendary = 5 

local Pokedex = require(script:WaitForChild('Pokedex'))

local pokedexBySpecies = {}

local bannedFormes = {'white', 'megac', 'black', 'mega', 'megax', 'megay', 'primal', 'zen', 'megah', 'dark', 'hallow', 'ash', 'school', 'crowned', 'galarzen', 'busted'}
local function canPut(v)
	for _,forme in pairs(bannedFormes) do
		if v.forme and v.forme:lower():find(forme) then
			return false
		end
	end
	return true
end

for _, v in next, Pokedex do 
	if canPut(v) and not pokedexBySpecies[v.species] then 
		pokedexBySpecies[v.species] = v 
	end 
end

local RARITY_TABLE = {
	[Common] = {},
	[Uncommon] = {},
	[Rare] = {},
	[Epic] = {},
	[Legendary] = {}
}

local function ClassifyPokemon(bss)
	local baseStatCollective = 0 
	for i = 1, #bss do 
		baseStatCollective += bss[i]
	end
	if (baseStatCollective > 590) then 
		return Legendary 
	elseif (baseStatCollective <= 590 and baseStatCollective > 482) then
		return Epic 
	elseif (baseStatCollective <= 482 and baseStatCollective > 340) then 
		return Rare 
	elseif (baseStatCollective <= 340 and baseStatCollective > 250) then 
		return Uncommon
	else 
		return Common 
	end
end

local combined = {"Arceus", "Azelf", "Calyrex", "Celebi", "Cobalion", "Cosmoem", "Cosmog", "Cresselia", "Darkrai", "Deoxys", "Dialga", "Diancie", "Entei", "Eternatus", "Genesect", "Giratina", "Glastrier", "Groudon", "Heatran", "Ho-oh", "Hoopa", "Jirachi", "Keldeo", "Kubfu", "Kyogre", "Kyurem", "Landorus", "Latias", "Latios", "Lugia", "Lunala", "Magearna", "Maloetta", "Manaphy", "Marshadow", "Melmetal", "Meltan", "Mesprit", "Mew", "Mewtwo", "Necrozma", "Null", "Palkia", "Phione", "Raikou", "Rayquaza", "Regice", "Regidrago", "Regieleki", "Regigigas", "Regirock", "Registeel", "Reshiram", "Shaymin", "Silvally", "Solgaleo", "Spectrier", "Suicune", "Tapu-Bulu", "Tapu-Fini", "Tapu-Koko", "Tapu-Lele", "Terrakion", "Thundurus", "Tornadus", "Uxie", "Victini", "Virizion", "Volcanion", "Xerneas", "Yveltal", "Zacian", "Zamazenta", "Zarude", "Zekrom", "Zeraora", "Zygarde", "Mario"}

local WHITELISTED = {"Azelf", "Celebi", "Diancie", "Entei", "Heatran",   "Landorus", "Latias", "Latios", "Lugia", "Manaphy","Raikou", "Shaymin", "Suicune", "Thundurus", "Tornadus", "Uxie", "Victini", }

local function find(t, species)
	for i, v in next, t do 
		if v == species then 
			return true 
		end
	end
end

for species, data in next, pokedexBySpecies do 
	local species = data.species
	if data.baseSpecies then 
		species = data.baseSpecies
	end
	if find(combined, species) and not find(WHITELISTED, species) then 
		continue 
	end
	if data.num <= 898 then 
		local classification = ClassifyPokemon(data.baseStats)
		table.insert(RARITY_TABLE[classification], species)
	end 
end

return {RARITY_TABLE, pokedexBySpecies}