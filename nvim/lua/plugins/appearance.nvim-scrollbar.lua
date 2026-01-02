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
    require("scrollbar").setup({ handlers = { search = true } })
    require("scrollbar.handlers.search").setup({
      override_lens = function() end,
    })

    vim.cmd [[
    :hi ScrollbarSearchHandle guifg=gray
    :hi ScrollbarSearch guifg=gray
    ]]
  end,
}
