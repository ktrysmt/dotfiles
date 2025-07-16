return {
  'numToStr/Comment.nvim',
  keys = {
    { 'gcc', mode = { "n", "v" } },
    { 'gb',  mode = { "v" } },
  },
  config = function()
    require('Comment').setup()
  end
}
