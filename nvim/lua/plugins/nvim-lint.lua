return {
  'mfussenegger/nvim-lint',
  event = { 'BufWritePost' },
  config = function()
    local lint_group = vim.api.nvim_create_augroup('lint_group', { clear = true })
    vim.api.nvim_create_autocmd({ "FileType" }, {
      pattern = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
      group = lint_group,
      callback = function()
        if vim.fn.executable('node_modules/.bin/eslint') > 0 then
          require('lint').linters_by_ft = {
            javascript = {'eslint'},
            typescript = {'eslint'},
          }
          require("lint").try_lint()
        end
      end,
    })
  end
}
