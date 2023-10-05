return require(script.Parent.CSV)({
	map = {
		name = function(v)
			return string.lower(v)
		end,
	}
	--[[
	ALL = not allowed at all (unless AG)
	Bn = Banlist only
	type = Typing of pokemon allowed
	| = Used to seperate multiple tiers/moves
	]]
}, [[name,tier,forme,moves,item
hiddenpower,[Empty],[Empty],[Empty],[Empty]
Mewtwo,Bn,,,
Marshadow,Bn,,,
Zekrom,Bn,,,
Reshiram,Bn,,,
Eternatus,Bn,,,
Kyogre,Bn,,,blueorb
Groudon,Bn,,,redorb
Blastoise,Bn,,,blastoisite
Blaziken,Bn,,,blazikenite
Salamence,Bn,,,salamencite
Dragapult,Bn,,,ghostiumz
]])