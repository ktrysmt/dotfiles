return {
  'nvim-lualine/lualine.nvim',
  event = { "VeryLazy" },
  config = function()
    require('lualine').setup {
      options = {
        theme = 'gruvbox-material', --'material',
        -- component_separators = { left = '', right = '' },
        -- section_separators = { left = '', right = '' },
        globalstatus = false,
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
        },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'location' },
        lualine_z = {},
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          { 'filename' }
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
      },
      extensions = {
        'aerial',
        'neo-tree',
        'mason',
        'lazy',
        'fugitive',
        'oil',
        'man',
        'fzf',
        'quickfix',
      }
    }
  end
}
