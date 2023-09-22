return {
  "sindrets/diffview.nvim",
  cmd = {
    "DiffviewClose",
    "DiffviewFileHistory",
    "DiffviewFocusFiles",
    "DiffviewLog",
    "DiffviewOpen",
    "DiffviewRefresh",
    "DiffviewToggleFiles",
  },
  -- keys = {
  --   { "<Leader>gv", "<cmd>DiffviewOpen<cr>",        mode = "n" },
  --   { "<Leader>gh", "<cmd>DiffviewFileHistory<cr>", mode = "n" },
  -- },
  config = function()
    require("diffview").setup({
      file_history_panel = {
        win_config = { -- See ':h diffview-config-win_config'
          position = "left",
        },
      },
    })
  end
}
