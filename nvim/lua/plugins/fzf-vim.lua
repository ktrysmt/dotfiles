return {
  'junegunn/fzf.vim',
  event = {
    -- "BufEnter",
    "VeryLazy",
  },
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
    { "<c-i>fm",    mode = "i" },
    { "<c-i>fw",    mode = "i" },
    { "<c-i>fp",    mode = "i" },
    { "<c-i>ff",    mode = "i" },
    { "<c-i>fl",    mode = "i" },
  },
  dependencies = {
    "junegunn/fzf",
  },
  config = function()
    vim.cmd [[
    nnoremap <expr> <Leader>x (expand('%') =~ '^fern://' ? "\<c-w>\<c-w>" : '').":Commands\<cr>"
    nnoremap <expr> <Leader>d (expand('%') =~ '^fern://' ? "\<c-w>\<c-w>" : '').":GFiles?\<cr>"
    nnoremap <expr> <Leader>b (expand('%') =~ '^fern://' ? "\<c-w>\<c-w>" : '').":Buffers\<cr>"
    nnoremap <expr> <Leader>hc (expand('%') =~ '^fern://' ? "\<c-w>\<c-w>" : '').":History:\<cr>"
    nnoremap <expr> <Leader>hs (expand('%') =~ '^fern://' ? "\<c-w>\<c-w>" : '').":History/\<cr>"
    nnoremap <expr> <Leader>r (expand('%') =~ '^fern://' ? "\<c-w>\<c-w>" : '').":Ripgrep\<cr>"
    nnoremap <expr> <Leader>w (expand('%') =~ '^fern://' ? "\<c-w>\<c-w>" : '').":Windows\<cr>"
    nnoremap <expr> <Leader>f (expand('%') =~ '^fern://' ? "\<c-w>\<c-w>" : '').":Files\<cr>"

    nmap <leader>m <plug>(fzf-maps-n)
    xmap <leader>m <plug>(fzf-maps-x)
    omap <leader>m <plug>(fzf-maps-o)

    imap <c-i>fm <plug>(fzf-maps-i)

    imap <c-i>fw <plug>(fzf-complete-word)
    imap <c-i>fp <plug>(fzf-complete-path)
    imap <c-i>ff <plug>(fzf-complete-file)
    imap <c-i>fl <plug>(fzf-complete-line)

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
  end

}
