local humanoid = script.Parent:WaitForChild("Humanoid")

if (humanoid.RigType == Enum.HumanoidRigType.R6) then
	print("Fired - R6")
	require(script:WaitForChild("R6"))(script)
else
	print("Fired - R15")
	require(script:WaitForChild("R15"))(script)
end