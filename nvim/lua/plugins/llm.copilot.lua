return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  cond = not vim.env.SRC_ACCESS_TOKEN,
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = "<M-n>",
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
