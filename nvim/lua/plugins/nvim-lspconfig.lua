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
      {
        "williamboman/mason-lspconfig.nvim",
        "weilbith/nvim-lsp-smag",
      },
    },
    config = function()
      local lspconfig = require('lspconfig')
      local mason_lspconfig = require("mason-lspconfig")

      mason_lspconfig.setup({
        automatic_installation = true
      })

      mason_lspconfig.setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({})
        end,
      })

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
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

        for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
          vim.api.nvim_set_hl(0, group, {})
        end
      end

      local lspconfig_group = vim.api.nvim_create_augroup('lspconfig_group', { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = lspconfig_group,
        callback = init_lspconfig,
      })

      -- https://www.reddit.com/r/neovim/comments/11q17mq/comment/jc13v1o/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
      --
      -- lspconfig.rust_analyzer.setup {
      --   settings = {
      --     ['rust-analyzer'] = {
      --       textDocument = {
      --         inlayHint = {
      --           typeHints = {
      --             dynamicRegistration = false,
      --             resolveSupport = {
      --               properties = { "command" }
      --             }
      --           }
      --         }
      --       }
      --     },
      --   },
      -- }
    end,
  },
}
