return function(_p)--local _p = require(script.Parent.Parent)--game:GetService('ReplicatedStorage').Plugins)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write


	local TrainerCard = {}
	local cr = .035

--[[
	Themes:
		main						light
red		Color3.new(1, .4, .4)	Color3.new(1, .8, .8)
blue		Color3.new(.2, .4, 1)	Color3.new(.4, .8, 1)
--]]


	function TrainerCard:viewMyCard()
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()

		spawn(function() _p.Menu:disable() end)
		local mouseDisabler = create 'ImageButton' {
			BackgroundTransparency = 1.0,
			Selectable = false,
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
			ZIndex = 1, Parent = Utilities.frontGui,
		}
		self:createGui(true)
		local gui = self.gui
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			gui.Position = UDim2.new(0.5, -gui.gui.AbsoluteSize.X/2, 1.0-.7*a, 0)
		end)
		local close = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = Color3.new(1, 1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(1/5, 0, 1/16, 0),
			Position = UDim2.new(0.6, 0, 0.3-3/32, 0),
			ZIndex = 3, Parent = Utilities.frontGui,
		}
		write 'Close' {
			Frame = create 'Frame' {
				Name = 'ButtonText',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 0.7, 0),
				Position = UDim2.new(0.0, 0, 0.15, 0),
				ZIndex = 4, Parent = close.gui,
			}, Scaled = true, Color = Color3.new(.6, .6, .6),
		}
		gui.close = close
		close.MouseButton1Click:wait()
		gui.close = nil
		close:Destroy()
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			gui.Position = UDim2.new(0.5, -gui.gui.AbsoluteSize.X/2, 0.3+.7*a, 0)
		end)
		gui:Destroy()
		self.gui = nil
		mouseDisabler:Destroy()

		_p.MasterControl.WalkEnabled = true
		_p.Menu:enable()
	end

	function TrainerCard:enterName(renaming)
		local gui = self.gui
		if not renaming then
			self:createGui(true, true)
			gui = self.gui
			Utilities.Tween(.5, 'easeOutCubic', function(a)
				gui.Position = UDim2.new(0.5, -gui.gui.AbsoluteSize.X/2, 1.0-.7*a, 0)
			end)
		end
		local container = create 'Frame' {
			BackgroundTransparency = 1.0,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(0.95, 0, 0.5, 0),
			Position = UDim2.new(0.5, -gui.gui.AbsoluteSize.X/2, 0.3, 0),
			Parent = Utilities.gui
		}
		--	wait(1)
		gui.Parent = container
		gui.SizeConstraint = Enum.SizeConstraint.RelativeXY
		Utilities.Tween(.6, 'easeOutCubic', function(a)
			local scale = 1+2*a
			gui.CornerRadius = Utilities.gui.AbsoluteSize.Y*cr*scale
			gui.Size = UDim2.new(-scale, 0, scale, 0)
			gui.Position = UDim2.new(1.0+.25*a, 0, -0.1*a, 0)
		end)
		local entryBox = create 'TextBox' {
			BackgroundTransparency = 1.0,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			Font = Enum.Font.SourceSansBold,
			Text = '',
			Size = UDim2.new(0, 300, 0.8, 0),
			Position = UDim2.new(0.75, 0, 0.1, 0),
			ZIndex = 4,
			Parent = gui.gui.NameStripe,
		}
		local prompt = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.1, 0),
			Position = UDim2.new(0.5, 0, 0.05, 0),
			Parent = Utilities.gui,
		}
		write 'Type your name.' {
			Frame = prompt,
			Scaled = true,
		}
		local function filter() -- in-game filter; Roblox's filter applied below
			entryBox.Text = entryBox.Text:gsub('%s', '')
			if entryBox.Text:len() > 16 then
				entryBox.Text = entryBox.Text:sub(1, 16)
			end
		end
		entryBox.Changed:connect(filter)
		local name, nameFrame
		local player = _p.player
		while true do
			pcall(function() nameFrame:Destroy() end)
			prompt.Visible = true
			entryBox:CaptureFocus()
			entryBox.FocusLost:wait()
			filter()
			name = entryBox.Text
			pcall(function() name = _p.Network:get('PDS', 'getFilteredString', entryBox.Text) end)
			entryBox.Text = name
			if name:len() > 0 then
				prompt.Visible = false
				entryBox.Text = ''
				nameFrame = create 'Frame' {
					Name = 'NAME',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.55, 0),
					Position = UDim2.new(0.75, 0, 0.275, 0),
					ZIndex = 4, Parent = gui.gui.NameStripe,
				}
				write(name) {
					Frame = nameFrame,
					Scaled = true,
				}
				if _p.NPCChat:say('[y/n]"' .. name .. '" ... Did I write that correctly?') then break end
			end
		end
		entryBox:Destroy()
		prompt:Destroy()
		--
		_p.PlayerData.trainerName = name
		_p.Network:post('PDS', 'chooseName', name)
		Utilities.Tween(.6, 'easeOutCubic', function(a)
			local scale = 3-2*a
			local o = 1-a
			gui.CornerRadius = Utilities.gui.AbsoluteSize.Y*cr*scale
			gui.Size = UDim2.new(-scale, 0, scale, 0)
			gui.Position = UDim2.new(1.0+.25*o, 0, -0.1*o, 0)
		end)
		gui.Parent = Utilities.frontGui
		gui.SizeConstraint = Enum.SizeConstraint.RelativeYY
		gui.Size = UDim2.new(0.95, 0, 0.5, 0)
		gui.Position = UDim2.new(0.5, -self.gui.gui.AbsoluteSize.X/2, 0.3, 0)
		--	wait(1)
		--	Utilities.Tween(.6, 'easeOutCubic', function(a)
		--		gui.Position = UDim2.new(0.5, -self.gui.gui.AbsoluteSize.X/2, 0.3+.7*a, 0)
		--	end)
	end

	function TrainerCard:createGui(forceNew, ignoreName)
		if self.gui and not forceNew then return end
		pcall(function() self.gui:Destroy() end)
		pcall(function() self.resizeCn:disconnect() end)
		local theme = Color3.new(.6, .6, .6)
		local themeLight = Color3.new(1, 1, 1)
		self.gui = _p.RoundedFrame:new {
			CornerRadius = Utilities.gui.AbsoluteSize.Y*cr,
			BackgroundColor3 = themeLight,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(0.95, 0, 0.5, 0),
			Position = UDim2.new(.25,0,.3,0), 
			ZIndex = 2, Parent = Utilities.frontGui,

			create 'Frame' {
				Name = 'NameStripe',
				BorderSizePixel = 0,
				BackgroundColor3 = theme,
				Size = UDim2.new(1.0, 0, 0.15, 0),
				Position = UDim2.new(0.0, 0, 0.075, 0),
				ZIndex = 3,
			},

			create 'Frame' {
				Name = 'ID',
				BorderSizePixel = 0,
				BackgroundColor3 = theme,
				Size = UDim2.new(0.4, 0, 0.075, 0),
				Position = UDim2.new(0.025, 0, 0.25, 0),
				ZIndex = 3,
			},
			create 'Frame' {
				Name = 'Dex',
				BorderSizePixel = 0,
				BackgroundColor3 = theme,
				Size = UDim2.new(0.4, 0, 0.075, 0),
				Position = UDim2.new(0.025, 0, 0.35, 0),
				ZIndex = 3,
			},
			create 'Frame' {
				Name = 'Money',
				BorderSizePixel = 0,
				BackgroundColor3 = theme,
				Size = UDim2.new(0.4, 0, 0.075, 0),
				Position = UDim2.new(0.025, 0, 0.45, 0),
				ZIndex = 3,
			},
			create 'Frame' {
				Name = 'BP',
				BorderSizePixel = 0,
				BackgroundColor3 = theme,
				Size = UDim2.new(0.4, 0, 0.075, 0),
				Position = UDim2.new(0.025, 0, 0.55, 0),
				ZIndex = 3,
			},
			create 'Frame' {
				Name = 'Tix',
				BorderSizePixel = 0,
				BackgroundColor3 = theme,
				Size = UDim2.new(0.4, 0, 0.075, 0),
				Position = UDim2.new(0.025, 0, 0.65, 0),
				ZIndex = 3,
			},

			create 'Frame' {
				Name = 'Badges',
				BorderSizePixel = 0,
				BackgroundColor3 = theme,
				Size = UDim2.new(1.0, 0, 0.15, 0),
				Position = UDim2.new(0.0, 0, 0.775, 0),
				ZIndex = 4,
			},

			create 'Frame' {
				BackgroundTransparency = 1.0,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(-0.65, 0, 0.65, 0),
				Position = UDim2.new(0.95, 0, 0.3, 0),
				ClipsDescendants = true,

				create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'http://www.roblox.com/Thumbs/Avatar.ashx?format=png&width=352&height=352&userId='..(_p.userId > 1 and _p.userId or 1),
					Size = UDim2.new(1.0, 0, 1.0, 0),
					Position = UDim2.new(),
					ZIndex = 3,
				},
			}
		}
		write 'Trainer Card' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.7, 0),
				Position = UDim2.new(0.05, 0, 0.15, 0),
				ZIndex = 4, Parent = self.gui.gui.NameStripe,
			}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
		}

		write 'ID:' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.7, 0),
				Position = UDim2.new(0.05, 0, 0.15, 0),
				ZIndex = 4, Parent = self.gui.gui.ID,
			}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
		}
		write(tostring(_p.userId)) {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.7, 0),
				Position = UDim2.new(0.95, 0, 0.15, 0),
				ZIndex = 4, Parent = self.gui.gui.ID,
			}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
		}

		write 'Money:' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.7, 0),
				Position = UDim2.new(0.05, 0, 0.15, 0),
				ZIndex = 4, Parent = self.gui.gui.Money,
			}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
		}


		write 'Badges:' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.4, 0),
				Position = UDim2.new(0.04, 0, 0.15, 0),
				ZIndex = 5, Parent = self.gui.gui.Badges,
			}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
		}
		local badgeLabels = {}
		for i, scale in pairs({1.25, 1.1, 1.1, 1.5, 1, 1.3, 1, 1}) do
			badgeLabels[i] = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(scale, 0, scale, 0),
				Position = UDim2.new(-(scale-1)/2, 0, -(scale-1)/2, 0),
				ZIndex = 6,
				Parent = create 'Frame' {
					BorderColor3 = themeLight,
					BackgroundColor3 = theme,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(1.0, 0, 1.0, 0),
					Position = UDim2.new(0.11 + 0.098*i, 0, 0.2, 0),
					ZIndex = 5, Parent = self.gui.gui.Badges,
				}
			}
		end
		if ignoreName then
			write '[$]0' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.7, 0),
					Position = UDim2.new(0.95, 0, 0.15, 0),
					ZIndex = 4, Parent = self.gui.gui.Money,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
			}
		else
			Utilities.fastSpawn(function()
				local data = _p.Network:get('PDS', 'getCardInfo')
				write(data.name) {
					Frame = create 'Frame' {
						Name = 'NAME',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.55, 0),
						Position = UDim2.new(0.75, 0, 0.275, 0),
						ZIndex = 4, Parent = self.gui.gui.NameStripe,
					}, Scaled = true
				}
				local edit_button; edit_button = create 'ImageButton' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://6604651220',
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(-.5, 0, .5, 0),
					Position = UDim2.new(.98, 0, .4, 0),
					ZIndex = 4, Parent = self.gui.gui.NameStripe,
					MouseButton1Click = function()
						edit_button.Visible = false
						pcall(function() self.gui.gui.NameStripe.NAME:Destroy() end)
						pcall(function() self.gui.close.Visible = false end)
						self:enterName(true)
						_p.Menu:rewriteTrainerName()
						edit_button.Visible = true
						pcall(function() self.gui.close.Visible = true end)
					end
				}
				if data.dex > 0 then
					write 'Pok[e\']dex:' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.7, 0),
							Position = UDim2.new(0.05, 0, 0.15, 0),
							ZIndex = 4, Parent = self.gui.gui.Dex,
						}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
					}
					write(tostring(data.dex)) {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.7, 0),
							Position = UDim2.new(0.95, 0, 0.15, 0),
							ZIndex = 4, Parent = self.gui.gui.Dex,
						}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
					}
				end
				write('[$]'..Utilities.comma_value(data.money)) {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.7, 0),
						Position = UDim2.new(0.95, 0, 0.15, 0),
						ZIndex = 4, Parent = self.gui.gui.Money,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
				}
				if data.badges[1] == 1 then
					write 'BP:' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.7, 0),
							Position = UDim2.new(0.05, 0, 0.15, 0),
							ZIndex = 4, Parent = self.gui.gui.BP,
						}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
					}
					write(tostring(data.bp)) {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.7, 0),
							Position = UDim2.new(0.95, 0, 0.15, 0),
							ZIndex = 4, Parent = self.gui.gui.BP,
						}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
					}
				end
				if data.badges[3] == 1 then
					write 'Tix:' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.7, 0),
							Position = UDim2.new(0.05, 0, 0.15, 0),
							ZIndex = 4, Parent = self.gui.gui.Tix,
						}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
					}
					write(Utilities.comma_value(data.tix)) {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.7, 0),
							Position = UDim2.new(0.95, 0, 0.15, 0),
							ZIndex = 4, Parent = self.gui.gui.Tix,
						}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
					}
				end
				for i = 1, 8 do
					if data.badges[i] == 1 and _p.badgeImageId[i] then
						badgeLabels[i].Image = 'rbxassetid://'.._p.badgeImageId[i]
					end
				end
			end)
		end
		--	self.resizeCn = Utilities.gui.Changed:connect(function(prop)
		--		if prop ~= 'AbsoluteSize' then return end
		----		self.gui.Position = UDim2.new(0.5, -self.gui.gui.AbsoluteSize.X/2, self.gui.gui.Position.Y.Scale, 0)
		----		self.gui.CornerRadius = Utilities.gui.AbsoluteSize.Y*cr
		--	end)
	end


	return TrainerCard end