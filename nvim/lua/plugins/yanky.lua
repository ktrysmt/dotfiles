return  {
  "gbprod/yanky.nvim",
  event = { "VeryLazy" },
  -- keys = {
  --   { "<leader>y" }
  -- },
  dependencies = {
    "stevearc/dressing.nvim",
  },
  config = function()

    require("yanky").setup({
      ring = {
        history_length = 500,
      },
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 50,
      },
      preserve_cursor_position = {
        enabled = true,
      },
    })

    vim.keymap.set({"n","x"}, "y", "<Plug>(YankyYank)")
    vim.keymap.set("n", "<c-n>", "<Plug>(YankyCycleForward)")
    vim.keymap.set("n", "<c-p>", "<Plug>(YankyCycleBackward)")
    vim.keymap.set({"n","x"}, "p", "<Plug>(YankyPutAfter)")
    vim.keymap.set({"n","x"}, "P", "<Plug>(YankyPutBefore)")
    vim.keymap.set({"n","x"}, "gp", "<Plug>(YankyGPutAfter)")
    vim.keymap.set({"n","x"}, "gP", "<Plug>(YankyGPutBefore)")

    require("dressing").setup({
      input = {
        mappings = {
          n = {
            ["<Esc>"] = "Close",
            ["<CR>"] = "Confirm",
          },
          i = {
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
        backend = { "fzf_lua", "builtin" },
        fzf_lua = {
          winopts = {
            height = 0.5,
            width = 0.99,
          },
        },
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
