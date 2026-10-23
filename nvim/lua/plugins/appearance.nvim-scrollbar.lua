return {
  'petertriho/nvim-scrollbar',
  -- TODO: remove after 2026-11-16, when v2 replaces v1 on main (petertriho/nvim-scrollbar#121)
  branch = "refactor/v2",
  event = { "VeryLazy" },
  config = function()
    require("scrollbar").setup({
      exclude = {
        buftypes = {
          'nofile',
        },
        filetypes = {
          "cmp_docs",
          "cmp_menu",
          "prompt",
        },
      },
      set_highlights = true,
      marks = {
        Search = { highlight = { fg = "gray" } },
      },
    })
  end,
}
