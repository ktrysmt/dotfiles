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
  --   { "<Leader>gvo", "<cmd>DiffviewOpen<cr>",        mode = "n" },
  --   { "<Leader>gvc", "<cmd>DiffviewClose<cr>",       mode = "n" },
  --   { "<Leader>gvh", "<cmd>DiffviewFileHistory<cr>", mode = "n" },
  -- },
  config = function()
    require("diffview").setup({
      file_history_panel = {
        win_config = { -- See ':h diffview-config-win_config'
          position = "left",
        },
      },
    })
    vim.api.nvim_set_hl(0, 'DiffAdd',    { bg = '#252a1a' })
    vim.api.nvim_set_hl(0, 'DiffDelete', { bg = '#2d1a1a', fg = '#c47a6a' })
    vim.api.nvim_set_hl(0, 'DiffChange', { bg = '#1f1a10' })
    vim.api.nvim_set_hl(0, 'DiffText',   { bg = '#332c1c' })
  end
}
