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

      -- Check if Ollama is running
      local ollama_running = vim.fn.system("pgrep -x ollama")

      if ollama_running then
        -- Use Ollama with Claude mode
        -- `ollama launch claude --model qwen3-coder-next` で起動した場合
        -- APIは http://localhost:11434/v1 で、モデル名は qwen3-coder-next
        env_vars = {
          ANTHROPIC_AUTH_TOKEN = "not-needed-for-ollama",
          ANTHROPIC_BASE_URL = "http://localhost:11434/v1",
          ANTHROPIC_DEFAULT_OPUS_MODEL = "qwen3-coder-next:cloud",
          ANTHROPIC_DEFAULT_SONNET_MODEL = "qwen3-coder-next:cloud",
          ANTHROPIC_DEFAULT_HAIKU_MODEL = "qwen3-coder-next:cloud",
        }
      elseif vim.env.ANTHROPIC_AUTH_TOKEN then
        -- Use Anthropic/OpenRouter
        env_vars = {
          ANTHROPIC_AUTH_TOKEN = vim.env.ANTHROPIC_AUTH_TOKEN,
          ANTHROPIC_BASE_URL = "https://openrouter.ai/api",
          -- ANTHROPIC_DEFAULT_OPUS_MODEL = "arcee-ai/trinity-large-preview:free",
          -- ANTHROPIC_DEFAULT_SONNET_MODEL = "arcee-ai/trinity-large-preview:free",
          -- ANTHROPIC_DEFAULT_HAIKU_MODEL = "arcee-ai/trinity-large-preview:free",
          ANTHROPIC_DEFAULT_OPUS_MODEL = "z-ai/glm-4.7",
          ANTHROPIC_DEFAULT_SONNET_MODEL = "z-ai/glm-4.7",
          ANTHROPIC_DEFAULT_HAIKU_MODEL = "arcee-ai/trinity-large-preview:free",
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
      vim.keymap.set("n", "<leader>cda", "<cmd>ClaudeCodeDiffAccept<cr>")
      vim.keymap.set("n", "<leader>cdd", "<cmd>ClaudeCodeDiffDeny<cr>")
    end
  }
}
