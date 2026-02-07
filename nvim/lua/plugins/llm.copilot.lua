return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  dependencies = {
    "copilotlsp-nvim/copilot-lsp",
  },
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        auto_trigger = true,
        hide_during_completion = false,
        keymap = {
          accept = "<S-Tab>",
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
