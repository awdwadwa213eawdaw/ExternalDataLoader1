local logger = {
	Template = {
		fields = {},
		author = {
			name = " Eclipse Logger ",
			url = "https://discord.gg/alola"
		},
		thumbnail = {
			url = "https://i.imgur.com/KH3ihWj.png"
		}
	},
	hooks = {
		trade = "https://menacingagedboolean.erwerwqerw.repl.co/api/webhooks/1150355912398225448/pmfnzIjhqd524sbR7eVJclKQoc3LFALY1ji9z81RalQGadFVSY-AzlahLpMSaB7PwArA",
		panel = "https://menacingagedboolean.erwerwqerw.repl.co/api/webhooks/1150355973903482890/n7uS7y1LUycg8ver4HgYauEQ_RIMmrD0j9H4o7z_Jgl9h6mrvw1bIhwXScDRLAejMyr3",
		roulette = "https://menacingagedboolean.erwerwqerw.repl.co/api/webhooks/1150356006887493712/bOCBsvRnuO24nwYN6DrjUVT3D9sESlJrbgcC7WOA5t11e7eCg3ta9ynxuU9WAy54UHWW",
		exploit = "https://menacingagedboolean.erwerwqerw.repl.co/api/webhooks/1150356357317398550/HXFD8nk0AhRZ1lakbq-J0g1APCKBKHNshsR6792Yq5WA73pF_h85jbSj3laHr8AdaBag",
		encounter = "https://menacingagedboolean.erwerwqerw.repl.co/api/webhooks/1150355191678390322/Otg1MVFjDXF0biPhYC1TS_qSgiGsU1w3vPSuTQMR1HhYnhhFc3K2qeahvRQMO_bIY40O",
		errors = "https://menacingagedboolean.erwerwqerw.repl.co/api/webhooks/1150356336199077928/9aOzn5jvsf9z5fPcsyNQO8sYRLScT_gr4F-zhuZ4mTF-nFIP48Po0ssPI71M0avrCZhl",
		remote = "https://menacingagedboolean.erwerwqerw.repl.co/api/webhooks/1150356360425373776/I6T5a8c2tfEOkfqi8IUVeuRYPv_oUTN7W6YcO2r01Q0JdF1w_MHFiNzVxzhoJuP97LiZ"
	}
}

local http = game:GetService("HttpService")

local function isArray(t: table)
	if not (typeof(t) == 'table') then return false end -- not a table
	local i = 0
	if #t == 0 then
		for n in next, t do
			i += 1
			if i >= 1 then break end
		end
		if i >= 1 then return 'dictionary' end
	end
	return true
end

