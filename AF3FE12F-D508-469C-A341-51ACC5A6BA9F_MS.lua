local _f = require(script.Parent)

-- NOTE: TO RUN THIS EVENT AGAIN:
--	InanimateInteract.ManaphyEgg must be OVH'd
--	There may be other work; investigate/test

math.randomseed(os.time()-1000)

local EGG_CHANCE_PER_WAVE = 2500 -- 1 in 600 per 7.4sec -> 1 per hour and 15 min per server on average
local EGG_MAX_STAY_DURATION = 10*60
--
local minZ = -2279
local maxZ = -2024
local avoid = {-2089, -2068}

local waveDuration = 2*math.pi/0.85 -- about 7.4 seconds

local Utilities = _f.Utilities--require(game:GetService('ServerStorage').Utilities)
local eggModel = game:GetService('ServerStorage'):WaitForChild('Models').ManaphyEgg
local sandCFrame = CFrame.new(-1199.79138, 87.9947205, 0--[[-2167.8999]], -4.47034836e-08, -0.258819133, 0.965925813, -2.98023224e-08, 0.965926051, 0.258819044, -1.00000036, 0, -4.37113883e-08)
local sandTopV = Vector3.new(-0.258819133, 0.965926051, 0)
local sandFrontV = sandCFrame.lookVector

local eggEnabled = false
local currentEgg, placeAt, mcf, timeEggArrived
local pickupRemoteFn = game:GetService('ReplicatedStorage'):WaitForChild('Remote').PickUpManaphyEgg -- a child is used to fire sounds

_f.Network:bindFunction('GrabManaphyEgg', function(player)
    if not eggEnabled then return false end
    
    local playerData = _f.PlayerDataService[player]
    
    if #playerData:getParty() >= 6 then
        return false
    end
    
    local egg = playerData:newPokemon {
        name = 'Manaphy',
        egg = true,
        shinyChance = 1024,
    }
    table.insert(playerData.party, #playerData:getParty() + 1, egg)
    eggEnabled = false
    currentEgg:Destroy()
    currentEgg = nil
    return true
end)

--wait(5*60)
wait(waveDuration)


while true do
	local now = tick()
	local thisCycleStart = now - ((now+.1) % waveDuration)
	local timeUntilNextCycle = thisCycleStart + waveDuration - now
	wait(timeUntilNextCycle)
	if not currentEgg and math.random(EGG_CHANCE_PER_WAVE) == 1 then
		local z, ok; repeat
			z = math.random(minZ, maxZ)
			ok = true
			for _, az in pairs(avoid) do
				if math.abs(z-az) <= 2 then
					ok = false
					break
				end
			end
		until ok
		local origin = sandCFrame + Vector3.new(0, 0, z)
		wait(.5)
		local egg = eggModel:Clone()
		local main = egg.Main
		mcf = main.CFrame
		local cfs = {}
		for _, p in pairs(egg:GetChildren()) do
			if p:IsA('BasePart') and p ~= main then
				cfs[p] = mcf:toObjectSpace(p.CFrame)
			end
		end
		mcf = mcf + Vector3.new(0, 0, z-mcf.p.z) + sandFrontV*6
		placeAt = function(ncf)--pos)
--			local ncf = mcf - mcf.p + pos
			main.CFrame = ncf
			for p, rcf in pairs(cfs) do
				p.CFrame = ncf:toWorldSpace(rcf)
			end
		end
		placeAt(mcf + (sandFrontV*5) + (sandTopV*.5))--origin * Vector3.new(-7, 1, 0))
		egg.Parent = workspace
		-- give egg initial position
		pickupRemoteFn.PlaySound:FireAllClients(main)
		Utilities.Tween(waveDuration/3, nil, function(a)
--			if not currentEgg then return false end
			local c = math.cos(a*math.pi*2)
			if a < .5 then
				placeAt(mcf + (sandFrontV * c * 5 + (sandTopV * (.5-a))))
			else
				placeAt(mcf + (sandFrontV * (-4+1*c)))
			end
--			if a < .5 then
--				local c = -math.cos(a*math.pi*2)
--				placeAt(origin * Vector3.new(0, -c, 7*c))
--			else
--				local c = math.cos((a-.5)*math.pi)
--				placeAt(origin * Vector3.new(0, -1, 6+c))
--			end
		end)
		currentEgg = egg
		eggEnabled = true
		timeEggArrived = tick()
		Utilities.Create 'StringValue' {
			Name = '#InanimateInteract',
			Value = 'ManaphyEgg',
			Parent = egg,
		}
	elseif currentEgg and tick()-timeEggArrived > EGG_MAX_STAY_DURATION then
		wait(.85)
		pcall(function()
			Utilities.Tween(waveDuration/3, nil, function(a)
				local c = math.cos((1-a)*math.pi*2)
				if a > .5 then
					placeAt(mcf + (sandFrontV * c * 5) + (sandTopV * (.5-a)))
				else
					placeAt(mcf + (sandFrontV * (-4+1*c)))
				end
			end)
			eggEnabled = false
			currentEgg:Destroy()
			currentEgg = nil
		end)
	end
end

return 0