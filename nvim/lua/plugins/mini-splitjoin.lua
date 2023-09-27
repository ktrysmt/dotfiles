return {
  'echasnovski/mini.splitjoin',
  version = '*',
  keys = {
    { "gS", mode = "n" },
  },
  config = function()
    require('mini.splitjoin').setup()
  end
}
