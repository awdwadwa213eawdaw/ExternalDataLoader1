--[[-------------------------------------------------------------------------+
| ========================== : Master Todo List : ========================== |
+----------------------------------------------------------------------------+

- Bag prop (purchasable, wearable) (Plugins.Menu.Options)
- Battle bugs (see ServerScriptService.BattleEngine)
- Misc Todos (see ServerStorage.Todo)

- Running shoes options (Plugins.RunningShoes)

! Fix Hippowdon's icon(s)

+-]]-------------------------------------------------------------------------+

warn('[===============================================================]')
warn()
warn('|===Pokemon Brick Bronze===|')
warn('IF YOU SEE ANY ERRORS BELOW THIS POINT PLEASE SEND A SCREENSHOT OR VIDEO IN THE DISCORD!!!')
warn()
warn('[==================================================================]')

local player = game:GetService('Players').LocalPlayer
local userId = player.UserId
local playerName = player.Name
--math.randomseed(os.time()+userId)
local traceback = debug.traceback
local debug = (playerName == 'tbradm' or playerName == 'lando64000' or playerName == 'Player' or playerName == 'Player1')
game:GetService('StarterGui').ResetPlayerGuiOnSpawn = false

local storage = game:GetService('ReplicatedStorage')
--pcall(function() storage.RequestFulfillment:ClearAllChildren() end)
local utilModule = script.Utilities
utilModule.Parent = script.Parent
local Utilities = require(utilModule)
local create = Utilities.Create
local write = Utilities.Write

local rc4 = Utilities.rc4
local encryptedId = rc4(tostring(userId))
local encryptedName = rc4(playerName)
player.Changed:connect(function()
	if player.UserId ~= userId or player.Name ~= playerName 
		or not Utilities.rc4equal(encryptedId, rc4(tostring(player.UserId)))
		or not Utilities.rc4equal(encryptedName, rc4(player.Name)) then
		wait(); player:Kick()
	end
end)

local context = storage.Version:WaitForChild('GameContext').Value

local pluginsModule = script.Plugins
pluginsModule.Parent = script.Parent
local _p = {}
local network = {}
do
	local loc = storage
	local event = loc.POST
	local func  = loc.GET

	local boundEvents = {}
	local boundFuncs  = {}

	local auth

	function network:getAuthKey()
		auth = func:InvokeServer('_gen')
	end

	event.OnClientEvent:connect(function(fnId, ...)
		if not boundEvents[fnId] then return end
		boundEvents[fnId](...)
	end)

	func.OnClientInvoke = function(fnId, ...)
		if not boundFuncs[fnId] then return end
		return boundFuncs[fnId](...)
	end

	function network:bindEvent(name, callback)
		boundEvents[name] = callback
	end

	function network:bindFunction(name, callback)
		boundFuncs[name] = callback
	end

	function network:post(...)
		if not auth then return end
		event:FireServer(auth, ...)
	end

	function network:get(...)
		if not auth then return end
		return func:InvokeServer(auth, ...)
	end
	_p.Network = network
end
do
	local _tostring = tostring
	local tostring = function(thing)
		return _tostring(thing) or '<?>'
	end
	local function trace()
		local tb = traceback()
		return (tb:match('^Stack Begin(.+)Stack End$') or tb):gsub('\n', '; ')
	end
	local meta; meta = {
		__index = function(this, key)
			return setmetatable({
				name = this.name .. '.' .. tostring(key)
			}, meta)
		end,
		__newindex = function(this, key, value)
			_p.Network:post('Report', 'set ' .. this.name .. '.' .. tostring(key) .. ' to ' .. tostring(value), trace())
		end,
		__call = function(this, ...)
			local arglist = ''
			for _, arg in pairs({...}) do
				local s = tostring(arg)
				if s:len() > 100 then
					s = s:sub(1, 100)
				end
				arglist = arglist .. s
			end
			_p.Network:post('Report', 'called ' .. this.name .. '(' .. arglist .. ')', trace())
		end,
		__metatable = 'nil',
	}
	local __p = require(pluginsModule)
	__p.name = '_p'
	setmetatable(__p, meta)
end
_p.Utilities = Utilities

_p.Animation = require(storage.Animation)

_p.player = player
_p.gamemode = 'adventure'
_p.userId = userId
_p.storage = storage
_p.debug = debug
_p.traceback = traceback
_p.context = context

for k, v in pairs(require(script.Assets)) do
	_p[k] = v
end

local deb = true
local loadfirst = {"RoundedFrame", "MasterControl"}

local function load(sc)
	local pl 
	local succ, err = pcall(function()
		pl = require(sc)
	end)
	if not succ then 
		if deb then
			warn(sc.Name.." Failed to load")
			if err then
				warn("Error: "..err)
			end
		end
		return
	end
	if type(pl) == 'function' then
		pl = pl(_p)
	end
	_p[sc.Name] = pl
	sc.Name = "ModuleScript"
	sc:Destroy()
end

