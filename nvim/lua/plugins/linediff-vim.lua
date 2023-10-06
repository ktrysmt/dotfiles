return {
  'AndrewRadev/linediff.vim',
  keys = {
    { "<Leader>li", mode = "v" }
  },
  config = function()
    vim.cmd("vnoremap <Leader>li :Linediff<cr>")
  end
}
