return function(_p)
	local ui = script.Roulette
	local RouletteSpinner
	local isopen

	spawn(function()
		while wait() do
			pcall(function()
				ui.Main.Button.Visible = _p.player.PlayerGui.MainGui.Menu.Visible
			end)
		end
	end)
	
	ui.Main.Button.MouseButton1Down:Connect(function()
		if isopen then return end
		
		isopen = true
		spawn(function() _p.Menu:disable() end)
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		
		if not RouletteSpinner then
			RouletteSpinner = _p.DataManager:loadModule("RouletteSpinner")
		end
		RouletteSpinner:openSpinner()
		
		spawn(function() _p.Menu:enable() end)
		_p.MasterControl.WalkEnabled = true
		isopen = false
	end)
	
	ui.Parent = _p.player:WaitForChild('PlayerGui')
end