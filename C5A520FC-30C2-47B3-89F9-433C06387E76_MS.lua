return function(_p)--local _p = require(script.Parent)
local Utilities = _p.Utilities
local mouse = _p.player:GetMouse()

local currentlyDragging

game:GetService('UserInputService').InputEnded:connect(function(inputObject)
	if currentlyDragging and inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		currentlyDragging:endDrag()
	end
end)

local dragger = Utilities.class({
	clickEnabled = false,
	dragging = false,
	
}, function(self)
	if type(self) == 'userdata' then
		self = {gui = self}
	end
	local guiObject = self.gui
	-- if not guiObject then ?
	
	self.onDragBegin = Utilities.Signal()
	self.onDragMove = Utilities.Signal()
	self.onDragEnd = Utilities.Signal()
	self.onClick = Utilities.Signal()
	
	if guiObject:IsA('GuiButton') then
		guiObject.MouseButton1Down:connect(function() self:beginDrag() end)
	end
	
	return self
end)

function dragger:beginDrag()
	if currentlyDragging then currentlyDragging:endDrag() end
	currentlyDragging = self
	self.dragging = true
--	if Utilities.isTouchDevice() then
--		local vpo = workspace.CurrentCamera.ViewportSize-Utilities.gui.AbsoluteSize
--		oPos = Vector2.new(x, y-vpo.Y)
--	else
--		oPos = Vector2.new(mouse.X, mouse.Y)
--	end
	local mouseStartX, mouseStartY = mouse.X, mouse.Y
	self.dragStartPosition = Vector2.new(mouseStartX, mouseStartY)
	
	local clickEnabled = self.clickEnabled or false
	if clickEnabled then
		self.brokenThreshold = false
	else
		self.brokenThreshold = true
		self.onDragBegin:fire(Vector2.new())
	end
	local threshold = Utilities.gui.AbsoluteSize.Y * (self.clickThreshold or .03)
	local brokenThreshold = false
	self.moveCn = mouse.Move:connect(function()
		local offset = Vector2.new(mouse.X - mouseStartX, mouse.Y - mouseStartY)
		if clickEnabled and not brokenThreshold then
			if offset.magnitude < threshold then return end
			brokenThreshold = true
			self.brokenThreshold = true
			self.onDragBegin:fire(offset)
			return
		end
		self.onDragMove:fire(offset)
	end)
end

function dragger:endDrag()
	if currentlyDragging == self then currentlyDragging = nil end
	if not self.dragging then return end
	if self.clickEnabled and not self.brokenThreshold then
		self.onClick:fire()
	end
	pcall(function() self.moveCn:disconnect() end)
	self.moveCn = nil
	self.dragging = false
	self.onDragEnd:fire()
end


return dragger end