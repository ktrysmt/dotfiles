return {
  'kiddos/gemini.nvim',
  event = { "CursorHold", "CursorMoved", "ModeChanged", "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
  cond = function()
    return not vim.env.GEMINI_API_KEY
  end,
  config = function()
    local api = require('gemini.api')

    require('gemini').setup({
      model_config = {
        completion_delay = 1000,
        model_id = api.MODELS.GEMINI_2_0_FLASH,
        temperature = 0.2,
        top_k = 20,
        max_output_tokens = 8196,
        response_mime_type = 'text/plain',
      },
      completion = {
        move_cursor_end = true
      },
      instruction = {
        enabled = true,
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
}
