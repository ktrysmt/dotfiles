return {
  'kiddos/gemini.nvim',
  event = { "VeryLazy" },
  config = function()
    local gemini_api_key = vim.fn.getenv("GEMINI_API_KEY")
    if gemini_api_key then
      require('gemini').setup({
        completion = {
          move_cursor_end = true
        },
        instruction = {
          enabled = true,
          menu_key = '<C-o>',
          prompts = {
            {
              name = 'Code Review',
              command_name = 'GeminiCodeReview',
              menu = 'Code Review 📜',
              get_prompt = function(lines, bufnr)
                local code = vim.fn.join(lines, '\n')
                local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
                local prompt = 'Context:\n\n```%s\n%s\n```\n\n'
                    .. '目的: 以下のコードに対して徹底的なコードレビューを行ってください。\n'
                    .. '詳細な説明と率直なコメントを提供してください。\n'
                return string.format(prompt, filetype, code)
              end,
            },
            {
              name = 'Code Explain',
              command_name = 'GeminiCodeExplain',
              menu = 'Code Explain',
              get_prompt = function(lines, bufnr)
                local code = vim.fn.join(lines, '\n')
                local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
                local prompt = 'Context:\n\n```%s\n%s\n```\n\n'
                    .. '目的: 以下のコードを説明してください。\n'
                    .. '詳細な説明と率直なコメントを提供してください。\n'
                return string.format(prompt, filetype, code)
              end,
            },
          },
        },
      })
    end
  end
}
