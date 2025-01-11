return {
  "huggingface/llm.nvim",
  cmd = { "LLMSuggestion", "LLMToggleAutoSuggest" },
  event = "InsertEnter",
  config = function()
    local ollama_host = vim.fn.getenv("OLLAMA_HOST")
    local ollama_model = vim.fn.getenv("OLLAMA_MODEL")
    require("llm").setup({
      api_token = "api_token",
      models = {
        default = {
          type = ollama_model
        }
      },
      backend = "openai",
      url = "http://" .. (ollama_host or "localhost") .. ":11434",
      request_body = {
        parameters = {
          temperature = 0.2,
          top_p = 0.95,
        },
      },
      accept_keymap = "<M-n>",
      dismiss_keymap = "<S-M-n>",
      tls_skip_verify_insecure = true,
      context_window = 128000,
      enable_suggestions_on_startup = true,
      enable_suggestions_on_files = "*",
      disable_url_path_completion = false,
    })
  end
}
