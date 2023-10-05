-- Decompiled with the Synapse X Luau decompiler.

return function(p1)
	local v1 = {};
	local l__Utilities__2 = p1.Utilities;
	local u1 = 8;
	local u2 = 0;
	local u3 = 0;
	local u4 = 0;
	local u5 = nil;
	local u6 = nil;
	local score = 0
	function v1.End(p2)
		u1 = 8;
		u2 = 0;
		u3 = 0;
		u4 = 0;
		u5.BallFolder:destroy();
		local l__CurrentCamera__3 = workspace.CurrentCamera;
		local l__Score__4 = u5.Scoreboard.SurfaceGui.Container.Score;
		local l__ScoreLabel__5 = u5.Scoreboard.SurfaceGui.Container.ScoreLabel;
		l__ScoreLabel__5.Visible = false;
		l__Score__4.Visible = false;
		wait(0.5);
		l__ScoreLabel__5.Visible = true;
		l__Score__4.Visible = true;
		wait(1.5);
		l__ScoreLabel__5.Visible = false;
		l__Score__4.Visible = false;
		wait(0.5);
		l__ScoreLabel__5.Visible = true;
		l__Score__4.Visible = true;
		wait(1.5);
		l__ScoreLabel__5.Visible = false;
		l__Score__4.Visible = false;
		wait(0.5);
		l__ScoreLabel__5.Visible = true;
		l__Score__4.Visible = true;
		wait(1.5);
		u5.Scoreboard.SurfaceGui.Container.Score:destroy();
		u5.Scoreboard.SurfaceGui.Container.ScoreLabel:destroy();
		local l__CFrame__7 = l__CurrentCamera__3.CFrame;
		l__Utilities__2.Tween(1, "easeInOutCubic", function(p3)
			l__CurrentCamera__3.CFrame = l__CFrame__7:Lerp(u6, p3);
		end);
		l__CurrentCamera__3.CameraType = Enum.CameraType.Custom;
		p2.GameEnded:fire();
		print(score)
		p1.Network:get("PDS", "ArcadeReward", "skeeball", score)
	end;
	local l__map__8 = p1.DataManager.currentChunk.map;
	function v1.start(p4, p5)
		u5 = p5 or l__map__8.Skeeball;
		u5.PlayerCollider.CanCollide = false;
		local l__CurrentCamera__6 = workspace.CurrentCamera;
		l__CurrentCamera__6.CameraType = Enum.CameraType.Scriptable;
		u6 = l__CurrentCamera__6.CFrame;
		local u9 = u5.Focal.CFrame * CFrame.new(0, -1.5, 20.8) * CFrame.Angles(math.rad(-13), math.rad(-0.5), 0);
		l__Utilities__2.Tween(1, "easeInOutCubic", function(p6)
			l__CurrentCamera__6.CFrame = u6:Lerp(u9, p6);
		end);
		local v7 = l__Utilities__2.Create("TextLabel")({
			TextColor3 = Color3.new(1, 1, 1), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(0.35, 0, 1, 0), 
			Position = UDim2.new(0.5, 0, 0, 0), 
			Text = "0000", 
			TextSize = 90, 
			Name = "Score", 
			BackgroundTransparency = 1, 
			Parent = u5.Scoreboard.SurfaceGui.Container
		});
		local v8 = l__Utilities__2.Create("TextLabel")({
			TextColor3 = Color3.new(1, 1, 1), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(0.65, 0, 1, 0), 
			Position = UDim2.new(0, 0, 0, 0), 
			Text = "Score", 
			TextSize = 90, 
			Name = "ScoreLabel", 
			BackgroundTransparency = 1, 
			Parent = u5.Scoreboard.SurfaceGui.Container
		});
		local v9 = l__Utilities__2.Create("Folder")({
			Name = "BallFolder", 
			Parent = u5
		});
		while u2 ~= u1 - 1 do
			u2 = u2 + 1;
			wait(0.2);
			local v10 = u5.ExtraBalls:Clone();
			v10.Name = "Ball" .. u2;
			v10.Parent = v9;
			local v11 = l__Utilities__2.Create("SpecialMesh")({
				TextureId = "rbxassetid://433357907", 
				Scale = Vector3.new(0.15, 0.15, 0.15), 
				MeshId = "rbxassetid://433357903", 
				Parent = v10
			});
			v10.CFrame = u5.ExtraBalls.CFrame;
			v10.CanCollide = true;
			v10.Transparency = 0;
			v10.Anchored = false;		
		end;
		wait(0.5);
		spawn(function()
			v1:rollBall();
		end);
	end;
	function v1.floatingText(p7, p8, p9)
		local v12 = Instance.new("Part");
		v12.Name = "Floating";
		v12.Anchored = true;
		v12.CanCollide = false;
		v12.Transparency = 1;
		v12.Parent = workspace;
		v12.Size = Vector3.new(0.876, 0.715, 0.001);
		local v13 = Instance.new("BillboardGui");
		v13.Parent = v12;
		v13.LightInfluence = 0;
		v13.Size = UDim2.new(2, 0, 2, 0);
		local v14 = l__Utilities__2.Create("TextLabel")({
			TextColor3 = Color3.new(1, 1, 1), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(1, 0, 1, 0), 
			Position = UDim2.new(0, 0, 0, 0), 
			Text = "+" .. p8, 
			TextSize = 28, 
			Name = "NewScore", 
			BackgroundTransparency = 1, 
			Parent = v13
		});
		v12.Position = p9;
		local l__CFrame__10 = v12.CFrame;
		l__Utilities__2.Tween(1.5, "easeOutCubic", function(p10)
			v12.CFrame = l__CFrame__10 * CFrame.new(0, 0.5 * p10, 0);
		end);
		v12:Destroy();
	end;
	function v1.rollBall(p11)
		local l__mouse__15 = game.Players.LocalPlayer:GetMouse();
		local v16 = nil;
		if u1 == 8 then
			v16 = u5.ExtraBalls:Clone();
			v16.Name = "Ball" .. u2;
			v16.Parent = u5;
			local v17 = l__Utilities__2.Create("SpecialMesh")({
				TextureId = "rbxassetid://433357907", 
				Scale = Vector3.new(0.15, 0.15, 0.15), 
				MeshId = "rbxassetid://433357903", 
				Parent = v16
			});
			v16.CFrame = u5.ballstart.CFrame * CFrame.new(0, 0.5, 0) * CFrame.Angles(0, math.rad(180), math.rad(0));
			v16.CanCollide = true;
			v16.Transparency = 0;
			v16.Anchored = true;
		elseif u1 < 8 and u1 > 0 then
			if u5:FindFirstChild("BallFolder") then
				v16 = u5.BallFolder["Ball" .. u3];
				v16.Parent = u5;
				v16.Anchored = true;
				v16.CFrame = u5.ballstart.CFrame * CFrame.new(0, 0.5, 0) * CFrame.Angles(math.rad(0), math.rad(180), math.rad(0));
			end;
		elseif u1 == 0 then
			v1:End();
			return;
		end;
		u1 = u1 - 1;
		u3 = u3 + 1;
		local v18 = l__Utilities__2.Create("Part")({
			Name = "Arrow", 
			Parent = u5, 
			Size = Vector3.new(0, 0, 0), 
			Anchored = true, 
			CanCollide = false, 
			CanTouch = false, 
			Transparency = 1
		});
		local v19 = l__Utilities__2.Create("Decal")({
			Texture = "rbxassetid://134915318", 
			Color3 = Color3.fromRGB(255, 217, 0), 
			Face = "Top", 
			Parent = v18
		});
		local u11 = 0;
		local u12 = false;
		local l__CFrame__13 = u5.ballstart.CFrame;
		local u14 = nil;
		local u15 = game:GetService("RunService").Heartbeat:Connect(function()
			if v18.Parent then
				v18.CFrame = v16.CFrame * CFrame.new(0, 0.8, 0) * CFrame.Angles(0, math.rad(180), 0);
				v18.Size = Vector3.new(1, 0, u11);
			end;
			if not u12 then
				if l__CFrame__13.Position.Z + 2.65 < l__mouse__15.Hit.Position.Z then
					return;
				end;
				if l__mouse__15.Hit.Position.Z < l__CFrame__13.Position.Z + -2.65 then
					return;
				end;
				v16.Position = Vector3.new(v16.Position.X, v16.Position.Y, l__mouse__15.Hit.Position.Z);
			end;
			if u12 then
				if l__CFrame__13.Position.Z + 3.5 < l__mouse__15.Hit.Position.Z then
					return;
				end;
				if l__mouse__15.Hit.Position.Z < l__CFrame__13.Position.Z + -3.5 then
					return;
				end;
				local v20, v21, v22 = CFrame.new(v16.CFrame.p, l__mouse__15.Hit.p):ToOrientation();
				local v23, v24, v25 = v16.CFrame:ToOrientation();
				v16.CFrame = CFrame.new(v16.CFrame.p) * CFrame.fromOrientation(v23, -v21, v22);
				u11 = (l__mouse__15.Hit.Position - v16.Position).Magnitude;
				if u11 > 3.5 then
					u11 = 3.5;
				end;
			end;
		end);
		u14 = l__mouse__15.Button1Down:Connect(function()
			u12 = true;
			u14:Disconnect();
			local u16 = nil;
			u16 = l__mouse__15.Button1Up:Connect(function()
				u15:Disconnect();
				u12 = false;
				v18:destroy();
				v16.Anchored = false;
				u16:disconnect();
				local v26 = -(l__mouse__15.Hit.Position - v16.Position).Magnitude;
				v16.Velocity = v16.CFrame.LookVector * u11 * 30;
				wait(3);
				v16.Anchored = true;
				wait(1);
				if v16.Parent then
					v16:Destroy();
					if u3 <= 8 then
						v1:rollBall();
					end;
				end;
			end);
		end);
		local u17 = nil;
		u17 = v16.Touched:Connect(function(p12)
			if p12.Parent.Name == "Holes" then
				u17:Disconnect();
				u4 = u4 + p12.Name;
				if u4 == 0 then
					u5.Scoreboard.SurfaceGui.Container.Score.Text = "000" .. u4;
				end;
				if u4 >= 10 then
					u5.Scoreboard.SurfaceGui.Container.Score.Text = "00" .. u4;
				end;
				if u4 >= 100 then
					u5.Scoreboard.SurfaceGui.Container.Score.Text = "0" .. u4;
				end;
				if u4 >= 1000 then
					u5.Scoreboard.SurfaceGui.Container.Score.Text = u4;
				end;
				score = tonumber(u4)
				v1:floatingText(p12.Name, v16.Position + Vector3.new(0, 1.5, 0));
				v16:Destroy();
				if u3 <= 8 then
					v1:rollBall();
				end;
			end;
		end);
	end;
	v1.GameEnded = l__Utilities__2.Signal();
	return v1;
end;
