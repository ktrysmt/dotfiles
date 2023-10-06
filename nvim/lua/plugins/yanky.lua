return {
  "gbprod/yanky.nvim",
  keys = {
    { "<leader>y", mode = "n" },
    { "<c-n>",     mode = "n" },
    { "<c-p>",     mode = "n" },
    { "y",         mode = { "n", "v" } },
    { "p",         mode = { "n", "v" } },
    { "P",         mode = { "n", "v" } },
    { "gp",        mode = { "n", "v" } },
    { "gP",        mode = { "n", "v" } },
  },
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

    vim.keymap.set({ "n" }, "<leader>y", "<cmd>YankyRingHistory<cr>", { silent = true })
    vim.keymap.set({ "n" }, "<c-n>", "<Plug>(YankyCycleForward)")
    vim.keymap.set({ "n" }, "<c-p>", "<Plug>(YankyCycleBackward)")

    vim.keymap.set({ "n", "v" }, "y", "<Plug>(YankyYank)")
    vim.keymap.set({ "n", "v" }, "p", "<Plug>(YankyPutAfter)")
    vim.keymap.set({ "n", "v" }, "P", "<Plug>(YankyPutBefore)")
    vim.keymap.set({ "n", "v" }, "gp", "<Plug>(YankyGPutAfter)")
    vim.keymap.set({ "n", "v" }, "gP", "<Plug>(YankyGPutBefore)")

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
