 return {
  'nvim-lualine/lualine.nvim',
  event = { "VeryLazy" },
  config = function()
    require('lualine').setup {
      options = {
        theme = 'jellybeans',
      },
      sections = {
        lualine_b = {
          "branch",
          "diff",
          {
            'diagnostics',
            sources = { 'nvim_lsp', },
            symbols = {error = 'E', warn = 'W', info = 'I', hint = 'H'},
          },
        }
      }
    }
  end
}
