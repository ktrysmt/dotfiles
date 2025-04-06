return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  cmd = { "Oil" },
  -- Optional dependencies
  dependencies = {
    { "echasnovski/mini.icons", opts = {}, }
  },
  config = function()
    require("oil").setup()
  end
}
