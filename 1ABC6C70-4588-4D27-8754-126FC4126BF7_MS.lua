return function(_p)

	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write
	local tradeRQgui, rqListGui, rqButton, globalError
	local network = _p.Network
	local accepting, errorThread
	local settings = {}
	local requests = {}
	local trade = {
		updateBadgeNumber = function()
		end
	}

	function trade:init()
		network:bindEvent("TradeRequest", function(from, request)
			if request.error then
				if from == accepting.from then
					if accepting and accepting.loadTag then
						accepting.failed = true
						_p.DataManager:setLoading(accepting.loadTag, false)
					end
					accepting = nil
				end
				spawn(function() _p.Menu:enable() end)
				self:error(request.error, rqListGui.gui.ErrorText)
			elseif request.accepted then
				self:onRequestAccepted(from, request)
			elseif request.joinTrade then
				if accepting and accepting.loadTag then
					accepting.completed = true
					_p.DataManager:setLoading(accepting.loadTag, false)
				end
				accepting = nil
				self:beforeTrade()
				_p.Trade:joinSession(request.joinTrade)
			else
				self:receivedRequest(from, request)
			end
		end)
	end
	function trade:beforeTrade()
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		self.playerListWasEnabled = _p.PlayerList.enabled
		_p.PlayerList:disable()
		self.busy = true
		pcall(function()
			rqListGui.Parent = nil
		end)
		pcall(function()
			rqButton.Visible = false
		end)
	end
	function trade:afterTrade()
		if self.playerListWasEnabled then
			_p.PlayerList:enable()
		end
		network:post("UpdateTitle")
		self.busy = false
		pcall(function()
			rqButton.Visible = true
		end)
		_p.MasterControl.WalkEnabled = true
		_p.Menu:enable()
	end
	function trade:enableRequestMenu()
		globalError = create("Frame")({
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 0.05, 0),
			Position = UDim2.new(0.5, 0, 0.9, 0),
			Parent = Utilities.backGui
		})
		local rq = _p.RoundedFrame:new({
			Button = true,
			BackgroundColor3 = Color3.new(0, 0.64, 1),
			Size = UDim2.new(0.2, 0, 0.075, 0),
			Position = UDim2.new(0.775, 0, 0.9, 0),
			Parent = Utilities.backGui,
			MouseButton1Click = function()
				self:viewRequests()
			end
		})
		write("Requests")({
			Frame = create("Frame")({
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 0, 0.7, 0),
				Position = UDim2.new(0.5, 0, 0.15, 0),
				ZIndex = 2,
				Parent = rq.gui
			}),
			Scaled = true
		})
		local badgeIcon = create("ImageLabel")({
			BackgroundTransparency = 1,
			Image = "rbxassetid://11106505014",
			ImageColor3 = Color3.new(1, 0.2, 0.2),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(-0.8, 0, 0.8, 0),
			Position = UDim2.new(0.1, 0, -0.25, 0),
			Visible = false,
			ZIndex = 3,
			Parent = rq.gui
		})
		local badgeText = create("Frame")({
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 0.8, 0),
			Position = UDim2.new(0.5, 0, 0.1, 0),
			ZIndex = 4,
			Parent = badgeIcon
		})
		function self:updateBadgeNumber(n)
			badgeText:ClearAllChildren()
			if n == 0 then
				badgeIcon.Visible = false
				return
			end
			badgeIcon.Visible = true
			write(tostring(n))({Frame = badgeText, Scaled = true})
		end
		rqButton = rq
		self:updateBadgeNumber(#requests)
	end
	local function tableCell()
		return create("Frame")({
			BorderSizePixel = 0,
			ZIndex = 2,
			create("Frame")({
				Name = "PlayerName",
				BackgroundTransparency = 1,
				Size = UDim2.new(0.3, 0, 0.6, 0),
				Position = UDim2.new(0.02, 0, 0.2, 0),
				ZIndex = 3
			})
		})
	end
	do
		local gui
		function trade:updateRequests()
			for i = #requests, 1, -1 do
				if requests[i].expired then
					table.remove(requests, i)
				end
			end
			if gui and gui.Parent then
				local list = gui.gui.List
				local container = list.Container
				local ht = 0.05
				local contentRelativeSize = #requests * ht * container.AbsoluteSize.X / list.AbsoluteSize.Y
				list.CanvasSize = UDim2.new(list.Size.X.Scale, -1, contentRelativeSize * list.Size.Y.Scale, 0)
				container:ClearAllChildren()
				for i, request in pairs(requests) do
					do
						local cell = tableCell()
						if i % 2 == 1 then
							cell.BackgroundColor3 = Color3.new(0, 0.48, 0.75)
						else
							cell.BackgroundTransparency = 1
						end
						cell.Size = UDim2.new(1, 0, ht, 0)
						cell.Position = UDim2.new(0, 0, ht * (i - 1), 0)
						cell.Parent = container
						write(request.fromName)({
							Frame = cell.PlayerName,
							Scaled = true,
							TextXAlignment = Enum.TextXAlignment.Left
						})
						local button = create("TextButton")({
							Text = "",
							BackgroundColor3 = Color3.new(0, 0.24, 0.5),
							AutoButtonColor = false,
							BorderSizePixel = 0,
							Size = UDim2.new(0.175, 0, 0.8, 0),
							Position = UDim2.new(0.8, 0, 0.1, 0),
							ZIndex = 3,
							Parent = cell,
							MouseButton1Click = function()
								if accepting or not _p.Menu.enabled then
									return
								end
								self:acceptRequest(request)
							end
						})
						write("Accept")({
							Frame = create("Frame")({
								BackgroundTransparency = 1,
								Size = UDim2.new(0, 0, 0.8, 0),
								Position = UDim2.new(0.5, 0, 0.1, 0),
								ZIndex = 4,
								Parent = button
							}),
							Scaled = true
						})
					end
				end
			else
				local n = 0
				for _, r in pairs(requests) do
					if r.new then
						n = n + 1
					end
				end
				self:updateBadgeNumber(n)
			end
		end
		function trade:viewRequests()
			if not gui then
				gui = _p.RoundedFrame:new({
					BackgroundColor3 = Color3.new(0, 0.64, 1),
					Size = UDim2.new(0.6, 0, 0.7, 0),
					Parent = Utilities.backGui,
					create("ScrollingFrame")({
						Name = "List",
						BackgroundColor3 = BrickColor.new("Deep blue").Color,
						BorderSizePixel = 0,
						TopImage = "rbxassetid://1028868491",
						MidImage = "rbxassetid://1028874299",
						BottomImage = "rbxassetid://1028873474",
						Size = UDim2.new(0.9, 0, 0.7, 0),
						Position = UDim2.new(0.05, 0, 0.2, 0),
						ZIndex = 2,
						create("Frame")({
							Name = "Container",
							BackgroundTransparency = 1,
							SizeConstraint = Enum.SizeConstraint.RelativeXX
						})
					}),
					create("Frame")({
						Name = "ErrorText",
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0.05, 0),
						Position = UDim2.new(0.5, 0, 0.925, 0),
						ZIndex = 2
					})
				})
				write("Trade Requests")({
					Frame = create("Frame")({
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0.08, 0),
						Position = UDim2.new(0.5, 0, 0.01, 0),
						ZIndex = 2,
						Parent = gui.gui
					}),
					Scaled = true
				})
				do
					local header = tableCell()
					header.BackgroundColor3 = BrickColor.new("Navy blue").Color
					header.Position = UDim2.new(0.05, 0, 0.12, 0)
					local function cr()
						gui.CornerRadius = Utilities.gui.AbsoluteSize.Y * 0.04
						local sbw = Utilities.gui.AbsoluteSize.Y * 0.035
						gui.gui.List.ScrollBarThickness = sbw
						gui.gui.List.Container.Size = UDim2.new(1, -sbw, 1, -sbw)
						header.Size = UDim2.new(0.9, 0, 0.08, 0)
					end
					Utilities.gui.Changed:connect(cr)
					cr()
					header.Parent = gui.gui
					write("From")({
						Frame = header.PlayerName,
						Scaled = true,
						TextXAlignment = Enum.TextXAlignment.Left
					})
					rqListGui = gui
				end
			elseif gui.Parent then
				gui.Parent = nil
				return
			end
			if tradeRQgui then
				tradeRQgui.Parent = nil
			end
			for _, r in pairs(requests) do
				r.new = false
			end
			self:updateBadgeNumber(0)
			gui.Parent = Utilities.backGui
			self:updateRequests()
			Utilities.Tween(0.5, "easeOutCubic", function(a)
				gui.Position = UDim2.new(0.2, 0, 0.15 - (1 - a), 0)
			end)
		end
		function trade:acceptRequest(request)
			if request.expired then
				self:updateRequests()
				self:error("This request has expired", gui.gui.ErrorText)
				return
			end
			if not request.from or not request.from.Parent then
				request.expired = true
				self:updateRequests()
				self:error("Trade partner has left the game", gui.gui.ErrorText)
				return
			end

			spawn(function() _p.Menu:disable() end)
			accepting = request
			request.accepted = true
			local tag = {}
			_p.DataManager:setLoading(tag, true)
			network:post("TradeRequest", request.from, request)
			request.loadTag = tag
			wait(15)
			if not request.completed and not request.failed then
				accepting = nil
				_p.DataManager:setLoading(tag, false)
				self:error("Trade partner not ready", gui.gui.ErrorText)
				_p.Menu:enable()
			end
		end
	end
	function trade:onRequestAccepted(partner, request)
		if self.busy or _p.NPCChat.chatBox and _p.NPCChat.chatBox.Parent or not _p.Menu.enabled then
			request.error = "Player is busy"
			network:post("TradeRequest", partner, request)
			return
		end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		spawn(function() _p.Menu:disable() end)
		if not _p.NPCChat:say(partner.Name .. " accepted your trade request.", "[y/n]Are you ready to trade?") then
			request.error = "The trade partner canceled the trade"
			network:post("TradeRequest", partner, request)
			_p.MasterControl.WalkEnabled = true
			_p.Menu:enable()
			return
		end
		if not partner or not partner.Parent then
			self:error("The trade partner left the game")
			_p.MasterControl.WalkEnabled = true
			_p.Menu:enable()
			return
		end
		request.pseudoHost = true
		request.partner = partner
		self:beforeTrade()
		_p.Trade:createSession()
		network:post("TradeRequest", partner, {
			joinTrade = _p.Trade.sessionId
		})
	end
	function trade:receivedRequest(from, request)
		for i = #requests, 1, -1 do
			if requests[i].from == from then
				table.remove(requests, i)
			end
		end
		request.from = from
		request.fromName = from.Name
		request.new = true
		table.insert(requests, request)
		delay(60, function()
			request.expired = true
			self:updateRequests()
		end)
		self:updateRequests()
	end
	function trade:error(txt)
		if not tradeRQgui then
			return
		end
		local frame = globalError
		frame:ClearAllChildren()
		local thisThread = {}
		errorThread = thisThread
		write(txt)({
			Frame = frame,
			Color = Color3.new(1, 0.2, 0.2),
			Scaled = true
		})
		wait(3)
		if errorThread == thisThread then
			frame:ClearAllChildren()
		end
	end
	function trade:sendRequest()
		if not settings.targetPlayer then
			self:error("No trade partner selected")
			return
		end
		if not settings.targetPlayer.Parent then
			self:error("Selected player has left the resort")
			return
		end
		network:post("TradeRequest", settings.targetPlayer, settings)
		return true
	end
	function trade:onClickedPlayer(player)
		if rqListGui then
			rqListGui.Parent = nil
		end
		settings.targetPlayer = player
		if not tradeRQgui then
			tradeRQgui = _p.RoundedFrame:new({
				Button = true,
				BackgroundColor3 = Color3.new(0, 0.64, 1),
				Size = UDim2.new(0.4, 0, 0.4, 0),
				Parent = Utilities.backGui,
				create("Frame")({
					Name = "PartnerText",
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0.2, 0),
					Position = UDim2.new(0.5, 0, 0.4, 0),
					ZIndex = 2
				})
			})
			write("Trade With")({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0.2, 0),
					Position = UDim2.new(0.5, 0, 0.1, 0),
					ZIndex = 2,
					Parent = tradeRQgui.gui
				}),
				Scaled = true
			})
			do
				local cancel = _p.RoundedFrame:new({
					Button = true,
					BackgroundColor3 = Color3.new(0, 0.48, 0.75),
					Size = UDim2.new(0.35, 0, 0.2, 0),
					Position = UDim2.new(0.1, 0, 0.75, 0),
					ZIndex = 2,
					Parent = tradeRQgui.gui,
					MouseButton1Click = function()
						tradeRQgui.Parent = nil
					end
				})
				local send = _p.RoundedFrame:new({
					Button = true,
					BackgroundColor3 = Color3.new(0, 0.48, 0.75),
					Size = UDim2.new(0.35, 0, 0.2, 0),
					Position = UDim2.new(0.55, 0, 0.75, 0),
					ZIndex = 2,
					Parent = tradeRQgui.gui,
					MouseButton1Click = function()
						if self:sendRequest() then
							tradeRQgui.Parent = nil
						end
					end
				})
				write("Cancel")({
					Frame = create("Frame")({
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0.7, 0),
						Position = UDim2.new(0.5, 0, 0.15, 0),
						ZIndex = 3,
						Parent = cancel.gui
					}),
					Scaled = true
				})
				write("Send")({
					Frame = create("Frame")({
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0.7, 0),
						Position = UDim2.new(0.5, 0, 0.15, 0),
						ZIndex = 3,
						Parent = send.gui
					}),
					Scaled = true
				})
				local function cr()
					tradeRQgui.CornerRadius = Utilities.gui.AbsoluteSize.Y * 0.04
					cancel.CornerRadius = Utilities.gui.AbsoluteSize.Y * 0.03
					send.CornerRadius = Utilities.gui.AbsoluteSize.Y * 0.03
				end
				Utilities.gui.Changed:connect(cr)
				cr()
				tradeRQgui.Parent = nil
			end
		end
		local gui = tradeRQgui.gui
		gui.PartnerText:ClearAllChildren()
		write((player and player.Name or "NULL") .. "?")({
			Frame = gui.PartnerText,
			Scaled = true
		})
		if not tradeRQgui.Parent then
			tradeRQgui.Parent = Utilities.backGui
			Utilities.Tween(0.5, "easeOutCubic", function(a)
				tradeRQgui.Position = UDim2.new(0.3, 0, 0.3 - (1 - a), 0)
			end)
		end
	end


	return trade end
