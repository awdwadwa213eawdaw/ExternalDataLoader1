local ServerScriptService = game:GetService("ServerScriptService")
local ChatService = require(ServerScriptService:WaitForChild("ChatServiceRunner"):WaitForChild("ChatService"))
local Players = game:GetService("Players")
local Settings = require(script.Settings)

-- optimized by BlueGuyCodes

local function getTag(TagData)
	return     {
		TagText = TagData.Text, 
		TagColor = TagData.Color
	}
end

ChatService.SpeakerAdded:Connect(function(PlrName)
	local Speaker = ChatService:GetSpeaker(PlrName)
	local plr = Players[PlrName]
	local rank = plr:GetRankInGroup(Settings.GroupId)    
	local tags = {}

	if Settings.TagById[tostring(plr.UserId)] then
		table.insert(tags, getTag(Settings.TagById[tostring(plr.UserId)]))
	end

	if rank and Settings.GroupTags[tostring(rank)] then
		table.insert(tags, getTag(Settings.GroupTags[tostring(rank)]))
	end

	if #tags > 0 then
		Speaker:SetExtraData('Tags', tags)
	end
end)