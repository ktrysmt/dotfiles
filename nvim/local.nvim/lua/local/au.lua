local M = {}

function M.init()
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
  vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    pattern = "term://*",
    group = general_group,
    command = "startinsert"
  })
  vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = { "*.yaml.j2", "*.yml.j2" },
    group = general_group,
    command = "setfiletype yaml"
  })
  vim.api.nvim_create_autocmd({ 'TermOpen' }, {
    pattern = "*",
    group = general_group,
    command = "setl winhighlight=Normal:User1 | setl norelativenumber | setl nonumber"
  })

  local json_group = vim.api.nvim_create_augroup('json_group', { clear = true })
  vim.api.nvim_create_autocmd({ 'Filetype' }, {
    pattern = "json",
    group = json_group,
    command = "setl conceallevel=0"
  })
end

return M
