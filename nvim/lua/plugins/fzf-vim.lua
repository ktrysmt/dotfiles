return {
  'junegunn/fzf.vim',
  event = { 'TermOpen', "CursorHold" },
  keys = {
    { "<Leader>x",  mode = "n" },
    { "<Leader>d",  mode = "n" },
    { "<Leader>b",  mode = "n" },
    { "<Leader>hc", mode = "n" },
    { "<Leader>hs", mode = "n" },
    { "<Leader>r",  mode = "n" },
    { "<Leader>w",  mode = "n" },
    { "<Leader>f",  mode = "n" },
    { "<Leader>mr", mode = "n" },
    { "<A-m>",      mode = "n" },
    { "<A-i>",      mode = "i" },
    { "<A-x>",      mode = "x" },
  },
  dependencies = {
    'pbogut/fzf-mru.vim',
    "junegunn/fzf",
  },
  config = function()
    vim.cmd [[
    nnoremap <expr> <Leader>x (expand('%') =~ '^neo-tree filesystem\|^oil://' ? "\<c-w>\<c-w>" : '') . ":Commands\<cr>"
    nnoremap <expr> <Leader>d (expand('%') =~ '^neo-tree filesystem\|^oil://' ? "\<c-w>\<c-w>" : '').":GFiles?\<cr>"
    nnoremap <expr> <Leader>b (expand('%') =~ '^neo-tree filesystem\|^oil://' ? "\<c-w>\<c-w>" : '').":Buffers\<cr>"
    nnoremap <expr> <Leader>hc (expand('%') =~ '^neo-tree filesystem\|^oil://' ? "\<c-w>\<c-w>" : '').":History:\<cr>"
    nnoremap <expr> <Leader>hs (expand('%') =~ '^neo-tree filesystem\|^oil://' ? "\<c-w>\<c-w>" : '').":History/\<cr>"
    nnoremap <expr> <Leader>r (expand('%') =~ '^neo-tree filesystem\|^oil://' ? "\<c-w>\<c-w>" : '').":Ripgrep\<cr>"
    nnoremap <expr> <Leader>w (expand('%') =~ '^neo-tree filesystem\|^oil://' ? "\<c-w>\<c-w>" : '').":Windows\<cr>"
    nnoremap <expr> <Leader>f (expand('%') =~ '^neo-tree filesystem\|^oil://' ? "\<c-w>\<c-w>" : '').":Files\<cr>"

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

    vim.cmd [[
    function! s:ConditionalVSplit(lines) abort
      if empty(a:lines)
        echohl WarningMsg | echo "fzf: No item selected for vsplit." | echohl None
        return
      endif

      let target_path = a:lines[0]

      if &filetype ==# 'neo-tree' || &filetype ==# 'oil'
        silent! wincmd w
      endif

      try
        execute 'silent vsplit ' . fnameescape(target_path)
      catch
        echohl ErrorMsg
        echo "fzf: Failed to vsplit '" . target_path . "'"
        echohl None
        echomsg "fzf vsplit error: " . v:exception . " | " . v:throwpoint
      endtry
    endfunction

    function! s:build_quickfix_list(lines)
      call setqflist(map(copy(a:lines), '{ "filename": v:val, "lnum": 1 }'))
      copen
      cc
    endfunction

    let g:fzf_action = {
      \ 'ctrl-q': function('s:build_quickfix_list'),
      \ 'ctrl-t': 'tab split',
      \ 'ctrl-x': 'split',
      \ 'ctrl-v': function('s:ConditionalVSplit')
      \ }
    ]]

    local opt = { silent = true }

    -- vim.keymap.set("n", "<Leader>d", ":GFiles?<cr>", opt)
    -- vim.keymap.set("n", "<Leader>b", ":Buffers<cr>", opt)
    -- vim.keymap.set("n", "<Leader>f", ":Files<cr>", opt)
    -- vim.keymap.set("n", "<Leader>hc", ":History:<cr>", opt)
    -- vim.keymap.set("n", "<Leader>hs", ":History/<cr>", opt)
    -- vim.keymap.set("n", "<Leader>r", ":Ripgrep<cr>", opt)
    -- vim.keymap.set("n", "<Leader>w", ":Windows<cr>", opt)
    -- vim.keymap.set("n", "<Leader>x", ":Commands<cr>", opt)

    vim.keymap.set("n", "<A-m>", "<plug>(fzf-maps-n)", opt)
    vim.keymap.set("i", "<A-i>", "<plug>(fzf-maps-i)", opt)
    vim.keymap.set("x", "<A-x>", "<plug>(fzf-maps-x)", opt)

    vim.keymap.set("n", "<Leader>mr", ":FZFMru<cr>", opt)
  end
}
