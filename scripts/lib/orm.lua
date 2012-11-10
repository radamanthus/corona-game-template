local sql = require 'sql'
local sqlite3 = require "sqlite3"
local radlib = require "radlib"


local M = {}

------------------------------------------------------------------------------
-- Initialize the database connection
------------------------------------------------------------------------------
local initialize = function( dbPath )
  if dbPath ~= nil then
    _G.db = sqlite3.open( dbPath )
  else
    _G.db = sqlite3.open_memory()
  end
  return db
end
M.initialize = initialize

------------------------------------------------------------------------------
-- Close the database
------------------------------------------------------------------------------
local close = function()
  _G.db:close()
end
M.close = close

------------------------------------------------------------------------------
-- Return all the contents of an SQLite table as a table structure
------------------------------------------------------------------------------
local selectAll = function( tableName, params )
  local result = {}
  local s = sql.generateSelect({
    tableName = tableName,
    order = params.order,
    limit = params.limit
  })
  for row in _G.db:nrows(s) do
    result[#result+1] = row
  end
  return result
end
M.selectAll = selectAll

------------------------------------------------------------------------------
-- Return contents of an SQLite table filtered by a WHERE query
-- Return value is a table structure
------------------------------------------------------------------------------
local selectWhere = function(tableName, params )
  local result = {}
  local s = sql.generateSelect({
    tableName = tableName,
    where = params.where,
    order = params.order,
    limit = params.limit
  })
  for row in _G.db:nrows(s) do
    result[#result+1] = row
  end
  return result
end
M.selectWhere = selectWhere

------------------------------------------------------------------------------
-- Return the row from the given table,
-- selected from the given key/keyValue pair
------------------------------------------------------------------------------
local selectOne = function(tableName, key, keyValue)
  local result = {}
  local s = sql.generateSelect({
    tableName = tableName,
    where = key .. " = " .. keyValue,
    limit = 1
  })
  for row in _G.db:nrows(s) do
    result[1] = row
    break
  end
  return result[1]
end
M.selectOne = selectOne

------------------------------------------------------------------------------
-- Returns the number of rows for the given table
------------------------------------------------------------------------------
local getTableRowCount = function(tableName)
  local rowCount = 0
  for row in _G.db:nrows("SELECT COUNT(*) as rowcount FROM " .. tableName) do
    rowCount = row.rowcount
  end
  return rowCount
end
M.getTableRowCount = getTableRowCount

------------------------------------------------------------------------------
-- Inserts a row into the given table
------------------------------------------------------------------------------
local insertRow = function( tableName, row )
  -- temporary holding variables
  local columnList = " ( "
  local valuesList = " VALUES("

  -- format column values into SQL-safe strings
  -- then concatenate them together
  for i,v in pairs(row) do
    local colName = i
    local colValue = v
    if type(v) == 'string' then
      colValue = radlib.string.toSqlString(v)
    end
    columnList = columnList .. colName .. ","
    valuesList = valuesList .. colValue .. ","
  end

  -- strip off the trailing comma and add a closing parentheses
  columnList = string.sub( columnList, 1, columnList:len()-1 ) .. ')'
  valuesList = string.sub( valuesList, 1, valuesList:len()-1 ) .. ')'

  -- prepare the complete SQL command
  local sql = "INSERT INTO " .. tableName .. columnList .. valuesList

  -- execute the SQL command for inserting the row
  _G.db:exec( sql )
end
M.insertRow = insertRow

------------------------------------------------------------------------------
-- Updates a row on the given table
------------------------------------------------------------------------------
local updateRow = function( tableName, recordData )
  -- format column values into SQL-safe strings
  -- then concatenate them together
  local updateStr = ''
  for i,v in pairs(recordData) do
    if i ~= 'id' then
      local colName = i
      local colValue = v
      if type(v) == 'string' then
        colValue = radlib.string.toSqlString(v)
      end
      updateStr = updateStr .. colName .. " = " .. colValue .. ","
    end
  end

  -- remove the trailing comma
  updateStr = string.sub( updateStr, 1, #updateStr-1 )

  local sql = "UPDATE " .. tableName .. " SET " .. updateStr .. " WHERE id = " .. recordData.id
  db:exec( sql )
end
M.updateRow = updateRow

------------------------------------------------------------------------------
-- If a matching id already exists in the database, do an update
-- otherwise do an insert
------------------------------------------------------------------------------
local createOrUpdate = function( tableName, recordData )
  local existingRecord = nil
  if recordData.id ~= nil then
    existingRecord = M.selectOne( tableName, 'id', recordData.id )
  end

  if existingRecord == nil then
    M.insertRow( tableName, recordData )
  else
    M.updateRow( tableName, recordData )
  end
end
M.createOrUpdate = createOrUpdate

------------------------------------------------------------------------------
-- Updates all rows in the given table
------------------------------------------------------------------------------
local updateAll = function( tablename, updateSql )
  local str = "UPDATE " .. tablename ..
    " SET " .. updateSql
  db:exec( str )
end
M.updateAll = updateAll

------------------------------------------------------------------------------
-- Updates one column for one row in a given table
------------------------------------------------------------------------------
local updateAttribute = function( tablename, filter, columnName, columnValue )
  if type(columnValue) == 'string' then
    columnValue = radlib.string.toSqlString( columnValue )
  end
  local updateStr = "UPDATE " .. tablename ..
    " SET " .. columnName .. " = " .. columnValue ..
    " WHERE " .. filter
  db:exec( updateStr )
end
M.updateAttribute = updateAttribute

------------------------------------------------------------------------------
-- Updates multiple columns for one row in a given table
------------------------------------------------------------------------------
local updateAttributes = function( tablename, filter, columns, columnValues )
  local updateStr = ''
  local newValue = nil
  for i,v in ipairs(columns) do
    if type(v) == 'string' then
      newValue = radlib.string.toSqlString( columnValues[i] )
    else
      newValue = columnValues[i]
    end
    updateStr = updateStr .. v .. " = " .. newValue
    if i < #columns then
      updateStr = updateStr .. ", "
    end
  end
  db:exec(
    "UPDATE " .. tablename .. " SET " ..
    updateStr ..
    " WHERE " .. filter
  )
end
M.updateAttributes = updateAttributes

------------------------------------------------------------------------------
-- Updates all rows that match the filter in the given table
------------------------------------------------------------------------------
local updateWhere = function( tablename, updateSql, filter )
  local str = "UPDATE " .. tablename ..
    " SET " .. updateSql ..
    " WHERE " .. filter
  db:exec( str )
end
M.updateWhere = updateWhere


return M

