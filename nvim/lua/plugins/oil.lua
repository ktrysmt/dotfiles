return {
  'stevearc/oil.nvim',
  opts = {},
  cmd = { "Oil" },
  dependencies = {
    { "echasnovski/mini.icons", opts = {}, }
  },
  config = function()
    require("oil").setup()
  end
}
