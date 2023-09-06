return {
  "neovim/nvim-lspconfig",
  event = { "BufEnter" },
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

    local opts = { silent = true }
    vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

    mason_lspconfig.setup_handlers({ function(server_name)
      local opts = {}
      opts.on_attach = function(_, bufnr)
        local bufopts = { silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        vim.keymap.set('n', 'gvd', ':vsplit | lua vim.lsp.buf.definition()<CR>', bufopts)
      end
      nvim_lsp[server_name].setup(opts)
    end
    })


    require("mason").setup()
    require("mason-lspconfig").setup()

    require("mason-lspconfig").setup_handlers {
        -- The first entry (without a key) will be the default handler
        -- and will be called for each installed server that doesn't have
        -- a dedicated handler.
        function (server_name) -- default handler (optional)
            require("lspconfig")[server_name].setup {}
        end,
        -- Next, you can provide a dedicated handler for specific servers.
        -- For example, a handler override for the `rust_analyzer`:
        ["rust_analyzer"] = function ()
            require("rust-tools").setup {}
        end
    }


  end,
}
