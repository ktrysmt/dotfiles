local function claude_send_focus()
  vim.cmd("ClaudeCodeSend")
  vim.defer_fn(function()
    vim.cmd("ClaudeCodeFocus")
  end, 170)
end

return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    port_range = { min = 10000, max = 65535 },
    auto_start = true,
    log_level = "info",
    terminal_cmd = nil,
    track_selection = true,
    visual_demotion_delay_ms = 50,
    -- terminal = {
    --   split_side = "right",
    --   split_width_percentage = 0.40,
    --   provider = "auto",
    --   auto_close = true,
    --   snacks_win_opts = {},
    --   provider_opts = {
    --     external_terminal_cmd = nil,
    --   },
    -- },
    terminal = {
      ---@module "snacks"
      ---@type snacks.win.Config|{}
      snacks_win_opts = {
        width = 90,
        keys = {
          claude_hide = {
            "<leader>cc",
            function(self)
              self:hide()
            end,
            mode = "t",
            desc = "Hide",
          },
        },
      },
    },
    diff_opts = {
      auto_close_on_accept = true,
      vertical_split = true,
      open_in_current_tab = true,
      keep_terminal_focus = false,
    },
  },
  keys = {
    { "<leader>cc",  "<cmd>ClaudeCode<cr>", },
    { "<leader>ca",  "<cmd>ClaudeCodeAdd %<cr><cmd>ClaudeCodeFocus<cr>", mode = "n" },
    { "<leader>ca",  claude_send_focus,                                  mode = "v" },
    { "<leader>cda", "<cmd>ClaudeCodeDiffAccept<cr>", },
    { "<leader>cdd", "<cmd>ClaudeCodeDiffDeny<cr>", },
  }
}
