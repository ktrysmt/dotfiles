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
      require('gitsigns').setup()

      -- highlight GitSignsAddNr guibg=#173315 guifg=#626262
      vim.cmd [[
      set signcolumn=yes:2
      ]]
    end
  },
}
