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
  autocmd FileType javascript,typescript,typescriptreact nmap <silent> <Leader>ln :ALENextWrap<CR>
  autocmd FileType javascript,typescript,typescriptreact nmap <silent> <Leader>LN :ALEPreviousWrap<CR>
augroup END
