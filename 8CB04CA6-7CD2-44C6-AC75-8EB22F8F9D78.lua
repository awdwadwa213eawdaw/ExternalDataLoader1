-- Buildthomas (2016)
-- Voltorb Flip minigame example

VoltorbFlip	= require(script.VoltorbFlip)
UI = script.Parent
Player = game.Players.LocalPlayer -- For name of winner
Stepped = game["Run Service"].RenderStepped -- For animation of tiles

-- The data for the current level:
local currentGame = nil
-- Whether we can interact with the board at the moment:
local flipEnabled = false

-- Total accumulated score:
local totalScore = 0

-- Used for message blocking:
local messageInput = false

-- Images with spritesheet support:

Backfaces = {
	[false]	= {"rbxassetid://66231444", Vector2.new(0,0), Vector2.new(0,0)},	-- Default
	[true]	= {"rbxassetid://66593681", Vector2.new(0,0), Vector2.new(0,0)},	-- Marked (right-click to toggle)
}

Frontfaces = {
	[0] = {"rbxassetid://66232266", Vector2.new(0,0), Vector2.new(0,0)},		-- Voltorb
	[1] = {"rbxassetid://66231462", Vector2.new(0,0), Vector2.new(0,0)},		-- 1 Point
	[2] = {"rbxassetid://66231472", Vector2.new(0,0), Vector2.new(0,0)},		-- 2 Point
	[3] = {"rbxassetid://66231483", Vector2.new(0,0), Vector2.new(0,0)},		-- 3 Point
}

function setImage(object, data)
	object.Image = data[1]
	object.ImageRectOffset = data[2]
	object.ImageRectSize = data[3]
end

-- Wait a number of frames:

function waitFrames(frames)
	for i=1,frames do
		Stepped:wait()
	end
end

-- Show a blocking message of two lines to user:
-- (time <= 0: user has to click, otherwise it waits this time)

function doMessage(time, line1, line2)
	
	-- Setup:
	UI.TextBox.Dot.Visible = false
	UI.TextBox.Line1.Text = line1 or ""
	UI.TextBox.Line2.Text = line2 or ""
	
	-- Show:
	UI.TextBox.Visible = true
	
	-- User hasn't clicked:
	messageInput = false
	
	if time <= 0 then
		-- Wait until user has clicked, blink continue label until they do:
		while not messageInput do
			UI.TextBox.Dot.Visible = not UI.TextBox.Dot.Visible
			waitFrames(25) -- 25 frames ~ 0.45-0.5 seconds
		end
	else
		-- Just wait that time:
		wait(time)
	end
	
	-- Disable text box:
	UI.TextBox.Visible = false
	
end

-- Set the row/column indicators to zeros:

function resetCounters()
	for row = 1, 5 do
		local counter = UI.Game.RowIndicators[tostring(row)]
		counter.Points.Text.Text = "00"
		counter.Voltorb.Text.Text = "0"
	end
	for col = 1, 5 do
		local counter = UI.Game.ColumnIndicators[tostring(col)]
		counter.Points.Text.Text = "00"
		counter.Voltorb.Text.Text = "0"
	end
end

-- Set the row/column indicators based on current level data:

function setCounters()
	for row = 1, 5 do
		local counter = UI.Game.RowIndicators[tostring(row)]
		counter.Points.Text.Text = ("%.2d"):format(currentGame.Rows[row].Points)
		counter.Voltorb.Text.Text = currentGame.Rows[row].Voltorbs
	end
	for col = 1, 5 do
		local counter = UI.Game.ColumnIndicators[tostring(col)]
		counter.Points.Text.Text = ("%.2d"):format(currentGame.Columns[col].Points)
		counter.Voltorb.Text.Text = currentGame.Columns[col].Voltorbs
	end
end

-- Reset the current score text label:

function resetCurrentScore()
	UI.Score.Score.Text = "00000"
end

-- Update the score text labels:

function setScores()
	UI.Score.Score.Text = ("%.5d"):format(currentGame.Score)
	UI.TotalScore.Score.Text = ("%.5d"):format(totalScore)
end

-- Reset all game data:

function resetGame()
	
	-- Disable interaction:
	flipEnabled = false
	
	-- Kill game and reset visuals:
	
	currentGame = nil
	
	resetCounters()
	resetCurrentScore()
	
end

-- Setup new game (should be called eventually in script to start loop):

function startNewGame()
	
	-- Make a new level: (8 voltorbs, minimum score of 150)
	currentGame = VoltorbFlip.new(8, 150)
	
	-- Set visuals:
	
	setCounters()
	setScores()
	
	for _,v in pairs(UI.Game.Containers:GetChildren()) do
		setImage(v, Backfaces[false])
	end
	
	-- Allow interaction:
	flipEnabled = true
	
end

-- Flips all tiles:
--   reset == false: show their front faces after animating (revealing board)
--   reset == true:  show default back faces after animating (resetting visual to default)

