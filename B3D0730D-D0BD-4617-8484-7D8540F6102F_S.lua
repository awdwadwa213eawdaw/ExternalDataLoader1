l = game:service("Lighting")
Light = script.Parent.SpotLight
LightSource = script.Parent


--[[
Hello! This script will turn this red light green when the time reaches 18:00:00, or 6 PM,
then return to red at 7:30, or 7:30 AM. With enough flexibility, you can make this do 
other things!
]]

function toMinutes(hour) --turns something like 7.5 hours into 450 minutes.
hour = hour * 60
return hour
end

--This uses a 24 hour format.
--This example uses 18:00 to 7:30, or 6 PM to 7:30 AM

local time1 = 18 --18:00, or 6:00 PM
local time2 = 7.5 --07:30, or 7:30 AM

function event1() --Event when the time is within your designated time.
	Light.Enabled = true
	LightSource.Material = "Neon"
end

function event2() --Event when the time is outside your designated time.
	Light.Enabled = false
	LightSource.Material = "SmoothPlastic"
end

function onChanged()
	if time2 <= time1 then
		if l:GetMinutesAfterMidnight() >= toMinutes(time1) or l:GetMinutesAfterMidnight() <= toMinutes(time2) then
		event1()
		else
		event2()
		end
	elseif time2 >= time1 then
		if l:GetMinutesAfterMidnight() >= toMinutes(time1) and l:GetMinutesAfterMidnight() <= toMinutes(time2) then
		event1()
		else
		event2()
		end
	end
end

l.Changed:connect(onChanged)
