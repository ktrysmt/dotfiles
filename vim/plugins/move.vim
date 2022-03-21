" ---
" easy-motion
" ---
let g:EasyMotion_keys = 'hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB'
let g:EasyMotion_leader_key = ';'
let g:EasyMotion_grouping = 1

nmap ; <Plug>(easymotion-prefix)


" ---
" fixcursorhold
" ---
let g:cursorhold_updatetime = 100


" ---
" anzu
" ---
set statusline+=%{anzu#search_status()}

nmap n <Plug>(anzu-n-with-echo)
nmap N <Plug>(anzu-N-with-echo)
nmap # <Plug>(anzu-star-with-echo)
nmap * <Plug>(anzu-sharp-with-echo)
