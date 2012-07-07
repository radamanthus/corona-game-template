local M = {}
M.string = {}

local doubleQuote = function( str )
  return '"' .. str .. '"'
end
M.doubleQuote = doubleQuote

local singleQuote = function( str )
  return "'" .. str .. "'"
end
M.singleQuote = singleQuote

local toSqlString = function( str )
  local result = string.gsub( str, "'", "'''")
  result = singleQuote( result )
  return result
end
M.toSqlString = toSqlString

return M
