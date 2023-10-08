return {
  'junegunn/fzf.vim',
  keys = {
    { "<Leader>x",  mode = "n" },
    { "<Leader>d",  mode = "n" },
    { "<Leader>b",  mode = "n" },
    { "<Leader>hc", mode = "n" },
    { "<Leader>hs", mode = "n" },
    { "<Leader>r",  mode = "n" },
    { "<Leader>w",  mode = "n" },
    { "<Leader>f",  mode = "n" },
    { "<Leader>m",  mode = { "n", "x", "o" } },
    { "<Leader>j",  mode = "n" },
  },
  dependencies = {
    'pbogut/fzf-mru.vim',
    "junegunn/fzf",
  },
  config = function()
    vim.cmd [[
    let g:fzf_layout = { 'down': '~40%' }

    command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

    command! -bang -nargs=* Ripgrep
    \ call fzf#vim#grep(
    \   'rg --hidden --glob "!{node_modules/*,vendor/*,.git/*}" --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>),
    \   1,
    \   fzf#vim#with_preview({'options': '--exact --reverse --delimiter : --nth 3..'}, 'right:50%'),
    \   <bang>0
    \ )

    command! -bang -nargs=? GFiles
      \ call fzf#vim#gitfiles(
      \   <q-args>,
      \   {'options': ['--layout=reverse', '--info=inline', '--ansi', '--preview', 'echo {} | cut -f3 -d" " | xargs git --no-pager diff | BAT_THEME=Dracula bat --color=always --style=plain']},
      \   <bang>0
      \ )
    ]]

    local opt = { silent = true }
    vim.keymap.set("n", "<Leader>r", ":Ripgrep<cr>", opt)
    vim.keymap.set("n", "<Leader>w", ":Windows<cr>", opt)
    vim.keymap.set("n", "<Leader>f", ":Files<cr>", opt)
    vim.keymap.set("n", "<Leader>x", ":Commands<cr>", opt)
    vim.keymap.set("n", "<Leader>d", ":GFiles?<cr>", opt)
    vim.keymap.set("n", "<Leader>hc", ":History:<cr>", opt)
    vim.keymap.set("n", "<Leader>hs", ":History/<cr>", opt)

    vim.keymap.set("n", "<Leader>m", "<plug>(fzf-maps-n)", opt)
    vim.keymap.set("i", "<Leader>mi", "<plug>(fzf-maps-i)", opt)
    vim.keymap.set("x", "<Leader>m", "<plug>(fzf-maps-x)", opt)
    vim.keymap.set("o", "<Leader>m", "<plug>(fzf-maps-o)", opt)

    vim.keymap.set("n", "<Leader>j", ":FZFMru<cr>", opt)
  end
}
