return {
  "gbprod/yanky.nvim",
  keys = {
    { "<leader>y", mode = "n" },
    { "<c-n>",     mode = "n" },
    { "<c-p>",     mode = "n" },
    { "y",         mode = { "n", "v" } },
    { "p",         mode = { "n", "v" } },
    { "P",         mode = { "n", "v" } },
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
        sync_with_numbered_registers = true,
      },
      system_clipboard = {
        sync_with_ring = true,
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
    vim.keymap.set("n", "<c-n>", "<Plug>(YankyCycleForward)")
    vim.keymap.set("n", "<c-p>", "<Plug>(YankyCycleBackward)")
    vim.keymap.set({ "n", "x" }, "y", "<Plug>(YankyYank)")
    vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
    vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")

    require("dressing").setup({
      input = {
        enabled = false,
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
