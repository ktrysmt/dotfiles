return {
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  cmd = {
    "MasonToolsInstall",
    "MasonToolsUpdate",
  },
  config = function()
    local mason_tool_installer = require('mason-tool-installer')
    mason_tool_installer.setup({
      ensure_installed = {
        'golangci-lint',
        'bash-language-server',
        'pylsp',
        'lua-language-server',
        'vim-language-server',
        'gopls',
        'stylua',
        'shellcheck',
        'dockerfile-language-server',
        'gofumpt',
        'golines',
        'gomodifytags',
        'gotests',
        'impl',
        'lua-language-server',
        'json-to-struct',
        'misspell',
        'revive',
        'shellcheck',
        'shfmt',
        'staticcheck',
        'vint',
      },
    })
  end
}
