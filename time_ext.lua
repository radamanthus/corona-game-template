local M = {}

------------------------------------------------------------------------------
-- Given a time duration in seconds, returns it in HH::MM::SS format
-- Assumes that duration is less than 24 hours
------------------------------------------------------------------------------
local formatTimeDuration = function( duration )
  local d = duration
  local hours = math.floor( duration / 3600 )
  d = d - ( hours * 3600 )
  local minutes = math.floor( d / 60 )
  d = d - ( minutes * 60 )
  local seconds = d

  return string.format( "%02d:%02d:%02d", hours, minutes, seconds )
end
M.formatTimeDuration = formatTimeDuration

return M

