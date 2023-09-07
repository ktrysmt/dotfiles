return {
  'AndrewRadev/linediff.vim',
  event = { "VeryLazy" },
  config = function()
    vim.cmd("vnoremap <Leader>li :Linediff<cr>")
  end
}
