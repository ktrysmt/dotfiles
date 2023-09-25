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

local general_group = vim.api.nvim_create_augroup('general_group', { clear = true })
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  pattern = "*",
  group = general_group,
  command = [[%s/\s\+$//ge]],
})
vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
  pattern = "*",
  group = general_group,
  command = "set nopaste"
})
vim.api.nvim_create_autocmd({ 'QuickFixCmdPost' }, {
  pattern = "*grep*",
  group = general_group,
  command = "cwindow"
})
vim.api.nvim_create_autocmd({ 'TermOpen' }, {
  pattern = "*",
  group = general_group,
  command = "setl winhighlight=Normal:User1 | setl norelativenumber | setl nonumber"
})
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  pattern = "term://*",
  group = general_group,
  command = "startinsert"
})
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = { "*.yaml.j2", "*.yml.j2" },
  group = general_group,
  command = "setfiletype yaml.ansible"
})

local json_group = vim.api.nvim_create_augroup('json_group', { clear = true })
vim.api.nvim_create_autocmd({ 'Filetype' }, {
  pattern = "json",
  group = json_group,
  command = "setl conceallevel=0"
})

local highlight_group = vim.api.nvim_create_augroup('highlight_group', { clear = true })
vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  pattern = "*",
  group = highlight_group,
  command = "hi IdeographicSpace ctermbg=DarkGreen guibg=DarkGreen | hi NormalNC guibg=#101010 | hi User1 guifg=#dddddd"
})
vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  pattern = "*",
  group = highlight_group,
  command = "match IdeographicSpace /　/"
})


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
