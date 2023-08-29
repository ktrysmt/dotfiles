return {
  'lambdalisue/fern.vim',
  keys = {
    { "<C-e>", ":Fern . -reveal=% -drawer -toggle -width=50<CR>", silent = true},
    { '<C-w>f', ":cd %:p:h<CR> :cd `git rev-parse --show-toplevel`<CR> :Fern . -reveal=% -drawer -width=50<CR>", noremap = true, silent = true }
  },
  config = function()
    vim.keymap.set('n', 'o', '<Plug>(fern-action-open-or-expand)')

    -- VimL: nmap <buffer> <Plug>(fern-my-leave-and-tcd) ...
    vim.api.nvim_exec([[
      nmap <buffer> <Plug>(fern-my-leave-and-tcd) <Plug>(fern-action-leave)<Plug>(fern-wait)<Plug>(fern-action-tcd:root)
    ]], false)

    -- VimL: nmap <buffer> u <Plug>(fern-my-leave-and-tcd)
    vim.api.nvim_exec([[
      nmap <buffer> u <Plug>(fern-my-leave-and-tcd)
    ]], false)

  end,
}
