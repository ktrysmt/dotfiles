return {
  'iberianpig/tig-explorer.vim',
  keys = {
    { "<Leader>gi", mode = "n" }
  },
  event = { 'CmdlineEnter', 'CmdwinEnter' },
  config = function()
    local o = { silent = true }
    vim.keymap.set("n", "<Leader>gi", ":TigOpenCurrentFile<cr>", o)
  end
}
