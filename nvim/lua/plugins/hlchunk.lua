return {
  "shellRaining/hlchunk.nvim",
  -- event = { "BufReadPre", "BufNewFile" },
    event = { "CursorHold", "CursorMoved" },
  config = function()
    require("hlchunk").setup({
      chunk = {
        enable = true,
        style = {
          { fg = "#555555" }
        }
      },
      indent = {
        enable = false
      }
    })
  end
}
