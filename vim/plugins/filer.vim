let g:fern#opener = "vsplit"
let g:fern#default_hidden = 1
let g:fern#default_exclude = ".DS_Store"
let g:fern#disable_drawer_hover_popup = 1


function! s:init_fern() abort

  " custom expander
  nmap <buffer><expr>
      \ <Plug>(fern-my-expand-or-collapse)
      \ fern#smart#leaf(
      \   "\<Plug>(fern-action-collapse)",
      \   "\<Plug>(fern-action-expand:stay)",
      \   "\<Plug>(fern-action-collapse)",
      \ ) " 循環するので使うのはexpand:stay固定で
  " overwrite fern-action-expand
  nmap <buffer>
        \ <Plug>(fern-action-expand)
        \ <Plug>(fern-my-expand-or-collapse)

  nmap <buffer> o <Plug>(fern-action-open-or-expand)

  nmap <buffer> go <Plug>(fern-action-open:edit)<C-w>p
  nmap <buffer> t <Plug>(fern-action-open:tabedit)
  nmap <buffer> T <Plug>(fern-action-open:tabedit)gT
  nmap <buffer> i <Plug>(fern-action-open:split)
  nmap <buffer> gi <Plug>(fern-action-open:split)<C-w>p
  nmap <buffer> s <Plug>(fern-action-open:vsplit)
  nmap <buffer> gs <Plug>(fern-action-open:vsplit)<C-w>p

  nmap <buffer> ma <Plug>(fern-action-new-path)
  nmap <buffer> mm <Plug>(fern-action-move)
  nmap <buffer> mc <Plug>(fern-action-copy)
  nmap <buffer> md <Plug>(fern-action-trash)

  nmap <buffer> y <Plug>(fern-action-yank:label)
  nmap <buffer> Y <Plug>(fern-action-yank:path)

  nnoremap <buffer> P gg

  nnoremap <buffer> l <Nop>
  nnoremap <buffer> e <Nop>
  nnoremap <buffer> E <Nop>

  nmap <buffer> <Plug>(fern-my-enter-and-tcd)
        \ <Plug>(fern-action-enter)
        \ <Plug>(fern-wait)
        \ <Plug>(fern-action-tcd:root)
  nmap <buffer> C <Plug>(fern-my-enter-and-tcd)

  nmap <buffer> <Plug>(fern-my-leave-and-tcd)
        \ <Plug>(fern-action-leave)
        \ <Plug>(fern-wait)
        \ <Plug>(fern-action-tcd:root)
  nmap <buffer> u <Plug>(fern-my-leave-and-tcd)

  nmap <buffer> r <Plug>(fern-action-reload)
  nmap <buffer> R gg<Plug>(fern-action-reload)<C-o>
  nmap <buffer> cd <Plug>(fern-action-cd)
  nmap <buffer> CD gg<Plug>(fern-action-cd)<C-o>

  nmap <buffer> I <Plug>(fern-action-hide-toggle)

  nnoremap <buffer> q :<C-u>quit<CR>
endfunction

function! s:toggle_fern() abort
  :silent! cd `git rev-parse --show-toplevel`
  :Fern . -reveal=% -drawer -stay -toggle -width=50
endfunction

function! s:focus_fern() abort
  :cd %:p:h
  :silent! cd `git rev-parse --show-toplevel`
  :Fern . -reveal=% -drawer -width=50
endfunction

nmap <silent> <C-E> :<C-u>call <SID>toggle_fern()<CR>
nnoremap <silent> <C-W>f :<C-u>call <SID>focus_fern()<CR>

augroup FernSetting
  " user function / use ++nested to allow automatic file type detection and such
  autocmd!
  autocmd FileType fern call s:init_fern()
  autocmd VimEnter * ++nested Fern . -reveal=% -drawer -stay -width=50
  autocmd FileType fern nmap <buffer> N <Plug>(anzu-N-with-echo)
  autocmd FileType fern nmap <buffer> n j <Plug>(anzu-n-with-echo)
augroup END



" Fern mapping fzf
" -----------------
function! Fern_mapping_fzf_customize_option(spec)
  let a:spec.options .= ' --multi'
  return fzf#vim#with_preview(a:spec)
endfunction

function! Fern_mapping_fzf_before_all(dict)
  if !len(a:dict.lines)
    return
  endif
  return a:dict.fern_helper.async.update_marks([])
endfunction

function! s:reveal(dict)
  execute "FernReveal -wait" a:dict.relative_path
  " execute "normal \<Plug>(fern-action-mark:set)"
endfunction

function! Fern_mapping_fzf_after_all(dict)
  execute "normal \<Plug>(fern-action-open:vsplit)"
endfunction

let g:Fern_mapping_fzf_file_sink = function('s:reveal')
let g:Fern_mapping_fzf_dir_sink = function('s:reveal')

