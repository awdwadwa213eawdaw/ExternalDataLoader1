local _f = require(script.Parent.Parent)
local Utilities = _f.Utilities
local rc4 = Utilities.rc4

-- TODO:
-- "stnshp" and "bp" shops encrypt after they are requested; move this to before

local encryptedShop = {
	pkbl = {rc4('pokeball'),     200},
	grbl = {rc4('greatball'),    600},
	utbl = {rc4('ultraball'),   1200},
	ptn  = {rc4('potion'),       300},
	sptn = {rc4('superpotion'),  700},
	hptn = {rc4('hyperpotion'), 1200},
	mptn = {rc4('maxpotion'),   2500},
	frst = {rc4('fullrestore'), 3000},
	reve = {rc4('revive'),      1500},
	antd = {rc4('antidote'),     100},
	przh = {rc4('paralyzeheal'), 150},
	awk  = {rc4('awakening'),    250},
	brnh = {rc4('burnheal'),     250},
	iceh = {rc4('iceheal'),      250},
	flhl = {rc4('fullheal'),     600},
	escr = {rc4('escaperope'),   550},
	rpl  = {rc4('repel'),        350},
	srpl = {rc4('superrepel'),   500},
	mrpl = {rc4('maxrepel'),     700},
	rcdy = {rc4('rarecandy'),    2500},

	ntbl = {rc4('netball'),     1000},
	lxbl = {rc4('luxuryball'),  1000},
	qkbl = {rc4('quickball'),   1000},
	dkbl = {rc4('duskball'),    1000},

	pmbl = {rc4('pumpkinball'), 2500}, -- OCTOBER
	gnms = {rc4('gengariteh'), 100},   -- OCTOBER
	--fsbl = {rc4('frostyball'), 2500}, -- DECEMBER
}

local dailyBalls = {
	{
		{rc4('toxicball'),     2000},
		{rc4('insectball'),    2000},
		{rc4('icicleball'),    2000},
	}, {
		{rc4('skyball'),       2000},
		{rc4('zapball'),       2000},
	}, {
		{rc4('fistball'),      2000},
		{rc4('flameball'),     2000},
		{rc4('dracoball'),     2000},
	}, {
		{rc4('spookyball'),    2000},
		{rc4('pixieball'),     2000},
	}, {
		{rc4('earthball'),     2000},
		{rc4('stoneball'),     2000},
		{rc4('dreadball'),     2000},
	}, {
		{rc4('colorlessball'), 2000},
		{rc4('splashball'),    2000},
	}, {
		{rc4('mindball'),      2000},
		{rc4('meadowball'),    2000},
		{rc4('steelball'),     2000},
	}
}

