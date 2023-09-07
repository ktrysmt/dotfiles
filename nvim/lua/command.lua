vim.api.nvim_create_user_command('Rg', ':silent grep <args>', { nargs = '*', complete = file })
if vim.fn.executable('rg') == 1 then
  vim.o.grepprg = 'rg --vimgrep --no-heading --sort-files'
  vim.o.grepformat = '%f:%l:%c:%m,%f:%l:%m'
end

vim.api.nvim_create_user_command('Rv', ':source $MYVIMRC', {})
vim.api.nvim_create_user_command('Ev', ':edit $HOME/dotfiles/.vimrc', {})

vim.cmd([[
  cabbr w!! w !sudo tee > /dev/null %
]])

local general_group = vim.api.nvim_create_augroup('general_group', { clear = true })
vim.api.nvim_create_autocmd({'BufWritePre'}, {
  pattern = "*",
  group = general_group,
  command = [[%s/\s\+$//ge]],
})
vim.api.nvim_create_autocmd({'InsertLeave'}, {
  pattern = "*",
  group = general_group,
  command = "set nopaste"
})
vim.api.nvim_create_autocmd({'QuickFixCmdPost'}, {
  pattern = "*grep*",
  group = general_group,
  command = "cwindow"
})
vim.api.nvim_create_autocmd({'TermOpen'}, {
  pattern = "*",
  group = general_group,
  command = "setlocal norelativenumber"
})
vim.api.nvim_create_autocmd({'TermOpen'}, {
  pattern = "*",
  group = general_group,
  command = "setlocal nonumber"
})

local json_group = vim.api.nvim_create_augroup('json_group', { clear = true })
vim.api.nvim_create_autocmd({'Filetype'}, {
  pattern = "json",
  group = json_group,
  command = "setl conceallevel=0"
})

local highlight_group = vim.api.nvim_create_augroup('highlight_group', { clear = true })
vim.api.nvim_create_autocmd({'VimEnter'}, {
  pattern = "*",
  group = highlight_group,
  command = "highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen"
})
vim.api.nvim_create_autocmd({'VimEnter'}, {
  pattern = "*",
  group = highlight_group,
  command = "match IdeographicSpace /　/"
})
