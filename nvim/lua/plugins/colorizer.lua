return {
  'norcalli/nvim-colorizer.lua',
  event = { "CursorHold", "CursorMoved", "ModeChanged" },
  config = function()
    require 'colorizer'.setup({
      '*',
      css = {
        rgb_fn = true,
        names = true,
      },
    }, { names = false })
    vim.cmd [[ColorizerAttachToBuffer]]
  end
}
