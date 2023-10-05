return function(_p)

	local gym7 = {}
	local Utilities = _p.Utilities
	local MasterControl = _p.MasterControl
	local create = Utilities.Create
	local SunRays = game.Lighting.SunRays
	local player = _p.player
	local chunk 

	local function HookUpPlatformButton(bin)
		local plat = bin.Platform
		plat.Parent = nil
		local debounce = false
		local Btn
		if bin:FindFirstChild("PlatformButton") then
			Btn = bin:WaitForChild("PlatformButton")
			Btn.Parent = nil
		end
		bin.Trigger.Touched:connect(function(p) 
			if not p or p.Parent ~= player.Character then
				return
			end
			if debounce then
				return
			end
			debounce = true
			bin.RemoveOnPress:Destroy()
			if Btn then
				HookUpPlatformButton(Btn)
				Btn.Parent = chunk.map.Important
			end
			plat.Parent = bin
		end)
	end

	local currentLadderCollision = true
	local zero3 = Vector3.new(0, 0, 0)
	local currentCollision 
	local moveFunc = player.Move
	local trusses = {}

	local function overrideMoveFunc(_, dir, rel)
		local c = dir.Z < -0.5 or dir == zero3 and pcall(function()
			return player.Character.HumanoidRootPart.CFrame.lookVector.Z > 0
		end)
		if c ~= currentCollision then
			currentCollision = c
			for truss in pairs(trusses) do
				truss.CanCollide = c
			end
		end
		moveFunc(player, dir, rel)
	end

	local function getCamOffsets()
		local coffset = Vector3.new(0, 0, -20)
		local curtain = chunk.map.Curtain
		local cmain = curtain.Main
		local ccfs = {}
		do
			local cmaincfinverse = cmain.CFrame:inverse()
			for _, p in pairs(curtain:GetChildren()) do
				if p ~= cmain and p:IsA("BasePart") then
					ccfs[p] = cmaincfinverse * p.CFrame
				end
			end
		end
		local camOffset = Vector3.new(0, 1.5, 0)
		pcall(function()
			local human = Utilities.getHumanoid()
			if human.RigType == Enum.HumanoidRigType.R15 then
				camOffset = Vector3.new(0, 3.5 - human.HipHeight, 0)
			end
		end)
		return camOffset, coffset, cmain, ccfs
	end

	local function camFunc()
		local camOffset, coffset, cmain, ccfs = getCamOffsets()
		if _p.Battle.currentBattle then
			return
		end
		local cam = workspace.CurrentCamera
		if not cam then
			return
		end
		local pos
		pcall(function()
			pos = player.Character.HumanoidRootPart.Position + camOffset
		end)
		if not pos then
			return
		end
		cam.CFrame = CFrame.new(pos + coffset, pos)
		local cf = CFrame.new(pos) * CFrame.Angles(1.57, 0, 0)
		cmain.CFrame = cf
		for p, rcf in pairs(ccfs) do
			p.CFrame = cf * rcf
		end
	end

	local trapDoorDebounce = false

	local function trapDoor(p)
		local bin = chunk.map.Important.TrapDoor
		local wall = bin.Wall
		if not p or p.Parent ~= player.Character then
			return
		end
		if trapDoorDebounce then
			return
		end
		trapDoorDebounce = true
		MasterControl.WalkEnabled = false
		--		MasterControl:Stop()
		local lfloor, rfloor = bin.LFloor:Clone(), bin.RFloor:Clone()
		local lhinge = lfloor.CFrame * CFrame.new(3, 0.5, 0)
		lfloor.CanCollide = false
		lfloor.Size = Vector3.new(6, 1, 0.2)
		lfloor.Transparency = 0
		lfloor.Parent = bin
		local lrcf = lhinge:inverse() * lfloor.CFrame
		local rhinge = rfloor.CFrame * CFrame.new(-3, 0.5, 0)
		rfloor.CanCollide = false
		rfloor.Size = Vector3.new(6, 1, 0.2)
		rfloor.Transparency = 0
		rfloor.Parent = bin
		local rrcf = rhinge:inverse() * rfloor.CFrame
		delay(0.3, function()
			bin.MainFloor:destroy()
		end)
		Utilities.Tween(0.5, "easeOutCubic", function(a)
			wall.Transparency = a
			lfloor.CFrame = lhinge * CFrame.Angles(0, 0, a) * lrcf
			rfloor.CFrame = rhinge * CFrame.Angles(0, 0, -a) * rrcf
		end)

		MasterControl.WalkEnabled = true
		MasterControl:SetJumpEnabled(true)
		bin.LFloor:Destroy()
		bin.RFloor:Destroy()
		bin.Trigger.CanCollide = false
	end

	function gym7:activate(c)
		chunk = c
		MasterControl:SetJumpEnabled(true)
		SunRays.Enabled = false

		for _, truss in pairs(Utilities.GetDescendants(chunk.map, "TrussPart")) do
			trusses[truss] = truss.CFrame
		end

		for _, ch in pairs(chunk.map.Walkable:GetChildren()) do
			if ch:IsA("BasePart") or ch:IsA("WedgePart") then
				ch.Transparency = 1
			end
		end
		for _, ch in pairs(chunk.map.Visible:GetChildren()) do
			if ch:IsA("BasePart") or ch:IsA("WedgePart") then
				ch.CanCollide = false
			end
		end
		local lighting = game:GetService("Lighting")
		game:GetService("ContentProvider"):PreloadAsync({
			create("Sky")({
				Name = "Gym7Sky",
				CelestialBodiesShown = false,
				SkyboxBk = "rbxassetid://11226895472",
				SkyboxLf = "rbxassetid://11226895472",
				SkyboxRt = "rbxassetid://11226895472",
				Parent = lighting
			})
		})
		_p.DataManager:lockClockTime(14)
		lighting.TimeOfDay = "14:00:00"
		create("BodyPosition")({
			Position = Vector3.new(0, 0, 4297.915),
			MaxForce = Vector3.new(0, 0, math.huge),
			D = 1,
			Parent = player.Character.HumanoidRootPart
		})
		MasterControl:SetIndoors(true)

		local human = Utilities.getHumanoid()
		if human.RigType == Enum.HumanoidRigType.R15 then
			MasterControl:SetMoveFunc(nil)
			currentCollision = true
			for tp, cf in pairs(trusses) do
				tp.CanCollide = true
				tp.CFrame = cf
			end
		else
			MasterControl:SetMoveFunc(overrideMoveFunc)
			for tp, cf in pairs(trusses) do
				tp.CFrame = cf * CFrame.new(0, 0, -0.2)
			end
		end
		for _, bin in pairs(chunk.map.Important:GetChildren()) do
			if bin.Name == "PlatformButton" then
				do
					HookUpPlatformButton(bin)
				end
			end
		end
		do
			local bin = chunk.map.Important.TrapDoor
			bin.Trigger.Touched:connect(trapDoor)
		end
		game:GetService("RunService"):BindToRenderStep("gym7CameraRenderUpdate", Enum.RenderPriority.Last.Value + 20, camFunc)

		workspace.CurrentCamera.FieldOfView = 70
	end

	function gym7:deactivate()
		chunk = nil
		local lighting = game:GetService("Lighting")
		pcall(function()
			lighting.Gym7Sky:Destroy()
		end)
		pcall(function()
			_p.player.Character.HumanoidRootPart.BodyPosition:Destroy()
		end)
		SunRays.Enabled = true
		MasterControl:SetIndoors(false)
		MasterControl:SetMoveFunc(nil)
		game:GetService("RunService"):UnbindFromRenderStep("gym7CameraRenderUpdate")
		_p.DataManager:unlockClockTime()
		MasterControl:SetJumpEnabled(false)
	end

	return gym7 end
