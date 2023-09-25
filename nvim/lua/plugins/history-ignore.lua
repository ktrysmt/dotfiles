return {
  'yutkat/history-ignore.nvim',
  event = { 'CmdlineEnter', "CmdwinEnter" },
  config = function()
    require('history-ignore').setup()
  end
}
