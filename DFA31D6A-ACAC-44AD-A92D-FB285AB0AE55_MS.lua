return function(_p)
	local Utilities = _p.Utilities
	local Create = Utilities.Create
	local MasterControl = _p.MasterControl

	local shadowVoid = {
		isDoingCutscene = false,
		isInWormhole = false,
	}

	function shadowVoid:setupCutscene()
		--Audio
		_p.DataManager:preload()
		--Decals
		_p.DataManager:preload()

	end

	function shadowVoid:setupControls()

	end

	return shadowVoid
end