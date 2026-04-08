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
    url = 'https://codeberg.org/andyg/leap.nvim',
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
    "https://github.com/atusy/treemonkey.nvim",
    init = function()
      vim.keymap.set({ "x", "o" }, "m", function()
        require("treemonkey").select({ ignore_injections = false })
      end)
    end
  },
  {
    'andymass/vim-matchup',
    event = 'BufReadPost',
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }
    end
  }
}
