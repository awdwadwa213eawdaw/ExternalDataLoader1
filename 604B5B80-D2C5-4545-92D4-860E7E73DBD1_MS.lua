return function(_p)

	local CameraShaker = {}
	CameraShaker.__index = CameraShaker
	local profileBegin = debug.profilebegin
	local profileEnd = debug.profileend
	local profileTag = "CameraShakerUpdate"

	local V3 = Vector3.new
	local CF = CFrame.new
	local ANG = CFrame.Angles
	local RAD = math.rad
	local v3Zero = V3()

	local CameraShakeInstance, CameraShakeState
	local defaultPosInfluence = V3(0.15, 0.15, 0.15)
	local defaultRotInfluence = V3(1, 1, 1)

	function CameraShaker.new(renderPriority, callback)
		assert(type(renderPriority) == "number", "RenderPriority must be a number (e.g.: Enum.RenderPriority.Camera.Value)")
		assert(type(callback) == "function", "Callback must be a function")
		local self = setmetatable({
			_running = false,
			_renderName = "CameraShaker",
			_renderPriority = renderPriority,
			_posAddShake = v3Zero,
			_rotAddShake = v3Zero,
			_camShakeInstances = {},
			_removeInstances = {},
			_callback = callback
		}, CameraShaker)
		return self
	end

	function CameraShaker:Start()
		if self._running then
			return
		end
		self._running = true
		local callback = self._callback
		game:GetService("RunService"):BindToRenderStep(self._renderName, self._renderPriority, function(dt)
			profileBegin(profileTag)
			local cf = self:Update(dt)
			profileEnd()
			callback(cf)
		end)
	end

	function CameraShaker:Stop()
		if not self._running then
			return
		end
		game:GetService("RunService"):UnbindFromRenderStep(self._renderName)
		self._running = false
	end

	function CameraShaker:Update(dt)
		local posAddShake = v3Zero
		local rotAddShake = v3Zero
		local instances = self._camShakeInstances
		for i = 1, #instances do
			local c = instances[i]
			local state = c:GetState()
			if state == CameraShakeState.Inactive and c.DeleteOnInactive then
				self._removeInstances[#self._removeInstances + 1] = i
			elseif state ~= CameraShakeState.Inactive then
				posAddShake = posAddShake + c:UpdateShake(dt) * c.PositionInfluence
				rotAddShake = rotAddShake + c:UpdateShake(dt) * c.RotationInfluence
			end
		end
		for i = #self._removeInstances, 1, -1 do
			local instIndex = self._removeInstances[i]
			table.remove(instances, instIndex)
			self._removeInstances[i] = nil
		end
		return CF(posAddShake) * ANG(0, RAD(rotAddShake.Y), 0) * ANG(RAD(rotAddShake.X), 0, RAD(rotAddShake.Z))
	end

	function CameraShaker:Shake(shakeInstance)
		assert(type(shakeInstance) == "table" and shakeInstance._camShakeInstance, "ShakeInstance must be of type CameraShakeInstance")
		self._camShakeInstances[#self._camShakeInstances + 1] = shakeInstance
		return shakeInstance
	end

	function CameraShaker:ShakeSustain(shakeInstance)
		assert(type(shakeInstance) == "table" and shakeInstance._camShakeInstance, "ShakeInstance must be of type CameraShakeInstance")
		self._camShakeInstances[#self._camShakeInstances + 1] = shakeInstance
		shakeInstance:StartFadeIn(shakeInstance.fadeInDuration)
		return shakeInstance
	end

	function CameraShaker:ShakeOnce(magnitude, roughness, fadeInTime, fadeOutTime, posInfluence, rotInfluence)
		local shakeInstance = CameraShakeInstance.new(magnitude, roughness, fadeInTime, fadeOutTime)
		shakeInstance.PositionInfluence = typeof(posInfluence) == "Vector3" and posInfluence or defaultPosInfluence
		shakeInstance.RotationInfluence = typeof(rotInfluence) == "Vector3" and rotInfluence or defaultRotInfluence
		self._camShakeInstances[#self._camShakeInstances + 1] = shakeInstance
		return shakeInstance
	end

	function CameraShaker:StartShake(magnitude, roughness, fadeInTime, posInfluence, rotInfluence)
		local shakeInstance = CameraShakeInstance.new(magnitude, roughness, fadeInTime)
		shakeInstance.PositionInfluence = typeof(posInfluence) == "Vector3" and posInfluence or defaultPosInfluence
		shakeInstance.RotationInfluence = typeof(rotInfluence) == "Vector3" and rotInfluence or defaultRotInfluence
		shakeInstance:StartFadeIn(fadeInTime)
		self._camShakeInstances[#self._camShakeInstances + 1] = shakeInstance
		return shakeInstance
	end

	CameraShakeInstance = {}
	CameraShakeInstance.__index = CameraShakeInstance

	local V3 = Vector3.new
	local NOISE = math.noise
	CameraShakeState = {
		FadingIn = 0,
		FadingOut = 1,
		Sustained = 2,
		Inactive = 3
	}
	CameraShakeInstance.CameraShakeState = CameraShakeState

	function CameraShakeInstance.new(magnitude, roughness, fadeInTime, fadeOutTime)
		if fadeInTime == nil then
			fadeInTime = 0
		end
		if fadeOutTime == nil then
			fadeOutTime = 0
		end
		assert(type(magnitude) == "number", "Magnitude must be a number")
		assert(type(roughness) == "number", "Roughness must be a number")
		assert(type(fadeInTime) == "number", "FadeInTime must be a number")
		assert(type(fadeOutTime) == "number", "FadeOutTime must be a number")
		local self = setmetatable({
			Magnitude = magnitude,
			Roughness = roughness,
			PositionInfluence = V3(),
			RotationInfluence = V3(),
			DeleteOnInactive = true,
			roughMod = 1,
			magnMod = 1,
			fadeOutDuration = fadeOutTime,
			originalFadeOutTime = fadeOutTime,
			fadeInDuration = fadeInTime,
			sustain = fadeInTime > 0,
			currentFadeTime = fadeInTime > 0 and 0 or 1,
			tick = Random.new():NextNumber(-100, 100),
			_camShakeInstance = true
		}, CameraShakeInstance)
		return self
	end

	function CameraShakeInstance:UpdateShake(dt)
		local _tick = self.tick
		local currentFadeTime = self.currentFadeTime
		local offset = V3(NOISE(_tick, 0) * 0.5, NOISE(0, _tick) * 0.5, NOISE(_tick, _tick) * 0.5)
		if 0 < self.fadeInDuration and self.sustain then
			if currentFadeTime < 1 then
				currentFadeTime = currentFadeTime + dt / self.fadeInDuration
			elseif 0 < self.fadeOutDuration then
				self.sustain = false
			end
		end
		if not self.sustain then
			currentFadeTime = currentFadeTime - dt / self.fadeOutDuration
		end
		if self.sustain then
			self.tick = _tick + dt * self.Roughness * self.roughMod
		else
			self.tick = _tick + dt * self.Roughness * self.roughMod * currentFadeTime
		end
		self.currentFadeTime = currentFadeTime
		return offset * self.Magnitude * self.magnMod * currentFadeTime
	end

	function CameraShakeInstance:StartFadeOut(fadeOutTime)
		if fadeOutTime == 0 then
			self.currentFadeTime = 0
		end
		self.fadeOutDuration = fadeOutTime
		self.fadeInDuration = 0
		self.sustain = false
	end

	function CameraShakeInstance:StartFadeIn(fadeInTime)
		if fadeInTime == 0 then
			self.currentFadeTime = 1
		end
		self.fadeInDuration = fadeInTime or self.fadeInDuration
		self.fadeOutDuration = 0
		self.sustain = true
	end

	function CameraShakeInstance:GetScaleRoughness()
		return self.roughMod
	end

	function CameraShakeInstance:SetScaleRoughness(v)
		self.roughMod = v
	end

	function CameraShakeInstance:GetScaleMagnitude()
		return self.magnMod
	end

	function CameraShakeInstance:SetScaleMagnitude(v)
		self.magnMod = v
	end

	function CameraShakeInstance:GetNormalizedFadeTime()
		return self.currentFadeTime
	end

	function CameraShakeInstance:IsShaking()
		return self.currentFadeTime > 0 or self.sustain
	end

	function CameraShakeInstance:IsFadingOut()
		return not self.sustain and self.currentFadeTime > 0
	end

	function CameraShakeInstance:IsFadingIn()
		return self.currentFadeTime < 1 and self.sustain and self.fadeInDuration > 0
	end

	function CameraShakeInstance:GetState()
		if self:IsFadingIn() then
			return CameraShakeInstance.CameraShakeState.FadingIn
		elseif self:IsFadingOut() then
			return CameraShakeInstance.CameraShakeState.FadingOut
		elseif self:IsShaking() then
			return CameraShakeInstance.CameraShakeState.Sustained
		else
			return CameraShakeInstance.CameraShakeState.Inactive
		end
	end
	CameraShaker.CameraShakeInstance = CameraShakeInstance

	local CameraShakePresets = {
		Bump = function()
			local c = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
			c.PositionInfluence = Vector3.new(0.15, 0.15, 0.15)
			c.RotationInfluence = Vector3.new(1, 1, 1)
			return c
		end,
		Explosion = function()
			local c = CameraShakeInstance.new(5, 10, 0, 1.5)
			c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
			c.RotationInfluence = Vector3.new(4, 1, 1)
			return c
		end,
		Earthquake = function()
			local c = CameraShakeInstance.new(0.6, 3.5, 2, 10)
			c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
			c.RotationInfluence = Vector3.new(1, 1, 4)
			return c
		end,
		Earthquake2 = function()
			local c = CameraShakeInstance.new(0.6, 3.5, 2, 10)
			c.PositionInfluence = Vector3.new(0.35, 0.5, 0.35)
			c.RotationInfluence = Vector3.new(1.5, 1, 4)
			return c
		end,
		BadTrip = function()
			local c = CameraShakeInstance.new(10, 0.15, 5, 10)
			c.PositionInfluence = Vector3.new(0, 0, 0.15)
			c.RotationInfluence = Vector3.new(2, 1, 4)
			return c
		end,
		HandheldCamera = function()
			local c = CameraShakeInstance.new(1, 0.25, 5, 10)
			c.PositionInfluence = Vector3.new(0, 0, 0)
			c.RotationInfluence = Vector3.new(1, 0.5, 0.5)
			return c
		end,
		Vibration = function()
			local c = CameraShakeInstance.new(0.4, 20, 2, 2)
			c.PositionInfluence = Vector3.new(0, 0.15, 0)
			c.RotationInfluence = Vector3.new(1.25, 0, 4)
			return c
		end,
		RoughDriving = function()
			local c = CameraShakeInstance.new(1, 2, 1, 1)
			c.PositionInfluence = Vector3.new(0, 0, 0)
			c.RotationInfluence = Vector3.new(1, 1, 1)
			return c
		end
	}
	CameraShaker.Presets = setmetatable({}, {
		__index = function(t, i)
			local f = CameraShakePresets[i]
			if type(f) == "function" then
				return f()
			end
			error("No preset found with index \"" .. i .. "\"")
		end
	})

	function CameraShaker:BeginEarthquake(callback, fadeInTime)
		local earthquakeInstance = self.Presets.Earthquake2
		if fadeInTime then
			earthquakeInstance.fadeInDuration = fadeInTime
		end
		local cameraShaker = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, callback)
		cameraShaker:Start()
		cameraShaker:ShakeSustain(earthquakeInstance)
		self.currentEarthquake = {cameraShaker, earthquakeInstance}
	end

	function CameraShaker:EndEarthquake(fadeOutTime)
		local currentEarthquake = self.currentEarthquake
		if not currentEarthquake then
			return
		end
		self.currentEarthquake = nil
		local cameraShaker, earthquakeInstance = unpack(currentEarthquake)
		fadeOutTime = fadeOutTime or earthquakeInstance.originalFadeOutTime
		earthquakeInstance:StartFadeOut(fadeOutTime)
		delay(fadeOutTime + 0.5, function()
			cameraShaker:Stop()
		end)
	end

	return CameraShaker

end