" ---
" magit
" ---
" let g:magit_show_help = 0
let g:magit_default_show_all_files = 2
let g:magit_default_fold_level = 2
let g:magit_default_sections = ['global_help', 'info', 'unstaged', 'staged', 'commit']

nnoremap <Leader>g :Magit<cr>

"---
"dispatch
"---
" nnoremap <Leader>gps :Dispatch! git push origin<cr>
" nnoremap <Leader>gpl :Dispatch! git pull origin<cr>
