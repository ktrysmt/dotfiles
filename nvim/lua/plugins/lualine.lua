return {
  'nvim-lualine/lualine.nvim',
  event = { "VimEnter" },
  config = function()
    require('lualine').setup {
      options = {
        theme = 'gruvbox-material', --'material',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
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
        lualine_c = {
          { 'filename',    path = 1 },
          { 'searchcount', maxcount = 999, timeout = 500, color = { fg = '#efcf00' } },
        }
      }
    }
  end
}
