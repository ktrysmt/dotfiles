return {
  'numToStr/Comment.nvim',
  keys = {
    { 'gcc', mode = { "n", "v" } },
    { 'gbc', mode = { "n", "v" } },
  },
  config = function()
    require('Comment').setup()
  end
}
