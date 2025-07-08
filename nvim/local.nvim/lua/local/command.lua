local M = {}

function M.init()
  -- vim.api.nvim_create_user_command("SayCommand", ':echo "command"', {}) -- hello_world

  -- Rg
  vim.api.nvim_create_user_command('Rg', ':silent grep <args>', { nargs = '*', complete = file })
  if vim.fn.executable('rg') == 1 then
    vim.opt.grepprg = 'rg --vimgrep --no-heading --sort-files'
    vim.opt.grepformat = '%f:%l:%c:%m,%f:%l:%m'
  end

  -- Rv,EV
  vim.api.nvim_create_user_command('Rv', ':source $MYVIMRC', {})
  vim.api.nvim_create_user_command('Ev', ':edit $HOME/dotfiles/nvim/init.lua', {})

  -- w!! (sudo)
  vim.cmd([[
  cabbr w!! w !sudo tee > /dev/null %
  ]])

  -- cn
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
