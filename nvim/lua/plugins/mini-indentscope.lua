return {
  'echasnovski/mini.indentscope',
  version = '*',
  event = { "VeryLazy" },
  config = function()
    local indentscope = require('mini.indentscope')
    indentscope.setup({
      draw = {
        animation = indentscope.gen_animation.none()
      },
      try_as_border = true,
      symbol = "│"
    })
    vim.cmd [[
    hi MiniIndentscopeSymbol guifg=#222222
    ]]
  end
}
