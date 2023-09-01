return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    {
      "williamboman/mason-lspconfig.nvim",
      -- cmd = { "LspInstall", "LspUninstall" },
      -- config = function()
      -- end,
    },
    {

    }
  },
  config = function()

    local nvim_lsp = require('lspconfig')
    local mason_lspconfig = require("mason-lspconfig")
    mason_lspconfig.setup({
      automatic_installation = true
    })

    mason_lspconfig.setup_handlers({ function(server_name)
      local opts = {}
      opts.on_attach = function(_, bufnr)
        local bufopts = { silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        vim.keymap.set('n', 'gdt', vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set('n', 'grf', vim.lsp.buf.references, bufopts)
      end
      nvim_lsp[server_name].setup(opts)
    end
    })

    local lsp_group = vim.api.nvim_create_augroup('lsp_group', { clear = true })
    vim.api.nvim_create_autocmd({'BufWritePre'}, {
      pattern = "*",
      group = lsp_group,
      callback = function()
        vim.lsp.buf.format()
      end,
    })

  end,
}
