return {
  'terrortylor/nvim-comment',
  keys = {
    'gcc',
  },
  config = function()
    require('nvim_comment').setup()
  end
}
