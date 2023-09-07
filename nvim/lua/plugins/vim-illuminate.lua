return {
  'RRethy/vim-illuminate',
  event = { "VeryLazy" },
  config = function()
    require('illuminate').configure({
    providers = {
        'regex',
    },
  })
  end
}
