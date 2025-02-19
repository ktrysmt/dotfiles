return {
  'kiddos/gemini.nvim',
  event = { "VeryLazy" },
  config = function()
    require('gemini').setup({
      completion = {
        move_cursor_end = true
      }
    })
  end
}
