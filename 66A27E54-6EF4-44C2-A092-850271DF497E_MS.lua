-- Animated Sprites v4
return function(p1) -- Line: 2
	local t_Stepped = game:GetService("RunService").Stepped
	local connect_ret = nil
	local table1 = {}
	local v1 = p1.Utilities.class({
		className = "AnimatedSprite",
		border = 1,
		startPixelY = 0,
		speed = 0.03,
		paused = true,
		startTime = 0,
		currentFrame = 0,
		nCaches = 0
	}, function(p12, pixelated) -- Line: 25
		local table2 = {
			spriteData = p12,
			startTime = tick()
		}
		local Instance_new_ret = Instance.new(p12.button and "ImageButton" or "ImageLabel")
		Instance_new_ret.BackgroundTransparency = 1
		Instance_new_ret.Size = UDim2.new(1, 0, 1, 0)
		Instance_new_ret.ImageRectSize = Vector2.new(p12.fWidth, p12.fHeight)
		if pixelated then
			Instance_new_ret.ResampleMode = Enum.ResamplerMode.Pixelated
		end
		table2.spriteLabel = Instance_new_ret
		if #p12.sheets > 1 then
			table2.nCaches = 1
			local ImageLabel = Instance.new("ImageLabel", Instance_new_ret)
			ImageLabel.ImageTransparency = 0.9
			ImageLabel.Image = "rbxassetid://" .. p12.sheets[1].id
			ImageLabel.BackgroundTransparency = 1
			ImageLabel.Size = UDim2.new(0, 1, 0, 1)
			if pixelated then
				ImageLabel.ResampleMode = Enum.ResamplerMode.Pixelated
			end
			table2.cache = ImageLabel
		end
		return table2
	end)
	v1.New = v1.new
	local t_UpdateFrame = nil
	local function update() -- Line: 71
		--[[
			Upvalues:
				[1] = table1
				[2] = connect_ret
				[3] = t_UpdateFrame
		--]]
		if #table1 == 0 then
			connect_ret:disconnect()
			connect_ret = nil
			return
		end
		for _, val1 in pairs(table1) do
			t_UpdateFrame(val1)
		end
	end
	function v1.Play(p2, p3) -- Line: 83
		--[[
			Upvalues:
				[1] = table1
				[2] = connect_ret
				[3] = t_Stepped
				[4] = update
		--]]
		if not p2.paused then return end
		p2.relativeSpeed = p3 or 1
		p2.paused = false
		if p2.pauseOffset then
			p2.startTime = tick() - p2.pauseOffset
			p2.pauseOffset = nil
		end
		for _, val2 in pairs(table1) do
			if p2 ~= val2 then continue end
			return
		end
		if not p2.frameData then
			local v9 = 0
			local t_spriteData = p2.spriteData
			local table3 = {}
			for key5, val5 in pairs(t_spriteData.sheets) do
				local v11 = v9
				local v12 = v9 + val5.rows * t_spriteData.framesPerRow
				for index4 = v9, math.min(v12, t_spriteData.nFrames) - 1 do
					local v13 = index4 - v11
					local v14 = v13 % t_spriteData.framesPerRow
					local math_floor_ret = math.floor(v13 / t_spriteData.framesPerRow)
					local v15 = p2.nCaches > 0 and (key5 == #t_spriteData.sheets and t_spriteData.sheets[1].id or t_spriteData.sheets[key5 + 1].id) or nil
					table3[index4 + 1] = {
						"rbxassetid://" .. val5.id,
						Vector2.new(v14 * (t_spriteData.fWidth + (t_spriteData.border or p2.border)), math_floor_ret * (t_spriteData.fHeight + (t_spriteData.border or p2.border)) + (val5.startPixelY or p2.startPixelY)),
						v15 and "rbxassetid://" .. v15 or nil
					}
				end
				v9 = v12
			end
			p2.frameData = table3
		end
		table.insert(table1, p2)
		if not connect_ret then
			connect_ret = t_Stepped:connect(update)
		end
	end
	function v1.PlayOnce(p4, p5) -- Line: 130
		--[[
			Upvalues:
				[1] = table1
				[2] = connect_ret
				[3] = t_Stepped
				[4] = update
		--]]
		p4.endOfLoopReached = false
		p4.startTime = tick()
		p4.pauseAfterFirstLoop = true
		p4:RenderFirstFrame()
		p4:Play()
		local bool1 = false
		for _, val3 in pairs(table1) do
			if p4 ~= val3 then continue end
			bool1 = true
			break
		end
		if not bool1 then
			table.insert(table1, p4)
		end
		if not connect_ret then
			connect_ret = t_Stepped:connect(update)
		end
		if p5 then
			while not p4.endOfLoopReached do
				t_Stepped:wait()
			end
		end
	end
	function v1.Pause(p6) -- Line: 154
		--[[
			Upvalues:
				[1] = table1
		--]]
		if p6.paused then return end
		p6.paused = true
		p6.pauseOffset = tick() - p6.startTime
		for index1 = #table1, 1, -1 do
			if table1[index1] == p6 then
				table.remove(table1, index1)
			end
		end
	end
	function v1.UpdateFrame(p7) -- Line: 166
		--[[
			Upvalues:
				[1] = table1
		--]]
		if p7.paused then return end
		local t_spriteLabel = p7.spriteLabel
		if not t_spriteLabel.Parent then
			p7:Destroy()
			return
		end
		if not t_spriteLabel.Visible then return end
		local t_spriteData2 = p7.spriteData
		local math_floor_ret2 = math.floor((tick() - p7.startTime) / (t_spriteData2.speed or p7.speed) * p7.relativeSpeed)
		local v2
		if p7.pauseAfterFirstLoop and t_spriteData2.nFrames <= math_floor_ret2 then
			v2 = t_spriteData2.nFrames
			for index3 = #table1, 1, -1 do
				if table1[index3] == p7 then
					table.remove(table1, index3)
				end
			end
			p7.endOfLoopReached = true
		else
			v2 = math_floor_ret2 % t_spriteData2.nFrames + 1
		end
		if v2 == p7.currentFrame then return end
		p7.currentFrame = v2
		local v3 = p7.frameData[v2]
		t_spriteLabel.Image = v3[1]
		t_spriteLabel.ImageRectOffset = v3[2]
		if v3[3] then
			p7.cache.Image = v3[3]
		end
		if p7.updateCallback then
			p7.updateCallback(v2 / t_spriteData2.nFrames, v2)
		end
	end
	t_UpdateFrame = v1.UpdateFrame
	function v1.RenderFirstFrame(p8) -- Line: 201
		local t_spriteLabel2 = p8.spriteLabel
		local v4 = p8.spriteData.sheets[1]
		t_spriteLabel2.Image = "rbxassetid://" .. v4.id
		t_spriteLabel2.ImageRectOffset = Vector2.new(0, v4.startPixelY or 0)
	end
	function v1.RenderLastFrame(p9) -- Line: 209
		local t_spriteLabel3 = p9.spriteLabel
		local t_frameData = p9.frameData
		if t_frameData then
			local v10 = t_frameData[#t_frameData]
			t_spriteLabel3.Image = v10[1]
			t_spriteLabel3.ImageRectOffset = v10[2]
			return
		end
		local t_spriteData3 = p9.spriteData
		local v5 = t_spriteData3.nFrames
		local t_framesPerRow = t_spriteData3.framesPerRow
		local v6 = nil
		for _, val4 in pairs(t_spriteData3.sheets) do
			v6 = val4
			v5 = v5 - t_framesPerRow * val4.rows
		end
		t_spriteLabel3.Image = "rbxassetid://" .. v6.id
		t_spriteLabel3.ImageRectOffset = Vector2.new((v5 - 1) * (t_spriteData3.fWidth + (t_spriteData3.border or p9.border)), (v6.startPixelY or 0) + (v6.rows - 1) * (t_spriteData3.fHeight + (t_spriteData3.border or p9.border)))
	end
	function v1.Destroy(p10) -- Line: 230
		p10:destroy()
	end
	function v1.destroy(p11) -- Line: 231
		--[[
			Upvalues:
				[1] = table1
		--]]
		for index2 = #table1, 1, -1 do
			if table1[index2] == p11 then
				table.remove(table1, index2)
			end
		end
		pcall(function() -- Line: 239
			--[[
				Upvalues:
					[1] = p11
			--]]
			p11.spriteLabel:Destroy()
		end)
		for v7 in pairs(p11.frameData) do
			p11.frameData[v7] = nil
		end
		for v8 in pairs(p11) do
			p11[v8] = nil
		end
	end
	return v1
end