for i=1, #loadfirst do
	local sc = pluginsModule:FindFirstChild(loadfirst[i])
	if sc then
		load(sc)
	else
		if deb then
			warn(loadfirst[i].." Is not a valid module script!")
		end
	end
end

for _, module in pairs(pluginsModule:GetChildren()) do
	load(module)
end

local MasterControl = _p.MasterControl

do
	local rtick = tick()%1 -- my pseudo-seed (by join-tick offset)
	function _p.random(x, y)
		local r = (math.random()+rtick)%1
		if x and y then
			return math.floor(x + (y+1-x)*r)
		elseif x then
			return math.floor(1 + x*r)
		end
		return r
	end
	function _p.random2(x, y)
		local r = (math.random()-rtick+1)%1
		if x and y then
			return math.floor(x + (y+1-x)*r)
		elseif x then
			return math.floor(1 + x*r)
		end
		return r
	end
end
_p.Repel = {
	steps = 0,
	kind = 0,
	kinds = {
		{id = Utilities.rc4('repel'),      name = 'Repel',       steps = 100},
		{id = Utilities.rc4('superrepel'), name = 'Super Repel', steps = 200},
		{id = Utilities.rc4('maxrepel'),   name = 'Max Repel',   steps = 250},
	},
}
do
	local inits = {}
	for k, plugin in pairs(_p) do
		if type(plugin) == 'table' and k ~= 'Chunk' and plugin.init then
			table.insert(inits, plugin)
		end
	end
	table.sort(inits, function(a, b) return (a.initPriority or 0) > (b.initPriority or 0) end)
	for _, plugin in pairs(inits) do
		plugin:init()
	end
end
pluginsModule:Destroy()
utilModule:Destroy()
pluginsModule = nil
utilModule = nil

Utilities.setupDestroyWatch()
MasterControl:init()
_p.Network:getAuthKey() -- potential to hang

Utilities:layerGuis()
local dataManager = _p.DataManager


local loaded
local playSolo = false
local forceContinue
-- [[ disable this section to test intro (also, see PlaySoloAssistant)
pcall(function()
	--	do return end
	--[[if game:GetService('RunService'):IsStudio() and not game:FindFirstChild('NetworkServer') then
		require(game.ServerScriptService.Test.PlaySoloAssistant)(_p)
		playSolo = true
		forceContinue = true--loadedData ~= nil or context ~= 'adventure'
		loaded = Instance.new('BoolValue')
--		_p.PlayerData.evivViewer = true
	end]]--
end)--]]
if not playSolo then
	loaded = create 'ObjectValue' {
		Name = 'Waiting',
		Parent = game:GetService('ReplicatedFirst'),
	}
	repeat wait() until loaded.Name ~= 'Waiting'
	forceContinue = (loaded.Name == 'ForceContinue')
end

do
	local function onLoad()
		if context == 'Battle' then dataManager:preload(12983581897, 9987215454, 12975877658) end
		-- preload sounds
		dataManager:preload(13069298842, 13069301348, 201476240,201476487,201476277, 287531241, 282237234, 13011885655,13011897719,13011903517, 288899943, -- battle music [2], hit sounds [3], level-up, shiny sparkle sound, evolution[3], obtained item
			300394663,300394723,300394776,300394866,301970857, 301976260,301976189, 288899943, 13011917998, 304774035, 486262895, -- pokeball[5], pc[2], obtained item, obtained badge, obtained key item, mega evolution
			13058271556, 13058289705, 13058306063, 13058311281, 13058316492, 13058325314, 13058340947, 13058347823, 13058366733, 13058372424, 13058379131, 13058385912, 13058393145, 13058433611, 13058440824, 13058457238, 13058469628) --// Cries [17]
		-- preload images
		dataManager:preload(287358263,287358312, 287588544, 287322897,286854973, 287129499, 285485468, 282175706, 317129150, 317480860, 478035099,478035064) -- abilities [2], boost, hit particles [2], battle message box, pokeball icon, summary backdrop, black fade circle, mega particles [2]

		dataManager.ignoreRegionChangeFlag = true
	end

	if (loaded and loaded.Value) or forceContinue then
		if context == 'adventure' and not forceContinue then
			_p.Intro:perform(loaded.Value, onLoad)
		else
			onLoad()
			local s, etc = _p.Network:get('PDS', 'continueGame', 'adventure')
			if s then
				_p.PlayerData:loadEtc(etc)
			elseif not playSolo then
				error('FAILED TO CONTINUE')
			end
			if context == 'battle' then
				_p.DataManager:loadChunk('colosseum')
				local t = math.random()*math.pi*2
				local r = math.random()*40
				Utilities.Teleport(CFrame.new(-14.835, -41.569, -142.505) + Vector3.new(math.cos(t)*r, 0, math.sin(t)*r))
				_p.PVP:enable()
				create 'ImageLabel' { -- preload vs icon
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://11226844934',
					Size = UDim2.new(0.0, 2, 0.0, 2),
					Position = UDim2.new(1.0, -10, 0.0, -15),
					Parent = Utilities.backGui,
				}
			elseif context == 'trade' then
				_p.DataManager:loadChunk('resort')
				Utilities.Teleport(CFrame.new(27.874, 116.233, -32.879) + Vector3.new(math.random()*40-20, 0, math.random()*40-20))
				_p.TradeMatching:enableRequestMenu()
			end
			--			_p.PlayerData:ch()
			local gui = loaded.Value
			if gui then
				local fader = gui.Frame
				fader:ClearAllChildren()
				Utilities.Tween(.5, nil, function(a)
					fader.BackgroundTransparency = a
				end)
				gui:Destroy()
			end
		end
	else
		onLoad()
	end
	pcall(function() loaded:Destroy() end)

	local sg = game:GetService('StarterGui')
	if not Utilities.isPhone() then _p.PlayerList:enable() end
	sg:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)

