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
local path = (...):sub(1, -string.len(".zoom_gesture") - 1)

---@type Kazari.BaseGesture
local BaseGesture = require(path..".base_gesture")
---@type Kazari.Util
local util = require(path..".util")

---Implements pinch zoom touch gesture.
---@class Kazari.ZoomGesture: Kazari.BaseGesture
local ZoomGesture = {}
ZoomGesture.__index = ZoomGesture ---@private
ZoomGesture.__parent = BaseGesture ---@private

---@package
---@param clip boolean?
---@param constraint Kazari.AnyConstraint?
function ZoomGesture:init(clip, constraint)
	self.constraint = constraint ---@private
	self.clipTouch = not not clip ---@private
end

---@generic T
---@param context T
---@param func fun(context:T, scale: number)
function ZoomGesture:onZoom(context, func)
	self.onZoomContext = context ---@private
	self.onZoomCallback = func ---@private
end

---@generic U
---@param context U
---@param func fun(context:U, scale: number)
function ZoomGesture:onZoomComplete(context, func)
	self.onZoomDoneContext = context ---@private
	self.onZoomDoneCallback = func ---@private
end

---@param x number
---@param y number
---@param pressure number
function ZoomGesture:touchpressed(id, x, y, pressure)
	if not util.pointInConstraint(x, y, self.constraint) then
		return false
	end

	if not self.t1 then
		self.t1 = {id, x, y} ---@private
	elseif not self.t2 then
		self.t2 = {id, x, y} ---@private

		-- Start gesture
		self.initDistance = util.distance(self.t1[2], self.t1[3], self.t2[2], self.t2[3]) ---@private
		self:_updateGesture(false)
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
function ZoomGesture:touchmoved(id, x, y, dx, dy, pressure)
	-- Update gesture
	if self.t1 and id == self.t1[1] then
		if self.clipTouch then
			x, y = util.ensurePointInside(x, y, self.constraint)
		end

		self.t1[2], self.t1[3] = x, y

		if self.t2 then
			self:_updateGesture(false)
		end
	elseif self.t2 and id == self.t2[1] then
		if self.clipTouch then
			x, y = util.ensurePointInside(x, y, self.constraint)
		end

		self.t2[2], self.t2[3] = x, y
		self:_updateGesture(false)
	else
		return false
	end

	return true
end

---@param x number
---@param y number
function ZoomGesture:touchreleased(id, x, y)
	if self.t1 and id == self.t1[1] then
		if self.clipTouch then
			x, y = util.ensurePointInside(x, y, self.constraint)
		end

		self.t1[2], self.t1[3] = x, y

		if self.t2 then
			self:_updateGesture(true)
		end

		self.t1 = self.t2 ---@private
		self.t2 = nil ---@private
	elseif self.t2 and id == self.t2[1] then
		if self.clipTouch then
			x, y = util.ensurePointInside(x, y, self.constraint)
		end

		self.t2[2], self.t2[3] = x, y
		self:_updateGesture(true)
		self.t2 = nil ---@private
	else
		return false
	end

	return true
end

---@private
---@param finish boolean
function ZoomGesture:_updateGesture(finish)
	local d = util.distance(self.t1[2], self.t1[3], self.t2[2], self.t2[3])
	local scale = d / self.initDistance

	if finish and self.onZoomDoneCallback then
		self.onZoomDoneCallback(self.onZoomDoneContext, scale)
	elseif self.onZoomCallback then
		self.onZoomCallback(self.onZoomContext, scale)
	end
end

function ZoomGesture:__tostring()
	return string.format("ZoomGesture<%p>(%s, %p)", self, self.clipTouch, self.constraint)
end

setmetatable(ZoomGesture, {
	__call = function(_, clip, constraint)
		local object = setmetatable({}, ZoomGesture)
		object:init(clip, constraint)
		return object
	end
})

return ZoomGesture
