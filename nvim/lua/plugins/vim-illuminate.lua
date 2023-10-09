return {
  'RRethy/vim-illuminate',
  event = { "CursorMoved" },
  config = function()
    require('illuminate').configure({
      providers = {
        'regex',
      },
    })
  end
}
