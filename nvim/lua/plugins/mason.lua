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
          'golangci-lint',
          'bash-language-server',
          'pylsp',
          'lua-language-server',
          'vim-language-server',
          'typos-lsp',
          'gopls',
          'typescript-language-server',
          'rust-analyzer',
          'stylua',
          'shellcheck',
          'dockerfile-language-server',
          'gomodifytags',
          'gotests',
          'impl',
          'svelte-language-server',
          'lua-language-server',
          'json-to-struct',
          'misspell',
          'revive',
          'shellcheck',
          'shfmt',
          'staticcheck',
          'vint',
          'clangd',
        },
      })
    end
  }
}
