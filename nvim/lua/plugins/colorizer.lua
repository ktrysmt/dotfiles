return {
  'norcalli/nvim-colorizer.lua',
  event = { "CursorHold", "CursorMoved", "ModeChanged" },
  config = function()
    require 'colorizer'.setup()
    vim.cmd [[ColorizerAttachToBuffer]]
  end
}
