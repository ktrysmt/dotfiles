return {
  'kiddos/gemini.nvim',
  event = { "VeryLazy" },
  config = function()
    local gemini_api_key = vim.fn.getenv("GEMINI_API_KEY")
    if gemini_api_key then
      require('gemini').setup({
        completion = {
          move_cursor_end = true
        }
      })
    end
  end
}
