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

    LeximaAlterCommand g Git
    LeximaAlterCommand g\%[push] "Git<space>push"
    LeximaAlterCommand g\%[blame] "Git<space>blame"

    LeximaAlterCommand gv DiffviewOpen
    LeximaAlterCommand gvc DiffviewClose
    LeximaAlterCommand gh DiffviewFileHistory
    ]]
  end
}
