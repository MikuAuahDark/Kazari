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

---All gestures inherit from this class. This class cannot be constructed!
---@class Kazari.BaseGesture
local BaseGesture = {}

---@param x number
---@param y number
---@param pressure number
---@return boolean
function BaseGesture:touchpressed(id, x, y, pressure)
	return false
end

---@param x number
---@param y number
---@param dx number
---@param dy number
---@param pressure number
---@return boolean
function BaseGesture:touchmoved(id, x, y, dx, dy, pressure)
	return false
end

---@param x number
---@param y number
---@return boolean
function BaseGesture:touchreleased(id, x, y)
	return false
end

return BaseGesture
