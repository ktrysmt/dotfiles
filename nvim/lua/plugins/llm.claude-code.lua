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

    require("claude-code").setup()
  end
}
