return {
  'petertriho/nvim-scrollbar',
  event = { "VeryLazy" },
  dependencies = {
    {
      'kevinhwang91/nvim-hlslens',
    },
  },
  config = function()
    require("hlslens").setup()
    require("scrollbar").setup({
      excluded_buftypes = {
        'nofile',
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
        search = true,
      },
    })
    require("scrollbar.handlers.search").setup({
      override_lens = function() end,
    })

    vim.cmd [[
    :hi ScrollbarSearchHandle guifg=gray
    :hi ScrollbarSearch guifg=gray
    ]]
  end,
}
