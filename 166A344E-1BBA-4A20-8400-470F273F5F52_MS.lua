return function(_p)
local Utilities = _p.Utilities
local create = Utilities.Create
local mapId = 11226715291
local cityId = 11226732139
local townId = 11226726338
local cityDisabledId = 11226698161
local townDisabledId = 11226703903

local map = {}

local mapData = { -- total 586 586
	{'Mitis Town',      1, .39, .75, 'chunk1', nil, 'yourhomef1'},--231 440
	{'Cheshma Town',    1, .41, .81, 'chunk2'},--242 472
	{'Silvent City',    2, .48, .87, 'chunk3'},--284 507
	{'Brimber City',    2, .3 , .8 , 'chunk5'},--177 468
	{'Lagoona Lake',    1, .23, .7 , 'chunk9'},--132 411
	{'Rosecove City',   2, .11, .51, 'chunk11'},--
	{'Cragonos Cliffs', 1, .12, .32, 'chunk17'},--
	{'Anthian City',    2, .67, .62, 'chunk21'},
	{'Aredia City',     2, .27, .16, 'chunk25', 'vAredia'},
	{'Fluoruma City',   2, .50, .20, 'chunk39', 'vFluoruma'},
	{'Frostveil City',  2, 0.7, 0.15, 'chunk46', 'vFrostveil'},
	{'Port Decca',      1, 0.85, 0.40, 'chunk58', 'vPortDecca'},
	{'Crescent Island', 1, .85, .60, 'chunk76', 'vCrescent'}
}



function map:fly()
	local mouse = _p.player:GetMouse()--
	local busy = false
	local sig = Utilities.Signal()
	
	local container = create 'Frame' {
		BackgroundTransparency = 1.0,
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = UDim2.new(.9, 0, .9, 0),
		Parent = Utilities.gui
	}
	local mapGui; mapGui = create 'ImageButton' {
		BackgroundColor3 = BrickColor.new('Cyan').Color,
		BorderSizePixel = 4,
		BorderColor3 = BrickColor.new('Deep blue').Color,
		Image = 'rbxassetid://'..mapId,
		Size = UDim2.new(1.0, 0, 1.0, 0),
		Position = UDim2.new(-.5, 0, 0.0, 0),
		ZIndex = 3, Parent = container,
--		MouseButton1Click = function()--
--			print((mouse.X-mapGui.AbsolutePosition.X)/mapGui.AbsoluteSize.X, (mouse.Y-mapGui.AbsolutePosition.Y)/mapGui.AbsoluteSize.Y)
--		end
	}
	local bg = create 'ImageButton' {
		AutoButtonColor = false,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1.0,
		Size = UDim2.new(1.0, 0, 1.0, 36),
		Position = UDim2.new(0.0, 0, 0.0, -36),
		Parent = Utilities.gui
	}
	local activeLocation
	local function onMouseLeave(loc)
		if not loc then return end
--		local label = loc.label
--		Utilities.Tween(.5, 'easeOutCubic', function(a)
--			label.Position = UDim2.new(-a, 0, 0.15, 0)
--		end)
		loc.button.ZIndex = 4
		loc.container:Destroy()
	end
	local function onMouseEnter(button, data)
		if activeLocation then
			local loc = activeLocation
			activeLocation = nil
			onMouseLeave(loc)
		end
		local container = create 'Frame' {
			ClipsDescendants = true,
			BackgroundTransparency = 1.0,
			Position = UDim2.new(.5, 0, 0.0, 0),
			ZIndex = 5, Parent = button
		}
		local label = Utilities.Write('  '..data[1]) {
			Frame = container,
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		}.Frame
		local thisLocation = {
			button = button,
			data = data,
			container = container,
			label = label,
		}
		button.ZIndex = 6
		activeLocation = thisLocation
		label.Size = UDim2.new(label.Size.X.Scale*.7, 0, .7, 0)
		container.Size = UDim2.new(label.Size.X.Scale+.5, 0, 1.0, 0)
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			if activeLocation ~= thisLocation then return false end
			label.Position = UDim2.new(a-1, 0, 0.15, 0)
		end)
	end
	local function onClick(button, data)
		busy = true
		local fly = _p.NPCChat:say('[y/n]Fly to '..data[1]..'?')
		if fly then
			sig:fire(data)
		elseif activeLocation then
			local loc = activeLocation
			activeLocation = nil
			onMouseLeave(loc)
			busy = false
		end
	end
	for _, d in pairs(mapData) do
		local rEvent = d[6]
		local enabled = not rEvent or _p.PlayerData.completedEvents[rEvent]
		local i; i = create 'ImageButton' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://'..(
				enabled and (d[2]==2 and cityId or townId)
				or (d[2]==2 and cityDisabledId or townDisabledId)),
			Size = UDim2.new(.055, 0, .055, 0),
			Position = UDim2.new(d[3]-.0275, 0, d[4]-.0275, 0),
			ZIndex = 4, Parent = mapGui
		}
		if Utilities.isTouchDevice() then
			if busy then return end
			i.TouchTap:connect(function()
				if activeLocation and activeLocation.data == d then
					if enabled then
						onClick(i, d)
					end
				else
					onMouseEnter(i, d)
				end
			end)
		else
			i.MouseEnter:connect(function()
				if busy or (activeLocation and activeLocation.data == d) then return end
				onMouseEnter(i, d)
			end)
			i.MouseLeave:connect(function()
				if busy then return end
				local loc = activeLocation
				activeLocation = nil
				onMouseLeave(loc)
			end)
			if enabled then
				i.MouseButton1Click:connect(function()
					if busy then return end
					onClick(i, d)
				end)
			end
		end
	end
