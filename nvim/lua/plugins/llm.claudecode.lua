return {
  {
    "coder/claudecode.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- "CursorHold", "CursorMoved", "ModeChanged", "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
    keys = {
      { "<leader>cc" },
      { "<leader>ca" },
      { "<leader>cda" },
      { "<leader>cdd" },
    },
    config = function()
      local env_vars = nil

      if vim.env.FALLBACK then
        vim.env.ANTHROPIC_API_KEY = nil
        local ollama_running = vim.fn.system("pgrep -f 'ollama serve'")
        if ollama_running ~= "" then
          env_vars = {
            ANTHROPIC_AUTH_TOKEN = "ollama",
            ANTHROPIC_BASE_URL = "http://localhost:11434",
            ANTHROPIC_MODEL = vim.env.FALLBACK_OLLAMA_MEDIUM_MODEL, -- "qwen3-coder-next:cloud",
            ANTHROPIC_DEFAULT_OPUS_MODEL = vim.env.FALLBACK_OLLAMA_MEDIUM_MODEL,
            ANTHROPIC_DEFAULT_SONNET_MODEL = vim.env.FALLBACK_OLLAMA_MEDIUM_MODEL,
            ANTHROPIC_DEFAULT_HAIKU_MODEL = vim.env.FALLBACK_OLLAMA_SMALL_MODEL,
          }
        elseif vim.env.FALLBACK_OPENROUTER_TOKEN then
          env_vars = {
            ANTHROPIC_AUTH_TOKEN = vim.env.FALLBACK_OPENROUTER_TOKEN,
            ANTHROPIC_BASE_URL = "https://openrouter.ai/api",
            ANTHROPIC_MODEL = vim.env.FALLBACK_OPENROUTER_MEDIUM_MODEL,
            ANTHROPIC_DEFAULT_OPUS_MODEL = vim.env.FALLBACK_OPENROUTER_MEDIUM_MODEL,
            ANTHROPIC_DEFAULT_SONNET_MODEL = vim.env.FALLBACK_OPENROUTER_MEDIUM_MODEL,
            ANTHROPIC_DEFAULT_HAIKU_MODEL = vim.env.FALLBACK_OPENROUTER_SMALL_MODEL,
          }
        end
      else
        env_vars = {
          ANTHROPIC_AUTH_TOKEN = ""
        }
      end

      require("claudecode").setup({
        port_range = { min = 10000, max = 65535 },
        auto_start = true,
        log_level = "info",
        terminal_cmd = nil,
        focus_after_send = true,
        track_selection = true,
        visual_demotion_delay_ms = 5,
        env = env_vars,
        terminal = {
          split_side = "right",
          split_width_percentage = 0.33,
          provider = "native",
          auto_close = true,
          provider_opts = {
            external_terminal_cmd = nil,
          },
        },
        diff_opts = {
          auto_close_on_accept = true,
          vertical_split = false,
          open_in_current_tab = false,
          keep_terminal_focus = true,
        },
      })

      vim.keymap.set("n", "<leader>cc", "<cmd>ClaudeCode<cr>")
      vim.keymap.set("n", "<leader>ca", "<cmd>ClaudeCodeAdd %<cr>")
      vim.keymap.set("v", "<leader>ca", "<cmd>ClaudeCodeSend<cr>")
      vim.keymap.set("n", "<leader>cf", "<cmd>ClaudeCodeFocus<cr>")
      vim.keymap.set("n", "<leader>cda", "<cmd>ClaudeCodeDiffAccept<cr>")
      vim.keymap.set("n", "<leader>cdd", "<cmd>ClaudeCodeDiffDeny<cr>")
    end
  }
}
