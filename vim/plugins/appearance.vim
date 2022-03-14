" ---
" [colorscheme]
" ---
set termguicolors
set background=dark

" colorscheme everforest
colorscheme gruvbox-material
" colorscheme gruvbox
" colorscheme moonshine_lowcontrast

" let g:everforest_background = 'soft'
" highlight Visual gui=reverse
highlight Visual ctermbg=52 guibg=#5d4251
highlight VisualNOS ctermbg=52 guibg=#5d4251


" ---
" [illuminate]
" ---
let g:Illuminate_ftblacklist = ['fern']


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

