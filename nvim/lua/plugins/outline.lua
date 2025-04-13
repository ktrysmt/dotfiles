return {
  "hedyhli/outline.nvim",
  keys = {
    { "<leader>a", mode = "n" }
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
    }
  end
}
