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


" ---
" ale
" ---
let g:ale_fixers = {
 \ 'javascript': ['prettier'],
 \ 'typescript': ['prettier'],
 \ 'typescriptreact': ['prettier'],
 \ }
let g:ale_linters = {
 \ 'javascript': ['eslint'],
 \ 'typescript': ['eslint'],
 \ 'typescriptreact': ['eslint'],
 \ }
let g:ale_fix_on_save = 1

if executable('eslint_d')
  let g:ale_javascript_eslint_use_global = 1
  let g:ale_javascript_eslint_executable = 'eslint_d'
endif

augroup ALESetting
  autocmd!
  autocmd FileType javascript,typescript,typescriptreact nnoremap <silent> <Leader>ln :ALENextWrap<CR>
  autocmd FileType javascript,typescript,typescriptreact nnoremap <silent> <Leader>LN :ALEPreviousWrap<CR>
augroup END


" ---
" linediff
" ---
vnoremap <Leader>li :Linediff<cr>


" ansible
augroup AnsibleSetting
  au!
  au BufRead,BufNewFile *.j2 set filetype=yaml.ansible
augroup END
