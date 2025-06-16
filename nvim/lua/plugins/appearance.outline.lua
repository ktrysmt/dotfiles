return {
  "hedyhli/outline.nvim",
  keys = {
    { "<leader>a", mode = "n" }
  },
  dependencies = {
    'epheien/outline-treesitter-provider.nvim',
    'epheien/outline-ctags-provider.nvim'
  },
  config = function()
    -- Example mapping to toggle outline
    vim.keymap.set("n", "<leader>a", "<cmd>belowright Outline<CR>",
      { desc = "Toggle Outline" })

    require("outline").setup {
      -- Your setup opts here (leave empty to use defaults)
      symbols = {
        icon_fetcher = function(kind, bufnr, symbol) return kind:sub(1, 1) end,
      },
      symbol_folding = {
        autofold_depth = 3,
        auto_unfold = {
          hovered = true,
        },
      },
      providers = {
        priority = { 'lsp', 'markdown', 'norg', 'man', 'treesitter', 'ctags' },
      },
      ctags = {
        program = 'ctags',
        filetypes = {
          ['c++'] = {
            scope_sep = '::',
            kinds = {
              alias = 'TypeAlias',
              ['local'] = 'Variable',
              typedef = 'TypeAlias',
              enumerator = 'Enum',
            },
          },
          ['json'] = {
            scope_sep = ':',
            kinds = {}
          },
          ['yaml.ansible'] = {
            scope_sep = ':',
            kinds = {}
          },
        },
      },
    }
  end
}
