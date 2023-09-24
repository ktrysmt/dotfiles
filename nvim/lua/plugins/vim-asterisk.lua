return {
  'haya14busa/vim-asterisk',
  keys = {
    { "#",  mode = "n" },
    { "*",  mode = "n" },
    { "n",  mode = "n" },
    { "N",  mode = "n" },
    { "g#", mode = "n" },
    { "g*", mode = "n" },
  },
  config = function()
    vim.cmd [[
      let g:asterisk#keeppos = 1

      map #  <Plug>(asterisk-z*)
      map *  <Plug>(asterisk-z#)
      map g# <Plug>(asterisk-gz*)
      map g* <Plug>(asterisk-gz#)
    ]]
  end
}
