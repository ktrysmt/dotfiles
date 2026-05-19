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

    local function sync_system_clipboard_to_ring()
      local utils = require("yanky.utils")
      local history = require("yanky.history")
      local reg_info = utils.get_register_info(utils.get_default_register())
      if not reg_info or not reg_info.regcontents or reg_info.regcontents == "" then
        return
      end
      local first = history.first()
      if not first or not vim.deep_equal(first, reg_info) then
        history.push(reg_info)
      end
    end

    vim.keymap.set({ "n" }, "<leader>y", "<cmd>YankyRingHistory<cr>", { silent = true })
    vim.keymap.set({ "n" }, "<c-n>", "<Plug>(YankyCycleForward)")
    vim.keymap.set({ "n" }, "<c-p>", "<Plug>(YankyCycleBackward)")

    vim.keymap.set({ "n", "v" }, "y", "<Plug>(YankyYank)")
    vim.keymap.set({ "n", "v" }, "p", function()
      sync_system_clipboard_to_ring()
      return "<Plug>(YankyPutAfter)"
    end, { expr = true, remap = true })
    vim.keymap.set({ "n", "v" }, "P", function()
      sync_system_clipboard_to_ring()
      return "<Plug>(YankyPutBefore)"
    end, { expr = true, remap = true })
    -- vim.keymap.set({ "n", "v" }, "p", "<Plug>(YankyGPutAfter)")
    -- vim.keymap.set({ "n", "v" }, "P", "<Plug>(YankyGPutBefore)")
    -- vim.keymap.set({ "n", "v" }, "gp", "<Plug>(YankyGPutAfter)")
    -- vim.keymap.set({ "n", "v" }, "gP", "<Plug>(YankyGPutBefore)")

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
