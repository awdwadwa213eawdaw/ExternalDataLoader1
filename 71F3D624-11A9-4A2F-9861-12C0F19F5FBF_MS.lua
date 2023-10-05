return function(_p)
	--local _p = require(script.Parent)
	local Utilities = _p.Utilities

	-- change autosave settings (intervals, etc.) for battle colosseum / trade resort?

	local autosave = {
		enabled = false
	}

	local AUTOSAVE_INTERVAL = 2 * 60
	local AUTOSAVE_SHORT_INTERVAL = 30

	local lastSuccessfulAutosave = 0


	-- ui
	function autosave:animateSuccessfulAutosave()
		spawn(function()
			local create = Utilities.Create
			local floppy = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://6604436477',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(-0.05, 0, -0.05, 0),
				Position = UDim2.new(1.0, -20, 1.0, -20),
				ZIndex = 7, Parent = Utilities.frontGui,
			}
			local check = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://6604437727',
				ImageColor3 = Color3.new(124/255, 186/255, 99/255),
				ZIndex = 8, Parent = floppy,
			}
			Utilities.Tween(.5, 'easeOutCubic', function(a)
				floppy.ImageTransparency = 1-a
				check.ImageRectSize = Vector2.new(450*a, 450)
				check.Size = UDim2.new(a, 0, 1.0, 0)
			end)
			wait(1)
			Utilities.Tween(.5, 'easeOutCubic', function(a)
				floppy.ImageTransparency = a
				check.ImageTransparency = a
			end)
			floppy:Destroy()
		end)
	end
	--

	function autosave:canSave()
		return _p.Menu.enabled and _p.MasterControl.WalkEnabled and (not _p.NPCChat.chatBox or not _p.NPCChat.chatBox.Parent) and not _p.Battle.currentBattle and not _p.DataManager.currentChunk.data.noSaving
	end

	do
		local currentQueuedSaveThread

		function autosave:queueSave()
			if not self.enabled or currentQueuedSaveThread then return end
			local thisThread = {}
			currentQueuedSaveThread = thisThread
			Utilities.fastSpawn(function()
				while not self:canSave() do
					wait(2)
					if not self.enabled then return end
				end

				currentQueuedSaveThread = nil
			end)
		end
	end

	function autosave:attemptSave()
		if not self:canSave() then return false end
		local success = _p.PlayerData:save()
		if success then
			lastSuccessfulAutosave = tick()
			--		_p.DataManager:commitPermanentKeys()
			_p.Menu.willOverwriteIfSaveFlag = nil
			self:animateSuccessfulAutosave()
		end
		return success
	end

	--function autosave:tryEnable()
	--	if _p.Menu.willOverwriteIfSaveFlag then
	--		--
	--	end
	--end

	function autosave:enable()
		_p.DataManager:preload(6604436477, 6604437727)
		self.enabled = true
		delay(AUTOSAVE_SHORT_INTERVAL, function()
			while self.enabled do
				local et = tick()-lastSuccessfulAutosave
				if et < AUTOSAVE_INTERVAL-1 then
					wait(AUTOSAVE_INTERVAL-et)
				end
				if not self.enabled then return end
				if self:canSave() then
					local success = self:attemptSave()
					if success then
						wait(AUTOSAVE_INTERVAL)
					else
						-- notify player on-screen that an attempted autosave failed
						-- (but not every single short interval after the first failure)
						wait(AUTOSAVE_SHORT_INTERVAL)
					end
				else
					-- perhaps shorten the interval the longer it's been since a successful autosave
					-- (in case our timing has just been bad [e.g. player has opened menu on interval] up until now)
					wait(AUTOSAVE_SHORT_INTERVAL)
				end
			end
		end)
	end

	function autosave:disable()
		self.enabled = false
	end


	return autosave end