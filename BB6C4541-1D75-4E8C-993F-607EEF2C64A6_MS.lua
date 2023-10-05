return function(_p)

	local players = game:GetService('Players')
	local player = players.LocalPlayer
	local mouse = player:GetMouse()

	local runService = game:GetService('RunService')
	local stepped = runService.RenderStepped
	local userInputService = game:GetService('UserInputService')
	local storage = game:GetService('ReplicatedStorage')

	--local _p = require(script.Parent)
	local context = _p.context
	local Utilities = _p.Utilities
	local write = Utilities.Write
	local MasterControl = _p.MasterControl

	local interactableNPCs, silentInteract; do
		local weakKeys = {__mode = 'k'}
		interactableNPCs = setmetatable({}, weakKeys)
		silentInteract = setmetatable({}, weakKeys)
	end
	local inanimateInteract = require(script.InanimateInteract)(_p)


	local maxInteractDistance = 6.5
	local customMaxInteractDist = {
		Snorlax = 17,
	}

	local NPCChat = {
		interactableNPCs = interactableNPCs,
		silentInteract = silentInteract,
		customMaxInteractDist = customMaxInteractDist,
		speed = 35,
	}

	local function CalcSpeed()
		return NPCChat.speed
	end

	local clickCon
	local chatQueue = {}
	local chatArrow, chatTarget
	local continueIcon

	local gui = Utilities.gui
	local chatIcon = Utilities.Create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://6607841823',
		Size = UDim2.new(0.0, 30, 0.0, 30),
	}
	local pcIcon = Utilities.Create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://6607843174',
		Size = UDim2.new(0.0, 30, 0.0, 30),
	}
	local interactIcon = Utilities.Create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://7323936021',
		Size = UDim2.new(0.0, 30, 0.0, 30),
	}
	local playerIcon = {}
	if context == 'battle' then
		playerIcon = Utilities.Create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://6793640923',
			--	ImageColor3 = Color3.new(1, .7, .7),
			Size = UDim2.new(0.0, 50, 0.0, 50),
		}
	elseif context == 'trade' then
		playerIcon = Utilities.Create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://6793642655',
			Size = UDim2.new(0.0, 50, 0.0, 50),
		}
	end

	local advance = Utilities.Signal()
	local manualAdvance = Utilities.Signal()
	local waitingForManualAdvance
	userInputService.InputBegan:connect(function(inputObject)
		if inputObject.KeyCode == Enum.KeyCode.ButtonA or inputObject.KeyCode == Enum.KeyCode.ButtonX or ((inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch) and inputObject.UserInputState == Enum.UserInputState.Begin) then
			advance:fire()
		end
	end)
	NPCChat.AdvanceSignal = advance

	local function getNPCTarget()
		local camP = workspace.CurrentCamera.CoordinateFrame.p
		local targ, pos = Utilities.findPartOnRayWithIgnoreFunction(Ray.new(camP, (mouse.hit.p-camP).unit*100), {player.Character}, function(obj) return --[[obj:IsA('BasePart') and]] (obj.Transparency >= 1.0 and obj.Name ~= 'Main') or (obj.Parent and obj.Parent:IsA('Accoutrement')) end)
		if targ and targ.Parent and (interactableNPCs[targ.Parent] or targ.Parent:FindFirstChild('Interact')) and targ.Parent:FindFirstChild('HumanoidRootPart') and (targ.Parent.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).magnitude < (customMaxInteractDist[targ.Parent] or maxInteractDistance) then
			return targ.Parent
		end
		return nil, targ, pos
	end

	local function getOtherTarget(targ, pos)
		--	local targ = mouse.Target
		if not targ or not targ.Parent then return end
		if targ.Parent.Name == '#PC' and (targ.Parent.Main.Position-player.Character.HumanoidRootPart.Position).magnitude <= maxInteractDistance then
			return targ.Parent, 'pc'
		elseif targ.Parent:FindFirstChild('#InanimateInteract') then
			local kind = targ.Parent['#InanimateInteract'].Value
			local closeEnough
			if kind == 'rockClimb' then
				closeEnough = ((targ.Parent.Main.Position-player.Character.HumanoidRootPart.Position)*Vector3.new(1,0,1)).magnitude <= 9
			else
				local maxDist = customMaxInteractDist[kind] or maxInteractDistance+2
				closeEnough = (targ.Parent.Main.Position-player.Character.HumanoidRootPart.Position).magnitude <= maxDist
			end
			if closeEnough then
				return targ.Parent, 'inanimateInteract', kind
			end
		elseif targ.Name == 'Water' then
			local mp = pos--mouse.Hit.p
			local root = player.Character.HumanoidRootPart
			local cp = root.Position
			pcall(function()
				local human = Utilities.getHumanoid()
				if human.RigType == Enum.HumanoidRigType.R15 then
					cp = cp + Vector3.new(0, 3 - root.Size.Y/2 - human.HipHeight, 0)
				end
			end)
			if mp.y < cp.y-2.9 and mp.y > cp.y-8 and Vector3.new(mp.x-cp.x, 0, mp.z-cp.z).magnitude < 8.5 then--maxInteractDistance then
				return targ, 'inanimateInteract', 'Water'
			end
		end
		if context == 'battle' or context == 'trade' then
			local opponent = players:GetPlayerFromCharacter(targ.Parent)
			if not opponent or opponent == player then return end
			local s, tooFar = pcall(function() return (player.Character.HumanoidRootPart.Position-opponent.Character.HumanoidRootPart.Position).magnitude > 10 end)
			if s and tooFar then return end
			return opponent
		end
	end

	local interacting = false
	local function onCheckMouse()
		local targ, hitObj, hitPos = getNPCTarget()
		local cb = NPCChat.chatBox
		chatIcon.Parent = nil
		pcIcon.Parent = nil
		interactIcon.Parent = nil
		playerIcon.Parent = nil
		if (cb and cb.Parent) or interacting then return end
		if targ then
			chatIcon.Parent = gui
			for i = 1, 3 do
				chatIcon.Position = UDim2.new(0.0, mouse.X + 5, 0.0, mouse.Y + 20)-- - 16)
				stepped:wait()
			end
		else
			local t, kind = getOtherTarget(hitObj, hitPos)
			if not t then return end
			if kind == 'pc' then
				pcIcon.Parent = gui
				for i = 1, 3 do
					pcIcon.Position = UDim2.new(0.0, mouse.X + 8, 0.0, mouse.Y + 17)
					stepped:wait()
				end
			elseif kind == 'inanimateInteract' then
				interactIcon.Parent = gui
				for i = 1, 3 do
					interactIcon.Position = UDim2.new(0.0, mouse.X + 3, 0.0, mouse.Y + 22)
					stepped:wait()
				end
			elseif t:IsA('Player') then
				playerIcon.Parent = gui
				for i = 1, 3 do
					playerIcon.Position = UDim2.new(0.0, mouse.X - 2, 0.0, mouse.Y + 20)
					stepped:wait()
				end
			end
		end
	end

	local function onMouseDown()
		if interacting or not MasterControl.WalkEnabled then return end
		local cb = NPCChat.chatBox
		if cb and cb.Parent then 
			--		advance:fire()
			return
		end
		if not NPCChat.enabled then return end
		local targ, hitObj, hitPos = getNPCTarget()
		if not targ then
			local kind, arg1
			targ, kind, arg1 = getOtherTarget(hitObj, hitPos)
			if not targ then
				-- be sure to debounce silent interactions and
				-- add proximity checks manually
				pcall(function() silentInteract[hitObj.Parent]() end)
				return
			end
			if kind == 'pc' then
				if not NPCChat.enabled then return end
				NPCChat:disable()
				_p.Menu.pc:bootUp(targ)
				NPCChat:enable()
			elseif kind == 'inanimateInteract' then
				local v = inanimateInteract[arg1]
				if type(v) == 'function' then
					v(targ, hitPos)
				end
			elseif targ:IsA('Player') then
				if context == 'battle' then
					playerIcon.Parent = nil
					_p.PVP:onClickedPlayer(targ)
				elseif context == 'trade' then
					playerIcon.Parent = nil
					_p.TradeMatching:onClickedPlayer(targ)
				end
			end
			return
		end
		if not _p.Menu.enabled then return end
		chatIcon.Parent = nil
		interacting = true

		MasterControl.WalkEnabled = false
		MasterControl:Stop()

		for _, npc in pairs(_p.DataManager.currentChunk:getNPCs()) do
			if npc.model == targ then
				spawn(function() pcall(function() npc:LookAt(player.Character.HumanoidRootPart.Position) end) end)
				break
			end
		end
		spawn(function() pcall(function() MasterControl:LookAt(targ.HumanoidRootPart.Position) end) end)

		local interact = interactableNPCs[targ] or targ.Interact
		if type(interact) == 'function' then
			interact()
			MasterControl.WalkEnabled = true
			interacting = false
			return
		elseif type(interact) == 'userdata' then
			if interact:IsA('StringValue') then
				interact = interact.Value
				pcall(function() interact = Utilities.jsonDecode(interact) end)
			elseif interact:IsA('ModuleScript') then
				interact = require(interact)
			else
				MasterControl.WalkEnabled = true
				interacting = false
				return
			end
		end

		chatTarget = targ:FindFirstChild('Head')
		if type(interact) == 'table' then
			NPCChat:say(unpack(interact))
		else
			NPCChat:say(interact)
		end

		MasterControl.WalkEnabled = true
		interacting = false
	end

	local font = Utilities.AvenirFont--require(storage.Utilities.FontDisplayService.FontCreator).load('Avenir')
	function NPCChat:doChat()
		spawn(function() _p.Menu:close() end)
		local gui = Utilities.frontGui
		local chatBox = self.chatBox
		local cboxColor = Color3.fromRGB(50, 50, 50)
		if not chatBox then
			chatArrow = Utilities.Create 'ImageLabel' {
				Name = 'ChatArrowPointer',
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://6607848477',
				ImageColor3 = cboxColor,
				Visible = false,
				ZIndex = 8,
				Parent = gui,
			}
			chatBox = _p.RoundedFrame:new {
				Name = 'ChatBox',
				ClipsDescendants = true,
				BackgroundColor3 = cboxColor,
				ZIndex = 9,
			}
			chatBox.gui.Changed:connect(function(prop)
				if prop ~= 'Parent' then return end
				local cb = chatBox
				if not chatTarget or not cb.gui.Parent then
					chatArrow.Visible = false
					return
				end
				while cb.gui.Parent do
					if not chatTarget then
						chatArrow.Visible = false
						break
					end
					local pos, onscreen = workspace.CurrentCamera:WorldToScreenPoint(chatTarget.Position)
					if onscreen then
						local p1 = Vector2.new(cb.AbsolutePosition.X + cb.AbsoluteSize.X*.5,
							cb.AbsolutePosition.Y + (self.bottom and cb.AbsoluteSize.Y*.25 or cb.AbsoluteSize.Y*.75))
						local p2 = Vector2.new(pos.x, pos.y)
						local offset = p2-p1
						p2 = p1 + offset*.9
						offset = p2-p1
						chatArrow.Size = UDim2.new(0.0, cb.AbsoluteSize.Y*0.3, 0.0, offset.magnitude)
						chatArrow.Rotation = math.deg(math.atan2(offset.y, offset.x))-90
						local p = p1 + offset/2 - chatArrow.AbsoluteSize/2
						chatArrow.Position = UDim2.new(0.0, p.x, 0.0, p.y)
						chatArrow.Visible = true
					else
						chatArrow.Visible = false
					end
					stepped:wait()
				end
			end)
			continueIcon = Utilities.Create 'ImageLabel' {
				Image = 'rbxassetid://2668806888',
				ImageColor3 = Color3.fromRGB(220, 5, 235),
				BackgroundTransparency = 1.0,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.2, 0, 0.1333, 0),
				Position = UDim2.new(0.94, 0, 0.775, 0),
				Visible = false,
				ZIndex = 10,
				Parent = chatBox.gui,
			}
			self.chatBox = chatBox
		end

		local lineHeight
		local line1Pos
		local line2Pos
		local x = 2
		local y	= 0.65
		local function setlinepos()
			lineHeight = y/(font.baseHeight*x+font.lineSpacing)*font.baseHeight
			line1Pos = (1-y)/x
			line2Pos = line1Pos + y/(font.baseHeight*x+font.lineSpacing)*(font.baseHeight+font.lineSpacing)
		end
		setlinepos()
		while #chatQueue > 0 do
			local line = 0
			local lines = {}
			chatBox.Size = UDim2.new(0.0, gui.AbsoluteSize.X*0.75, 0.0, gui.AbsoluteSize.Y*0.225)
			chatBox.Position = UDim2.new(0.0, gui.AbsoluteSize.X*0.125, 0.0, self.bottom and gui.AbsoluteSize.Y*0.75 or gui.AbsoluteSize.Y*0.025)
			chatBox.Parent = gui
			chatBox.CornerRadius = chatBox.AbsoluteSize.Y / 4

			local RGB = (self.rgb or Color3.new(1, 1, 1))
			local str = table.remove(chatQueue, 1)
			local overflow
			local yesorno = false
			local small = false
			local thisWaitingForManualAdvance = false
			local v50 = false
			repeat
				if str:sub(1, 5):lower() == '[y/n]' then
					yesorno = true
					self.answer = nil
					str = str:sub(6)
				end
				if str:sub(1, 4):lower() == '[ma]' then
					thisWaitingForManualAdvance = true
					waitingForManualAdvance = true
					str = str:sub(5)
					v50 = true
				end
				if str:sub(1, 7) == "[small]" then
					small = true
					x = 3
					y = 0.72
					setlinepos()
					str = str:sub(8)
				end
				line = line + 1
				local lf = Utilities.Create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.9, 0, lineHeight, 0),
					Position = UDim2.new(0.05, 0, line==1 and line1Pos or line2Pos, 0),
					Parent = self.chatBox.gui,
					ZIndex = 10,
				}
				lines[line] = lf
				if line > 2 then
					local l1 = lines[line-2]
					local l2 = lines[line-1]
					local offset = line2Pos-line1Pos
					Utilities.Tween(.2, 'easeOutCubic', function(a)
						l1.Position = UDim2.new(0.05, 0, line1Pos-a*offset, 0)
						l2.Position = UDim2.new(0.05, 0, line2Pos-a*offset, 0)
					end)
					l1:Destroy()
				end
				overflow = write(str) {
					Size = lf.AbsoluteSize.Y,
					Frame = lf,
					Color = RGB or Color3.new(1, 1, 1),
					WritingToChatBox = true,
					AnimationRate = CalcSpeed(), -- ht / sec
				}

				if yesorno and not overflow then
					yesorno = false
					self.answer = self:promptYesOrNo()
				elseif not v50 or not overflow then
					if line ~= 1 and overflow then
						continueIcon.Visible = true
						advance:wait()
						continueIcon.Visible = false
					elseif not overflow then
						if thisWaitingForManualAdvance then
							manualAdvance:fire()
							if waitingForManualAdvance then
								manualAdvance:wait()
							end
						else
							continueIcon.Visible = true
							advance:wait()
							continueIcon.Visible = false
						end
					end
				end
				str = overflow
				if self.canceling then break end
			until not overflow
			if small then
				small = false
				x = 2
				y = 0.65
				setlinepos()
			end
			continueIcon.Parent = nil
			chatBox:ClearAllChildren()
			continueIcon.Parent = chatBox.gui
			if self.canceling then break end
		end
		chatArrow.Visible = false
		chatTarget = nil
		chatBox.Parent = nil
	end


	do
		local sig, yon, yes, no
		function NPCChat:promptYesOrNo()
			local isTouchDevice = Utilities.isTouchDevice()
			if not yon then
				sig = Utilities.Signal()
				NPCChat.yonSignal = sig
				yon = _p.RoundedFrame:new {
					Name = 'YesOrNoPrompt',
					BackgroundColor3 = Color3.fromRGB(50, 50, 50),
					Size = UDim2.new(0.15, 0, 0.3, 0),
					Position = UDim2.new(0.7, 0, 0.275, 0),
					ZIndex = 39, Parent = Utilities.frontGui,
				}

				yes = Utilities.Create('ImageButton')({
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.8, 0, 0.25, 0),
					Position = UDim2.new(0.1, 0, 0.175, 0),
					ZIndex = 40,
					Parent = yon.gui,
					MouseButton1Click = function()
						if self.CoverYesWithCones then
							return
						end
						sig:fire(true)
					end,
				})

				write ('Yes') ({
					Frame = yes,
					Scaled = true,
					Color = Color3.new(1, 1, 1),
					TextXAlignment = Enum.TextXAlignment.Center,
				})

				no = Utilities.Create 'ImageButton' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.8, 0, 0.25, 0),
					Position = UDim2.new(0.1, 0, 0.575, 0),
					ZIndex = 40,
					Parent = yon.gui,
					MouseButton1Click = function()
						if self.CoverNoWithCones then
							return
						end
						sig:fire(false)
					end,
				}

				write 'No' {
					Frame = no,
					Scaled = true,
					Color = Color3.new(1, 1, 1),
					TextXAlignment = Enum.TextXAlignment.Center,
				}
			end			
			yon.CornerRadius = Utilities.gui.AbsoluteSize.Y*.05
			yon.Visible = true
			local Cones, Cones2

			if self.CoverYesWithCones then
				Cones = Utilities.Create("ImageLabel")({
					BackgroundTransparency = 1, 
					Image = "rbxassetid://9202084840", 
					Size = UDim2.fromScale(0.8, 0.5), 
					Position = UDim2.fromScale(0.1, 0.05), -- 0.45 (pos for "no" if need be xD)
					ZIndex = 41, 
					Parent = yon.gui
				})
			end

			if self.CoverNoWithCones then
				Cones2 = Utilities.Create("ImageLabel")({
					BackgroundTransparency = 1, 
					Image = "rbxassetid://9202084840", 
					Size = UDim2.fromScale(0.8, 0.5), 
					Position = UDim2.fromScale(0.1, 0.45), -- 0.45 (pos for "no" if need be xD)
					ZIndex = 41, 
					Parent = yon.gui
				})
			end

			local r = sig:wait()
			yon.Visible = false
			if Cones then
				Cones:Destroy()
			end
			if Cones2 then
				Cones2:Destroy()
			end
			return r
		end
	end

	function NPCChat:choose(...)
		local options = {...}
		local sig = Utilities.Signal()
		local u = 1/(1+#options*3)
		local menu = _p.RoundedFrame:new {
			CornerRadius = Utilities.gui.AbsoluteSize.Y*(.02+.01*#options),
			BackgroundColor3 = Color3.fromRGB(59, 59, 59),
			Size = UDim2.new(0.2, 0, 0.4/9/u, 0),
			Position = UDim2.new(0.6, 0, 0.05, 0),
			Parent = Utilities.frontGui,
		}
		local maxX = 0
		for i, option in pairs(options) do
			local text = write(option) {
				Frame = Utilities.Create 'ImageButton' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.8, 0, u*1.6, 0),
					Position = UDim2.new(0.1, 0, u*1.2+(i-1)*u*3, 0),
					ZIndex = 2,
					Parent = menu.gui,
					MouseButton1Click = function()
						sig:fire(i)--option)
					end,
				},
				Scaled = true,
				Color = Color3.new(1, 1, 1),
			}
			maxX = math.max(maxX, text.MaxBounds.X)
		end
		local size = menu.Size.X.Scale
		local desiredSize = size/menu.gui.AbsoluteSize.X*maxX+.05
		if desiredSize > size then
			local plus = desiredSize-size
			menu.Size = menu.Size + UDim2.new(plus, 0, 0.0, 0)
			menu.Position = menu.Position + UDim2.new(-plus/2, 0, 0.0, 0)
		end
		local choice = sig:wait()
		menu:destroy()
		return choice
	end

	function NPCChat:say(arg1, ...)
		local arg1type = type(arg1)
		if arg1type == 'string' then
			table.insert(chatQueue, arg1)
		elseif arg1type == 'userdata' and arg1.IsA and arg1:IsA('BasePart') then
			chatTarget = arg1
		elseif arg1type == 'table' and arg1.className == 'NPC' then
			pcall(function() chatTarget = arg1.model.Head end)
		end
		for _, c in pairs({...}) do
			table.insert(chatQueue, c)
		end
		local cb = self.chatBox
		if not cb or not cb.Parent then
			self:doChat()
		else
			while cb.gui.Parent do
				cb.gui.AncestryChanged:wait()
			end
		end
		local ans = self.answer
		self.answer = nil
		return ans
	end

	function NPCChat:manualAdvance()
		waitingForManualAdvance = nil
		manualAdvance:fire()
	end

	function NPCChat:clear()
		while #chatQueue > 0 do
			table.remove(chatQueue)
		end
		self.canceling = true
		self.answer = false
		manualAdvance:fire()
		advance:fire()
		pcall(function() self.yonSignal:fire() end)
		self.canceling = nil
	end

	local heartbeatCn
	function NPCChat:enable()
		if self.enabled then return end
		self.enabled = true
		--	runService:BindToRenderStep('NPCMouseCheck', Enum.RenderPriority.Last.Value, onCheckMouse)
		if not heartbeatCn and not Utilities.isTouchDevice() then
			heartbeatCn = runService.Heartbeat:connect(onCheckMouse)
		end
		if not clickCon then clickCon = mouse.Button1Down:connect(onMouseDown) end
	end

	function NPCChat:disable()
		self.enabled = false
		--	runService:UnbindFromRenderStep('NPCMouseCheck')
		pcall(function() heartbeatCn:disconnect() end)
		heartbeatCn = nil
		chatIcon.Parent = nil
		pcIcon.Parent = nil
		interactIcon.Parent = nil
		playerIcon.Parent = nil
		chatTarget = nil
	end


	return NPCChat end