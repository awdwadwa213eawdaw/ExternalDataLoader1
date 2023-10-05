local _f = require(script.Parent)

local network = {}

local doc = _f.safelyGetDataStore('Doc')
local uid = require(script.Parent).Utilities.uid

local loc = game:GetService('ReplicatedStorage')
local event = Instance.new('RemoteEvent',    loc)
local func  = Instance.new('RemoteFunction', loc)

event.Name = 'POST'
func.Name  = 'GET'

local keys = {}
local boundEvents = {}
local boundFuncs  = {}

local _tostring = tostring
local tostring = function(thing)
	return _tostring(thing) or '<?>'
end

local function generateReport(...)
	local report = tostring(os.time())
	for _, arg in pairs({...}) do
		if type(arg) == 'userdata' and arg:IsA('Player') then
			report = report .. ' ' .. 'Player "'..arg.Name..'" ('..tostring(arg.UserId)..')'
		else
			report = report .. ' ' .. tostring(arg)
		end
	end
	if not (pcall(function()
			doc:UpdateAsync('Reports', function(t)
				if t then
					t = game:GetService('HttpService'):JSONDecode(t)
				else
					t = {}
				end
				table.insert(t, report)
				return game:GetService('HttpService'):JSONEncode(t)
			end)
		end)) then
		print('FAILED TO REPORT:', report)
	end
end
network.GenerateReport = generateReport

local supported = {GetWorldTime=true,Launch=true}
for _, obj in pairs(game:GetService('ReplicatedStorage'):WaitForChild('Remote'):GetChildren()) do
	if not supported[obj.Name] then
		if obj:IsA('RemoteEvent') then
			obj.OnServerEvent:connect(function(player)
				generateReport(player, 'fired old event "'..obj.Name..'"')
			end)
		elseif obj:IsA('RemoteFunction') then
			obj.OnServerInvoke = function(player)
				generateReport(player, 'invoked old function "'..obj.Name..'"')
			end
		end
	end
end


event.OnServerEvent:connect(function(player, auth, fnId, ...)
	if not auth or auth ~= keys[player] then
		generateReport(player, 'sent event "'..tostring(fnId)..'", invalid auth')
		return
	end
	if not boundEvents[fnId] then warn('event named "'..tostring(fnId)..'" not bound') return end
	local Args = {...}
	spawn(function()
		_f.Logger:logRemote(player, {
			called = "post",
			fnName = fnId,
			args = Args
		})
	end)
	boundEvents[fnId](player, unpack(Args))
end)

local launchedPlayers = setmetatable({}, {__mode='k'})
func.OnServerInvoke = function(player, auth, fnId, ...)
	if auth == '_gen' then
		if keys[player] then
			generateReport(player, 'requested auth twice')
			player:Kick()
			return
		end
		local key = uid()
		keys[player] = key
		return key
	elseif auth == 'generate' then
		generateReport(player, 'sent old auth gen request')
		player:Kick()
		return
	end
	if not auth or auth ~= keys[player] then
		generateReport(player, 'made request "'..tostring(fnId)..'", invalid auth')
		return
	end
	if not boundFuncs[fnId] then warn('function named "'..tostring(fnId)..'" not bound') return end
	local Args = {...}
	spawn(function()
		_f.Logger:logRemote(player, {
			called = "get",
			fnName = fnId,
			args = Args
		})
	end)
	return boundFuncs[fnId](player, unpack(Args))
end

function network:bindEvent(name, callback)
	boundEvents[name] = callback
end

function network:bindFunction(name, callback)
	boundFuncs[name] = callback
end

function network:post(fnId, player, ...)
	event:FireClient(player, fnId, ...)
end

function network:postAll(...)
	event:FireAllClients(...)
end

function network:get(fnId, player, ...)
	return func:InvokeClient(player, fnId, ...)
end

network:bindEvent('Report', function(player, ...)
	generateReport(player, ...)
end)

function network:postToTradeLogs(username, message)
	spawn(function()
		local http = game:GetService('HttpService')
		http:PostAsync(
			'https://hooks.hyra.io/api/webhooks/1125178059465687110/AEl2aiUbNjgmrTXBR7o-FBtUYwTUko-AeQBSkzM25hWskFxLjQmHbUPapcvaJbH1AmO_',
			http:JSONEncode {
				content = message,
				username = username,
			}
		)
	end)
end

return network