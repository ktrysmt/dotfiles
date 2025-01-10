return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
  config = function()
    local ollama_host = vim.fn.getenv("OLLAMA_HOST")
    local gemini_api_key = vim.fn.getenv("GEMINI_API_KEY")

    require("codecompanion").setup({
      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              url = "http://" .. (ollama_host or "localhost") .. ":11434",
            },
            schema = {
              model = {
                default = "deepseek-coder-v2:16b",
              },
            },
          })
        end,
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            env = {
              api_key = gemini_api_key or "",
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "ollama",
          keymaps = {
            send = {
              modes = {
                i = { "<C-m>" },
                n = { "<C-m>" },
              },
            },
          },
        },
        inline = {
          adapter = "ollama",
        },
        agent = {
          adapter = "ollama",
        },
      },
    })
  end,
}
