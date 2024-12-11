return {
  'iberianpig/tig-explorer.vim',
  keys = {
    { "<Leader>gt", mode = "n" }
  },
  event = { 'CmdlineEnter', 'CmdwinEnter' },
  config = function()
    local o = { silent = true }
    vim.keymap.set("n", "<Leader>gt", ":TigOpenCurrentFile<cr>", o)
  end
}
