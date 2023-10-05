-- Decompiled with the Synapse X Luau decompiler.

return function(p1)
	local v1 = {};
	local score = 0
	local l__map__2 = p1.DataManager.currentChunk.map;
	local u1 = l__map__2.Smonkaroons;
	function v1.randomizeGradient(p2)
		local v3 = Random.new():NextNumber(-0.5, 0.5);
		u1.Board.SurfaceGui.BackgroundContainer.Gradient.Position = UDim2.new(0, 0, v3, 0);
	end;
	local l__Utilities__2 = p1.Utilities;
	function v1.floatingText(p3, p4, p5)
		local v4 = Instance.new("Part");
		v4.Name = "Floating";
		v4.Anchored = true;
		v4.CanCollide = false;
		v4.Transparency = 1;
		v4.Parent = workspace;
		v4.Size = Vector3.new(0.876, 0.715, 0.001);
		local v5 = Instance.new("BillboardGui");
		v5.Parent = v4;
		v5.LightInfluence = 0;
		v5.Size = UDim2.new(2, 0, 2, 0);
		local v6 = l__Utilities__2.Create("TextLabel")({
			TextColor3 = Color3.new(1, 1, 1), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(1, 0, 1, 0), 
			Position = UDim2.new(0, 0, 0, 0), 
			Text = "+" .. p4, 
			TextSize = 28, 
			Name = "NewScore", 
			BackgroundTransparency = 1, 
			Parent = v5
		});
		v4.CFrame = p5;
		local l__CFrame__3 = v4.CFrame;
		l__Utilities__2.Tween(1.5, "easeOutCubic", function(p6)
			v4.CFrame = l__CFrame__3 * CFrame.new(0, 0.5 * p6, 0);
		end);
		v4:Destroy();
	end;
	local u4 = nil;
	local u5 = 0;
	function v1.start(p7, p8)
		u4 = p8 or l__map__2.Smonkaroons;
		u1 = u4;
		local l__CurrentCamera__7 = workspace.CurrentCamera;
		l__CurrentCamera__7.CameraType = Enum.CameraType.Scriptable;
		local l__CFrame__6 = l__CurrentCamera__7.CFrame;
		local u7 = u1.Target.CFrame * CFrame.new(5, 5.5, -8) * CFrame.Angles(math.rad(0), math.rad(150), 0);
		l__Utilities__2.Tween(1, "easeInOutCubic", function(p9)
			l__CurrentCamera__7.CFrame = l__CFrame__6:Lerp(u7, p9);
		end);
		u1.Board.SurfaceGui.Enabled = true;
		local v8 = l__Utilities__2.Create("TextLabel")({
			TextColor3 = Color3.new(1, 1, 1), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(1, 0, 1, 0), 
			Position = UDim2.new(0, 0, 0, 0), 
			Text = "000", 
			TextSize = 28, 
			Name = "Score", 
			BackgroundTransparency = 1, 
			Parent = u1.Board.SurfaceGui.ScoreContainer
		});
		v1:GetArrow();
		wait(1.8);
		v1:GetArrow();
		wait(1.8);
		v1:GetArrow();
		wait(1.8);
		v8.Visible = false;
		wait(0.5);
		v8.Visible = true;
		wait(1.5);
		v8.Visible = false;
		wait(0.5);
		v8.Visible = true;
		wait(1.5);
		v8.Visible = false;
		wait(0.5);
		v8.Visible = true;
		wait(1.5);
		u5 = 0;
		u1.Board.SurfaceGui.ScoreContainer.Score:destroy();
		u1.Board.SurfaceGui.Enabled = false;
		u1.hammer:destroy();
		l__Utilities__2.Tween(1, "easeInOutCubic", function(p10)
			l__CurrentCamera__7.CFrame = u7:Lerp(l__CFrame__6, p10);
		end);
		l__CurrentCamera__7.CameraType = Enum.CameraType.Custom;
		print(score)
		p1.Network:get("PDS", "ArcadeReward", "hammer", score)
	end;
	function v1.GetArrow(p11)
		if u1:FindFirstChild("hammer") then
			u1.hammer:destroy();
		end;
		local v9 = l__map__2.WhackADiglett.frame.hammer:Clone();
		v9.Parent = u1;
		v9.CFrame = u1.Target.CFrame * CFrame.new(0, 4, -2);
		v9.Mesh.Scale = Vector3.new(0.4, 0.4, 0.4);
		local l__Arrow__10 = u1.Board.SurfaceGui.Arrow;
		local l__mouse__11 = game.Players.LocalPlayer:GetMouse();
		local v12 = Instance.new("NumberValue");
		v12.Parent = workspace;
		l__Arrow__10.Position = UDim2.new(0, 0, 0, 0);
		v1:randomizeGradient();
		local u8 = nil;
		local u9 = false;
		local function u10(p12)
			return math.floor(p12 + 0.5);
		end;
		local u11 = 0;
		u8 = l__mouse__11.Button1Down:Connect(function()
			u8:disconnect();
			local v13 = u1.Target.CFrame * CFrame.new(0, 4, -2);
			local u12 = v9.CFrame;
			l__Utilities__2.Tween(0.15, nil, function(p13)
				v9.CFrame = u12 * CFrame.new(0, -2 * p13, 1 * p13) * CFrame.Angles(math.rad(90 * p13), 0, 0);
			end);
			u9 = true;
			spawn(function()
				local v14 = l__Utilities__2.Create("Sound")({
					Parent = u1.Target, 
					TimePosition = 0, 
					Volume = 0.8, 
					SoundId = "rbxassetid://138285836", 
					PlaybackSpeed = 0.9, 
					Playing = true
				});
				v14.Ended:Connect(function()
					v14:destroy();
				end);
			end);
			u12 = v9.CFrame;
			spawn(function()
				l__Utilities__2.Tween(0.15, nil, function(p14)
					v9.CFrame = u12:Lerp(v13, p14);
				end);
			end);
			if v12.Value > 4.8 and v12.Value < 5.1 then
				v1:hitTarget(100);
			end;
			if v12.Value > 5.2 then
				v1:hitTarget(u10(u11 * 10 * 2));
			end;
			if v12.Value < 4.8 then
				v1:hitTarget(u10(u11 * 10 * 2));
			end;
		end);
		local l__Gradient__13 = u1.Board.SurfaceGui.BackgroundContainer.Gradient;
		spawn(function()
			while true do
				task.wait();
				if u9 then
					break;
				end;
				v12.Value = (l__Gradient__13.AbsolutePosition - l__Arrow__10.AbsolutePosition).Magnitude / 24.5;
				if v12.Value > 4.8 and v12.Value < 5.2 then
					u11 = 5;
				end;
				if v12.Value > 5.25 then
					if v12.Value > 5.27 and v12.Value < 6 then
						u11 = 4.5;
					end;
					if v12.Value > 6.1 and v12.Value < 6.5 then
						u11 = 4;
					end;
					if v12.Value > 6.5 and v12.Value < 7 then
						u11 = 3.5;
					end;
					if v12.Value > 7.1 and v12.Value < 7.5 then
						u11 = 3;
					end;
					if v12.Value > 7.6 and v12.Value < 8 then
						u11 = 2.5;
					end;
					if v12.Value > 8.1 and v12.Value < 8.5 then
						u11 = 2;
					end;
					if v12.Value > 8.6 and v12.Value < 9 then
						u11 = 1.5;
					end;
					if v12.Value > 9.5 and v12.Value < 10 then
						u11 = 1;
					end;
				elseif v12.Value < 4.8 then
					u11 = (l__Gradient__13.AbsolutePosition - l__Arrow__10.AbsolutePosition).Magnitude / 24.5;
				end;			
			end;
		end);
		while not u9 do
			task.wait();
			l__Utilities__2.Tween(0.35, nil, function(p15)
				if u9 then
					return false;
				end;
				l__Arrow__10.Position = UDim2.new(0.4, 0, 0 + 0.9 * p15);
			end);
			l__Utilities__2.Tween(0.35, nil, function(p16)
				if u9 then
					return false;
				end;
				l__Arrow__10.Position = UDim2.new(0.4, 0, 0.9 - 0.9 * p16);
			end);		
		end;
	end;
	function v1.hitTarget(p17, p18)
		p18 = p18 
		local v15 = u1.FirstGreen:Clone();
		local v16 = u1.SecondGreen:Clone();
		v15.Parent = u1.Frame;
		v16.Parent = u1.Frame;
		local l__Size__17 = v15.Size;
		local l__Size__18 = v16.Size;
		local u14 = v15.CFrame;
		l__Utilities__2.Tween(0.2, nil, function(p19)
			v15.Size = Vector3.new(0.21, 0.21, 0.21 + 6.1 * p19);
			v15.CFrame = u14 * CFrame.new(0, 0, 3.05 * p19);
		end);
		spawn(function()
			for v19, v20 in pairs(u1.Lights:GetDescendants()) do
				if v20:IsA("BasePart") then
					spawn(function()
						while v15.Parent and v16.Parent do
							task.wait();
							if v20.CFrame.Y < v16.CFrame.Y + p18 / 16 then
								v20.Material = Enum.Material.Neon;
							else
								v20.Material = Enum.Material.SmoothPlastic;
							end;						
						end;
					end);
				end;
			end;
		end);
		local u15 = v16.CFrame;
		l__Utilities__2.Tween(0.7, "easeOutCubic", function(p20)
			v16.Size = Vector3.new(0.22, 0.22 + p18 / 7.5 * p20, 0.22);
			v16.CFrame = u15 * CFrame.new(0, 0 + p18 / 16 * p20, 0);
		end);
		if p18 == 100 then
			local v21 = l__Utilities__2.Create("Sound")({
				Parent = u1.Bell, 
				TimePosition = 0.3, 
				Volume = 1, 
				SoundId = "rbxassetid://6150774030", 
				PlaybackSpeed = 0.3, 
				Playing = true
			});
			v21.Ended:Connect(function()
				v21:destroy();
			end);
		end;
		u5 = u5 + p18;
		if u5 == 0 then
			u1.Board.SurfaceGui.ScoreContainer.Score.Text = "00" .. u5;
		end;
		if u5 >= 10 then
			u1.Board.SurfaceGui.ScoreContainer.Score.Text = "0" .. u5;
		end;
		if u5 >= 100 then
			u1.Board.SurfaceGui.ScoreContainer.Score.Text = u5;
		end;
		score = tonumber(u5)
		u14 = v15.CFrame;
		u15 = v16.CFrame;
		spawn(function()
			v1:floatingText(p18, u15 * CFrame.new(2, p18 / 16, 0));
		end);
		l__Utilities__2.Tween(0.7, "easeInCubic", function(p21)
			v16.CFrame = u15 * CFrame.new(0, 0 - p18 / 7 * p21, 0);
		end);
		local l__Z__16 = v15.Size.Z;
		l__Utilities__2.Tween(0.2, nil, function(p22)
			v15.Size = Vector3.new(0.21, 0.21, l__Z__16 - 6.1 * p22);
			v15.CFrame = u14 * CFrame.new(0, 0, -3.05 * p22);
		end);
		v15:Destroy();
		v16:Destroy();
	end;
	return v1;
end;