--	print(mapGui.AbsoluteSize)
	local close = _p.RoundedFrame:new {
		Button = true,
		BackgroundColor3 = BrickColor.new('Deep blue').Color,
		Size = UDim2.new(.31, 0, .08, 0),
		Position = UDim2.new(.85, 0, -.03, 0),
		ZIndex = 9, Parent = mapGui,
		MouseButton1Click = function()
			sig:fire()
		end
	}
	Utilities.Write 'Cancel' {
		Frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 0.7, 0),
			Position = UDim2.new(0.0, 0, 0.15, 0),
			ZIndex = 10, Parent = close.gui
		}, Scaled = true,
	}
	Utilities.Tween(.8, 'easeOutCubic', function(a)
		bg.BackgroundTransparency = 1-.3*a
		container.Position = UDim2.new(.5, 0, .05+1-a, 0)
	end)
	local location = sig:wait()
	if not location then
		spawn(function() _p.Menu.party:open() end)
	end
	Utilities.Tween(.8, 'easeOutCubic', function(a)
		bg.BackgroundTransparency = .7+.3*a
		container.Position = UDim2.new(.5, 0, .05+a, 0)
	end)
	close:destroy()
	bg:Destroy()
	container:Destroy()
	if location then
		local cam = workspace.CurrentCamera
		cam.CameraType = Enum.CameraType.Scriptable
		_p.Hoverboard:unequip(true)
		
		local bird = _p.storage.Models.GenericFly:Clone()
		local cfs = {}
		local mcf = bird.Main.CFrame
		for _, p in pairs(bird:GetChildren()) do
			if p:IsA('BasePart') then
				cfs[p] = mcf:toObjectSpace(p.CFrame)
			end
		end
		bird.Parent = workspace
		
		local root = _p.player.Character.HumanoidRootPart
		local forward = root.CFrame.lookVector
		forward = (forward*Vector3.new(1, 0, 1)).unit
		if forward.magnitude < .5 then
			forward = Vector3.new(0, 0, -1)
		end
		local human = Utilities.getHumanoid()
		local r = 20
		local right = root.CFrame.rightVector
		local sin, cos = math.sin, math.cos
		local up = Vector3.new(0, 1, 0)
		
		local function swoop(rp)
			local focus = rp + Vector3.new(0, r+(human.RigType==Enum.HumanoidRigType.R15 and (-root.Size.Y/2-human.HipHeight+1) or -2), 0)
			Utilities.Tween(.75, nil, function(a)
				local th = a*3.14
				local s, c = sin(th), cos(th)
				local pos = focus + r*(forward*-c + up*-s)
				local dir = forward*s + up*-c
				local top = right:Cross(dir)
				local cf = CFrame.new(pos.X, pos.Y, pos.Z,
					dir.X, top.X, right.X,
					dir.Y, top.Y, right.Y,
					dir.Z, top.Z, right.Z)
				for p, rcf in pairs(cfs) do
					p.CFrame = cf:toWorldSpace(rcf)
				end
			end)
		end
		
		delay(.375, Utilities.TeleportToSpawnBox)
		swoop(root.Position)
		
		Utilities.FadeOut(.5)
		local chunk = _p.DataManager.currentChunk
		if _p.Surf.surfing then
			_p.Surf:forceUnsurf()
		end
		if location[5] ~= chunk.id then
			chunk:destroy()
			wait()
			chunk = _p.DataManager:loadChunk(location[5])
		end
		local door = chunk:getDoor(location[7] or 'PokeCenter')
		local cf = door.CFrame * CFrame.new(0, -door.Size.Y/2+3, -5)
		cam.CFrame = CFrame.new(cf * Vector3.new(0, 10, -14), cf * Vector3.new(0, 1.5, 0))
		Utilities.FadeIn(.5)
		
		forward = door.CFrame.rightVector
		delay(.375, function() Utilities.Teleport(cf) end)
		swoop(cf.p)
		bird:Destroy()
		cam.CameraType = Enum.CameraType.Custom
		_p.MasterControl.WalkEnabled = true
		_p.Menu:enable()
	end
end



return map end