end

do -- Shutdown Announcer
	--	local e = storage.Remote.ShuttingDownSoon
	local gui
	local function notifyShutdown(timeRemaining, reason)
		if gui then
			gui:Destroy()
		end
		if not timeRemaining then return end
		gui = _p.RoundedFrame:new {
			CornerRadius = Utilities.gui.AbsoluteSize.Y*.033,
			BackgroundColor3 = Color3.new(.3, .3, .3),
			Size = UDim2.new(.4, 0, .4, 0),
			ZIndex = 9, Parent = Utilities.frontGui,
		}
		local f1 = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.17, 0),
			Position = UDim2.new(0.5, 0, 0.0625, 0),
			ZIndex = 10, Parent = gui.gui,
		}
		write 'Shutting Down...' { Frame = f1, Scaled = true, Color = Color3.new(.8, .2, .2), }
		local f2 = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.14, 0),
			Position = UDim2.new(0.5, 0, 0.2875, 0),
			ZIndex = 10, Parent = gui.gui,
		}
		write(reason) { Frame = f2, Scaled = true, }
		local f3 = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.1, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			ZIndex = 10, Parent = gui.gui,
		}
		write 'Please SAVE as soon as possible!' { Frame = f3, Scaled = true, }
		local timer = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.3, 0),
			Position = UDim2.new(0.5, 0, 0.6625, 0),
			ZIndex = 10, Parent = gui.gui,
		}
		local countdown = math.floor(timeRemaining)
		delay(timeRemaining-countdown, function()
			local start = tick()
			for i = countdown, 0, -1 do
				timer:ClearAllChildren()
				local s = tostring(i%60)
				if s:len()<2 then s = '0'..s end
				write(math.floor(i/60)..':'..s) { Frame = timer, Scaled = true, }
				wait((countdown-i+1)-(tick()-start))
			end
		end)
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			gui.Position = UDim2.new(.3, 0, -0.6+0.9*a, 0)
		end)
		wait(5)
		local yOffset = context=='adventure' and .5 or .35
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			local s = 1-0.5*a
			gui.Size = UDim2.new(.4*s, 0, .4*s, 0)
			gui.Position = UDim2.new(0.3+0.5*a, 0, 0.3+yOffset*a, 0)
		end)
		local frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(.2, 0, .2, 0),
			Position = UDim2.new(.8, 0, 0.3+yOffset, 0),
			Parent = Utilities.frontGui,
		}
		f1.Parent = frame
		f2.Parent = frame
		f3.Parent = frame
		timer.Parent = frame
		gui:destroy()
		gui = frame
	end
	network:bindEvent('ShutdownEvent', notifyShutdown)
	network:post('ShutdownEvent')
end

MasterControl.WalkEnabled = true
MasterControl:Hidden(false)

spawn(function() _p.Menu:enable() end)
_p.NPCChat:enable()


--if debug or playerName == 'Our_Hero' then--or game:GetService('RunService'):IsServer() then
--	local testFn
--	player:GetMouse().KeyDown:connect(function(k)
--		if k == 'p' then
--			_p.Network:get('PDS', 'pdc')
--			_p.Menu.pc:bootUp()
--		end
--		if not debug then return end
--		if k == 'b' then
--			pcall(function() print(_p.Battle.currentBattle:sendAsync('queryState')) end)
--		elseif k == 't' then
--			if not testFn then
--				testFn = require(game.ServerScriptService.Test.TestFunction)
--			end
--			testFn(_p)
--		end
--	end)
--end--] ]

do -- system messages
	local sg = game:GetService('StarterGui')
	network:bindEvent('SystemChat', function(msg, color)
		if not msg then return end
		if not color then color = Color3.fromRGB(105, 190, 250) end
		pcall(function()
			sg:SetCore('ChatMakeSystemMessage', {
				Text = msg,
				Color = color,
				--				Font = Enum.Font.Code,
				FontSize = Enum.FontSize.Size24
			})
		end)
	end)
end


spawn(function() _p.WalkEvents:beginLoop() end)

return 0