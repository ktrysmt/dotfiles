return {
  'petertriho/nvim-scrollbar',
  commit = "5b103ef0fd2e8b9b4be3878ed38d224522192c6c",
  event = { "VeryLazy" },
  dependencies = {
    {
      'kevinhwang91/nvim-hlslens',
      -- tag = "v1.1.0",
    },
  },
  config = function()
    -- これを先に呼ぶことでhlslens virtual text を無効化
    require("scrollbar.handlers.search").setup({
      override_lens = function() end,
    })

    require("scrollbar").setup({
      excluded_buftypes = {
        'nofile', -- to disable in floating windows
      },
      excluded_filetypes = {
        "cmp_docs",
        "cmp_menu",
        "prompt",
      },
      set_highlights = true,
      handlers = {
        cursor = true,
        diagnostic = true,
        handle = true,
        search = true, -- Requires hlslens
      },
    })

    vim.cmd [[
    :hi ScrollbarSearchHandle guifg=gray
    :hi ScrollbarSearch guifg=gray
    ]]
  end,
}
