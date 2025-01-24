return {
  "Kurama622/llm.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
  cmd = { "LLMSessionToggle", "LLMSelectedTextHandler" },
  keys = {
    { "<leader>ac", mode = "n", "<cmd>LLMSessionToggle<cr>" },
    { "<leader>ae", mode = "v", "<cmd>LLMSelectedTextHandler 请解释下面这段代码<cr>" },
    { "<leader>t", mode = "x", "<cmd>LLMSelectedTextHandler 英译汉<cr>" },
  },
  config = function()
    require("llm").setup({
      prompt = "You are a helpful javanese software engineer assistant.",

      prefix = {
        user = { text = "😃 ", hl = "Title" },
        assistant = { text = "⚡ ", hl = "Added" },
      },

      style = "float", -- right | left | above | below | float

      -- [[ Github Models ]]
      -- url = "https://models.inference.ai.azure.com/chat/completions",
      -- model = "gpt-4o",
      -- api_type = "openai",
      -- --[[ Optional: If you need to use models from different platforms simultaneously,
      -- you can configure the `fetch_key` to ensure that different models use different API Keys.]]
      -- fetch_key = function()
      --   return switch("enable_gpt")
      -- end,

      -- [[ cloudflare ]]
      -- model = "@cf/google/gemma-7b-it-lora",

      -- [[ ChatGLM ]]
      -- url = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
      -- model = "glm-4-flash",

      -- [[ kimi ]]
      -- url = "https://api.moonshot.cn/v1/chat/completions",
      -- model = "moonshot-v1-8k", -- "moonshot-v1-8k", "moonshot-v1-32k", "moonshot-v1-128k"
      -- api_type = "openai",

      -- [[ ollama ]]
      -- url = "http://localhost:11434/api/chat",
      -- model = "llama3.2:1b",
      -- api_type = "ollama",

      -- [[ siliconflow ]]
      -- url = "https://api.siliconflow.cn/v1/chat/completions",
      -- api_type = "openai",
      -- model = "Qwen/Qwen2.5-7B-Instruct",
      -- -- [optional: fetch_key]
      -- fetch_key = function()
      --   return switch("enable_siliconflow")
      -- end,

      -- [[ openrouter ]]
      -- url = "https://openrouter.ai/api/v1/chat/completions",
      -- model = "google/gemini-2.0-flash-exp:free",
      -- api_type = "openai",
      -- fetch_key = function()
      --   return switch("enable_openrouter")
      -- end,

      -- [[deepseek]]
      -- url = "https://api.deepseek.com/chat/completions",
      -- model = "deepseek-chat",
      -- api_type = "openai",
      -- fetch_key = function()
      --   return switch("enable_deepseek")
      -- end,
      --
      -- [[lm studio]]
      url = "http:/172.27.16.1:1234/v1/completions",
      model = "deepseek-v2-lite-chat-imat",
      api_type = "openai",

      max_tokens = 16240,
      save_session = true,
      max_history = 15,
      history_path = "/tmp/history", -- where to save history
      temperature = 0.3,
      top_p = 0.7,

      spinner = {
        text = {
          "󰧞󰧞",
          "󰧞󰧞",
          "󰧞󰧞",
          "󰧞󰧞",
        },
        hl = "Title",
      },

      display = {
        diff = {
          layout = "vertical",    -- vertical|horizontal split for default provider
          opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
          provider = "mini_diff", -- default|mini_diff
        },
      },

      -- stylua: ignore
      keys = {
        -- The keyboard mapping for the input window.
        ["Input:Cancel"]      = { mode = "n", key = "<C-c>" },
        ["Input:Submit"]      = { mode = "n", key = "<cr>" },
        ["Input:Resend"]      = { mode = "n", key = "<C-r>" },

        -- only works when "save_session = true"
        ["Input:HistoryNext"] = { mode = "n", key = "<C-j>" },
        ["Input:HistoryPrev"] = { mode = "n", key = "<C-k>" },

        -- The keyboard mapping for the output window in "split" style.
        ["Output:Ask"]        = { mode = "n", key = "i" },
        ["Output:Cancel"]     = { mode = "n", key = "<C-c>" },
        ["Output:Resend"]     = { mode = "n", key = "<C-r>" },

        -- The keyboard mapping for the output and input windows in "float" style.
        ["Session:Toggle"]    = { mode = "n", key = "<leader>ac" },
        ["Session:Close"]     = { mode = "n", key = "<esc>" },
      },
    })
  end,
}
