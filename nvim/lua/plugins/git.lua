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
        signs      = {
          add          = { text = '+' },
          change       = { text = '|' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        -- sign_priority = 1,
        signcolumn = false,
        numhl      = true,
        linehl     = false,
      })
      -- highlight GitSignsAddNr guibg=#173315 guifg=#626262
      -- highlight GitSignsAddNr guibg=#173315 guifg=#6c6c6c
      -- highlight GitSignsAdd guifg=#528832
      -- set signcolumn=yes:2
      vim.cmd [[
      highlight GitSignsAddNr guibg=#173315 guifg=#6c6c6c
      highlight GitSignsChangeNr guibg=#353512 guifg=#6c6c6c
      highlight GitSignsDeleteNr guibg=#351415 guifg=#6c6c6c
      ]]
    end
  }
}
