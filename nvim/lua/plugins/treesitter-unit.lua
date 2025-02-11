return {
  {
    'machakann/vim-sandwich',
    keys = {
      { "sa", mode = { "n", "x" } },
      { "sr", mode = { "n", "x" } },
      { "sd", mode = { "n", "x" } },
      { "ib", mode = { "x" } }, -- auto select and be able to dot repeat
      { "is", mode = { "x" } }, -- vis", vis<, ... etc
    }
  },
  {
    'kana/vim-niceblock',
    keys = {
      { "ip", mode = { "x", "o" } },
      { "ap", mode = { "x", "o" } },
    },
  },
  {
    'David-Kunz/treesitter-unit',
    keys = {
      { "io", mode = { "x", "o" } },
      { "ao", mode = { "x", "o" } },
    },
    config = function()
      vim.keymap.set("x", "io", ':lua require"treesitter-unit".select()<cr>')
      vim.keymap.set("o", "io", ':<c-u>lua require"treesitter-unit".select()<cr>')
      vim.keymap.set("x", "ao", ':lua require"treesitter-unit".select(true)<cr>')
      vim.keymap.set("o", "ao", ':<c-u>lua require"treesitter-unit".select(true)<cr>')
    end
  },
  {
    'ggandor/leap.nvim',
    keys = {
      { 'f', mode = { "n", "x", "o" } },
      { 'F', mode = { "n", "x", "o" } },
    },
    config = function()
      local leap = require('leap')
      leap.opts.case_sensitive = false
      local l = { "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
        "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z" }
      leap.opts.labels = l
      leap.opts.safe_labels = l
      -- leap.opts.substitute_chars = { ['\r'] = '¬' }
      leap.opts.special_keys.prev_target = '<space>'
      vim.keymap.set({ 'n', 'x', 'o' }, 'f', '<Plug>(leap-forward)')
      vim.keymap.set({ 'n', 'x', 'o' }, 'F', '<Plug>(leap-backward)')

      -- vim.api.nvim_set_hl(0, 'LeapBackdrop', { fg = '#aaaaaa' })
      vim.api.nvim_set_hl(0, 'LeapLabelPrimary', { fg = 'black', bg = '#bfff19' })
    end
  },
  {
    'mfussenegger/nvim-treehopper',
    keys = {
      { "m", mode = { "x", "o" } }, -- input "vm\d"
    },
    dependencies = {
      "phaazon/hop.nvim"
    },
    config = function()
      local l = { "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
        "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z" }
      require("tsht").config.hint_keys = l
      vim.keymap.set("o", "m", ":<C-U>lua require('tsht').nodes()<CR>", { remap = true, silent = true })
      vim.keymap.set("x", "m", ":lua require('tsht').nodes()<CR>", { silent = true })
    end
  }
}
