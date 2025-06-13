return {
  "easymotion/vim-easymotion",
  keys = {
    { ";", mode = 'n' },
  },
  config = function()
    vim.g.EasyMotion_keys = 'hjklasdfgyuiopqwertnmzxcvb'
    vim.g.EasyMotion_leader_key = ';'
    vim.g.EasyMotion_grouping = 1
    vim.g.EasyMotion_verbose = 0
    vim.g.EasyMotion_startofline = 0
    vim.keymap.set("n", ";", "<Plug>(easymotion-prefix)", { silent = true, remap = true })
  end
}
