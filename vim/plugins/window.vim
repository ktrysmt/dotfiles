" ---
" vista
" ---
nnoremap <C-q> :Vista!!<CR>
let g:vista_default_executive = 'ctags'
let g:vista_executive_for = {
  \ 'python': 'vim_lsp',
  \ 'go': 'vim_lsp',
  \ 'vim': '',
  \ 'typescript': 'vim_lsp',
  \ 'typescriptreact': 'vim_lsp',
  \ 'rust': 'vim_lsp',
  \ }
let g:vista_sidebar_width = 48
let g:vista#renderer#enable_icon = 0
let g:vista_fzf_preview = ['right:50%']


" ---
" gitgutter
" ---
highlight GitGutterAdd    guifg=#5bb15b guibg=#121212
highlight GitGutterChange guifg=#c0c036 guibg=#121212
highlight GitGutterDelete guifg=#e04a4a guibg=#121212
" augroup HighlightGitGutter
"   autocmd!
"   autocmd Colorscheme * highlight GitGutterAdd    guifg=#009900 guibg=NONE
"   autocmd Colorscheme * highlight GitGutterChange guifg=#bbbb00 guibg=NONE
"   autocmd Colorscheme * highlight GitGutterDelete guifg=#ff2222 guibg=NONE
"
"   " autocmd Colorscheme * highlight link GitGutterAddLineNr String
"   " autocmd Colorscheme * highlight link GitGutterChangeLineNr String
"   " autocmd Colorscheme * highlight link GitGutterDeleteLineNr String
"   " autocmd Colorscheme * highlight link GitGutterChangeDeleteLineNr String
"   "
"   " autocmd Colorscheme * highlight link GitGutterChangeLineNr String
" augroup END
set signcolumn=yes:1


" ---
" yankround
" ---
let g:unite_enable_split_vertically = 1
nnoremap <C-p> :Unite -create -buffer-name=yankround yankround<Return>:se nu<Return>
let g:yankround_max_history = 80

" ---
" undotree
" ---
set undofile
set undodir=~/.cache/nvim/undofile
let g:undotree_WindowLayout = 3
let g:undotree_DiffpanelHeight = 30
let g:undotree_SplitWidth = 50
nnoremap <silent> <Leader>un :UndotreeToggle<CR>:UndotreeFocus<CR>

