return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  cond = function()
    return not vim.env.OPENROUTER_API_KEY
  end,
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = "<S-Tab>",
          -- accept = "<M-n>",
          accept_word = "<S-M-n>",
        }
      },
      filetypes = {
        text = false,
        markdown = false,
        ["*"] = true,
      },
    })
  end,
}
