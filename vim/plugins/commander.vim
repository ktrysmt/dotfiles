" ---
" magit
" ---
let g:magit_default_show_all_files = 2
let g:magit_default_sections = ['global_help', 'info', 'commit', 'staged', 'unstaged' ]
let g:magit_auto_close = 1

function s:open_magit() abort
  :vne
  :MagitOnly
endfunction

nmap <silent> <Leader>g :<C-u>call <SID>open_magit()<cr>

"---
"dispatch
"---
" nnoremap <Leader>gps :Dispatch! git push origin<cr>
" nnoremap <Leader>gpl :Dispatch! git pull origin<cr>
