return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write
	local Roulette = {
		rouletteType = 1
	}

	local SpriteData = nil 

	--local stampData = require(script.StampData)
	local pokemonRarities, pokedexBySpecies = unpack(require(script.PokemonData))

	local runService = game:GetService('RunService')

	local SPIN_SPEED = 2.3
	local SPIN_DECEL = .4

	local styleIcons = {}
	for i = 0, 4 do
		styleIcons[i+1] = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://673676504',
			ImageRectSize = Vector2.new(180, 180),
			ImageRectOffset = Vector2.new(10+200*(i%3), 10+200*math.floor(i/3)),
			ZIndex = 3
		}
	end

	local bsig


	local tierColors = {
		[0] = Color3.new(.7, .7, .7),
		Color3.fromRGB(21,198,27),
		Color3.fromRGB(32,63,216),
		Color3.fromRGB(107,17,216),
		Color3.fromRGB(219,189,101),
		Color3.fromRGB(127,0,0)
	}

	for i, tc in pairs(tierColors) do
		local h, s, v = Color3.toHSV(tc)
		tierColors[i] = Color3.fromHSV(h, s*.7, math.min(1, v*1.2))
	end


	local function getRandomPokemon(rand, rouletteType)
		rand = rand or math.random
		local tr = rand(100)
		local tier = 1
		if tr < 2 then
			tier = 5
		elseif tr < 8 then
			tier = 4
		elseif tr < 25 then
			tier = 3
		elseif tr < 60 then
			tier = 2
		end
		local _RND = rand(20)
		if _RND > 16 then
			tier = rouletteType
			if not tier then
				tier = Roulette.rouletteType
			end
		end

		local species = pokemonRarities[tier][math.random(#pokemonRarities[tier])]

		local pokeInfo = {
			species = species,
			color3 = tierColors[tier],
			rarity = tier,
			icon = pokedexBySpecies[species].icon,
		}
		return pokeInfo 

	end

	Roulette.getRandomPokemon = getRandomPokemon

	local function getStampIcon(stamp, button)
		if not stamp then
			stamp = getRandomPokemon()
		end

		local m = create(button and 'ImageButton' or 'ImageLabel') {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://6607914519',
			ImageColor3 = tierColors[stamp.rarity],
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(Vector2.new(20, 20), Vector2.new(80, 80)),
			AnchorPoint = Vector2.new(.5, 0),
			Size = UDim2.new(1.0, 0, 1.0, 0),
			ZIndex = 2
		}
		local image = nil
		if not stamp.icon then
			image = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				ImageTransparency = 1,
				--	ImageColor3 = stamp.color3,
				Size = UDim2.new(.6, 0, .6, 0),
				Position = UDim2.new(.2, 0, .1, 0),
				ZIndex = 2, Parent = m
			}
		else
			--image = create 'ImageLabel' {
			--	BackgroundTransparency = 1.0,
			--	Image = 'rbxassetid://'..stamp.gifInfo[1],
			--	ImageRectSize = Vector2.new(stamp.gifInfo[2], stamp.gifInfo[3]),
			--	Size = UDim2.new(.6, 0, .6, 0),
			--	Position = UDim2.new(.2, 0, .1, 0),
			--	ZIndex = 2, Parent = m
			--}
			local icon = _p.Pokemon:getIcon(stamp.icon-1, false)
			icon.Size = UDim2.new(.6, 0, .6, 0)
			icon.Position =  UDim2.new(.2, 0, .1, 0)
			icon.ZIndex = 2
			icon.Parent = m 
		end

		--local image = create 'ImageLabel' {
		--	BackgroundTransparency = 1.0,
		--	Image = 'rbxassetid://'..stamp.sheetId,
		--	ImageColor3 = stamp.color3,
		--	ImageRectSize = Vector2.new(200, 200),
		--	Size = UDim2.new(.6, 0, .6, 0),
		--	Position = UDim2.new(.2, 0, .1, 0),
		--	ZIndex = 2, Parent = m
		--}

		local q = stamp.species
		if stamp.species then 
			create 'TextLabel' {
				Name = 'SpeciesLabel',
				BackgroundTransparency = 1.0,
				Font = Enum.Font.Cartoon,
				Text = q,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				Size = UDim2.new(.3, 0, .25, 0),
				Position = UDim2.new(.1, 0, .65, 0),
				ZIndex = 3, Parent = m
			}
		end

		--local s = styleIcons[stamp.rarity]:Clone()
		--s.Size = UDim2.new(.38, 0, .38, 0)
		--s.Position = UDim2.new(.54, 0, .58, 0)
		--s.Parent = m
		return m
	end



	function Roulette:openSpinner()
		if self.spinnerOpen then return end
		self.spinnerOpen = true
		Roulette.rouletteType = 1
		
		local animating = true

		local bg = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://6607916286', -- 673784783
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(.6*4168/2217, 0, .6, 0),
			AnchorPoint = Vector2.new(.5, .5),
			ZIndex = 4, Parent = Utilities.frontGui
		}
		local pointer = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://6607849828',
			ImageColor3 = Color3.new(.8, .8, .8),
			ImageTransparency = .5,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(0.14, 0, 0.1, 0),
			AnchorPoint = Vector2.new(.5, .5),
			Position = UDim2.new(0.5, 0, 0.32, 0),
			ZIndex = 5, Parent = bg
		}
		local clipContainer = create 'Frame' {
			ClipsDescendants = true,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(37, 43, 49),
			Size = UDim2.new(.8, 0, .46, 0),
			Position = UDim2.new(.1, 0, .27, 0),
			Parent = bg
		}
		local squareContainer = create 'Frame' {
			BackgroundTransparency = 1.0,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(.7, 0, .7, 0),
			AnchorPoint = Vector2.new(.5, 0),
			Position = UDim2.new(.5, 0, 0.12, 0),
			Parent = clipContainer
		}
		local sig = Utilities.Signal()
		local spinning = true
		local stop = false
		local stopping = false

		local spins, shownSpins

		--1000x532
		--left  311x57@100,407
		--right 311x57@589,407
		local cr = Utilities.gui.AbsoluteSize.Y*.02
		local ypad = .032
		local xpad = .01--ypad/532*1000

		write 'Roulette Spinner' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(.0, 0, .125, 0),
				Position = UDim2.new(.5, 0, .1, 0),
				ZIndex = 5, Parent = bg
			}, Scaled = true
		}

		local buyButton = _p.RoundedFrame:new {
			CornerRadius = cr,
			Button = true,
			BackgroundColor3 = Color3.fromRGB(53, 63, 73),
			Size = UDim2.new(.311+xpad, 0, 57/532+ypad, 0),
			Position = UDim2.new(.35-xpad/2, 0, 407/532-ypad/2, 0),
			ZIndex = 5, Parent = bg,
			MouseButton1Click = function()
				if animating or not spinning or stop then return end
				local products = {_p.productId.RouletteSpinBasic, _p.productId.RouletteSpinBronze, _p.productId.RouletteSpinSilver, _p.productId.RouletteSpinGold, _p.productId.RouletteSpinDiamond}
				_p.MarketClient:promptProductPurchase(products[Roulette.rouletteType])
			end
		}
		write 'Buy Spin' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(.0, 0, .5, 0),
				Position = UDim2.new(.5, 0, .25, 0),
				ZIndex = 6, Parent = buyButton.gui
			}, Scaled = true
		}
		--local spinButton = _p.RoundedFrame:new {
		--	CornerRadius = cr,
		--	Button = true,
		--	BackgroundColor3 = Color3.fromRGB(53, 63, 73),
		--	Size = UDim2.new(.311+xpad, 0, 57/532+ypad, 0),
		--	Position = UDim2.new(.589-xpad/2, 0, 407/532-ypad/2, 0),
		--	ZIndex = 5, Parent = bg,
		--	MouseButton1Click = function()
		--		if animating then return end
		--		-- do nothing more than try to flag a stop here
		--		-- the step function takes care of accepting the stop and running related code
		--		stop = true
		--	end
		--}
		--write 'Use Spin' {
		--	Frame = create 'Frame' {
		--		BackgroundTransparency = 1.0,
		--		Size = UDim2.new(.0, 0, .5, 0),
		--		Position = UDim2.new(.5, 0, .25, 0),
		--		ZIndex = 6, Parent = spinButton.gui
		--	}, Scaled = true
		--}
		local closeButton = _p.RoundedFrame:new {
			Button = true,
			CornerRadius = cr*.5,
			BackgroundColor3 = Color3.fromRGB(53, 63, 73),
			Size = UDim2.new(.14, 0, .09, 0),
			Position = UDim2.new(.84, 0, .2, 0),
			ZIndex = 5, Parent = bg,
			MouseButton1Click = function()
				if animating or stop or stopping then return end
				animating = true
				sig:fire()
			end
		}
		write 'Close' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(.0, 0, .5, 0),
				Position = UDim2.new(.5, 0, .25, 0),
				ZIndex = 6, Parent = closeButton.gui
			}, Scaled = true
		}

		local oldBtn

		--ROULETTE TYPES --0.046, 0, 0.2, 0
		--local basicBTN = _p.RoundedFrame:new {
		--	Button = true,
		--	Name = "BasicBTN",
		--	CornerRadius = cr*.5,
		--	BackgroundColor3 = Color3.fromRGB(32, 214, 62),
		--	Size = UDim2.new(.093, 0, .178, 0),
		--	Position = UDim2.new(.026, 0, .2, 0),
		--	ZIndex = 5, Parent = bg,
		--	MouseButton1Click = function()
		--		if oldBtn then
		--			oldBtn.Size = UDim2.new(.093, 0, .178, 0)
		--		end
		--		bg:WaitForChild("BasicBTN").Size = UDim2.new(.093+0.03, 0, .178+0.03, 0)
		--		oldBtn = bg:WaitForChild("BasicBTN")
		--		Roulette.rouletteType = 1
		--	end
		--}
		local CLICK_SCALE = 0.03

		local basicBTN = create('ImageButton'){
			Name = 'BasicBTN',
			BackgroundTransparency = 1,
			ImageColor3 = Color3.fromRGB(32, 214, 62),
			Size = UDim2.new(.093+CLICK_SCALE, 0, .178+CLICK_SCALE, 0),-- UDim2.new(.093, 0, .178, 0),
			Position = UDim2.new(.046, 0, .2, 0),
			ZIndex = 15, 
			Parent = bg,
			AnchorPoint = Vector2.new(0.5, 0),
			Image = "rbxassetid://6607914519",
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(20, 20, 80, 80),
			create('TextLabel'){
				Text = "BASIC",
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				Font = Enum.Font.SourceSansBold,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 24,
				TextStrokeTransparency = 1,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 17,
			},
			MouseButton1Click = function()
				if oldBtn == bg:WaitForChild("BasicBTN") then return end
				if oldBtn then
					oldBtn.Size = UDim2.new(.093, 0, .178, 0)
				end
				oldBtn = bg:WaitForChild("BasicBTN")
				Roulette.rouletteType = 1
				Utilities.Tween(.4, 'easeOutCubic', function(a)
					bg:WaitForChild("BasicBTN").Size = UDim2.new(.093+CLICK_SCALE*a, 0, .178+CLICK_SCALE*a, 0)
				end)
			end,
		}

		oldBtn = basicBTN
		local bronzeBTN = create('ImageButton'){
			Name = 'BronzeBTN',
			BackgroundTransparency = 1,
			ImageColor3 = Color3.fromRGB(139, 78, 3),
			Size = UDim2.new(.093, 0, .178, 0),
			Position = UDim2.new(.046, 0, .4, 0),
			ZIndex = 15, 
			Parent = bg,
			AnchorPoint = Vector2.new(0.5, 0),
			Image = "rbxassetid://6607914519",
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(20, 20, 80, 80),
			create('TextLabel'){
				Text = "BRONZE",
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				Font = Enum.Font.SourceSansBold,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 20,
				TextStrokeTransparency = 1,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 17,
			},
			MouseButton1Click = function()
				if oldBtn == bg:WaitForChild("BronzeBTN") then return end
				if oldBtn then
					oldBtn.Size = UDim2.new(.093, 0, .178, 0)
				end
				--	bg:WaitForChild("BronzeBTN").Size = UDim2.new(.093+CLICK_SCALE, 0, .178+CLICK_SCALE, 0)
				oldBtn = bg:WaitForChild("BronzeBTN")
				Roulette.rouletteType = 2
				Utilities.Tween(.4, 'easeOutCubic', function(a)
					bg:WaitForChild("BronzeBTN").Size = UDim2.new(.093+CLICK_SCALE*a, 0, .178+CLICK_SCALE*a, 0)
				end)
			end,
		}


		local silverBTN = create('ImageButton'){
			Name = 'SilverBTN',
			BackgroundTransparency = 1,
			ImageColor3 = Color3.fromRGB(90, 90, 90),
			Size = UDim2.new(.093, 0, .178, 0),
			Position = UDim2.new(.046, 0, .6, 0),
			ZIndex = 15, 
			Parent = bg,
			AnchorPoint = Vector2.new(0.5, 0),
			Image = "rbxassetid://6607914519",
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(20, 20, 80, 80),
			create('TextLabel'){
				Text = "SILVER",
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				Font = Enum.Font.SourceSansBold,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 20,
				TextStrokeTransparency = 1,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 17,
			},
			MouseButton1Click = function()
				if oldBtn == bg:WaitForChild("SilverBTN") then return end
				if oldBtn then
					oldBtn.Size = UDim2.new(.093, 0, .178, 0)
				end
				--	bg:WaitForChild("SilverBTN").Size = UDim2.new(.093+CLICK_SCALE, 0, .178+CLICK_SCALE, 0)
				oldBtn = bg:WaitForChild("SilverBTN")
				Roulette.rouletteType = 3
				Utilities.Tween(.4, 'easeOutCubic', function(a)
					bg:WaitForChild("SilverBTN").Size = UDim2.new(.093+CLICK_SCALE*a, 0, .178+CLICK_SCALE*a, 0)
				end)
			end,
		}


		local goldBTN = create('ImageButton'){
			Name = 'GoldBTN',
			BackgroundTransparency = 1,
			ImageColor3 = Color3.fromRGB(255, 219, 108),
			Size = UDim2.new(.093, 0, .178, 0),
			Position = UDim2.new(.95, 0, .3, 0),
			ZIndex = 15, 
			Parent = bg,
			AnchorPoint = Vector2.new(0.5, 0),
			Image = "rbxassetid://6607914519",
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(20, 20, 80, 80),
			create('TextLabel'){
				Text = "GOLD",
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				Font = Enum.Font.SourceSansBold,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 20,
				TextStrokeTransparency = 1,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 17,
			},
			MouseButton1Click = function()
				if oldBtn == bg:WaitForChild("GoldBTN") then return end
				if oldBtn then
					oldBtn.Size = UDim2.new(.093, 0, .178, 0)
				end
				--	bg:WaitForChild("GoldBTN").Size = UDim2.new(.093+CLICK_SCALE, 0, .178+CLICK_SCALE, 0)
				oldBtn = bg:WaitForChild("GoldBTN")
				Roulette.rouletteType = 4
				Utilities.Tween(.4, 'easeOutCubic', function(a)
					bg:WaitForChild("GoldBTN").Size = UDim2.new(.093+CLICK_SCALE*a, 0, .178+CLICK_SCALE*a, 0)
				end)
			end,
		}

		local diamondBTN = create('ImageButton'){
			Name = 'DiamondBTN',
			BackgroundTransparency = 1,
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(.093, 0, .178, 0),
			Position = UDim2.new(.95, 0, .5, 0),
			ZIndex = 15, 
			Parent = bg,
			AnchorPoint = Vector2.new(0.5, 0),
			Image = "rbxassetid://6607914519",
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(20, 20, 80, 80),
			create('TextLabel'){
				Text = "DIAMOND",
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				Font = Enum.Font.SourceSansBold,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 16,
				TextStrokeTransparency = 1,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 17,
			},
			create 'UIGradient' {
				Rotation = 45,
				Color = ColorSequence.new(Color3.fromRGB(83, 255, 212), Color3.fromRGB(64, 124, 255)),
			},
			MouseButton1Click = function()
				if oldBtn == bg:WaitForChild("DiamondBTN") then return end
				if oldBtn then
					oldBtn.Size = UDim2.new(.093, 0, .178, 0)
				end
				--	bg:WaitForChild("DiamondBTN").Size = UDim2.new(.093+CLICK_SCALE, 0, .178+CLICK_SCALE, 0)
				oldBtn = bg:WaitForChild("DiamondBTN")
				Roulette.rouletteType = 5
				Utilities.Tween(.4, 'easeOutCubic', function(a)
					bg:WaitForChild("DiamondBTN").Size = UDim2.new(.093+CLICK_SCALE*a, 0, .178+CLICK_SCALE*a, 0)
				end)
			end,
		}

		--.178
		--local countContainer = create 'Frame' {
		--	ClipsDescendants = true,
		--	BorderSizePixel = 0,
		--	BackgroundColor3 = Color3.fromRGB(53, 63, 73),
		--	Size = UDim2.new(.11, 0, .095, 0),
		--	AnchorPoint = Vector2.new(.5, .5),
		--	Position = UDim2.new(.5, 0, .82, 0),
		--	ZIndex = 5, Parent = bg
		--}

		_p.Network:bindEvent("doBoughtSpin", function()
			spins = 1
			stop = true
			pcall(function()
				bsig:fire()
			end)
		end)

		local nums = {}
		local numCurrent = {}
		local function writeNumber(s)
			local f = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(.0, 0, .6, 0),
				ZIndex = 6
			}
			write(s) {Frame = f, Scaled = true}
			return f
		end

		local lastThread, currentThread
		local function setNumSpins(n)
			spins = n
			local thisThread = {}
			lastThread = thisThread
			if currentThread then
				while true do
					wait()
					if lastThread ~= thisThread then return end
					if not currentThread then break end
				end
			end
			currentThread = thisThread
			local animDir = 0
			if shownSpins then
				animDir = shownSpins > n and -1 or 1
			end
			local spinString = tostring(n)
			local animFuncs = {}
			for i = 1, 3 do
				local s = spinString:sub(-i,-i)
				s = s=='' and '0' or s
				if s ~= numCurrent[i] then
					numCurrent[i] = s
					local w = writeNumber(s)
					--w.Parent = countContainer
					local x = (7-2*i)/6
					if animDir == 0 or not nums[i] then
						w.Position = UDim2.new(x, 0, .2, 0)
					else
						local replacing = nums[i]
						table.insert(animFuncs, function()
							Utilities.Tween(.5, nil, function(a)
								replacing.Position = UDim2.new(x, 0, .2+a*animDir, 0)
								w.Position = UDim2.new(x, 0, .2-animDir+a*animDir, 0)
							end)
							replacing:Destroy()
						end)
					end
					nums[i] = w
				end
			end
			if #animFuncs > 0 then
				Utilities.Sync(animFuncs)
			end
			shownSpins = n
			if currentThread == thisThread then
				currentThread = nil
			end
		end


		local w = clipContainer.AbsoluteSize.X/squareContainer.AbsoluteSize.Y
		local half_w = w/2

		local et = 0
		local p0 = math.ceil(half_w)+1
		local speed = SPIN_SPEED
		local pos, accel, ep, wr, wonStamp

		local flashPointer

		local things = {}
		local thingCount = 0
		local null = {}
		local gcount = 0

		local rsId = 'RSpin_'..Utilities.uid()
		local st = tick()
		local spinUpdate = function()
			if not spinning then return end

			local et = tick()-st
			if accel then
				if accel*et+speed < 0 then
					pos = ep
				else
					pos = p0 + speed*et + accel*.5*et*et
				end
			else
				pos = p0 + speed*et
			end

			-- add/destroy things as necessary
			local min = math.floor(pos-half_w)
			local max = math.ceil(pos+half_w)
			--		print(min, max)
			for i = gcount+1, min-1 do
				local t = things[i]
				if t and t ~= null then
					t:Destroy()
					things[i] = null
				end
				gcount = i
			end
			for i = math.max(min, thingCount+1), max do
				local t = getStampIcon(i==wr and wonStamp or nil)
				--			t.Name = 'thing'..i --
				t.Parent = squareContainer
				things[i] = t
				thingCount = i
			end
			-- position things
			for i = min, max do
				things[i].Position = UDim2.new(1.03*(i-pos), 0, 0.0, 0)
			end

			if pos == ep then
				spinning = false
				--			local pauseAt = tick()
				pos = ep
				local wt = things[wr]
				local p = wt.Position.X.Scale-.5
				local newTopGui = Instance.new('ScreenGui', game.Players.LocalPlayer:WaitForChild('PlayerGui'))
				local sp = wt.AbsolutePosition
				local ss = wt.AbsoluteSize
				local es = ss * 1.5
				local ep = newTopGui.AbsoluteSize/2-es/2
				local ds, dp = es-ss, ep-sp
				wt.Parent = newTopGui
				wt.AnchorPoint = Vector2.new(0, 0)
				Utilities.Tween(.5, 'easeOutCubic', function(a)
					wt.Size = UDim2.new(.0, ss.X+ds.X*a, .0, ss.Y+ds.Y*a)
					wt.Position = UDim2.new(.0, sp.X+dp.X*a, .0, sp.Y+dp.Y*a)
				end)
				local quantity = ({'a', 'two', 'three'})[wonStamp.quantity or 1]
				--local colorName = wonStamp.colorName
				--if colorName == 'NoColor' then
				--	colorName = ''
				--else
				--	colorName = colorName:gsub('%u', ' %0')
				--end
				local chat = _p.NPCChat
				chat.bottom = true
				chat:say('You got '..wonStamp.species..'!')
				chat.bottom = nil
				newTopGui:Destroy()
				things[wr] = null
				-- safe reset here would be nice
				st = tick()-- -pos/speed
				p0 = pos
				accel, ep, wr, wonStamp = nil, nil, nil, nil
				stop = false
				spinning = true
				pointer.ImageTransparency = .5
				return
			end
			if not stopping and not accel then
				if stop then
					if et < .3 or not spins or spins < 1 then
						stop = false
					else
						stopping = true

						Utilities.fastSpawn(setNumSpins, spins-1)

						pointer.ImageTransparency = .0
						spawn(function()
							if not flashPointer then
								flashPointer = pointer:Clone()
								flashPointer.Parent = bg
							end
							Utilities.Tween(.5, 'easeOutCubic', function(a)
								local s = 1+a
								flashPointer.Size = UDim2.new(s*.14, 0, s*.1, 0)
								flashPointer.ImageTransparency = a
							end)
						end)

						Utilities.fastSpawn(function()
							wonStamp = _p.Network:get('PDS', 'spinRouletteForPoke')
							if not wonStamp then return end

							p0 = pos -- note that `pos` here has been changed by parallel thread
							accel = -SPIN_DECEL
							st = tick()

							local t = speed / -accel
							ep = pos + speed*t + .5*accel*t*t

							local mep = ep + .5*1.03
							local upper = math.ceil(mep)
							local lower = math.floor(mep)
							--				print(lower, upper)
							--				print(string.format('%.2f, %.2f', mep-lower, upper-mep))
							wr = upper-mep < mep-lower and upper or lower
							stopping = false
						end)
					end
					--			elseif pos > 100 then
					--				print('safe reset')
					--				local newThings = {}
					--				for i = min, max do
					--					newThings[i-gcount] = things[i]
					--				end
					--				things = newThings
					--				p0 = pos - gcount
					--				st = tick()-- - pos/speed
					--				gcount = 0
					--				thingCount = max - gcount
				end
			end

		end

		runService:BindToRenderStep(rsId, Enum.RenderPriority.First.Value+5, spinUpdate)

		Utilities.Tween(.6, 'easeOutCubic', function(a)
			bg.Position = UDim2.new(.5, 0, -.5+a, 0)
		end)
		animating = false
		sig:wait()
		Utilities.Tween(.6, 'easeOutCubic', function(a)
			bg.Position = UDim2.new(.5, 0, .5-a, 0)
		end)

		spinning = false
		runService:UnbindFromRenderStep(rsId)

		buyButton:destroy()
		--spinButton:destroy()
		closeButton:destroy()
		bg:Destroy()

		self.spinnerOpen = false
	end


	return Roulette
end 
