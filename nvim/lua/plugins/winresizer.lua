return {
  'simeji/winresizer',
  -- cmd = { 'WinResizerStartResize' },
  keys = {
    { '<C-w><C-w>', mode = "n" },
  },
  config = function()
    vim.g.winresizer_keycode_finish = "<C-c>"
    vim.keymap.set("n", '<C-w><C-w>', ":WinResizerStartResize<cr>")
  end
}
