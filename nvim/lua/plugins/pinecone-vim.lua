return {
  'ktrysmt/pinecone-vim',
  event = "VimEnter",
  priority = 1000,
  config = function()
    vim.cmd.colorscheme "pinecone"
  end,
}
