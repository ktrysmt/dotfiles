return {
  "sourcegraph/sg.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cond = vim.env.SRC_ACCESS_TOKEN,
  event = { "LspAttach", "CursorHold", "CursorMoved", "ModeChanged", "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
  keys = {
    { "<leader>cc", mode = "n" },
    { "<leader>ct", mode = "v" },
    { "<leader>ca", mode = "v" },
    { "<leader>ce", mode = "v" },
  },
  config = function()
    require("sg").setup()
    vim.keymap.set("n", "<leader>cc", ":<C-u>CodyToggle<CR>", { silent = true })
    vim.keymap.set("v", "<leader>ct", ":CodyTask ")
    vim.keymap.set("v", "<leader>ca", ":CodyAsk ")
    vim.keymap.set("v", "<leader>ce", ":CodyExplain<CR>")
    vim.keymap.set("n", "<leader>ct", ":CodyTask ", { silent = true })
  end
}
