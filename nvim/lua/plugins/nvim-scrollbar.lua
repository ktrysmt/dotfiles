return {
  'petertriho/nvim-scrollbar',
  event = { "VeryLazy" },
  -- keys = {
  --   { "#", mode = "n" },
  --   { "n", mode = "n" },
  --   { "N", mode = "n" },
  --   { "*", mode = "n" },
  --   { "/", mode = "n" },
  -- },
  dependencies = {
    {
      "kevinhwang91/nvim-hlslens",
      config = function()
        require("scrollbar.handlers.search").setup({
          override_lens = function() end,
        })
      end
    }
  },
  config = function()
    require("scrollbar").setup({
      excluded_buftypes = {
        'nofile', -- to disable in floating windows
      },
      excluded_filetypes = {
        "cmp_docs",
        "cmp_menu",
        "noice",
        "prompt",
        "fern",
        "TelescopePrompt",
      },
      set_highlights = false,
      handlers = {
        cursor = true,
        diagnostic = false,
        handle = true,
        search = true,
      },
    })
  end
}
