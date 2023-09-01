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
        vim.keymap.set('n', 'gtD', vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set('n', 'grf', vim.lsp.buf.references, bufopts)
        vim.keymap.set('n', '<space>p', vim.lsp.buf.format, bufopts)
      end
      nvim_lsp[server_name].setup(opts)
    end
    })

    -- local opts = { noremap=true, silent=true }
    -- vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
    -- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    -- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    -- keyboard shortcut
    -- vim.keymap.set('n', 'K',  '<cmd>lua vim.lsp.buf.hover()<CR>')
    -- vim.keymap.set("n", "gf", "<cmd>lua vim.lsp.buf.formatting()<CR>")
    -- vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
    -- vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
    -- vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
    -- vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
    -- vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
    -- vim.keymap.set("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
    -- vim.keymap.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>")
    -- vim.keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>')
    -- vim.keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
    -- LSP handlers
    -- vim.lsp.handlers["textDocument/publishDiagnostics"] =
    --     vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = true })
  end,
}
