return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = "<M-j>",
          accept_word = "<S-M-j>",
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
