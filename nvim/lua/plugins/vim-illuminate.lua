return {
  'RRethy/vim-illuminate',
  event = { "CursorMoved", "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
  config = function()
    require('illuminate').configure({
      providers = {
        'regex',
      },
    })
  end
}
