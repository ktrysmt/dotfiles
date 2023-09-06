 return {
  'nvim-lualine/lualine.nvim',
  event = { "VimEnter" },
  requires = { 'nvim-tree/nvim-web-devicons', opt = true },
  config = function()
    require('lualine').setup({
      options = { theme = 'jellybeans' }
    })
  end
}
