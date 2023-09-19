return {
  {
    "akinsho/git-conflict.nvim",
    event = { "VeryLazy" },
    version = "*",
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
        signcolumn = true,
        numhl      = false,
        linehl     = false,
      })

      -- set signcolumn=yes:2
      -- highlight GitSignsAddNr guibg=#173315 guifg=#6c6c6c
      -- highlight GitSignsChangeNr guibg=#353512 guifg=#6c6c6c
      -- highlight GitSignsDeleteNr guibg=#351415 guifg=#6c6c6c
      vim.cmd [[
      highlight GitSignsAdd guifg=#528832
      ]]
    end
  },
  {
    "kdheepak/lazygit.nvim",
    keys = {
      { "<Leader>lg", "<cmd>LazyGit<cr>", mode = "n" },

    },
  }
}