return function(self, shopId) -- where self is the PlayerData
	--	print('Shop ID:', shopId)
	if shopId == 'pbemp' then
		local items = {}
		table.insert(items, encryptedShop.pkbl)
		table.insert(items, encryptedShop.grbl)
		table.insert(items, encryptedShop.utbl)
		table.insert(items, {rc4'masterball', 'r15', 'MasterBall'})
		table.insert(items, encryptedShop.ntbl)
		table.insert(items, encryptedShop.lxbl)
		table.insert(items, encryptedShop.qkbl)
		table.insert(items, encryptedShop.dkbl)

		if _f.Date:getDate().MonthNum == 10 then -- OCTOBER
			table.insert(items, encryptedShop.pmbl)
		end

		--		if _f.Date:getDate().MonthNum == 12 then -- DECEMBER
		--			table.insert(items, encryptedShop.fsbl)
		--		end

		for _, ball in pairs(dailyBalls[_f.Date:getDate().WeekdayNum + 1]) do
			table.insert(items, ball)
		end
		return items
	elseif shopId == 'stnshp' then
		local stoneShop = {
			{rc4('firegem'),     5000},
			{rc4('watergem'),    5000},
			{rc4('electricgem'), 5000},
			{rc4('grassgem'),    5000},
			{rc4('icegem'),      5000},
			{rc4('fightinggem'), 5000},
			{rc4('poisongem'),   5000},
			{rc4('groundgem'),   5000},
			{rc4('flyinggem'),   5000},
			{rc4('psychicgem'),  5000},
			{rc4('buggem'),      5000},
			{rc4('rockgem'),     5000},
			{rc4('ghostgem'),    5000},
			{rc4('dragongem'),   5000},
			{rc4('darkgem'),     5000},
			{rc4('steelgem'),    5000},
			{rc4('normalgem'),   5000},
			{rc4('fairygem'),    5000},

			{rc4('waterstone'),    15000},
			{rc4('firestone'),     15000},
			{rc4('leafstone'),     15000},
			{rc4('thunderstone'),  15000},
			{rc4('moonstone'),     15000},
			{rc4('icestone'),      15000},

			{rc4('venusaurite'),   75000},
			{rc4('blastoisinite'), 75000},
			{rc4('charizarditex'), 75000},
			{rc4('charizarditey'), 75000},
			{rc4('ampharosite'),   50000},
			{rc4('beedrillite'),   50000},
			{rc4('slowbronite'),   50000},
			{rc4('pidgeotite'),    50000},
			{rc4('banettite'),     50000},
			{rc4('scizorite'),     50000},
			{rc4('sharpedonite'),  50000},
			{rc4('heracronite'),   50000},
			{rc4('pinsirite'),     50000},
			{rc4('altarianite'),   50000},
			{rc4('aerodactylite'), 50000},
			{rc4('alakazite'),     50000},
			{rc4('lopunnite'),     50000},
			{rc4('cameruptite'),   50000},
			{rc4('mawilite'),      50000},
			{rc4('manectite'),     50000},
			{rc4('houndoominite'), 50000},
			{rc4('glalitite'),   50000},
			{rc4('lucarionite'),   100000},
			{rc4('aggronite'),     100000},
			{rc4('garchompite'),   100000},
			{rc4('salamencite'),   100000},
			{rc4('tyranitarite'),  100000},
			{rc4('metagrossite'),  100000},
			{rc4('lopunnitee'),  200000},
		}

		--		if self.completedEvents.NiceListReward then -- during the Winter 2016 event, only people who completed the event could purchase Ice Stones
		--			table.insert(stoneShop, 24, {rc4('icestone'), 30000})
		--		end

		return stoneShop
	elseif shopId == 'bp' then
		local items = {
			{'BP10', 10},
			{'BP50', 30},
			{'BP200', 75},
			{'BP2000', 200},
			{'hpreset', 10},
			{'attackreset', 10},
			{'defensereset', 10},
			{'spatkreset', 10},
			{'spdefreset', 10},
			{'speedreset', 10},
			{'sawsbuckcoffee', 16},
			{'razorfang', 24},
			{'razorclaw', 24},
			{'affectionribbon', 24},
			{'airballoon', 24},
			{'weaknesspolicy', 24},
			{'eviolite', 24},
			{'scopelens', 24},
			{'focussash', 24},
			{'bindingband', 24},
			{'widelens', 24},
			{'seaincense', 24},
			{'laxincense',  24},
			{'roseincense', 24},
			{'pureincense', 24},
			{'rockincense', 24},
			{'oddincense',  24},
			{'waveincense', 24},
			{'fullincense', 24},
			{'luckincense', 50},
			{'sachet', 30},
			{'whippeddream', 30},
			{'assaultvest', 30},
			{'flameorb', 30},
			{'toxicorb', 30},
			{'duskstone', 38},
			{'dawnstone', 38},
			{'shinystone', 38},
			{'lifeorb', 50},
			{'rockyhelmet', 50},
			{'heavydutyboots', 50},
			{'machobrace', 60},
			{'upgrade', 75},
			{'metalcoat', 75},
			{'abilitycapsule', 100},
			{'abilitypatch', 750},
			{'lonelymint', 250},
			{'adamantmint', 250},
			{'naughtymint', 250},
			{'bravemint', 250},
			{'boldmint', 250},
			{'impishmint', 250},
			{'laxmint', 250},     
			{'relaxedmint', 250},  
			{'modestmint', 250},
			{'mildmint', 250},
			{'rashmint', 250},
			{'quietmint', 250},
			{'calmmint', 250},
			{'gentlemint', 250},
			{'carefulmint', 250},
			{'sassymint', 250},
			{'timidmint', 250},
			{'hastymint', 250},
			{'jollymint', 250},
			{'naivemint', 250},
			{'seriousmint', 250},  
			{'choiceband', 500},  
			{'choicespecs', 500},  
			{'choicescarf', 500},  
			{'TM01 Hone Claws', 45},
			{'TM04 Calm Mind', 45},
			{'TM21 Frustration', 45},
			{'TM27 Return', 45},
			{'TM44 Rest', 45},
			{'TM54 False Swipe', 45},
			{'TM12 Taunt', 55},
			{'TM28 Dig', 60},
			{'TM47 Low Sweep', 60},
			{'TM30 Shadow Ball', 60},
			{'TM53 Energy Ball', 60},
			{'TM19 Roost', 65},
			{'TM77 Psych Up', 65},
			{'TM72 Volt Switch', 65},
			{'TM89 U-turn', 65},
			{'TM16 Light Screen', 70},
			{'TM33 Reflect', 70},
			{'TM20 Safeguard', 70},
			{'TM17 Protect', 70},
			{'TM13 Ice Beam', 90},
			{'TM24 Thunderbolt', 90},
			{'TM35 Flamethrower', 90},
			{'TM26 Earthquake', 90},
			{'TM73 Thunder Wave', 90},
			{'TM75 Swords Dance', 90},
			{'TM80 Rock Slide', 90},
			{'TM03 Psyshock', 95},
			{'medichamite', 150},
			{'blazikenite', 100},
			{'swampertite', 100},
			{'sceptilite', 100},
			{'gengarite', 100},
			{'gyaradosite', 100},
			{'galladite', 100},
			{'gardevoirite', 100},
			{'kangaskhanite', 125}
		}
		if _f.Date:getDate().MonthNum == 10 then -- OCTOBER
			table.insert(items, encryptedShop.gnms)
		end
		return items
	elseif shopId == 'dt' then
		local items = {
			{rc4('tropicsticket'),     1000},
		}
		return items
	elseif shopId == 'arcade' then
		local Prizes = {
			{"powerweight",     750},
			{"powerbracer",     750},
			{"powerbelt",       750},
			{"powerlens",       750},
			{"powerband",       750},
			{"poweranklet",     750},
			{"audinite",        1500},
			{"destinyknot",     3500},
			{"luckyegg",        15000},
			{"TM09 Venoshock",  1500},
			{"TM90 Substitute", 1500},
			{"TM02 Dragon Claw",1500},
			{"TM29 Psychic",    2000},
			{"PKMN Audino",    2000},
			{"PKMN Chansey",    2500},
			{"PKMN Ditto",    7500},
			{"HOVER Mega Salamence Board",    15000},
			{"PKMN Zeraora",17000},
		}
		if self.flags.AA50 then
			table.insert(Prizes, {"HOVER Shiny M.Salamence Board",    25000})
		end
		return Prizes
	end

	local items = {}
	local badges = self:countBadges()
	table.insert(items, encryptedShop.pkbl)
	if badges >= 1 then table.insert(items, encryptedShop.grbl) end
	if badges >= 3 then table.insert(items, encryptedShop.utbl) end
	table.insert(items, encryptedShop.ptn)
	if badges >= 1 then table.insert(items, encryptedShop.sptn) end
	if badges >= 2 then table.insert(items, encryptedShop.hptn) end
	if badges >= 4 then table.insert(items, encryptedShop.mptn) end
	if badges >= 5 then table.insert(items, encryptedShop.frst) end
	if badges >= 6 then table.insert(items, encryptedShop.rcdy) end
	if badges >= 2 then table.insert(items, encryptedShop.reve) end
	table.insert(items, encryptedShop.antd)
	table.insert(items, encryptedShop.przh)
	if badges >= 1 then table.insert(items, encryptedShop.awk)  end
	if badges >= 1 then table.insert(items, encryptedShop.brnh) end
	if badges >= 1 then table.insert(items, encryptedShop.iceh) end
	if badges >= 3 then table.insert(items, encryptedShop.flhl) end
	if badges >= 1 then table.insert(items, encryptedShop.escr) end
	if badges >= 1 then table.insert(items, encryptedShop.rpl)  end
	if badges >= 2 then table.insert(items, encryptedShop.srpl) end
	if badges >= 3 then table.insert(items, encryptedShop.mrpl) end
	return items
end
