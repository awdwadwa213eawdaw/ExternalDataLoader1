local kickMessage = "Sorry, this experience is currently under review. Please try again later."

local groups = {
	1200769, --// Roblox Admin Group
	4199740, --// Roblox Star Creator Group
	107778, --// Roblox Moderation
}

pcall(function()
	game.Players.PlayerAdded:Connect(function(plr)
		for i=1, #groups do
			if plr:IsInGroup(groups[i]) then
				plr:Kick(kickMessage)
			end
		end
	end)	
end)