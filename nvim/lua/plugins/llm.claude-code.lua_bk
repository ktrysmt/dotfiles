return {
  "greggh/claude-code.nvim",
  cmd = { "ClaudeCode" },
  keys = {
    { "<leader>cc", mode = "n" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for git operations
  },
  config = function()
    -- keymap
    vim.keymap.set('n', '<leader>cc', '<cmd>ClaudeCode<CR>', { desc = 'Toggle Claude Code' })

    require("claude-code").setup({
      -- Terminal window settings
      window = {
        split_ratio = 0.3,              -- Percentage of screen for the terminal window (height or width)
        position = "rightbelow vsplit", -- Position of the window: "botright", "topleft", "vertical", "vsplit", etc.
        enter_insert = true,            -- Whether to enter insert mode when opening Claude Code
        start_in_normal_mode = false,   -- Whether to start in normal mode instead of insert mode
        hide_numbers = true,            -- Hide line numbers in the terminal window
        hide_signcolumn = true,         -- Hide the sign column in the terminal window
      },
      -- File refresh settings
      refresh = {
        enable = true,             -- Enable file change detection
        updatetime = 100,          -- updatetime when Claude Code is active (milliseconds)
        timer_interval = 1000,     -- How often to check for file changes (milliseconds)
        show_notifications = true, -- Show notification when files are reloaded
      },
      -- Git project settings
      git = {
        use_git_root = true, -- Set CWD to git root when opening Claude Code (if in git project)
      },
      -- Command settings
      command = "claude", -- Command used to launch Claude Code (do not include --cwd)
      -- Command variants
      command_variants = {
        -- Conversation management
        continue = "--continue", -- Resume the most recent conversation
        resume = "--resume",     -- Display an interactive conversation picker

        -- Output options
        verbose = "--verbose", -- Enable verbose logging with full turn-by-turn output
      },
      -- Keymaps
      keymaps = {
        toggle = {
          normal = "<leader>ac",     -- Normal mode keymap for toggling Claude Code
          terminal = "<C-o>",        -- Terminal mode keymap for toggling Claude Code
          variants = {
            continue = "<leader>cC", -- Normal mode keymap for Claude Code with continue flag
            verbose = "<leader>cV",  -- Normal mode keymap for Claude Code with verbose flag
          },
        },
        window_navigation = false,
        scrolling = false,
      }
    })
  end
}
