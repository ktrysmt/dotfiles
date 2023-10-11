local M = {}

function M.setup()
  require("local.options").init()
  require("local.keys").init()
  require("local.au").init()
  require("local.command").init()
end

return M
