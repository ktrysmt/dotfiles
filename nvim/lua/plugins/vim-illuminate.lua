return {
  'RRethy/vim-illuminate',
  event = { "CursorHold", "CursorMoved", "ModeChanged", "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
  config = function()
    require('illuminate').configure({
      providers = {
        'regex',
      },
    })
  end
}
