local x = script.Parent.X
local y = script.Parent.Y
local z = script.Parent.Z
local maxtilt = script.Parent.MaxTilt
local bodypos = script.Parent.BodyPosition
local gyro = script.Parent.BodyGyro
bodypos.Position = script.Parent.Position
gyro.CFrame = script.Parent.CFrame
while true do
	if script.Parent.Orientation.X > maxtilt.Value then
		x.Value = 0
	end
	if script.Parent.Orientation.Z > maxtilt.Value then
		z.Value = 0
	end
	gyro.CFrame = gyro.CFrame * CFrame.Angles(x.Value*(math.pi/180),0,0)
	gyro.CFrame = gyro.CFrame * CFrame.Angles(0,0,z.Value*(math.pi/180))
	bodypos.Position = bodypos.Position - Vector3.new(0,y.Value/10,0)
	x.Value = x.Value + x.Accel.Value/10
	y.Value = y.Value + y.Accel.Value/10
	z.Value = z.Value + z.Accel.Value/10
	wait(0.1)
end