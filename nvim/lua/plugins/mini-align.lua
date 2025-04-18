return {
  "echasnovski/mini.align",
  keys = {
    { mode = { "n", "v", "x" }, "<Leader>l" },
  },
  config = function()
    require("mini.align").setup({
      mappings = {
        start = "<Leader>l",
        start_with_preview = "<Leader>lp",
        stop = "<Leader>ls",
        repeat_last = "<Leader>lr",
      },
      preview = {
        delay = 0,
        win_config = {
          relative = "cursor",
          row = 1,
          col = 0,
          width = 40,
          height = 1,
          style = "minimal",
        },
      },
    })
  end
}
