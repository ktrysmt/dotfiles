return {
  "coder/claudecode.nvim",
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
      auto_start = false,
      log_level = "info",
      terminal_cmd = nil,
      track_selection = true,
      visual_demotion_delay_ms = 50,
      terminal = {
        split_side = "right",
        split_width_percentage = 0.30,
        provider = "auto",
        auto_close = false,
        provider_opts = {
          external_terminal_cmd = nil,
        },
      },
      diff_opts = {
        auto_close_on_accept = false,
        vertical_split = false,
        open_in_current_tab = false,
        keep_terminal_focus = false,
      },
    })

    local function is_claude_code_buffer()
      local buffers = vim.api.nvim_list_bufs()
      for _, buf in ipairs(buffers) do
        if vim.api.nvim_buf_is_loaded(buf) then
          local name = vim.api.nvim_buf_get_name(buf)
          if name:match("bin/claude$") then
            return true
          end
        end
      end
    end

    local function claude_send_path_then_focus()
      if is_claude_code_buffer() then
        vim.cmd("ClaudeCodeAdd %")
        vim.cmd("ClaudeCodeFocus")
      else
        vim.cmd("ClaudeCodeStart")
        vim.cmd("ClaudeCodeAdd %")
      end
    end

    local function claude_add_selected_buffer_then_focus()
      vim.cmd("ClaudeCodeSend")
      vim.defer_fn(function()
        vim.cmd("ClaudeCodeFocus")
      end, 150)
    end

    vim.keymap.set("n", "<leader>cc", "<cmd>ClaudeCode<cr>")
    vim.keymap.set("n", "<leader>ca", claude_send_path_then_focus)
    vim.keymap.set("v", "<leader>ca", claude_add_selected_buffer_then_focus)
    vim.keymap.set("n", "<leader>cda", "<cmd>ClaudeCodeDiffAccept<cr>")
    vim.keymap.set("n", "<leader>cdd", "<cmd>ClaudeCodeDiffDeny<cr>")
  end
}
