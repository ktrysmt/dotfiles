local M = {}

function M.init()
  -- vim.api.nvim_create_user_command("SayCommand", ':echo "command"', {})

  vim.api.nvim_create_user_command('Rg', ':silent grep <args>', { nargs = '*', complete = file })
  if vim.fn.executable('rg') == 1 then
    vim.opt.grepprg = 'rg --vimgrep --no-heading --sort-files'
    vim.opt.grepformat = '%f:%l:%c:%m,%f:%l:%m'
  end

  vim.api.nvim_create_user_command('Rv', ':source $MYVIMRC', {})
  vim.api.nvim_create_user_command('Ev', ':edit $HOME/dotfiles/nvim/init.lua', {})

  vim.cmd([[
  cabbr w!! w !sudo tee > /dev/null %
  ]])

  vim.cmd [[
  " https://github.com/Happy-Dude/dotfiles/blob/main/vim/.vim/vimrc/functions.vim#L23-L48
  " Usage :Pcre/pattern/replace/flags
  if executable('perl') && has('nvim')
    function s:PerlSubstitute(line1, line2, sstring)
      let l:lines = getline(a:line1, a:line2)
      let l:sysresult = systemlist("perl -CSDA -e 'use utf8;' -e '#line 1 \"PerlSubstitute\"' -pe ". shellescape("s".escape(a:sstring,"%!").";"), l:lines)
      if v:shell_error
        echo l:sysresult
        return
      endif
      call nvim_buf_set_lines(0, a:line1 - 1, a:line2, v:false, l:sysresult)
    endfunction
    command! -range -nargs=1 Pcre call s:PerlSubstitute(<line1>, <line2>, <q-args>)
  endif
  ]]

  vim.cmd [[
  function! s:search() abort
    let tmp = @"
    normal! gv""y
    let [text, @"] = [escape(@", '\/'), tmp]
    return '\V' .. substitute(text, "\n", '\\n', 'g')
  endfunction
  xnoremap <expr> cn "\<Esc>/\<C-r>=<SID>search()\<CR>\<CR>N\"_cgn"
  ]]
end

return M
