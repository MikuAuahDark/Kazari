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
local path = (...):sub(1, -string.len(".pan_gesture") - 1)

---@type Kazari.BaseGesture
local BaseGesture = require(path..".base_gesture")
---@type Kazari.Util
local util = require(path..".util")

---Implements multi-finger pan gesture.
---@class Kazari.PanGesture: Kazari.BaseGesture
local PanGesture = {}
PanGesture.__index = PanGesture ---@private
PanGesture.__parent = BaseGesture ---@private

---@param nfingers integer
---@param clip boolean?
---@param constraint Kazari.AnyConstraint?
function PanGesture:init(nfingers, clip, constraint)
	assert(nfingers > 0, "number of touches must be greater than 0")

	---@type {[1]:any,[2]:number,[3]:number,[4]:number}[]
	self.touches = {} ---@private
	self.minCount = nfingers ---@private
	self.clipTouch = not not clip ---@private
	self.constraint = constraint ---@private
end

---@generic T
---@param context T
---@param func fun(context:T,x:number,y:number,dx:number,dy:number,pressure:number)
function PanGesture:onMove(context, func)
	self.onMoveCallback = func ---@private
	self.onMoveContext = context ---@private
end

---@param x number
---@param y number
---@param pressure number
function PanGesture:touchpressed(id, x, y, pressure)
	if #self.touches >= self.minCount or not util.pointInConstraint(x, y, self.constraint) then
		return false
	end

	self.touches[#self.touches + 1] = {id, x, y, pressure}
	self:_update(false)
	return true
end

---@param x number
---@param y number
---@param dx number
---@param dy number
---@param pressure number
function PanGesture:touchmoved(id, x, y, dx, dy, pressure)
	-- Update gesture
	for _, v in ipairs(self.touches) do
		if v[1] == id then
			if self.clipTouch then
				x, y = util.ensurePointInside(x, y, self.constraint)
			end

			v[2], v[3], v[4] = x, y, pressure
			self:_update(false)
			return true
		end
	end

	return false
end

---@param x number
---@param y number
function PanGesture:touchreleased(id, x, y)
	for i, v in ipairs(self.touches) do
		if v[1] == id then
			if self.clipTouch then
				x, y = util.ensurePointInside(x, y, self.constraint)
			end

			v[2], v[3] = x, y
			self:_update(true)
			table.remove(self.touches, i)
			return true
		end
	end

	return false
end

---@private
---@param finalize boolean
function PanGesture:_update(finalize)
	if #self.touches < self.minCount then
		return
	end

	-- Average
	local avgX, avgY, avgP = 0, 0, 0
	for _, v in ipairs(self.touches) do
		avgX = avgX + v[2]
		avgY = avgY + v[3]
		avgP = avgP + v[4]
	end

	avgX = avgX / #self.touches
	avgY = avgY / #self.touches
	avgP = avgP / #self.touches

	local dx, dy = 0, 0

	if self.lastX then
		dx, dy = avgX - self.lastX, avgY - self.lastY
	else
		self.lastX = avgX ---@private
		self.lastY = avgY ---@private
	end

	if self.onMoveCallback then
		self.onMoveCallback(self.onMoveContext, avgX, avgY, dx, dy, avgP)
	end

	if finalize then
		self.lastX = nil ---@private
		self.lastY = nil ---@private
	end
end

function PanGesture:__tostring()
	return string.format("PanGesture<%p>(%d, %s, %p)", self, self.minCount, self.clipTouch, self.constraint)
end

setmetatable(PanGesture, {
	__call = function(_, nfingers, clip, constraint)
		local object = setmetatable({}, PanGesture)
		object:init(nfingers, clip, constraint)
		return object
	end
})

return PanGesture
