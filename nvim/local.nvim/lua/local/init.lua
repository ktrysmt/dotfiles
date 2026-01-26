local M = {}

function M.setup()
  require("local.command").init()
  require("local.au").init()
  require("local.checkhealth").init()
  require("local.clipboard").init()
end

return M
