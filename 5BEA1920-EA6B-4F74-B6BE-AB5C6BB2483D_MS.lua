return function(_p)--local _p = require(script.Parent)
local Utilities = _p.Utilities

local MusicManager = {}

local musicStack     = {}
local desiredVolumes = setmetatable({}, {__mode = 'k'})
local fadeThreads    = setmetatable({}, {__mode = 'k'})

--[[ uses of Utilities.loopSound:
-	region music
-	 room music
-	  trainer eyes meet (2 places)
-	   battle music
	
-	evolution
-	continue menu
-	parents abducted scene
	
-- uses of chunk:fadeMusicVolume
-	chunk - entering door
-	      - exiting door
-	trainer eyes meet (2 places)
-	before and after parents abducted scene
	
--]]

function MusicManager:getMusicStack()
	return musicStack
end

function MusicManager:getMusicNamed(name)
	for _, m in pairs(musicStack) do
		if m.Name == name then
			return m
		end
	end
end

function MusicManager:fadeToVolume(music, relVolume, fadeDuration)
	if music == 'top' or music == true then
		music = musicStack[#musicStack]
	elseif type(music) == 'string' then
		local st = music
		music = self:getMusicNamed(st)
		if not music then
			warn('unable to find music "'..st..'".')
			return
		end
	end
	if not music then return end
	local volume = (desiredVolumes[music] or .5) * relVolume
	local thisThread = {}
	fadeThreads[music] = thisThread
	local sv = music.Volume
	Utilities.Tween(fadeDuration or 1, nil, function(a)
		if fadeThreads[music] ~= thisThread then return false end
		music.Volume = sv + (volume - sv)*a
	end)
end

function MusicManager:prepareToStack(fadeDuration) -- fades music to be silent, ready to stack a new music
	local topMusic = musicStack[#musicStack]
	if not topMusic then return end
	self:fadeToVolume(topMusic, 0, fadeDuration)
end

function MusicManager:stackMusic(id, name, desiredVolume)
	local topMusic = musicStack[#musicStack]
	if topMusic and topMusic.Volume > 0 then
		spawn(function()
			self:fadeToVolume(topMusic, 0, .5)
		end)
	end
	local music = Utilities.loopSound(id, desiredVolume)
	music.Name = name
	table.insert(musicStack, music)
	if desiredVolume then
		desiredVolumes[music] = desiredVolume
	end
	return music
end

-- returns immediately
function MusicManager:popMusic(name, fadeDuration, silence)
	local startIndex
	if name == 'all' or name == true then
		startIndex = 1
	else
		for index, music in pairs(musicStack) do
			if music.Name == name then
				startIndex = index
				break
			end
		end
	end
	if not startIndex then return false end
	local fadeMusic = table.remove(musicStack)
	while #musicStack >= startIndex do
		local m = table.remove(musicStack)
		desiredVolumes[m] = nil
		fadeThreads[m] = nil
		m:Stop()
		delay(.5, function() -- Jul 28 '16 ROBLOX update bug workaround
			m:Destroy()
		end)
	end
	if not silence then
		spawn(function()
			self:returnFromSilence(fadeDuration or 1)
		end)
	end
	if not fadeMusic then return true end
	spawn(function()
		if fadeDuration then
			self:fadeToVolume(fadeMusic, 0, fadeDuration)
		end
		desiredVolumes[fadeMusic] = nil
		fadeThreads[fadeMusic] = nil
		fadeMusic:Stop()
		delay(.5, function() -- Jul 28 '16 ROBLOX update bug workaround
			fadeMusic:Destroy()
		end)
	end)
	return true
end

function MusicManager:returnFromSilence(fadeDuration)
	local topMusic = musicStack[#musicStack]
	if not topMusic then return end
	self:fadeToVolume(topMusic, 1, fadeDuration)
end


return MusicManager end