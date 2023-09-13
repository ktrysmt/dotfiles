return {
  {
    "akinsho/git-conflict.nvim",
    event = { "VeryLazy" },
    version = "*",
    config = true
  },
  {
    'tpope/vim-fugitive',
    event = { "VeryLazy" },
  },
  {
    'lewis6991/gitsigns.nvim',
    event = { "VeryLazy" },
    config = function()
      require('gitsigns').setup({
        signs = {
          add          = { text = '+' },
          change       = { text = '|' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        -- sign_priority = 100
      })

      -- highlight GitSignsAddNr guibg=#173315 guifg=#626262
      -- set signcolumn=yes:2
      vim.cmd [[
      highlight GitSignsAdd guifg=#528832 guibg=#071905
      ]]
    end
  },
}
