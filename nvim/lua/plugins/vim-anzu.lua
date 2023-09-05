return {
  "osyo-manga/vim-anzu",
  keys = {
    { "n", mode = 'n' },
    { "N", mode = 'n' },
    { "#", mode = 'n' },
    { "*", mode = 'n' },
  },
  config = function()
     vim.o.statusline = "%{anzu#search_status()}"

     local opt = { remap = true }
     vim.keymap.set("n", "n", "<Plug>(anzu-n-with-echo)", opt)
     vim.keymap.set("n", "N", "<Plug>(anzu-N-with-echo)", opt)
     vim.keymap.set("n", "#", "<Plug>(anzu-star-with-echo)", opt)
     vim.keymap.set("n", "*", "<Plug>(anzu-sharp-with-echo)", opt)
   end
 }
