return {
  'stevearc/aerial.nvim',
  keys = {
    { "<leader>a", mode = "n" }
  },
  config = function()
    require('aerial').setup({
      backends = { "treesitter", "lsp", "markdown", "man" },
      layout = {
        width = 50,
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr })
        vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr })
      end,
      filter_kind = {
        "Array",
        "Boolean",
        "Class",
        "Constant",
        "Constructor",
        "Enum",
        "EnumMember",
        "Event",
        "Field",
        "File",
        "Function",
        "Interface",
        "Key",
        "Method",
        "Module",
        "Namespace",
        "Null",
        "Number",
        "Object",
        "Operator",
        "Package",
        "Property",
        "String",
        "Struct",
        "TypeParameter",
        "Variable",
      },
    })
    vim.keymap.set('n', '<leader>a', '<cmd>AerialToggle<CR>')
  end
}
