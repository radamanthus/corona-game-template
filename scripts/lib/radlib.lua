-- Rad's Library of awesome Lua functions to complement the awesome Corona SDK

local M = {}

local geometry = require "geometry"
M.geometry = geometry

local ioExt = require "io_ext"
M.io = ioExt

local stringExt = require "string_ext"
M.string = stringExt

local tableExt = require "table_ext"
M.table = tableExt

local timeExt = require "time_ext"
M.time = timeExt

local debug = function( msg )
  native.showAlert("DEBUG", msg, {"OK"})
end
M.debug = debug

return M



