module(..., package.seeall)

-- From: http://stackoverflow.com/questions/1283388/lua-merge-tables
function tableMerge(t1, t2)
  for k,v in pairs(t2) do
    if type(v) == "table" then
      if type(t1[k] or false) == "table" then
        tableMerge(t1[k] or {}, t2[k] or {})
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
function filterTable( t, str )
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

function debug( msg )
  native.showAlert("DEBUG", msg, {"OK"})
end

