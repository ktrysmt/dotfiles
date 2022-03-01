" ---
" vim-expand-region
" ---
map K <Plug>(expand_region_expand)
map J <Plug>(expand_region_shrink)
let g:expand_region_text_objects = {
      \ 'iw'  :1,
      \ 'iW'  :1,
      \ 'i"'  :0,
      \ 'i''' :0,
      \ 'i]'  :1,
      \ 'ib'  :1,
      \ 'iB'  :1,
      \ }


" ---
" lexima
" ---
" https://qiita.com/yami_beta/items/26995a5c382bd83ac38f
inoremap <C-f> <C-r>=lexima#insmode#leave(1, '<LT>C-G>U<LT>RIGHT>')<CR>

" ---
" sandwich
" ---
" https://github.com/machakann/vim-sandwich/wiki/Introduce-vim-surround-keymappings
" https://zenn.dev/yano/articles/vim_plugin_top_10#vim-sandwich

