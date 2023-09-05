return {
  'kevinhwang91/nvim-hlslens',
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local opt = { silent = true }
    vim.keymap.set('n', 'n', "<cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>", opt)
    vim.keymap.set('n', 'N', "<cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>", opt)
    vim.keymap.set('n', '*', "*<Cmd>lua require('hlslens').start()<CR>", opt)
    vim.keymap.set('n', '#', "#<Cmd>lua require('hlslens').start()<CR>", opt)
    require('hlslens').setup({
      calm_down = true,
      nearest_only = true,
      nearest_float_when = 'always',
    })
  end
}
