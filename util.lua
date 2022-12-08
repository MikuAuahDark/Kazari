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

---@class Kazari.Util
local util = {}

---@param constraint Kazari.AnyConstraint?
function util.resolveConstraint(constraint)
	if constraint then
		if constraint.get then
			---@cast constraint NLay.BaseConstraint
			return constraint:get()
		elseif #constraint == 4 then
			return constraint[1], constraint[2], constraint[3], constraint[4]
		else
			return constraint.x, constraint.y, constraint.w, constraint.h
		end
	else
		return -2147483648, -2147483648, 4294967295, 4294967295
	end
end

---@param px number
---@param py number
---@param constraint Kazari.AnyConstraint?
function util.pointInConstraint(px, py, constraint)
	local x, y, w, h = util.resolveConstraint(constraint)
	return px >= x and py >= y and px < (x + w) and py < (y + h)
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
function util.distance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) ^ 2 + (y2-  y1) ^ 2)
end

---@param px number
---@param py number
---@param constraint Kazari.AnyConstraint?
function util.ensurePointInside(px, py, constraint)
	local x, y, w, h = util.resolveConstraint(constraint)
	return math.min(math.max(px, x), x + w), math.min(math.max(py, y), y + h)
end

return util
