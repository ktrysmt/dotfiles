" ---
" terraform
" ---
let g:terraform_fmt_on_save = 1


" ---
" emmet
" ---
let g:user_emmet_leader_key='<C-Y>'
let g:user_emmet_mode='in'
let g:user_emmet_install_global = 0
augroup EmmetSetting
  autocmd!
  autocmd FileType html,css,scss,javascript,javascriptreact,typescript,typescriptreact EmmetInstall
augroup END


" ---
" clang-format
" ---
let g:clang_format#auto_format = 1
