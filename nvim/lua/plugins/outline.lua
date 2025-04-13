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
    }
  end
}
