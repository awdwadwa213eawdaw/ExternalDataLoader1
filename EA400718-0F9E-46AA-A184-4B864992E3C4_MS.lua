return function(_p)

	game:GetService('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	local stepped = game:GetService('RunService').RenderStepped

	--local _p = require(script.Parent)
	local Utilities = _p.Utilities
	local animation = _p.AnimatedSprite
	local create = Utilities.Create
	local write = Utilities.Write


	local intro = {}


	function intro:newGame(fader)
		local canChat = true
		spawn(function() pcall(function() canChat = game:GetService('Chat'):CanUserChatAsync(_p.userId) end) end)
		_p.DataManager:preload(13206650540, 13206658822, 13206665797)
		Utilities:layerGuis()
		--	Utilities.Teleport(CFrame.new(44, 54, 135))
		local ac = Utilities.getHumanoid()
		local isR15 = ac.RigType == Enum.HumanoidRigType.R15
		local sleepTrack = ac:LoadAnimation(Utilities.Create'Animation'{AnimationId='rbxassetid://'.._p.animationId[isR15 and'R15_IntroSleep'or'IntroSleep']})
		local sitTrack   = ac:LoadAnimation(Utilities.Create'Animation'{AnimationId='rbxassetid://'.._p.animationId[isR15 and'R15_IntroWake'or'IntroSit']})
		local throwTrack = isR15 and ac:LoadAnimation(Utilities.Create'Animation'{AnimationId='rbxassetid://'.._p.animationId.R15_IntroTossClock}) or nil
		-- [[
		Utilities.sound(13488227260, nil, nil, 35)--288901896, nil, .5, 35)
		local cam = workspace.CurrentCamera
		cam.CameraType = Enum.CameraType.Scriptable
		-- route 1
		spawn(function()
			Utilities.Tween(.5, nil, function(a)
				fader.BackgroundTransparency = a
			end)
			wait(7)
			Utilities.Tween(.5, nil, function(a)
				fader.BackgroundTransparency = 1-a
			end)
		end)
		local p1 = Vector3.new(-48.1, 70, -5.7)
		local p2 = Vector3.new(7.1, 63.4, -17.3)
		local f1 = Vector3.new(-58.3, 63.4, -27.9)
		local f2 = Vector3.new(1.7, 62.6, -5.7)
		Utilities.Tween(8, nil, function(a)
			local p = p1:Lerp(p2, a)
			local f = f1:Lerp(f2, a)
			cam.CoordinateFrame = CFrame.new(p, f)
		end)
		-- dig site
		spawn(function()
			Utilities.Tween(.5, nil, function(a)
				fader.BackgroundTransparency = a
			end)
			wait(7)
			Utilities.Tween(.5, nil, function(a)
				fader.BackgroundTransparency = 1-a
			end)
		end)
		p1 = Vector3.new(102, 78, 189.6)
		p2 = Vector3.new(109.8, 87.1, 249)
		f1 = Vector3.new(121, 70.5, 240.6)
		f2 = Vector3.new(134.4, 82.5, 252.6)
		Utilities.Tween(8, nil, function(a)
			local p = p1:Lerp(p2, a)
			local f = f1:Lerp(f2, a)
			cam.CoordinateFrame = CFrame.new(p, f)
		end)
		-- lab
		spawn(function()
			Utilities.Tween(.5, nil, function(a)
				fader.BackgroundTransparency = a
			end)
			wait(7)
			Utilities.Tween(.5, nil, function(a)
				fader.BackgroundTransparency = 1-a
			end)
		end)
		p1 = Vector3.new(-46.6, 57.6, 179.8)
		p2 = Vector3.new(-108,  57.6, 179.8)--82.2, 204.2)
		local ptimer = Utilities.Timing.cubicBezier(8, .05, 0, .75, 1)
		local ptimer2 = Utilities.Timing.cubicBezier(8, .4, 0, .75, .75)
		f1 = Vector3.new(-74.6, 60, 179.8)
		f2 = Vector3.new(-138.4, 65.4, 189.4)
		Utilities.Tween(8, nil, function(a)
			local t = ptimer2(a*8)
			local p = p1:Lerp(p2, ptimer(a*8)) + Vector3.new(0, (82.2-57.6)*t, (204.2-179.8)*t)
			local f = f1:Lerp(f2, a)
			cam.CoordinateFrame = CFrame.new(p, f)
		end)
		-- house window
		spawn(function()
			Utilities.Tween(.5, nil, function(a)
				fader.BackgroundTransparency = a
			end)
		end)
		local f = Vector3.new(-29.816, 65.6, 136.415)
		Utilities.Tween(8, nil, function(a)
			local d = 1 + 20*(1-a)
			local p = f + Vector3.new(2, 1, 0).unit*d
			cam.CoordinateFrame = CFrame.new(p, f)
			if a > 7/8 then
				fader.BackgroundTransparency = 1 - (a*8-7)
			end
		end)--]]
		-- chunk/room setup
		local chunk = _p.DataManager.currentChunk
		chunk.indoors = true
		local room = chunk:getRoom('yourhomef1', chunk:getDoor('yourhomef1'), 1)
		chunk.roomStack = {room}
		chunk:stackSubRoom('yourhomef2', room.model.SubRoom, true)
		room = chunk.roomStack[2]
		chunk:bindIndoorCam()
		local root = _p.player.Character.HumanoidRootPart
		if isR15 then
			room.model.NewGameSpawn.CanCollide = false
		end
		root.Anchored = true
		Utilities.Teleport(room.model.NewGameSpawn.CFrame + (isR15 and Vector3.new(0, -.8+1+1.35, .3) or Vector3.new(0, 3, 1)))
		_p.MasterControl:SetIndoors(true)
		-- character
		local face
		pcall(function()
			face = _p.player.Character.Head.face.Texture
			_p.player.Character.Head.face.Texture = 'rbxassetid://14036939449'
		end)
		sleepTrack:Play(0)
		local alarm = Utilities.sound(292244949)
		wait(4)
		Utilities.Tween(.5, nil, function(a)
			fader.BackgroundTransparency = a
		end)
		wait(3)
		local character = _p.player.Character
		local ac = chunk.roomStack[2].model.AlarmClock
		local chat = _p.NPCChat
		local donomove = true
		spawn(function()
			while donomove do
				wait()
				pcall(function() 
					_p.MasterControl.WalkEnable = false
					_p.MasterControl:Stop()
				end)
			end
		end)
		if isR15 then
			local function schedule(animTrack, kfName, kfTime, func)
				local fired = false
				local cn
				local function onFire()
					if fired then return end
					fired = true
					pcall(function() cn:disconnect() end)
					cn = nil
					func()
				end
				cn = animTrack.KeyframeReached:connect(function(reachedKfName) if reachedKfName == kfName then onFire() end end)
				delay(kfTime+.05, onFire)
			end
			local alarmParts = {}
			local leftHand = character:FindFirstChild('LeftHand')
			local hold = false
			throwTrack:Play()
			schedule(throwTrack, 'Grab', 3.45, function()
				local lcf = leftHand.CFrame
				for _, p in pairs(ac:GetChildren()) do
					if p:IsA('BasePart') then
						alarmParts[p] = lcf:toObjectSpace(p.CFrame)
						p.CanCollide = false
					end
				end
				hold = true
				while hold do
					stepped:wait()
					local cf = leftHand.CFrame
					for p, rcf in pairs(alarmParts) do
						p.CFrame = cf:toWorldSpace(rcf)
					end
				end
			end)
			local proceed = Utilities.Signal()
			schedule(throwTrack, 'Throw', 3.8, function()
				hold = false
				local mcf = ac.Main.CFrame
				local offset = Vector3.new(4, 2, -20)
				local vol = alarm.Volume
				delay(.25, function() Utilities.sound(292244971, nil, nil, 5) end)
				Utilities.Tween(.5, nil, function(a)
					Utilities.MoveModel(ac.Main, mcf + offset*a)
					alarm.Volume = vol * (1-a)
				end)
				alarm:Destroy()
				ac:Destroy()
				proceed:fire()
			end)
			proceed:wait()

			-- jump out of bed
			wait(2)
			chat:enable()
			pcall(function() _p.player.Character.Head.face.Texture = face end)
			chat:say('...oh wait!')
			sitTrack:Play()
			delay(.1, function() sleepTrack:Stop() end)
			schedule(sitTrack, 'GetUp', 2.25, function()
				local rcf = root.CFrame
				Utilities.Tween(.5, 'easeInOutQuad', function(a)
					root.CFrame = rcf + Vector3.new(3.75*a, 0, 0)
				end)
				root.Anchored = false
			end)
			wait(4)
		else
			local m = create 'Model' { Parent = workspace, create 'Humanoid' {} }
			local larmNames = {['Left Arm']=true, LeftUpperArm=true, LeftLowerArm=true, LeftHand=true}
			local --[[larm,]] larmclone = create 'Part' {
				Name = 'Left Arm',
				Anchored = true,
				CanCollide = false,
				Size = Vector3.new(1, 2, 1),
				TopSurface = Enum.SurfaceType.Smooth,
				BottomSurface = Enum.SurfaceType.Smooth,
				Parent = m,
			}
			local torso = character:FindFirstChild('Torso')
				or character:FindFirstChild('UpperTorso')
			for _, obj in pairs(character:GetChildren()) do
				if obj:IsA('CharacterAppearance') and not obj:IsA('BodyColors')then
					obj:Clone().Parent = m
				elseif obj:IsA('Part') and obj.Name == 'Left Arm' then
					larmclone.BrickColor = obj.BrickColor
					--			larm = obj
					--			larmclone = larm:Clone()
					--			larmclone.Anchored = true
					--			larmclone.Parent = m
					--			larm.Transparency = 1
				end
			end
			for name in pairs(larmNames) do
				pcall(function() character[name].Transparency = 1 end)
			end

			local f = Vector3.new()
			local cframe = CFrame.new
			local angles = CFrame.Angles
			local function point()
				local joint = (torso.CFrame * cframe(-1, 0.5, 0)).p
				local top = (joint-f).unit
				local right = Vector3.new(0, 1, 0):Cross(top)
				local back = right:Cross(top)
				Utilities.MoveModel(larmclone, cframe(joint.x, joint.y, joint.z,
					right.x, top.x, back.x,
					right.y, top.y, back.y,
					right.z, top.z, back.z) * cframe(-0.5, -0.5, 0), true)
			end

			local p1 = (torso.CFrame*cframe(-1.5, -1, 0)).p
			local pts = {
				ac.Main.Position + Vector3.new(0, 1, -1.5),
				ac.Main.Position + Vector3.new(0, 0, -1.5),
				ac.Main.Position + Vector3.new(0, 2, 0),
				ac.Main.Position + Vector3.new(0, 0, 1.5),
				ac.Main.Position + Vector3.new(0, 1.5, -0.5),
				ac.Main.Position + Vector3.new(0, 0, -3),
				ac.Main.Position + Vector3.new(0, 1.5, -1),
				ac.Main.Position,
			}
			for _, p2 in pairs(pts) do
				Utilities.Tween(.5, nil, function(a)
					f = p1:Lerp(p2, a)
					pcall(point)
				end)
				p1 = p2
			end
			p2 = ac.Main.Position + Vector3.new(10, 8, -20)
			ac.Parent = m
			spawn(function()
				Utilities.Tween(.4, nil, function(a)
					f = p1:Lerp(p2, a)
					pcall(point)
				end)
			end)
			wait(.1)
			local from = ac.Main.Position
			local to = p2
			local pos1 = p2
			local pos2 = (torso.CFrame*cframe(-1.5, -1, 0)).p
			local v = alarm.Volume
			ac.Parent = chunk.map
			delay(.15, function() Utilities.sound(292244971, nil, nil, 5) end)
			Utilities.Tween(.5, nil, function(a)
				f = pos1:Lerp(pos2, a)
				pcall(point)
				local pos = from:Lerp(to, a)
				Utilities.MoveModel(ac.Main, ac.Main.CFrame - ac.Main.Position + pos, true)
				alarm.Volume = v * (1-a)
			end)
			alarm:Destroy()
			ac:Destroy()

			m:Destroy()
			--		pcall(function() larmclone:Destroy() end)
			--		pcall(function() larm.Transparency = 0 end)
			for name in pairs(larmNames) do
				pcall(function() character[name].Transparency = 0 end)
			end
			-- jump out of bed
			wait(2)
			chat:enable()
			pcall(function() _p.player.Character.Head.face.Texture = face end)
			chat:say('...oh wait!')
			sitTrack:Play(.5)
			sleepTrack:Stop(.5)
			wait(1.5)
			local cf = room.model.NewGameSpawn.CFrame
			Utilities.Tween(.4, 'easeInOutCubic', function(a)
				pcall(function() root.CFrame = cf * CFrame.Angles(0, math.pi*-.5*a, 0) + Vector3.new(0, 3, 1) end)
			end)
			root.Anchored = false
			wait()
			_p.player:Move(Vector3.new(5, 0, 0), false)
			sitTrack:Stop(.25)
			wait(.25)
			_p.player:Move(Vector3.new())
			local cf = root.CFrame
			Utilities.Tween(.4, 'easeOutCubic', function(a)
				pcall(function() root.CFrame = cf * CFrame.Angles(0, math.pi/2*a, 0) end)
			end)
		end
		wait(.2)
		donomove = false
		-- monologue
		chat:say('I can\'t believe today has finally come!',
			'Today I get my first pokemon from the pokemon Professor!',
			'I have always dreamed of setting out on my own adventure with pokemon by my side!',
			'There are so many pokemon in this world!',
			'I hope to discover them all one day!',
			'Well, I\'d better get going!')
		if canChat then
			chat:say('Oh, I almost forgot!',
				'I need to fill out my Trainer Card!')
			--	_p.PlayerData.pokedex = nil
			_p.Menu.card:enterName()
			wait(1)
			chat:say('Awesome!',
				'I\'m that much closer to officially being a pokemon Trainer!')
			wait(.3)
			local gui = _p.Menu.card.gui
			Utilities.Tween(.6, 'easeOutCubic', function(a)
				gui.Position = UDim2.new(0.5, -gui.gui.AbsoluteSize.X/2, 0.3+.7*a, 0)
			end)
			gui:Destroy()
			_p.Menu.card.gui = nil
		end
		_p.Menu.newGameFlag = true
		room.model.NewGameSpawn.CanCollide = true

		self:newPlayerInfo()
	end

	function intro:newPlayerInfo()
		--	do return end
		local fader = create 'Frame' {
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1.0,
			BorderSizePixel = 0,
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
			Parent = Utilities.frontGui,
		}
		local bg = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://14324134682',
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			ZIndex = 3, Parent = Utilities.frontGui,
		}
		local textbox = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.7, 0, 0.5, 0),
			Position = UDim2.new(0.15, 0, 0.3125, 0),
			ZIndex = 5, Parent = bg,
		}
		local textbox2 = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.5, 0, 0.2, 0),
			Position = UDim2.new(0.35, 0, 0.7375, 0),
			ZIndex = 5, Parent = bg,
		}
		local textbox3 = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.5, 0, 0.05, 0),
			Position = UDim2.new(0.325, 0, 0.8625, 0),
			ZIndex = 5, Parent = bg,
		}
		write([[Some notes from the developers of Bronze Eclipse:

 - You will only be able to trade and battle with other players AFTER you receive the first gym badge.

 - Your progress is NOT saved automatically. You must either manually save from the Menu OR enable autosave from the Options menu.

 - Bronze Eclipse is still in development. There will be bugs here and there but we're always working to fix them. Help us out by sending a message on our group wall or in our discord server!]]) {
			Frame = textbox,
			Size = textbox.AbsoluteSize.Y*.0375,
			Wraps = true,
		}
		write([[- If you have any questions about Bronze Eclipse, feel free to join us at discord.gg/alola for more info!]]) {
			Frame = textbox2,
			Size = textbox.AbsoluteSize.Y*.0375,
			Wraps = true,
		}
		write 'Thanks for playing!' {
			Frame = textbox3,
			Scaled = true,
		}

		local SIGN_NO_HOVER = 'rbxassetid://435740679'
		local SIGN_HOVER = 'rbxassetid://435740864'
		local signpostContainer = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(.05, 0, .05, 0),
			Parent = bg,
		}
		local signImage = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = SIGN_NO_HOVER,
			Size = UDim2.new(10, 0, 10, 0),
			Position = UDim2.new(-4, 0, -9.5, 0),
			ZIndex = 7, Parent = signpostContainer,
		}
		local button = create 'ImageButton' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(.7, 0, .2125, 0),
			Position = UDim2.new(.15, 0, .7, 0),
			Parent = signImage,
		}

		button.MouseEnter:connect(function()
			signImage.Image = SIGN_HOVER
		end)
		button.MouseLeave:connect(function()
			signImage.Image = SIGN_NO_HOVER
		end)

		local rotate = true
		spawn(function()
			local st = tick()
			local sin = math.sin
			while rotate do
				stepped:wait()
				local et = tick()-st
				signpostContainer.Rotation = 8 * sin(et)
			end
		end)

		Utilities.Tween(.5, 'easeOutCubic', function(a)
			fader.BackgroundTransparency = 1-.3*a
			bg.Position = UDim2.new(0.5, -bg.AbsoluteSize.X/2, -1.5*(1-a), 0)
			signpostContainer.Position = UDim2.new(1.0, 0, 0.975+3*(1-a), 0)
		end)
		button.MouseButton1Click:wait()

		Utilities.Tween(.5, 'easeOutCubic', function(a)
			fader.BackgroundTransparency = .7+.3*a
			bg.Position = UDim2.new(0.5, -bg.AbsoluteSize.X/2, -1.5*a, 0)
			signpostContainer.Position = UDim2.new(1.0, 0, 0.975+3*a, 0)
		end)
		bg:Destroy()
		fader:Destroy()

		if _p.userId < 1 then
			wait(.5)
			local chat = _p.NPCChat
			chat.bottom = true
			chat:say('You are currently playing ROBLOX as a Guest.',
				'Guests are not able to save their adventure in Pokemon Brick Bronze.',
				'If you choose to continue playing as a Guest, please remember that you will be unable to save later.',
				'You also cannot enter the PVP Battle Colosseum or Trade Resort.',
				'If you would like to be able to save, Sign in or Create a ROBLOX account now, then rejoin this game.',
				'It\'s FREE!')
		end
	end

	function intro:perform(loadGui, loadFn)
		local canSkip = false
		local skipped = false
		local function swait(t)
			if not canSkip then wait(t) return end
			local endTick = tick()+t
			while not skipped and tick() < endTick do
				stepped:wait()
			end
		end
		local function sdelay(t, f)
			if not canSkip then delay(t, f) return end
			if skipped then return end
			delay(t, function()
				if skipped then return end
				f()
			end)
		end

		local skipButton
		pcall(function() --if game.CreatorId == 6803112 or game:GetService('RunService'):IsServer() then
			canSkip = true
			skipButton =  _p.RoundedFrame:new {
				BackgroundColor3 = Color3.new(0.458824, 0.12549, 0.862745),
				Size = UDim2.new(0.08, 0, 0.08, 0),
				Position = UDim2.new(0.9, 0, 0.86, 0),
				Button = true, 
				MouseButton1Click = function()
					skipButton:Destroy()
					skipped = true
				end,
				ZIndex = 9, Parent = Utilities.frontGui,
			}

			write 'Skip' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.6, 0),
					Position = UDim2.new(0.5, 0, 0.2, 0),
					ZIndex = 10, Parent = skipButton.gui
				}, Scaled = true
			}
			--        Utilities.layerGuis()
		end)

		local bg = create 'Frame' {
			--		BackgroundTransparency = .5,-- <--- test only
			BackgroundColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
			Parent = Utilities.gui,
		}
		wait()
		local music
		for _, obj in pairs(loadGui:GetChildren()) do
			if obj:IsA('Sound') then
				music = obj
			else
				obj:Destroy()
			end
		end
		swait(1)
		local WAHJH = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.1, 0),
			Position = UDim2.new(0.25, 0, 0.17, 0),
			ZIndex = 5,
			Parent = bg,
		}
		sdelay(.3, function()
			local narwhal = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				ImageTransparency = 1.0,
				Image = 'rbxassetid://14036841288',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(-0.4, 0, 0.4, 0),
				ZIndex = 4, Parent = bg,
			}
			Utilities.Tween(3, nil, function(a) if skipped then return false end
				narwhal.Position = UDim2.new(0.85-0.1*a, 0, 0.125, 0)
				narwhal.ImageTransparency = math.max(0, 1-1.2*math.sin(a*math.pi))
			end)
			narwhal:Destroy()
		end)
		if not skipped then
			write 'Blaze & Noob' {
				Frame = WAHJH,
				Color = Color3.new(1, .4, .4),
				AnimationRate = 10,
				FadeAfter = 3,
				TextXAlignment = Enum.TextXAlignment.Left,
			}
		end
		local presents = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.075, 0),
			Position = UDim2.new(0.3, 0, 0.31, 0),
			ZIndex = 5,
			Parent = bg,
		}
		if not skipped then
			write 'present...' {
				Frame = presents,
				AnimationRate = 10,
				FadeAfter = 3,
				TextXAlignment = Enum.TextXAlignment.Left,
			}
		end

		swait(1.65)
		local association = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.075, 0),
			Position = UDim2.new(0.31, 0, 0.42, 0),
			ZIndex = 5,
			Parent = bg,
		}
		if not skipped then
			write 'in association with' {
				Frame = association,
				AnimationRate = 10,
				FadeAfter = 3,
				TextXAlignment = Enum.TextXAlignment.Left,
			}
		end
		sdelay(.45, function()
			local doctor = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				ImageTransparency = 1.0,
				Image = 'rbxassetid://14036848207',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.4, 0, 0.4, 0),
				ZIndex = 4, Parent = bg,
			}
			Utilities.Tween(3, nil, function(a) if skipped then return false end
				doctor.Position = UDim2.new(0.0625+0.1*a, 0, 0.5, 0)--.1
				doctor.ImageTransparency = math.max(0, 1-1.2*math.sin(a*math.pi))
			end)
			doctor:Destroy()
		end)
		for i, name in pairs({ "Mario", "Nash", "", "", "", "", "", "", "", "", "", ""}) do
			sdelay(i*.25, function()
				local x = i%2==1 and 0 or 1
				local y = math.ceil(i/2)
				write(name) {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0, 0, 0.04, 0),--.06
						Position = UDim2.new(0.15+0.025*i+.315*x, 0, 0.522+0.0375*i-.01875*x, 0),-- 0.07
						ZIndex = 5,
						Parent = bg,
					},
					Color = ({Color3.new(0.4, 1, 0.8), Color3.new(1, 0.8, 0.4), Color3.new(1, 0.4, 0.4), Color3.fromRGB(255, 233, 159), Color3.new(0.4, 1, 0.8), Color3.new(1, 0.4, 0.4), Color3.fromRGB(255, 233, 159), Color3.new(0.4, 0.8, 1), Color3.fromRGB(151, 103, 184), Color3.fromRGB(255, 233, 159), Color3.fromRGB(178, 96, 132), Color3.new(0.4, 0.8, 1)})[i],
					AnimationRate = 11,
					FadeAfter = ({ 3.8, 3, 3, 2.5, 1.9, 2.5, 2, 2, 2, 2.5, 1, 1})[i],
					TextXAlignment = Enum.TextXAlignment.Left,
				}
			end)
		end


		swait(4.35)
		local sq = create 'Frame' {
			BackgroundTransparency = 1.0,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Parent = Utilities.gui,
		}

		local function u(p) if p == 'AbsoluteSize' then sq.Position = UDim2.new(0.5, -sq.AbsoluteSize.X/2, 0.0, 0) end end
		local c = Utilities.gui.Changed:connect(u); u('AbsoluteSize')

		local hoopa, fireAnimBottom, fireAnimTop
		if not skipped then
			local fire = {sheets={{id=5478522832,startPixelY=1,rows=4},{id=5478523727,startPixelY=1,rows=4},{id=5478524690,startPixelY=1,rows=4},{id=5478525432,startPixelY=1,rows=4},},nFrames=64,fWidth=256,fHeight=256,framesPerRow=4,border=0}
			local s = 1.5
			fireAnimBottom = animation:new(fire)
			fireAnimBottom.startTime = 0
			fireAnimBottom.cache.Position = UDim2.new(0.0, 0, 0.5, 0)
			fireAnimBottom.spriteLabel.ImageColor3 = Color3.new(1, 0.3, 0.3)
			fireAnimBottom.spriteLabel.Size = UDim2.new(1.5, 0, 1.5, 0)
			fireAnimBottom.spriteLabel.Position = UDim2.new(-0.25, 0, 1.0, 0)
			fireAnimBottom.spriteLabel.ZIndex = 2
			fireAnimBottom.spriteLabel.Parent = sq
			fireAnimBottom:Play()
			hoopa = animation:new {sheets={{id=5224408011,startPixelY=100,rows=3},{id=5224411028,rows=4},{id=5224413663,rows=4},{id=5224416193,rows=4},{id=5224418887,rows=4},},nFrames=74,fWidth=131,fHeight=126,framesPerRow=4}
			local x = 0.7/126*131
			hoopa.spriteLabel.ImageColor3 = Color3.new(0, 0, 0)
			hoopa.spriteLabel.ImageTransparency = 0.9
			hoopa.spriteLabel.Size = UDim2.new(x, 0, 0.7, 0)
			hoopa.spriteLabel.Position = UDim2.new(0.5-x/2, 0, 0.25, 0)
			hoopa.spriteLabel.ZIndex = 3
			hoopa.spriteLabel.Parent = sq
			hoopa:Play()

			fireAnimTop = animation:new(fire)
			fireAnimTop.startTime = 1.92/2
			fireAnimTop.spriteLabel.ImageTransparency = 0.5
			fireAnimTop.cache.Position = UDim2.new(0.0, 0, 0.5, 0)
			fireAnimTop.spriteLabel.Size = UDim2.new(1.5, 0, 1.5, 0)
			fireAnimTop.spriteLabel.Position = UDim2.new(-0.25, 0, 1.0, 0)
			fireAnimTop.spriteLabel.ZIndex = 4
			fireAnimTop.spriteLabel.Parent = sq
			fireAnimTop:Play()
		end

		local pokemoncontainer = create("Frame")({
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0.38362919132149903, 0),
			Position = UDim2.new(0, 0, 0.05, 0),
			Parent = sq
		})
		local pokemoncutter = create("Frame")({
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Size = UDim2.new(0, 0, 1, 0),
			Parent = pokemoncontainer
		})
		local pokemon = create("ImageLabel")({
			BackgroundTransparency = 1,
			Image = "rbxassetid://14036945838", -- 771144807
			ZIndex = 5,
			Parent = pokemoncutter
		})
		local bbLetterBounds = {
			{
				0,
				0,
				190,
				246
			},
			{
				213,
				0,
				220,
				240
			},
			{
				455,
				0,
				78,
				239
			},
			{
				563,
				0,
				189,
				240
			},
			{
				769,
				0,
				220,
				239
			},
			{
				0,
				244,
				158,
				199
			},
			{
				161,
				244,
				165,
				199
			},
			{
				337,
				244,
				160,
				199
			},
			{
				513,
				246,
				170,
				197
			},
			{
				683,
				245,
				157,
				198
			},
			{
				842,
				244,
				148,
				199
			}
		}
		local bbContainer = create("Frame")({
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0.4484848484848485, 0),
			Position = UDim2.new(0, 0, 0.45, 0),
			Parent = sq
		})
		swait(2)
		Utilities.Tween(0.325, nil, function(a)
			if skipped then
				return false
			end
			local c = math.sin(a * math.pi)
			bg.BackgroundColor3 = Color3.new(c, c, c)
			pokemoncutter.Size = UDim2.new(a, 0, 1, 0)
			if a ~= 0 then
				pokemon.Size = UDim2.new(1 / a, 0, 1, 0)
			end
		end)
		swait(1)
		pcall(function()
			hoopa.spriteLabel.ImageTransparency = 0.5
		end)
		Utilities.Tween(3, "easeOutCubic", function(a)
			if skipped then
				return false
			end
			fireAnimBottom.spriteLabel.Position = UDim2.new(-0.25, 0, 1 - 1.45 * a, 0)
			fireAnimTop.spriteLabel.Position = UDim2.new(-0.25, 0, 1 - 1.45 * a, 0)
		end)
		swait(0.3)
		for _, lb in pairs(bbLetterBounds) do
			do
				local container = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(lb[3] / 990, 0, lb[4] / 444, 0),
					Position = UDim2.new(lb[1] / 990, 0, lb[2] / 444, 0),
					Parent = bbContainer
				})
				local letter = create("ImageLabel")({
					BackgroundTransparency = 1,
					Image = "rbxassetid://13206561162", -- 771148059
					ImageRectSize = Vector2.new(lb[3], lb[4]),
					ImageRectOffset = Vector2.new(lb[1], lb[2]),
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 5
				})
				sdelay(0.5 * math.random(), function()
					local bounce = Utilities.Timing.easeOutBounce(1)
					local cubic = Utilities.Timing.easeOutCubic(1)
					local dir = math.random() < 0.5 and 1 or -1
					local x = dir * 0.15 / container.Size.X.Scale
					local y = -0.3 / container.Size.Y.Scale
					letter.Parent = container
					Utilities.Tween(1, nil, function(a)
						if skipped then
							return false
						end
						local c = 1 - cubic(a)
						letter.ImageTransparency = c
						letter.Position = UDim2.new(x * (1 - a), 0, y * (1 - bounce(a)), 0)
						letter.Rotation = 30 * dir * c
					end)
				end)
			end
		end
		swait(5.4)
		local txt = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.05, 0),
			ZIndex = 6,
			Parent = Utilities.gui,
		}
		if not skipped then
			local touch = Utilities.isTouchDevice()
			write(touch and 'TAP TO PLAY' or 'CLICK TO PLAY') {
				Frame = txt,
				Scaled = true,
			}
			Utilities.Tween(.5, 'easeOutCubic', function(a) if skipped then return false end
				txt.Position = UDim2.new(0.5, 0, 1.0-0.075*a, 0)
			end)
			if not skipped then game:GetService('Players').LocalPlayer:GetMouse().Button1Down:wait() end
		end

		local fader = create 'Frame' {
			BackgroundColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
			ZIndex = 10,
			Parent = Utilities.gui,
		}
		local v
		pcall(function() v = music.Volume end)
		Utilities.Tween(1.5, nil, function(a) if skipped then return false end
			local o = 1-a
			pcall(function() music.Volume = v*o end)
			fader.BackgroundTransparency = o
		end)
		sq:Destroy()
		loadGui:Destroy()
		txt:Destroy()

		if skipped then bg:ClearAllChildren() end
		pcall(function() skipButton:Destroy() end)

		local sig = Utilities.Signal()
		local continue
		_p.gamemode = 'adventure'
		local hasFile, name, badges, pokedex = _p.Network:get('PDS', 'getContinueScreenInfo', _p.gamemode)
		if hasFile then
			continue = _p.RoundedFrame:new {
				Button = true, CornerRadius = Utilities.gui.AbsoluteSize.Y*.08,
				BackgroundColor3 = Color3.new(.4, 1, .8),
				Size = UDim2.new(0.65, 0, 0.65, 0),
				Position = UDim2.new(0.2, 0, 0.08, 0),
				ZIndex = 2, Parent = Utilities.gui,
				MouseButton1Click = function()
					sig:fire('continue')
				end,
			}
			write 'Continue' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.2, 0),
					Position = UDim2.new(0.075, 0, 0.085, 0),
					ZIndex = 3, Parent = continue.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left, Color = Color3.new(.3, .3, .3),
			}
			local color = Color3.new(.5, .5, .5)
			write 'Trainer:' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.10, 0),
					Position = UDim2.new(0.125, 0, 0.35, 0),
					ZIndex = 3, Parent = continue.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left, Color = color,
			}
			write(name) {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.10, 0),
					Position = UDim2.new(0.875, 0, 0.50, 0),
					ZIndex = 3, Parent = continue.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right, Color = color,
			}
			write 'Badges:' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.10, 0),
					Position = UDim2.new(0.125, 0, 0.65, 0),
					ZIndex = 3, Parent = continue.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left, Color = color,
			}
			write(tostring(badges)) {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.10, 0),
					Position = UDim2.new(0.875, 0, 0.65, 0),
					ZIndex = 3, Parent = continue.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right, Color = color,
			}
			write 'Pok[e\']dex:' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.10, 0),
					Position = UDim2.new(0.125, 0, 0.80, 0),
					ZIndex = 3, Parent = continue.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left, Color = color,
			}
			write(tostring(pokedex)) {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.10, 0),
					Position = UDim2.new(0.875, 0, 0.80, 0),
					ZIndex = 3, Parent = continue.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right, Color = color,
			}
		else
			write 'Are you ready to' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.1, 0),
					Position = UDim2.new(0.5, 0, 0.25, 0),
					ZIndex = 3, Parent = bg,
				}, Scaled = true,
			}
			write 'start your adventure?' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.1, 0),
					Position = UDim2.new(0.5, 0, 0.4, 0),
					ZIndex = 3, Parent = bg,
				}, Scaled = true,
			}
		end
		local newgame = _p.RoundedFrame:new {
			Button = true, CornerRadius = Utilities.gui.AbsoluteSize.Y*(hasFile and .025 or .06),
			BackgroundColor3 = Color3.new(.3, .3, .3),
			Size = (hasFile and UDim2.new(.22, 0, .08, 0) or UDim2.new(0.45, 0, 0.16, 0)),
			Position = (hasFile and UDim2.new(.75, 0, .81, 0) or UDim2.new(0.275, 0, 0.65, 0)),
			ZIndex = 2, Parent = Utilities.gui,
			MouseButton1Click = function()
				sig:fire('newgame')
			end,
		}
		write 'New Game' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.5, 0),
				Position = UDim2.new(0.5, 0, 0.25, 0),
				ZIndex = 3, Parent = newgame.gui,
			}, Scaled = true,
		}
		pcall(function()
			write(_p.storage.Version.Value) {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.04, 0),
					Position = UDim2.new(0.98, 0, 0.935, 0),
					ZIndex = 3, Parent = bg,
				}, Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Right,
			}
		end)
		local rfs = {}

		local gamemodes = {
			'Randomizer'
		}
		local otherAdventures = {}
		for _,gamemode in pairs(gamemodes) do
			local hasFile, name, badges, pokedex = _p.Network:get('PDS', 'getContinueScreenInfo', string.lower(gamemode))
			local infotable = {
				started = hasFile,
				name = gamemode, 
			}
			if hasFile then
				infotable = {
					started = hasFile,
					name = gamemode, 
					tName = name, 
					pokedex = pokedex, 
					badges = badges
				}
			end
			table.insert(otherAdventures, infotable)
		end

		--more adventures start
		if hasFile then 
			--local otherAdventures = {{started = false, name = 'Randomizer'}}
			if otherAdventures and badges >= 3 then
				local more
				local things = {
					{
						continue.gui,
						UDim2.new(0.2, 0, 0.1, 0)
					},
					{
						newgame.gui,
						UDim2.new(0.75, 0, 0.81, 0)
					}
				}
				local openSpawns = {}
				local state = 0
				local function openAdventures()
					if state ~= 0 then
						return
					end
					state = 1
					for _, uiPosPair in pairs(things) do
						wait(0.08)
						uiPosPair[1]:TweenPosition(uiPosPair[2] + UDim2.new(0, 0, -1, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.5, true)
					end
					wait(0.5)
					state = 2
				end
				local function closeAdventures()
					if state ~= 2 then
						return
					end
					state = 1
					for i = #things, 1, -1 do
						local uiPosPair = things[i]
						wait(0.08)
						uiPosPair[1]:TweenPosition(uiPosPair[2], Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.5, true)
					end
					wait(0.5)
					state = 0
				end
				more = _p.RoundedFrame:new({
					Button = true,
					CornerRadius = Utilities.gui.AbsoluteSize.Y * 0.031,
					BackgroundColor3 = Color3.new(0.3, 0.3, 0.3),
					Size = UDim2.new(0.3, 0, 0.12, 0),
					Position = UDim2.new(0.35, 0, 0.78, 0),
					ZIndex = 2,
					Parent = Utilities.gui,
					MouseButton1Click = openAdventures
				})
				table.insert(rfs, more)
				table.insert(things, {
					more.gui,
					UDim2.new(0.35, 0, 0.78, 0)
				})
				write("More Adventures")({
					Frame = create("Frame")({
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0.3, 0),
						Position = UDim2.new(0.5, 0, 0.14, 0),
						ZIndex = 3,
						Parent = more.gui
					}),
					Scaled = true
				})
				local arrow = create("ImageLabel")({
					BackgroundTransparency = 1,
					Image = "rbxassetid://11226580195",
					ImageTransparency = 1,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(0.7, 0, 0.6, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					ZIndex = 4,
					Parent = more.gui
				})
				local arrow2 = arrow:Clone()
				arrow2.Rotation = 180
				spawn(function()
					while arrow.Parent do
						wait(0.7)
						Utilities.Tween(1, nil, function(a)
							if a < 0.25 then
								arrow.ImageTransparency = 1 - a * 4
							elseif a > 0.75 then
								arrow.ImageTransparency = (a - 0.75) * 4
							else
								arrow.ImageTransparency = 0
							end
							arrow.Position = UDim2.new(0.5, 0, 0.7 + 0.4 * a, 0)
							arrow2.ImageTransparency = arrow.ImageTransparency
							arrow2.Position = UDim2.new(0.5, 0, 0.3 - 0.4 * a, 0)
						end)
					end
				end)
				local back = _p.RoundedFrame:new({
					Button = true,
					CornerRadius = Utilities.gui.AbsoluteSize.Y * 0.031,
					BackgroundColor3 = Color3.new(0.3, 0.3, 0.3),
					Size = UDim2.new(0.15, 0, 0.12, 0),
					Position = UDim2.new(0.425, 0, 1.05, 0),
					ZIndex = 2,
					Parent = Utilities.gui,
					MouseButton1Click = closeAdventures
				})
				table.insert(rfs, back)
				table.insert(things, {
					back.gui,
					UDim2.new(0.425, 0, 1.05, 0)
				})
				write("Back")({
					Frame = create("Frame")({
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0.3, 0),
						Position = UDim2.new(0.5, 0, 0.51, 0),
						ZIndex = 3,
						Parent = back.gui
					}),
					Scaled = true
				})
				arrow2.Parent = back.gui
				for i, adventure in pairs(otherAdventures) do
					do
						local pos = UDim2.new(0.3, 0, 1.26 + 0.225 * (i - 1), 0)
						local button = _p.RoundedFrame:new({
							Button = true,
							CornerRadius = Utilities.gui.AbsoluteSize.Y * 0.04,
							BackgroundColor3 = Color3.new(0.3, 1, 0.8),
							Size = adventure.started and UDim2.new(0.3, 0, 0.3, 0) or UDim2.new(0.3, 0, 0.2, 0),
							Position = pos,
							ZIndex = 2,
							Parent = Utilities.gui,
							MouseButton1Click = function()
								sig:fire(adventure.started and "continue" or "newgame", adventure)
							end
						})
						table.insert(rfs, button)
						table.insert(things, {
							button.gui,
							pos
						})
						write(adventure.name)({
							Frame = create("Frame")({
								BackgroundTransparency = 1,
								Size = UDim2.new(0, 0, 0.175, 0),
								Position = UDim2.new(0.075, 0, 0.075, 0),
								ZIndex = 3,
								Parent = button.gui
							}),
							Scaled = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							Color = Color3.new(0.3, 0.3, 0.3)
						})

						local color = Color3.new(.5, .5, .5)
						if adventure.started then
							write("Trainer:")({
								Frame = create("Frame")({
									BackgroundTransparency = 1,
									Size = UDim2.new(0, 0, 0.1, 0),
									Position = UDim2.new(0.125, 0, 0.35, 0),
									ZIndex = 3,
									Parent = button.gui
								}),
								Scaled = true,
								TextXAlignment = Enum.TextXAlignment.Left,
								Color = color
							})
							write(adventure.tName)({
								Frame = create("Frame")({
									BackgroundTransparency = 1,
									Size = UDim2.new(0, 0, 0.1, 0),
									Position = UDim2.new(0.875, 0, 0.5, 0),
									ZIndex = 3,
									Parent = button.gui
								}),
								Scaled = true,
								TextXAlignment = Enum.TextXAlignment.Right,
								Color = color
							})
							write("Badges:")({
								Frame = create("Frame")({
									BackgroundTransparency = 1,
									Size = UDim2.new(0, 0, 0.1, 0),
									Position = UDim2.new(0.125, 0, 0.65, 0),
									ZIndex = 3,
									Parent = button.gui
								}),
								Scaled = true,
								TextXAlignment = Enum.TextXAlignment.Left,
								Color = color
							})
							write(tostring(adventure.badges))({
								Frame = create("Frame")({
									BackgroundTransparency = 1,
									Size = UDim2.new(0, 0, 0.1, 0),
									Position = UDim2.new(0.875, 0, 0.65, 0),
									ZIndex = 3,
									Parent = button.gui
								}),
								Scaled = true,
								TextXAlignment = Enum.TextXAlignment.Right,
								Color = color
							})
							write("Pok[e']dex:")({
								Frame = create("Frame")({
									BackgroundTransparency = 1,
									Size = UDim2.new(0, 0, 0.1, 0),
									Position = UDim2.new(0.125, 0, 0.8, 0),
									ZIndex = 3,
									Parent = button.gui
								}),
								Scaled = true,
								TextXAlignment = Enum.TextXAlignment.Left,
								Color = color
							})
							write(tostring(adventure.pokedex) == 'nil' and '0' or tostring(adventure.pokedex))({
								Frame = create("Frame")({
									BackgroundTransparency = 1,
									Size = UDim2.new(0, 0, 0.1, 0),
									Position = UDim2.new(0.875, 0, 0.8, 0),
									ZIndex = 3,
									Parent = button.gui
								}),
								Scaled = true,
								TextXAlignment = Enum.TextXAlignment.Right,
								Color = color
							})
						else
							write("No Data")({
								Frame = create("Frame")({
									BackgroundTransparency = 1,
									Size = UDim2.new(0, 0, 0.15, 0),
									Position = UDim2.new(0.5, 0, 0.5, 0),
									ZIndex = 3,
									Parent = button.gui
								}),
								Scaled = true,
								Color = color
							})
						end
						local a_newgame = _p.RoundedFrame:new({
							Button = true,
							CornerRadius = Utilities.gui.AbsoluteSize.Y * 0.0125,
							BackgroundColor3 = Color3.new(0.3, 0.3, 0.3),
							Size = UDim2.new(0.44, 0, 0.16, 0),
							Position = UDim2.new(1.1, 0, 0.72, 0),
							ZIndex = 2,
							Parent = button.gui,
							MouseButton1Click = function()
								sig:fire("newgame", adventure)
							end
						})
						table.insert(rfs, a_newgame)
						write("New Game")({
							Frame = create("Frame")({
								BackgroundTransparency = 1,
								Size = UDim2.new(0, 0, 0.5, 0),
								Position = UDim2.new(0.5, 0, 0.25, 0),
								ZIndex = 3,
								Parent = a_newgame.gui
							}),
							Scaled = true
						})
					end 
				end
			end
		end
		--		bg.BackgroundColor3 = Color3.new(.1, .2, .1)
		local cm = Utilities.loopSound(_p.musicId.ContinueScreen, .6)--.4)
		Utilities.Tween(.5, nil, function(a) if skipped then return false end
			fader.BackgroundTransparency = a
		end)
		if skipped then fader.BackgroundTransparency = 1.0 end

		local v = cm.Volume
		local choice, adventure
		while true do
			choice, adventure = sig:wait()
			Utilities.Tween(.5, nil, function(a)
				local o = 1-a
				cm.Volume = v*o
				fader.BackgroundTransparency = o
			end)
			if choice ~= 'newgame' or not hasFile then break end
			local confirmNewGame
			if adventure then --user chose a new adventure
				if adventure.name == 'Randomizer' then 
					confirmNewGame = _p.NPCChat:say('You are starting a New Game for Randomizer.', 'Your previous data for the main adventure won\'t be lost.', 'Any new data saved in this Randomizer will be saved as Randomizer data.', '[y/n]Are you sure you want to start a New Game for Randomizer?')
				end
			else
				confirmNewGame = _p.NPCChat:say('You are starting a New Game.', 'Your previous data has not been overwritten.', 'However, if you choose to Save after starting a new game, your previous data will then be lost.','Overwritten data CANNOT be recovered.', '[y/n]Are you sure you want to start a New Game?')
			end

			if confirmNewGame then break end
			Utilities.Tween(.5, nil, function(a)
				cm.Volume = v*a
				fader.BackgroundTransparency = a
			end)
		end
		cm:Stop()
		cm:Destroy()
		if continue then continue:Destroy() end
		newgame:Destroy()
		bg:Destroy()
		loadFn()
		for index, value in next, rfs do 
			value:Destroy()
		end
		if adventure then
			_p.gamemode = string.lower(adventure.name)
		end
		pcall(function() c:disconnect() end)
		if choice == 'newgame' then
			local st = tick()
			_p.Network:get('PDS', 'startNewGame', _p.gamemode)
			if _p.gamemode ~= 'adventure' then
				for _,gamemode in pairs(otherAdventures) do
					if string.lower(gamemode.name) == _p.gamemode and gamemode.started then
						_p.Menu.willOverwriteIfSaveFlag = true
					end
				end
			elseif hasFile then
				_p.Menu.willOverwriteIfSaveFlag = true
			end
			_p.DataManager:loadChunk('chunk1')
			local et = tick()-st
			if et < 3 then wait(3-et) end
			--			_p.PlayerData.party = {}
			_p.PlayerData.gameBegan = true
			self:newGame(fader)
		else
			local s, etc = _p.Network:get('PDS', 'continueGame', _p.gamemode)
			if s then
				_p.PlayerData:loadEtc(etc)
			else
				error('FAILED TO CONTINUE')
			end
			Utilities.Tween(.5, nil, function(a)
				fader.BackgroundTransparency = a
			end)
			fader:Destroy()
		end
		--		_p.loadedData = nil

	end


	return intro end