local M = {}

------------------------------------------------------------
-- Public: checks if the given point is inside the given container
--
-- Assumptions:
-- The container has the properties: top, left, bottom, right
-- The point has the properties x, y
--
-- Returns:
--  true if the point is inside the container
--  false if not
------------------------------------------------------------
local pointIsInside = function(point, rectangle)
  if (
    (point.x >= rectangle.left) and
    (point.x <= rectangle.right) and
    (point.y >= rectangle.top) and
    (point.y <= rectangle.bottom)
    ) then
    return true
  else
    return false
  end
end
M.pointIsInside = pointIsInside

------------------------------------------------------------
-- Public: checks if the given rectangle is completely
-- inside the given rectangular container
--
-- Assumptions:
-- Both container and object have the properties: top, left, bottom, right
--
-- Returns:
--  true if the both (top,left) and (bottom,right)
--  of the rectangle are inside the container
--  false otherwise
------------------------------------------------------------
local rectIsInside = function(object, container)
  if pointIsInside({x = object.left, y = object.top}, container) and
    pointIsInside({x = object.right, y = object.bottom}, container) then
    return true
  else
    return false
  end
end
M.rectIsInside = rectIsInside

------------------------------------------------------------
-- Public: checks if the given rectangle is at at least partially
-- inside the given rectangular container
--
-- Assumption:
-- Both container and object have the properties: top, left, bottom, right
--
-- Returns:
--  true if at least one of the corners of the rectangle
--  is inside the container
--  false otherwise
------------------------------------------------------------
local rectIsPartiallyInside = function(object, container)
  if pointIsInside({x = object.left, y = object.top}, container) or
    pointIsInside({x = object.right, y = object.top}, container) or
    pointIsInside({x = object.left, y = object.bottom}, container) or
    pointIsInside({x = object.right, y = object.bottom}, container) then
    return true
  else
    return false
  end
end
M.rectIsPartiallyInside = rectIsPartiallyInside

return M


