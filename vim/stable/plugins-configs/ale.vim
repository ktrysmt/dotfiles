let g:ale_fixers = {
 \ 'javascript': ['prettier'],
 \ 'typescript': ['prettier'],
 \ }
let g:ale_linters = {
 \ 'javascript': ['eslint'],
 \ 'typescript': ['eslint'],
 \ }
let g:ale_fix_on_save = 1
" let g:ale_echo_cursor = 0
let g:ale_linters_explicit = 1

if executable('eslint_d')
  let g:ale_javascript_eslint_use_global = 1
  let g:ale_javascript_eslint_executable = 'eslint_d'
endif

let g:ale_javascript_prettier_options = '--single-quote --trailing-comma all'

