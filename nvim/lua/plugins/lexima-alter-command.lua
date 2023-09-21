return {
  'yuki-yano/lexima-alter-command.vim',
  event = { "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
  dependencies = {
    "cohama/lexima.vim"
  },
  config = function()
    vim.cmd [[
    LeximaAlterCommand rg Rg
    LeximaAlterCommand lz Lazy
    LeximaAlterCommand qf\%[replace] Qfreplace
    LeximaAlterCommand ma\%[son] Mason
    ]]
  end
}
