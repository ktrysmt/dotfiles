return {
  "ktrysmt/memd.nvim",
  -- dir = "~/workspace/memd.nvim", -- for development
  event = "VeryLazy",
  keys = {
    { '<leader>mm', mode = "n", desc = 'Memd: Toggle preview' },
  },
  config = function()
    require('memd').setup()
    vim.keymap.set('n', '<leader>mm', require('memd').toggle, { desc = 'Memd: Toggle preview' })
  end,
}
