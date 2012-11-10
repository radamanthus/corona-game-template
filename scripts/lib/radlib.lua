-- Rad's Library of awesome Lua functions to complement the awesome Corona SDK

local M = {}

local geometry = require "scripts.lib.geometry"
M.geometry = geometry

local ioExt = require "scripts.lib.io_ext"
M.io = ioExt

local stringExt = require "scripts.lib.string_ext"
M.string = stringExt

local tableExt = require "scripts.lib.table_ext"
M.table = tableExt

local timeExt = require "scripts.lib.time_ext"
M.time = timeExt

local debug = function( msg )
  native.showAlert("DEBUG", msg, {"OK"})
end
M.debug = debug

return M



