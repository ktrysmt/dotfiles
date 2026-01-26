local highlight_group = vim.api.nvim_create_augroup('highlight_group', { clear = true })
vim.api.nvim_create_autocmd({ 'VimEnter', 'Colorscheme' }, {
  pattern = "*",
  group = highlight_group,
  command =
  "hi IdeographicSpace ctermbg=DarkGreen guibg=DarkGreen | hi NormalNC guibg=#171717 | hi User1 guifg=#dddddd | hi @variable guifg=Normal"
})
vim.api.nvim_create_autocmd({ 'VimEnter', 'WinEnter' }, {
  pattern = "*",
  group = highlight_group,
  command = "match IdeographicSpace /　/"
})
