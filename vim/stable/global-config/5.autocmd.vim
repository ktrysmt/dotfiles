" Example code;
"
" autocmd BufReadPost quickfix setlocal modifiable
" 	\ | silent exe 'g/^/s//\=line(".")." "/'
" 	\ | setlocal nomodifiable

augroup GeneralAutocmdSetting
  autocmd!
  autocmd BufWritePre * :%s/\s\+$//ge
  autocmd InsertLeave * set nopaste
  autocmd QuickFixCmdPost *grep* cwindow
  autocmd Filetype json setl conceallevel=0
augroup END

augroup HighlightIdegraphicSpaceSetting
  autocmd!
  autocmd Colorscheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
  autocmd VimEnter,WinEnter * match IdeographicSpace /　/
augroup END

augroup GeneralColorSchemeSetting
  autocmd!
  autocmd ColorScheme * hi LineNr ctermfg=239
  autocmd ColorScheme * hi Normal ctermbg=none
  autocmd ColorScheme * hi Todo ctermfg=230 ctermbg=none guifg=Yellow guibg=none
augroup END

augroup QuickRunSetting
  autocmd!
  autocmd Filetype quickrun set syntax=zsh
  let g:quickrun_config = {}
  autocmd BufNewFile,BufRead *.rs  let g:quickrun_config.rust = {'exec' : 'cargo run'}
augroup END

