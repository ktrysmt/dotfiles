return {
  'easymotion/vim-easymotion',
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    vim.keymap.set('n', ";", "<Plug>(easymotion-prefix)", { remap = true })

    vim.g.EasyMotion_keys = 'hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB'
    vim.g.EasyMotion_leader_key = ';'
    vim.g.EasyMotion_grouping = 1
  end
}
