return {
  "ktrysmt/memd.nvim",
  event = "VeryLazy",
  config = function()
    require('memd').setup()
  end,
}
