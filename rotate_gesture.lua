-- Kazari, a touch gesture library.
--
-- Copyright (C) 2022 Miku AuahDark
--
-- This software is provided 'as-is', without any express or implied
-- warranty.  In no event will the authors be held liable for any damages
-- arising from the use of this software.
--
-- Permission is granted to anyone to use this software for any purpose,
-- including commercial applications, and to alter it and redistribute it
-- freely, subject to the following restrictions:
--
-- 1. The origin of this software must not be misrepresented; you must not
--    claim that you wrote the original software. If you use this software
--    in a product, an acknowledgment in the product documentation would be
--    appreciated but is not required.
-- 2. Altered source versions must be plainly marked as such, and must not be
--    misrepresented as being the original software.
-- 3. This notice may not be removed or altered from any source distribution.

---@type string
local path = (...):sub(1, -string.len(".rotate_gesture") - 1)

---@type Kazari.BaseGesture
local BaseGesture = require(path..".base_gesture")
---@type Kazari.Util
local util = require(path..".util")

---Implements rotate gesture
---@class Kazari.RotateGesture
local RotateGesture = {}
RotateGesture.__index = RotateGesture ---@private
RotateGesture.__parent = BaseGesture ---@private

---@package
---@param constraint Kazari.AnyConstraint?
function RotateGesture:init(constraint)
	self.constraint = constraint ---@private
end

---@generic T
---@param context T
---@param func fun(context:T,angle:number,da:number)
function RotateGesture:onRotate(context, func)
	self.onRotateContext = context ---@private
	self.onRotateCallback = func ---@private
end

---@generic U
---@param context U
---@param func fun(context:U,angle:number)
function RotateGesture:onRotateComplete(context, func)
	self.onRotateDoneContext = context ---@private
	self.onRotateDoneCallback = func ---@private
end

---@param x number
---@param y number
---@param pressure number
function RotateGesture:touchpressed(id, x, y, pressure)
	if not util.pointInConstraint(x, y, self.constraint) then
		return false
	end

	if not self.t1 then
		self.t1 = {id, x, y} ---@private
	elseif not self.t2 then
		self.t2 = {id, x, y} ---@private

		-- Start gesture
		self:_updateGesture(0)
	else
		return false
	end

	return true
end

---@param x number
---@param y number
---@param dx number
---@param dy number
---@param pressure number
function RotateGesture:touchmoved(id, x, y, dx, dy, pressure)
	-- Update gesture
	if self.t1 and id == self.t1[1] then
		self.t1[2], self.t1[3] = x, y

		if self.t2 then
			self:_updateGesture(1)
		end
	elseif self.t2 and id == self.t2[1] then
		self.t2[2], self.t2[3] = x, y
		self:_updateGesture(1)
	else
		return false
	end

	return true
end

---@param x number
---@param y number
function RotateGesture:touchreleased(id, x, y)
	if self.t1 and id == self.t1[1] then
		self.t1[2], self.t1[3] = x, y

		if self.t2 then
			self:_updateGesture(2)
		end

		self.t1 = self.t2 ---@private
		self.t2 = nil ---@private
	elseif self.t2 and id == self.t2[1] then
		self.t2[2], self.t2[3] = x, y
		self:_updateGesture(2)
		self.t2 = nil ---@private
	else
		return false
	end

	return true
end

---@private
---@param mode 0|1|2
function RotateGesture:_updateGesture(mode)
	local a = math.atan2(self.t2[3] - self.t1[3], self.t2[2] - self.t1[2])

	if mode == 0 then
		self.initAngle = a ---@private
		self.angle = 0 ---@private
	end

	local da = a - self.initAngle
	if da > math.pi then
		da = 2 * math.pi - da
	elseif da < -math.pi then
		da = 2 * math.pi + da
	end

	self.initAngle = a ---@private
	self.angle = self.angle + da ---@private

	if self.onRotateCallback then
		self.onRotateCallback(self.onRotateContext, self.angle, da)
	end

	if mode == 2 then
		if self.onRotateDoneCallback then
			self.onRotateDoneCallback(self.onRotateDoneContext, self.angle)
		end

		self.initAngle = nil ---@private
		self.angle = nil ---@private
	end
end

function RotateGesture:__tostring()
	return string.format("RotateGesture<%p>(%p)", self, self.constraint)
end

setmetatable(RotateGesture, {
	__call = function(_, constraint)
		local object = setmetatable({}, RotateGesture)
		object:init(constraint)
		return object
	end
})

return RotateGesture
