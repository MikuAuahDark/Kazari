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

local kazari = {
	_VERSION = "0.0.1",
	_AUTHOR = "Miku AuahDark",
	_LICENSE = "zLib"
}

---@type string
local path = ...
assert(path:find("/", 1, true) == nil, "usage of period is enforced in this library!")
if path:sub(-5) == ".init" then
	path = path:sub(1, -6)
end

---@alias Kazari.NumberedConstraint {[1]:number,[2]:number,[3]:number,[4]:number}
---@alias Kazari.NamedConstraint {x:number,y:number,w:number,h:number}
---@alias Kazari.AnyConstraint Kazari.NumberedConstraint|Kazari.NamedConstraint|NLay.BaseConstraint

---@param obj any
---@param class Kazari.BaseGesture
function kazari.is(obj, class)
	local meta = getmetatable(obj)

	while meta ~= nil do
		if meta == class then
			return true
		end

		meta = meta.__parent
	end

	return false
end

---@type Kazari.ZoomGesture|fun(clip:boolean?,constraint:Kazari.AnyConstraint?):Kazari.ZoomGesture
kazari.ZoomGesture = require(path..".zoom_gesture")
---@type Kazari.RotateGesture|fun(constraint:Kazari.AnyConstraint?):Kazari.RotateGesture
kazari.RotateGesture = require(path..".rotate_gesture")

return kazari
