-- Decompiled with the Synapse X Luau decompiler.

return function(p1)
	local v1 = {};
	local l__map__2 = p1.DataManager.currentChunk.map;
	local l__WhackADiglett__3 = l__map__2.WhackADiglett;
	local l__UniqueMoles__4 = l__WhackADiglett__3.UniqueMoles;
	local l__Common__1 = l__WhackADiglett__3.Common;
	local u2 = nil;
	local l__Utilities__3 = p1.Utilities;
	local u4 = 45;
	local score = 0
	function v1.appear(p2, p3, p4)
		local v5 = math.random(1, 9);
		p4 = p4 and math.random(1, 9);
		if u2.Nodes[p4]:FindFirstChild("Occupied") then
			return;
		end;
		local v6 = (p3 or l__Common__1):Clone();
		v6.Parent = u2.frame;
		local l__p__7 = v6.p;
		l__Utilities__3.MoveModel(l__p__7, u2.Nodes[p4].CFrame * CFrame.new(1, 0, 0));
		local v8 = l__Utilities__3.Create("NumberValue")({
			Name = "Occupied", 
			Value = 0, 
			Parent = u2.Nodes[p4]
		});
		local u5 = v6.p.CFrame;
		l__Utilities__3.Tween(0.2, nil, function(p5)
			l__Utilities__3.MoveModel(l__p__7, u5 * CFrame.new(-1.5 * p5, 0, 0));
		end);
		local v9 = Instance.new("NumberValue");
		local v10 = 0;
		if u4 < 30 then
			v10 = 1;
		end;
		if u4 < 15 then
			v10 = 2;
		end;
		v9.Value = 3 - v10;
		v9.Parent = v6;
		spawn(function()
			while true do
				task.wait();
				if v9.Value == 0 then
					break;
				end;			
			end;
			u5 = v6.p.CFrame;
			l__Utilities__3.Tween(0.2, nil, function(p6)
				l__Utilities__3.MoveModel(l__p__7, u5 * CFrame.new(1.5 * p6, 0, 0));
			end);
			u2.Nodes[p4].Occupied:destroy();
			v6:Destroy();
		end);
		while true do
			wait(1);
			v9.Value = v9.Value - 1;		
		end;
	end;
	local l__Rare__6 = l__WhackADiglett__3.Rare;
	local u7 = { l__UniqueMoles__4.Beard, l__UniqueMoles__4.BuilderDong, l__UniqueMoles__4.Girl, l__UniqueMoles__4.Landumb, l__UniqueMoles__4.Our_Negr0, l__UniqueMoles__4.Sparkle, l__UniqueMoles__4.TheBreadMan, l__UniqueMoles__4.TopHat, l__UniqueMoles__4.Watermelon, l__UniqueMoles__4.Zambie, l__UniqueMoles__4.Brew };
	function v1.SpawnBunch(p7, p8)
		p8 = p8 and 2;
		for v11 = 1, p8 do
			spawn(function()
				local v12 = l__Common__1;
				if math.random(1, 40) == 1 then
					v12 = l__Rare__6;
				end;
				if math.random(1, 10) == 1 then
					v12 = u7[math.random(1, #u7)];
				end;
				v1:appear(v12, math.random(1, 9));
			end);
		end;
	end;
	function v1.GetHammer(p9)
		local v13 = u2.frame.hammer:Clone();
		v13.Parent = workspace;
		local l__MousePlane__14 = u2.MousePlane;
		v13.Size = Vector3.new(0.8, 2, 1.5);
		v13.Mesh.Scale = Vector3.new(0.21, 0.21, 0.21);
		v13.Position = l__MousePlane__14.Position;
		local l__Heartbeat__15 = game:GetService("RunService").Heartbeat;
		local l__mouse__8 = game.Players.LocalPlayer:GetMouse();
		local u9 = l__MousePlane__14.Position.Y + 1.5;
		local u10 = false;
		local u11 = l__mouse__8.Button1Down:Connect(function()
			if u10 then
				return;
			end;
			u10 = true;
			l__Utilities__3.Tween(0.1, nil, function(p10)
				v13.Orientation = Vector3.new(0 + 90 * p10, 90, 0);
			end);
			v13.Anchored = false;
			local v16 = v13:GetTouchingParts();
			local u12 = false;
			local u13 = nil;
			u13 = v13.Touched:Connect(function(p11)
				if p11.Name == "p" then
					if u12 then
						u13:Disconnect();
					end;
					if not u12 then
						u12 = true;
						print("HIT");
						local v17 = Instance.new("Part");
						v17.Transparency = 1;
						v17.Anchored = true;
						v17.CFrame = p11.CFrame;
						v17.Parent = u2;
						v17.Name = "BoomPart";
						local v18 = Instance.new("Attachment");
						v18.Parent = v17;
						v18.Position = Vector3.new(-0.7, 0, -0.15);
						--local v19 = u2.Boom:Clone();
						--v19.Enabled = true;
						--v19.Parent = v18;
						--v19.AlwaysOnTop = true;
						delay(0.2, function()
							v17:Destroy();
						end);
						p11.Parent.Value.Value = 0;
						if u2:FindFirstChild("Score") then
							if p11.Parent.Name == "Common" then
								u2.Score.Value = u2.Score.Value + 50;
								return;
							end;
							if p11.Parent.Name == "Rare" then
								u2.Score.Value = u2.Score.Value + 500;
								return;
							end;
							u2.Score.Value = u2.Score.Value + 100;
						end;
					end;
				end;
			end);
			delay(0.01, function()
				if not u12 then
					u13:Disconnect();
				end;
			end);
			l__Utilities__3.Tween(0.1, nil, function(p12)
				v13.Orientation = Vector3.new(90 - 90 * p12, 90, 0);
			end);
			v13.Anchored = true;
			u12 = false;
			u10 = false;
		end);
		local u14 = l__Heartbeat__15:Connect(function()
			v13.Orientation = Vector3.new(0, 90, 0);
			v13.Position = Vector3.new(l__mouse__8.Hit.X, u9, l__mouse__8.Hit.Z);
		end);
		spawn(function()
			while task.wait() do
				if u2.Scoreboard.SurfaceGui:FindFirstChild("TimeCount") and u2.Scoreboard.SurfaceGui.TimeCount.Text == "00" then
					u11:Disconnect();
					u14:Disconnect();
					v13:Destroy();
					return;
				end;			
			end;
		end);
	end;
	local u15 = false;
	function v1.start(p13, p14)
		u2 = p14 or l__map__2.WhackADiglett;
		u2.frame.Barrier.CFrame = CFrame.new(0, 0, 0);
		u4 = 45;
		local l__SurfaceGui__20 = u2.Scoreboard.SurfaceGui;
		local v21 = l__Utilities__3.Create("TextLabel")({
			BackgroundTransparency = 1, 
			TextColor3 = Color3.new(1, 1, 1), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(0.2, 0, 0.2, 0), 
			Position = UDim2.new(0.79, 0, 0, 0), 
			Text = "00000", 
			TextSize = 65, 
			Parent = l__SurfaceGui__20
		});
		local v22 = l__Utilities__3.Create("TextLabel")({
			BackgroundTransparency = 1, 
			TextColor3 = Color3.new(1, 1, 1), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(0.2, 0, 0.2, 0), 
			Position = UDim2.new(0.57, 0, 0, 0), 
			Text = "Score", 
			TextSize = 65, 
			Parent = l__SurfaceGui__20
		});
		local v23 = l__Utilities__3.Create("TextLabel")({
			BackgroundTransparency = 1, 
			TextColor3 = Color3.new(1, 1, 1), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(0.25, 0, 0.2, 0), 
			Position = UDim2.new(0, 0, 0, 0), 
			Text = "Time", 
			TextSize = 65, 
			Parent = l__SurfaceGui__20
		});
		local v24 = l__Utilities__3.Create("TextLabel")({
			BackgroundTransparency = 1, 
			TextColor3 = Color3.new(1, 1, 1), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(0.15, 0, 0.2, 0), 
			Position = UDim2.new(0.2, 0, 0, 0), 
			Text = "45", 
			Name = "TimeCount", 
			TextSize = 65, 
			Parent = l__SurfaceGui__20
		});
		local l__CurrentCamera__25 = workspace.CurrentCamera;
		l__CurrentCamera__25.CameraType = Enum.CameraType.Scriptable;
		local l__CFrame__16 = l__CurrentCamera__25.CFrame;
		local u17 = u2.focal.CFrame * CFrame.new(0, -1.5, 7) * CFrame.Angles(math.rad(-15), math.rad(0), math.rad(0));
		l__Utilities__3.Tween(1, "easeInOutCubic", function(p15)
			l__CurrentCamera__25.CFrame = l__CFrame__16:Lerp(u17, p15);
		end);
		v1:GetHammer();
		local v26 = Instance.new("NumberValue");
		v26.Name = "Score";
		v26.Parent = u2;
		local u18 = 0;
		spawn(function()
			while v26.Parent do
				u18 = v26.Value;
				task.wait();
				if u18 == 0 then
					v21.Text = "0000" .. u18;
				end;
				if u18 < 100 and u18 > 10 then
					v21.Text = "000" .. u18;
				end;
				if u18 >= 100 then
					v21.Text = "00" .. u18;
				end;
				if u18 >= 1000 then
					v21.Text = "0" .. u18;
				end;
				if u18 >= 10000 then
					v21.Text = u18;
				end;
				score = tonumber(u18)
			end;
		end);
		spawn(function()
			while not (u4 <= 0) do
				v1:SpawnBunch(math.random(2, 4));
				local v27 = 1;
				if u4 < 30 then
					v27 = 1.5;
				end;
				if u4 < 15 then
					v27 = 2;
				end;
				wait(math.random(1, 2) / v27);			
			end;
		end);
		while true do
			u15 = false;
			if u4 == 0 then
				break;
			end;
			wait(1);
			u4 = u4 - 1;
			v24.Text = u4;
			if u4 < 10 then
				v24.Text = "0" .. u4;
			end;		
		end;
		local v28 = l__Utilities__3.Create("TextLabel")({
			BackgroundTransparency = 1, 
			TextColor3 = Color3.new(0, 0, 0), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(1, 0, 0.65, 0), 
			Position = UDim2.new(0, 0, 0, 0), 
			Text = "Final Score", 
			TextSize = 100, 
			Parent = l__SurfaceGui__20
		});
		local v29 = l__Utilities__3.Create("TextLabel")({
			BackgroundTransparency = 1, 
			TextColor3 = Color3.new(0, 0, 0), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(1, 0, 1, 0), 
			Position = UDim2.new(0, 0, 0, 0), 
			Text = "00000", 
			TextSize = 100, 
			Parent = l__SurfaceGui__20
		});
		if u18 == 0 then
			v29.Text = "0000" .. u18;
		end;
		if u18 < 100 and u18 > 10 then
			v29.Text = "000" .. u18;
		end;
		if u18 >= 100 then
			v29.Text = "00" .. u18;
		end;
		if u18 >= 1000 then
			v29.Text = "0" .. u18;
		end;
		if u18 >= 10000 then
			v29.Text = u18;
		end;
		wait(1.5);
		v28.Visible = false;
		v29.Visible = false;
		wait(0.5);
		v28.Visible = true;
		v29.Visible = true;
		wait(1.5);
		v28.Visible = false;
		v29.Visible = false;
		wait(0.5);
		v28.Visible = true;
		v29.Visible = true;
		wait(1.5);
		v28.Visible = false;
		v29.Visible = false;
		wait(0.5);
		v28.Visible = true;
		v29.Visible = true;
		wait(1.5);
		v29:destroy();
		v28:destroy();
		v26:Destroy();
		v24:destroy();
		v23:destroy();
		v22:destroy();
		v21:destroy();
		l__Utilities__3.Tween(1, "easeInOutCubic", function(p16)
			l__CurrentCamera__25.CFrame = u17:Lerp(l__CFrame__16, p16);
		end);
		l__CurrentCamera__25.CameraType = Enum.CameraType.Custom;
		u2.frame.Barrier.CFrame = u2.frame.Barrier.CFrame;
		u18 = 0;
		print(score)
		p1.Network:get("PDS", "ArcadeReward", "whack", score)
	end;
	return v1;
end;
