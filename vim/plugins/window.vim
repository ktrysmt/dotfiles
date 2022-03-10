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
augroup HighlightGitGutter
  autocmd!
  autocmd Colorscheme * highlight GitGutterAdd    guifg=#009900 guibg=Gray ctermbg=233 ctermfg=2
  autocmd Colorscheme * highlight GitGutterChange guifg=#bbbb00 guibg=Gray ctermbg=233 ctermfg=3
  autocmd Colorscheme * highlight GitGutterDelete guifg=#ff2222 guibg=Gray ctermbg=233 ctermfg=1
augroup END
set signcolumn=yes:1


" ---
" yankround
" ---
let g:unite_enable_split_vertically = 1
nnoremap <C-p> :Unite -create -buffer-name=yankround yankround<Return>:se nu<Return>
let g:yankround_max_history = 80
