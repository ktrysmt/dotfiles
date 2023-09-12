return {
  'terrortylor/nvim-comment',
  keys = {
    { 'gcc', mode = { "n", "v" } }
  },
  config = function()
    require('nvim_comment').setup()
  end
}
