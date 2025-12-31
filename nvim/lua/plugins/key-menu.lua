return {
  "emmanueltouzery/key-menu.nvim",
  event = "VeryLazy",
  config = function()
    require 'key-menu'.set('n', '<Space>')
  end
}
