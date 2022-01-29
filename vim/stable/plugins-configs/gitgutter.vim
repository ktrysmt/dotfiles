augroup HighlightGitGutter
  autocmd!
  autocmd Colorscheme * highlight GitGutterAdd    guifg=#009900 guibg=Gray ctermbg=233 ctermfg=2
  autocmd Colorscheme * highlight GitGutterChange guifg=#bbbb00 guibg=Gray ctermbg=233 ctermfg=3
  autocmd Colorscheme * highlight GitGutterDelete guifg=#ff2222 guibg=Gray ctermbg=233 ctermfg=1
augroup END

set signcolumn=yes:1

