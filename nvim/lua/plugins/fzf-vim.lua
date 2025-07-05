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
    { "<A-m>",      mode = { "n", "i", "x", "v" } },
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

    function! s:grep_sink(lines) abort
      if empty(a:lines)
        echohl WarningMsg | echo "fzf: No item selected" | echohl None
        return
      endif

      let action = a:lines[0]
      let parts = split(a:lines[1], ':')

      if len(parts) < 3
        echohl ErrorMsg | echo "fzf: Invalid ripgrep line format." | echohl None
        return
      endif

      let filename = parts[0]
      let line_number = parts[1]

      if &filetype ==# 'neo-tree' || &filetype ==# 'oil'
        silent! wincmd w
      endif

      try
        if action == 'ctrl-v'
          execute 'silent vsplit ' . fnameescape(filename)
          execute line_number
          normal! zz
        elseif action == 'ctrl-t'
          execute 'silent tabedit ' . fnameescape(filename)
          execute line_number
          normal! zz
        elseif action == 'ctrl-x'
          execute 'silent split ' . fnameescape(filename)
          execute line_number
          normal! zz
        else
          execute 'silent edit ' . fnameescape(filename)
          execute line_number
          normal! zz
        endif
      catch
        echohl ErrorMsg
        echo "fzf: Failed to vsplit '" . filename . "'"
        echohl None
        echomsg "fzf vsplit error: " . v:exception . " | " . v:throwpoint
      endtry
    endfunction

    command! -bang -nargs=* Ripgrep
      \ call fzf#vim#grep(
      \   'rg --hidden --glob "!{node_modules/*,vendor/*,.git/*}" --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>),
      \   1,
      \   fzf#vim#with_preview({'options': '--exact --reverse --delimiter : --nth 3..', 'sink*': function('s:grep_sink')}, 'right:50%'),
      \   <bang>0
      \ )
    " \   fzf#vim#with_preview({'options': '--exact --reverse --delimiter : --nth 3..'}, 'right:50%'),

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
    vim.keymap.set("n", "<A-m>", "<plug>(fzf-maps-n)", opt)
    vim.keymap.set("i", "<A-m>", "<plug>(fzf-maps-i)", opt)
    vim.keymap.set({ "v", "x" }, "<A-m>", "<plug>(fzf-maps-x)", opt)

    vim.keymap.set("n", "<Leader>mr", ":FZFMru<cr>", opt)

    local function should_switch_window()
      local bufname = vim.fn.expand('%')
      return bufname:match('^neo%-tree filesystem') or bufname:match('^oil://')
    end

    vim.keymap.set("n", "<Leader>x", function()
      if should_switch_window() then vim.cmd('wincmd w') end
      vim.cmd('Commands')
    end, opt)

    vim.keymap.set("n", "<Leader>d", function()
      if should_switch_window() then vim.cmd('wincmd w') end
      vim.cmd('GFiles?')
    end, opt)

    vim.keymap.set("n", "<Leader>b", function()
      if should_switch_window() then vim.cmd('wincmd w') end
      vim.cmd('Buffers')
    end, opt)

    vim.keymap.set("n", "<Leader>hc", function()
      if should_switch_window() then vim.cmd('wincmd w') end
      vim.cmd('History:')
    end, opt)

    vim.keymap.set("n", "<Leader>hs", function()
      if should_switch_window() then vim.cmd('wincmd w') end
      vim.cmd('History/')
    end, opt)

    vim.keymap.set("n", "<Leader>r", function()
      if should_switch_window() then vim.cmd('wincmd w') end
      vim.cmd('Ripgrep')
    end, opt)

    vim.keymap.set("n", "<Leader>w", function()
      if should_switch_window() then vim.cmd('wincmd w') end
      vim.cmd('Windows')
    end, opt)

    vim.keymap.set("n", "<Leader>f", function()
      if should_switch_window() then vim.cmd('wincmd w') end
      vim.cmd('Files')
    end, opt)
  end
}