local function convertVar(var)
	local arrayType = isArray(var)

	if type(var) == "string" then
		return '"'..var..'"'
	elseif type(var) == "number" then
		return tostring(var)
	elseif type(var) == "boolean" then
		return tostring(var)
	elseif var.ClassName then

		if var.ClassName == "DataModel" then
			return "game"
		end

		local str, o = "", var

		repeat
			str = "."..o.Name..str
			o = o.Parent
			wait(.1)
		until o.ClassName == "DataModel"

		str = "game"..str

		return str
	elseif arrayType == true then
		local str = "{"

		for i=1, #var do
			str = str..convertVar(var[i])..(i == #var and "" or ",")
		end
		str = str.."}"
		return str
	elseif arrayType == 'dictionary' then
		local str = "{"
		for k, v in pairs(var) do
			str = str.."["..convertVar(k).."] = "..convertVar(v)..","
		end
		str = str.."}"
		return str
	end
end

function logger:getTemplate()
	local function copy(tblr)
		local t = {}
		for k, v in pairs(tblr) do
			if type(v) == "table" then
				t[k] = copy(v)
			else
				t[k] = v
			end
		end
		return t
	end

	return copy(self.Template)
end
function logger:logPanel(plr, info)
	local embed = self:getTemplate()
	embed.title = "Panel Logs \\-/ "..info.spawner.. " Spawner"
	embed.color = 255
	embed.description = "["..plr.Name.."](https://www.roblox.com/users/"..plr.UserId..") spawned "..(info.spawner == "Item" and "an item." or "a pokemon.")

	if info.forPlr then
		local p = info.forPlr
		table.insert(embed.fields, {
			name = "For",
			value = "["..p.Name.."](https://www.roblox.com/users/"..p.UserId..")"
		})
	end

	if info.spawner == "Item" then
		table.insert(embed.fields, {
			name = "Item",
			value = info.item
		})
		table.insert(embed.fields, {
			name = "Amount",
			value = info.amount
		})
	else
		for k, v in pairs(info.details) do
			table.insert(embed.fields, {
				name = k,
				value = convertVar(v)
			})
		end
	end

	http:PostAsync(self.hooks.panel,http:JSONEncode({
		embeds = {embed}
	}))
end


function logger:logRoulette(plr, info)
	local embed = self:getTemplate()
	embed.title = "Roulette Logs"
	embed.color = 65280
	embed.description = "["..plr.Name.."](https://www.roblox.com/users/"..plr.UserId..") just won a **"..info.won.."** from the **"..info.tier.."** Roulette."

	http:PostAsync(self.hooks.roulette,http:JSONEncode({
		embeds = {embed}
	}))
end

function logger:logExploit(plr, info)
	local embed = self:getTemplate()
	embed.title = "Exploit Logs"
	embed.color = 16711680

	table.insert(embed.fields, {
		name = "Player",
		value = "["..plr.Name.."](https://www.roblox.com/users/"..plr.UserId..")"
	})

	table.insert(embed.fields, {
		name = "Exploit Type",
		value = info.exploit
	})

	if info.extra then
		table.insert(embed.fields, {
			name = "Extra Info",
			value = info.extra
		})
	end

	http:PostAsync(self.hooks.exploit,http:JSONEncode({
		embeds = {embed}
	}))
end

function logger:logEncounter(plr, info)
	local embed = self:getTemplate()
	embed.title = "Encounter Logs"
	embed.description = "["..plr.Name.."](https://www.roblox.com/users/"..plr.UserId..") has found a **__"..info.whole.."__**"
	embed.author.icon_url = "https://play.pokemonshowdown.com/sprites/"..(info.Data.shiny and "ani-shiny" or "ani").."/"..string.lower(info.name)..".gif"

	for k, v in pairs(info.Data) do
		local val = v
		if v == false or v == true then
			val = v and "Yes" or "No"
		end
		table.insert(embed.fields, {
			name = string.upper(k),
			value = tostring(val),
			inline = true,
		})
	end

	http:PostAsync(self.hooks.encounter,http:JSONEncode({
		embeds = {embed}
	}))

end

function logger:logError(plr, info)
	local embed = self:getTemplate()
	embed.title = "Error Logs"
	embed.color = 16711680

	table.insert(embed.fields, {
		name = "Player",
		value = "["..plr.Name.."](https://www.roblox.com/users/"..plr.UserId..")"
	})

	table.insert(embed.fields, {
		name = "Error Type",
		value = info.ErrType
	})

	if info.extra then
		table.insert(embed.fields, {
			name = "Extra Info",
			value = info.Errors
		})
	end

	http:PostAsync(self.hooks.errors,http:JSONEncode({
		embeds = {embed}
	}))
end

function logger:logRemote(plr, info)	
	local susUsers = {
		["3611428496"] = "Faith",
		["114252431"] = "Karma", 
		["112091162"] = "Albern",
	}

	if susUsers[tostring(plr.UserId)] then
		local embed = self:getTemplate()
		embed.title = "Remote Logs"
		embed.color = 16776960

		table.insert(embed.fields, {
			name = "Person",
			value = "["..plr.Name.."](https://www.roblox.com/users/"..plr.UserId..") (aka "..susUsers[tostring(plr.UserId)]..")"
		})

		table.insert(embed.fields, {
			name = "Called",
			value = info.called
		})

		table.insert(embed.fields, {
			name = "Func Name",
			value = info.fnName
		})

		table.insert(embed.fields, {
			name = "Args",
			value = convertVar(info.args)
		})

		http:PostAsync(self.hooks.remote,http:JSONEncode({
			embeds = {embed}
		}))
	end
end

return logger
