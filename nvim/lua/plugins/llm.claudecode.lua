return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  event = { "CursorHold", "CursorMoved", "ModeChanged", "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
  keys = {
    { "<leader>cc" },
    { "<leader>ca" },
    { "<leader>ca", mode = "v" },
    { "<leader>cda" },
    { "<leader>cdd" },
  },
  config = function()
    require("claudecode").setup({
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
    })

    local function claude_send_focus()
      vim.cmd("ClaudeCodeSend")
      vim.defer_fn(function()
        vim.cmd("ClaudeCodeFocus")
      end, 170)
    end

    vim.keymap.set("n", "<leader>cc", "<cmd>ClaudeCode<cr>")
    vim.keymap.set("n", "<leader>ca", "<cmd>ClaudeCodeAdd %<cr><cmd>ClaudeCodeFocus<cr>")
    vim.keymap.set("v", "<leader>ca", claude_send_focus)
    vim.keymap.set("n", "<leader>cda", "<cmd>ClaudeCodeDiffAccept<cr>")
    vim.keymap.set("n", "<leader>cdd", "<cmd>ClaudeCodeDiffDeny<cr>")
  end
}
