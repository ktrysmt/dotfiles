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

      local function get_installed_servers()
        local servers = {}
        for _, s in ipairs(mason_lspconfig.get_installed_servers()) do
          if s ~= "pylsp" and s ~= "lua_ls" and s ~= "gopls" then
            table.insert(servers, s)
          end
        end
        return servers
      end
      vim.lsp.enable(get_installed_servers())

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
        local function jump_to_definition()
          vim.lsp.buf.definition({ on_list = on_list })
        end
        vim.keymap.set('n', 'gv', jump_to_definition_vsplit, opts)
        vim.keymap.set('n', 'gd', jump_to_definition, opts)
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

      local lspconfig_group = vim.api.nvim_create_augroup('lspconfig_group', { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = lspconfig_group,
        callback = init_lspconfig,
      })

      -- https://rust-analyzer.github.io/book/other_editors.html#nvim-lsp
      -- lspconfig.rust_analyzer.setup({
      --   on_attach = function(client, bufnr)
      --     -- vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      --   end
      -- })

      -- https://github.com/neovim/nvim-lspconfig
      lspconfig.rust_analyzer.setup {
        settings = {
          ['rust-analyzer'] = {},
        },
      }
      lspconfig.pylsp.setup {
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = {
                ignore = { 'E501', 'E241' }, -- This is the Error code for line too long.
                maxLineLength = 200          -- This sets how long the line is allowed to be. Also has effect on formatter.
              },
            },
          },
        },
      }
      lspconfig.lua_ls.setup {
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' }
            }
          }
        }
      }
      lspconfig.gopls.setup {
        settings = {
          gopls = {
            staticcheck = true,
          }
        }
      }

      -- https://www.reddit.com/r/neovim/comments/11q17mq/comment/jc13v1o/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
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
