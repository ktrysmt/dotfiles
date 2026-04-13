return {
  'catgoose/nvim-colorizer.lua',
  event = { "CursorHold", "CursorMoved", "ModeChanged" },
  config = function()
    require 'colorizer'.setup({
      filetypes = { "*" },
      options = {
        parsers = {
          css = true,
          css_fn = true,
          names = {
            enable = false,
          }
        }
      }
    })
    vim.cmd [[ColorizerAttachToBuffer]]
  end
}
