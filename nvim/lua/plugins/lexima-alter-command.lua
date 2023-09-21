return {
  'yuki-yano/lexima-alter-command.vim',
  event = { "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
  dependencies = {
    "cohama/lexima.vim"
  },
  config = function()
    vim.cmd [[
    LeximaAlterCommand rg Rg
    LeximaAlterCommand l\%[azy] Lazy
    LeximaAlterCommand q\%[freplace] Qfreplace
    LeximaAlterCommand m\%[ason] Mason
    ]]
  end
}
