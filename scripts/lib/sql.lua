------------------------------------------------------------------------------
-- Module for SQL generation
------------------------------------------------------------------------------
local _ = require 'underscore'
local string_ext = require 'string_ext'

local M = {}
------------------------------------------------------------------------------
-- Generate the sql for the given field def flags
------------------------------------------------------------------------------
local sqlForFieldFlags = function(fieldDef)
  if fieldDef.flags ~= nil then
    return _.join(fieldDef.flags, ' '):upper()
  else
    return ''
  end
end
M.sqlForFieldFlags = sqlForFieldFlags

------------------------------------------------------------------------------
-- Generate a CREATE TABLE IF NOT EXISTS statement
-- for the given tablename and tablefield definitions
------------------------------------------------------------------------------
local generateCreateTable = function(tableName, tableFields)
  local result = ''
  result = 'CREATE TABLE IF NOT EXISTS ' .. tableName .. '('
  for fieldName,fieldDef in pairs(tableFields) do
    result = result .. string_ext.doubleQuote(fieldName) .. ' ' .. fieldDef.dataType:upper()
    result = result .. ' ' .. M.sqlForFieldFlags(fieldDef)
    result = result .. ','
  end
  result = string.sub( result, 1, result:len()-1 )
  result = result .. ')'
  return result
end
M.generateCreateTable = generateCreateTable

------------------------------------------------------------------------------
-- Generate a SELECT statement
--
-- Parameters:
--   tableName
--   columns
--   where
--   order
--   limit
------------------------------------------------------------------------------
local generateSelect = function(params)
  local tableName = ''
  if params.tableName == nil or params.tableName == '' then
    return ''
  else
    tableName = params.tableName
  end

  local columns = ''
  if params.columns == nil or params.columns == '' then
    columns = '*'
  else
    columns = params.columns
  end

  local result = ''
  result = 'SELECT ' .. columns .. ' FROM ' .. tableName
  if params.where ~= nil and params.where ~= '' then
    result = result .. ' WHERE ' .. params.where
  end
  if params.order ~= nil and params.order ~= '' then
    result = result .. ' ORDER BY ' .. params.order
  end
  if params.limit ~= nil and params.limit ~= '' then
    result = result .. ' LIMIT ' .. params.limit
  end
  return result
end
M.generateSelect = generateSelect


return M
