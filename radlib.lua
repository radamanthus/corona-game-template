-- Rad's Library of awesome Lua functions to complement the awesome Corona SDK

module(..., package.seeall)

function io.parseJson( filename )
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

-- From: http://stackoverflow.com/questions/1283388/lua-merge-tables
function table.merge(t1, t2)
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

-- Similar to Ruby's Enumerable#select
-- Given an input table, return only those rows that include the string str
function table.filter( t, str )
  local result = {}
  if str == '' then
    result = t
  else
    for i,v in ipairs(t) do
      if (v:lower()):find( str:lower() ) ~= nil then
        result[#result + 1] = v
      end
    end
  end
  return result 
end

function table.print( t )
  for i,v in ipairs(t) do
    print(i .. " = " .. v)
  end
end

function debug( msg )
  native.showAlert("DEBUG", msg, {"OK"})
end


