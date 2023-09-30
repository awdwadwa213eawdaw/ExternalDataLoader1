-------------------------------------------------------------------------
-- @CloneTrooper1019, 2015
-- Animated Lava Script
-------------------------------------------------------------------------
-- Setup

local self = script.Parent
local rs = game:GetService("RunService")
local texRegistry = {}
local texPattern = "rbxasset://textures/water/normal_%02d.dds"
local floor = math.floor

-------------------------------------------------------------------------
-- Kill Humanoids that come in contact with this part.

function onTouched(hit)
	if hit.Parent then
		local h = hit.Parent:FindFirstChild("Humanoid")
		if h then
			h:TakeDamage(100)
		end
	end
end

self.Touched:connect(onTouched)

-------------------------------------------------------------------------
-- Register Textures.

local function registerTexture(obj)
	if obj:IsA("Texture") then
		table.insert(texRegistry,obj)
	end
end

for _,v in pairs(self:GetChildren()) do
	registerTexture(v)
end

self.ChildAdded:connect(registerTexture)

-------------------------------------------------------------------------
-- Lava Animation

local function update()
	local now = tick()
	local frame = 1 + (floor(now*25)%25)
	local nextImg = texPattern:format(frame)
	for _,v in pairs(texRegistry) do
		v.Texture = nextImg
	end
end

rs.Stepped:connect(update)
-------------------------------------------------------------------------