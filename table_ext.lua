local M = {}

------------------------------------------------------------------------------
-- Merge two tables
-- From: http://stackoverflow.com/questions/1283388/lua-merge-tables
------------------------------------------------------------------------------
local merge = function(t1, t2)
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
M.merge = merge

------------------------------------------------------------------------------
-- Print the contents of a table
------------------------------------------------------------------------------
local tablePrint = function( t )
  for i,v in pairs(t) do
    if "table" == type(v) then
      print(i .. " = [table]: ")
      print("---")
      M.print(v)
      print("---")
    else
      print(i .. " = " .. v)
    end
  end
end
M.print = tablePrint

------------------------------------------------------------------------------
-- Wrap the values of a table inside single quotes
------------------------------------------------------------------------------
local quoteValues = function( t )
  local result = {}
  for i,v in pairs(t) do
    result[i] = "'" .. v .. "'"
  end
  return result
end
M.quoteValues = quoteValues


return M
