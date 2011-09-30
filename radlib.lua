-- Rad's Library of awesome Lua functions to complement the awesome Corona SDK

local M = {}
M.io = {}
M.table = {}

require "json"

local parseJson = function( filename )
  local file = io.open( filename, "r" )
  if file then
    local contents = file:read( "*a" )
    result = json.decode( contents )
    io.close( file )
    return result
  else
    return {}
  end
end
M.io.parseJson = parseJson

-- From: http://stackoverflow.com/questions/1283388/lua-merge-tables
local tableMerge = function(t1, t2)
  for k,v in pairs(t2) do
    if type(v) == "table" then
      if type(t1[k] or false) == "table" then
        table.merge(t1[k] or {}, t2[k] or {})
      else
        t1[k] = v
      end
    else
      t1[k] = v
    end
  end
  return t1
end
M.table.merge = tableMerge

-- Similar to Ruby's Enumerable#select
-- Given an input table and a function, return only those rows where fx(row) returns true
local tableFindAll = function( t, fx )
  local result = {}
  for i,v in ipairs(t) do
    if fx(v) then
      result[#result + 1] = v
    end
  end
  return result
end
M.table.findAll = tableFindAll

local tablePrint = function( t )
  for i,v in pairs(t) do
    if "table" == type(v) then
      print(i .. " = [table]: ")
      print("---")
      table.print(v)
      print("---")
    else
      print(i .. " = " .. v)
    end
  end
end
M.table.print = tablePrint

local debug = function( msg )
  native.showAlert("DEBUG", msg, {"OK"})
end
M.debug = debug

return M


