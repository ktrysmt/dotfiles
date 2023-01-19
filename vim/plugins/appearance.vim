" ---
" [colorscheme]
" ---
set termguicolors

" colorscheme pinecone
colorscheme gruvbit
" colorscheme moonshine_lowcontrast

" set background=dark
" let g:gruvbox_material_background = 'hard'
" " let g:gruvbox_material_visual = 'green background'
" autocmd ColorScheme * highlight Visual ctermbg=52 guibg=#5d4251
" colorscheme gruvbox-material

" let g:despacio_Sunset = 1
" let g:despacio_Twilight = 1
" let g:despacio_Midnight = 1
" let g:despacio_Pitch = 1
" colorscheme despacio


" ---
" [illuminate]
" ---
let g:Illuminate_ftblacklist = ['fern']
augroup illuminate_augroup
    autocmd!
    autocmd VimEnter * hi illuminatedWord guibg=#202020 gui=underline
augroup END

" ---
" [lightline]
" ---
set laststatus=2
let g:lightline = {
  \'colorscheme': 'wombat',
  \'active': {
  \  'left': [
  \    ['mode', 'paste'],
  \    ['readonly', 'filename', 'modified'],
  \  ]
  \},
  \'component_function': {
  \  'lsp': 'LspNextError'
  \},
\}


