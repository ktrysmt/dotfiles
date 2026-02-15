return {
  {
    "seblj/nvim-echo-diagnostics",
    event = { "CursorHold" },
    config = function()
      local echo_diagnostics = require("echo-diagnostics")

      echo_diagnostics.setup({
        show_diagnostic_number = true,
        show_diagnostic_source = true,
      })

      local echo_diagnostics_group = vim.api.nvim_create_augroup('echo_diagnostics_group', { clear = true })
      vim.api.nvim_create_autocmd("CursorHold", {
        pattern = "*",
        group = echo_diagnostics_group,
        callback = require('echo-diagnostics').echo_line_diagnostic,
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "weilbith/nvim-lsp-smag",
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
    },
    config = function()
      --
      -- diagnostics
      --
      vim.diagnostic.config({ virtual_text = false, float = false, severity_sort = true })
      local init_lspconfig = function(ev)
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
        local opts = { buffer = ev.buf }

        vim.keymap.set('n', 'gn', function()
          vim.diagnostic.goto_next({ float = false })
        end, opts)
        vim.keymap.set('n', 'gp', function()
          vim.cmd [[:normal k]]
          vim.diagnostic.goto_prev({ float = false })
        end, opts)

        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        local function on_list(options)
          vim.fn.setqflist({}, ' ', options)
          vim.cmd.cfirst()
        end
        local function jump_to_definition_vsplit()
          vim.cmd [[
          silent! vsplit
          silent! wincmd w
          ]]
          vim.lsp.buf.definition({ on_list = on_list })
        end
        -- local function jump_to_definition()
        --   vim.lsp.buf.definition({ on_list = on_list })
        -- end
        vim.keymap.set('n', 'gv', jump_to_definition_vsplit, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'I', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        -- vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', 'grn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, 'gca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

        for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
          vim.api.nvim_set_hl(0, group, {})
        end
      end

      --
      -- mason
      --
      local all_servers = {
        'bashls',
        'clangd',
        'dockerls',
        'gopls',
        'lua_ls',
        'pylsp',
        'rust_analyzer',
        'svelte',
        'typos_lsp',
        'vimls',
      }
      local mason_lspconfig = require("mason-lspconfig")
      mason_lspconfig.setup({
        ensure_installed = all_servers,
      })

      --
      -- lsp each config
      --
      -- rust
      vim.lsp.config('rust_analyzer', {
        settings = {
          ['rust-analyzer'] = {},
        },
      })
      vim.lsp.enable('rust_analyzer')

      -- python
      vim.lsp.config('pylsp', {
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = {
                ignore = { 'E501', 'E241' },
                maxLineLength = 200
              },
            },
          },
        },
      })
      vim.lsp.enable('pylsp')

      -- lua
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' }
            }
          }
        }
      })
      vim.lsp.enable('lua_ls')

      -- gopls
      vim.lsp.config('gopls', {
        settings = {
          gopls = {
            staticcheck = true,
          }
        }
      })
      vim.lsp.enable('gopls')

      -- other lsp
      vim.lsp.enable(all_servers)

      --
      -- attach it
      --
      local lspconfig_group = vim.api.nvim_create_augroup('lspconfig_group', { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = lspconfig_group,
        callback = init_lspconfig,
      })
    end,
  },
}
