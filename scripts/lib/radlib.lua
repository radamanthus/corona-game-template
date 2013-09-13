-- Rad's Library of awesome Lua functions to complement the awesome Corona SDK

local M = {}

M.geometry = require "scripts.lib.geometry"

M.io = require "scripts.lib.io_ext"

M.string = require "scripts.lib.string_ext"

M.table = require "scripts.lib.table_ext"

M.time = require "scripts.lib.time_ext"

M.debug = function( msg )
  native.showAlert("DEBUG", msg, {"OK"})
end

return M



