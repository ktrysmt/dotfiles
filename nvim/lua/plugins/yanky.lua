return {
  "gbprod/yanky.nvim",
  event = { "VeryLazy" },
  dependencies = {
    "stevearc/dressing.nvim",
    "kkharji/sqlite.lua",
  },
  config = function()
    require("yanky").setup({
      ring = {
        history_length = 500,
        storage = 'sqlite',
      },
      highlight = {
        on_put = false,
        on_yank = false,
      },
      preserve_cursor_position = {
        enabled = true,
      },
    })

    vim.keymap.set("n", "<leader>y", "<cmd>YankyRingHistory<cr>", { silent = true })

    vim.keymap.set({ "n", "x" }, "y", "<Plug>(YankyYank)")
    vim.keymap.set("n", "<c-n>", "<Plug>(YankyCycleForward)")
    vim.keymap.set("n", "<c-p>", "<Plug>(YankyCycleBackward)")
    vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
    vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
    vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
    vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")

    require("dressing").setup({
      input = {
        mappings = {
          n = {
            ["<Esc>"] = "Close",
            ["<CR>"] = "Confirm",
          },
          i = {
            ["<Esc>"] = "Close",
            ["<C-c>"] = "Close",
            ["<CR>"] = "Confirm",
            ["<Up>"] = "HistoryPrev",
            ["<C-k>"] = "HistoryPrev",
            ["<Down>"] = "HistoryNext",
            ["<C-j>"] = "HistoryNext",
          },
        },
      },
      select = {
        backend = { "builtin" },
        builtin = {
          win_options = {
            winblend = 0,
          },
          height = 50,
        },
      },
    })
  end
}
