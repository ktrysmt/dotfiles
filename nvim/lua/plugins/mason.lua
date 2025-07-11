return {
  {
    'williamboman/mason.nvim',
    cmd = {
      "Mason",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
      "MasonUpdate",
    },
    opts = {
      ui = {
        check_outdated_packages_on_open = true,
        icons = {
          package_installed = "✓",
          package_uninstalled = "✗",
          package_pending = "⟳",
        },
      },
    },
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    cmd = {
      "MasonToolsInstall",
      "MasonToolsUpdate",
    },
    config = function()
      local mason_tool_installer = require('mason-tool-installer')
      mason_tool_installer.setup({
        ensure_installed = {
          'bash-language-server',
          'clangd',
          'dockerfile-language-server',
          'golangci-lint',
          'gomodifytags',
          'gopls',
          'gotests',
          'impl',
          'json-to-struct',
          'lua-language-server',
          'lua-language-server',
          'misspell',
          'python-lsp-server',
          'revive',
          'rust-analyzer',
          'shellcheck',
          'shellcheck',
          'shfmt',
          'staticcheck',
          'stylua',
          'svelte-language-server',
          'terraform',
          'typescript-language-server',
          'typos-lsp',
          'vim-language-server',
          'vint',
        },
      })
    end
  }
}
