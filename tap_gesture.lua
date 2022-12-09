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
local path = (...):sub(1, -string.len(".tap_gesture") - 1)

---@type Kazari.BaseGesture
local BaseGesture = require(path..".base_gesture")
---@type Kazari.Util
local util = require(path..".util")

---Implements multi-finger pan gesture.
---@class Kazari.TapGesture: Kazari.BaseGesture
local TapGesture = {}
TapGesture.__index = TapGesture ---@private
TapGesture.__parent = BaseGesture ---@private

---@param nfingers integer
---@param moveThreshold number?
---@param altDuration number?
---@param constraint Kazari.AnyConstraint?
function TapGesture:init(nfingers, moveThreshold, altDuration, constraint)
	assert(nfingers > 0, "number of touches must be greater than 0")

	---@type {[1]:any,[2]:number,[3]:number}[]
	self.touches = {} ---@private
	self.minCount = nfingers ---@private
	self.moveThreshold = moveThreshold or 32
	self.alternativeDuration = altDuration or 0 ---@private
	self.checkAlt = self.alternativeDuration > 0 ---@private
	self.constraint = constraint ---@private
	self.cancelled = false
	self.duration = 0
end

---@generic T
---@param context T
---@param func fun(context:T)
function TapGesture:onStart(context, func)
	self.onStartCallback = func ---@private
	self.onStartContext = context ---@private
end

---@generic U
---@param context U
---@param func fun(context:U,duration:number)
function TapGesture:onCancel(context, func)
	self.onCancelCallback = func ---@private
	self.onCancelContext = context ---@private
end

---@generic V
---@param context V
---@param func fun(context:V,alternate:boolean,duration:number)
function TapGesture:onTap(context, func)
	self.onTapCallback = func ---@private
	self.onTapContext = context ---@private
end

---@param dt number
function TapGesture:update(dt)
	if #self.touches >= self.minCount and (not self.cancelled) then
		self.duration = self.duration + dt
	end
end

---@param x number
---@param y number
---@param pressure number
function TapGesture:touchpressed(id, x, y, pressure)
	if #self.touches >= self.minCount or not util.pointInConstraint(x, y, self.constraint) then
		return false
	end

	self.touches[#self.touches + 1] = {id, x, y}
	self:_update(0)
	return true
end

---@param x number
---@param y number
---@param dx number
---@param dy number
---@param pressure number
function TapGesture:touchmoved(id, x, y, dx, dy, pressure)
	-- Update gesture
	for _, v in ipairs(self.touches) do
		if v[1] == id then
			v[2], v[3] = x, y
			self:_update(1)
			return true
		end
	end

	return false
end

---@param x number
---@param y number
function TapGesture:touchreleased(id, x, y)
	for i, v in ipairs(self.touches) do
		if v[1] == id then
			v[2], v[3] = x, y
			self:_update(2)
			table.remove(self.touches, i)
			return true
		end
	end

	return false
end

---@private
---@param mode 0|1|2
function TapGesture:_update(mode)
	if #self.touches < self.minCount then
		return
	end

	if mode == 0 then
		self.cancelled = false
		self.duration = 0
	elseif self.cancelled then
		return
	end

	-- Average
	local avgX, avgY = 0, 0
	for _, v in ipairs(self.touches) do
		avgX = avgX + v[2]
		avgY = avgY + v[3]
	end

	avgX = avgX / #self.touches
	avgY = avgY / #self.touches

	if mode == 0 then
		self.lastX = avgX ---@private
		self.lastY = avgY ---@private

		if self.onStartCallback then
			self.onStartCallback(self.onStartContext)
		end
	end

	if util.distance(avgX, avgY, self.lastX, self.lastY) >= self.moveThreshold then
		-- Cancel
		self.cancelled = true

		if self.onCancelCallback then
			self.onCancelCallback(self.onCancelContext, self.duration)
		end
	elseif mode == 2 then
		self.lastX = nil ---@private
		self.lastY = nil ---@private

		if self.onTapCallback then
			local isAlt = false
			if self.checkAlt then
				isAlt = self.duration >= self.alternativeDuration
			end

			self.onTapCallback(self.onTapContext, isAlt, self.duration)
		end
	end
end

function TapGesture:__tostring()
	return string.format("TapGesture<%p>(%d, %d, %p)", self, self.minCount, self.moveThreshold, self.constraint)
end

setmetatable(TapGesture, {
	__call = function(_, nfingers, moveThreshold, altDuration, clip, constraint)
		local object = setmetatable({}, TapGesture)
		object:init(nfingers, moveThreshold, altDuration, clip, constraint)
		return object
	end
})

return TapGesture