function flipAll(reset)

	-- Get a list of all frames that should be flipped:
	-- (all frames when reset == true, otherwise all
	-- frames that weren't flipped yet)
	local framesToFlip = {}
	for row = 1, 5 do
		for col = 1, 5 do
			if reset or not currentGame.Flipped[row][col] then
				local tile = UI.Game.Containers[tostring(col) .. tostring(row)]
				table.insert(framesToFlip, {tile, row, col})
			end
		end
	end
	
	-- Animate half-turn on all tiles to be flipped:
	for i = 1, 6 do
		for _,v in pairs(framesToFlip) do
			v[1].Position = v[1].Position + UDim2.new(0,3,0,0)
			v[1].Size = v[1].Size - UDim2.new(0,6,0,0)
		end
		waitFrames(1)
	end
	
	if reset then
		-- Set back face:
		for _,v in pairs(framesToFlip) do
			setImage(v[1], Backfaces[false])
		end
	else
		-- Set front face determined by value at each position:
		for _,v in pairs(framesToFlip) do
			setImage(v[1], Frontfaces[currentGame.Board[v[2]][v[3]]])
		end
	end
	
	-- Animate half-turn of all tiles to be flipped:
	for i = 1, 6 do
		for _,v in pairs(framesToFlip) do
			v[1].Position = v[1].Position - UDim2.new(0,3,0,0)
			v[1].Size = v[1].Size + UDim2.new(0,6,0,0)
		end
		waitFrames(1)
	end
	
end

-- Shows the board of current level, resets the game, and starts new game:

function endGame()
	
	-- Show all tiles front faces:
	flipAll(false)
	
	wait(3)
	
	-- Reset tiles to their default back face:
	flipAll(true)
	
	-- Kill game:
	resetGame()
	
	wait(1)
	
	-- New game:
	startNewGame()
	
end

-- Responsible for flipping a particular tile:
--   tile: the ImageButton object which was clicked
--   row:  corresponding row value
--   col:  corresponding column value

function flipTile(tile, row, col)
	
	-- Only proceed if legal:
	if flipEnabled and not currentGame.Flipped[row][col] and tile.Image == Backfaces[false] then
	
		-- Disable interaction with board:
		flipEnabled = false
		
		-- Perform the flip:
		local indicator, value = currentGame:flip(row, col)
		
		-- Animate half-turn:
		for i = 1, 6 do
			tile.Position = tile.Position + UDim2.new(0,3,0,0)
			tile.Size = tile.Size - UDim2.new(0,6,0,0)
			waitFrames(1) -- wait a frame ~ 1/60s
		end
		
		-- Set image according to results:
		if indicator == VoltorbFlip.LOSE then
			setImage(tile, Frontfaces[0])
		elseif indicator == VoltorbFlip.POINTS then
			setImage(tile, Frontfaces[value])
		end
		
		-- Animate half-turn:
		for i = 1, 6 do
			tile.Position = tile.Position - UDim2.new(0,3,0,0)
			tile.Size = tile.Size + UDim2.new(0,6,0,0)
			waitFrames(1) -- wait a frame ~ 1/60s
		end
		
		-- Update score values:
		setScores()
		
		if indicator == VoltorbFlip.LOSE then
			
			-- TODO: blowup animation
			
			doMessage(0, "Oh no! You get 0 Coins!")
			
			endGame()
			
		elseif indicator == VoltorbFlip.POINTS then
		
			-- TODO: point get animation
			
			-- Show message depending on situation:
			if currentGame.TilesFlipped == 1 then
				-- First tile flipped, so score was 0 beforehand:
				doMessage(1, ("%d! Received %d Coin(s)!"):format(value, currentGame.Score))
			elseif value > 1 then
				-- Not first tile, so score wasn't 0, so it was a multiplier:
				doMessage(1, ("x%d! Received %d Coin(s)!"):format(value, currentGame.Score))
			end
			
			-- Check if there are more 2/3 tiles to find:
			if currentGame.Complete then
			
				UI.Shader.Visible = true
				
				-- Win messages:
				doMessage(0,"Game clear!")
				doMessage(0,"You've found all of the hidden","x2 and x3 cards!")
				doMessage(0,"This means you've found all the Coins","in this game, so this game is now over.")
				
				local name = Player.Name:sub(1,1):upper() .. Player.Name:sub(2)
				doMessage(0, ("%s received %d Coin(s)!"):format(name, currentGame.Score))
				
				-- Update total score and visuals:
				totalScore = math.min(totalScore + currentGame.Score, 99999)
				setScores()
				resetCurrentScore() -- puts current score label to 0
				
				UI.Shader.Visible = false
				
				wait(.5)
				
				-- Show board and restart:
				endGame()
				
			else
				
				-- Flip was successful and didn't end game, continue:
				flipEnabled = true
				
			end
			
		end
		
	end
	
end

-- Loop over all container buttons: (25 in total)
for _,v in pairs(UI.Game.Containers:GetChildren()) do

	-- Find row/col based on its name:
	local row = tonumber(v.Name:sub(2,2))
	local col = tonumber(v.Name:sub(1,1))
	
	-- When left clicked, attempt to flip:
	v.MouseButton1Down:connect(
		function()
			flipTile(v, row, col)
		end
	)
	
	-- When right clicked, mark/unmark the container:
	-- (container can't be flipped when marked)
	v.MouseButton2Down:connect(
		function()
			if flipEnabled and not currentGame.Flipped[row][col] then
				setImage(v, Backfaces[v.Image == Backfaces[false]])
			end
		end
	)
	
end

-- When textbox is clicked, set variable that indicates that user wants to proceed:
UI.TextBox.Button.MouseButton1Down:connect(
	function()
		messageInput = true
	end
)

-- Finally, start game loop:
startNewGame()