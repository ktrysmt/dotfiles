return {
  'nvim-lualine/lualine.nvim',
  event = { "VeryLazy" },
  config = function()
    require('lualine').setup {
      options = {
        theme = 'jellybeans',
        globalstatus = true,
      },
      sections = {
        lualine_b = {
          "branch",
          "diff",
          {
            'diagnostics',
            sources = { 'nvim_lsp', },
            symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' },
          },
        },
        lualine_c = { { 'filename', path = 1 } }
      }
    }
  end
}
