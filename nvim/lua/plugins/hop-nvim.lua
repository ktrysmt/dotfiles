return {
  "phaazon/hop.nvim",
  keys = {
    { ";w", mode = 'n' },
    { ";b", mode = 'n' },
    { ";f", mode = 'n' },
    { ";j", mode = 'n' },
    { ";k", mode = 'n' },
  },
  config = function()
    hop = require('hop')
    hop.setup({})

    local opt = { silent = true }
    vim.keymap.set("n", ";w", "<cmd>HopWordAC<cr>", opt)
    vim.keymap.set("n", ";b", "<cmd>HopWordBC<cr>", opt)
    vim.keymap.set("n", ";f", "<cmd>HopChar1<cr>", opt)
    vim.keymap.set("n", ";j", "<cmd>HopLineAC<cr>", opt)
    vim.keymap.set("n", ";k", "<cmd>HopLineBC<cr>", opt)

  end
}
