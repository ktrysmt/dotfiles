" general
let mapleader = "\<Space>"

map <Leader>p "0p

tnoremap <ESC> <C-\><C-n>
nnoremap cn *Ncgn
nnoremap cN *NcgN
nnoremap <Leader>%s  :%s/\v
nnoremap <silent> <ESC><ESC> :nohlsearch<CR><ESC>
nnoremap <C-g> :echo expand('%:p')<Return>
nnoremap <Leader>co :copen<cr>
nnoremap <Leader>cl :cclose<cr>
nnoremap <Leader>t :new \| :terminal<CR><insert>
nnoremap <Leader>T :tabnew \| :terminal<CR><insert>
nnoremap <Leader>vt :vne \| :terminal<CR><insert>

" not yank typed s
" nnoremap x "_x
nnoremap s "_s

" move by byte unit on insert mode
inoremap <C-f> <Right>
inoremap <C-b> <Left>
inoremap <C-c> <ESC>

" change case (snake,camel,kebab)
function! s:change_case(v1, ...)
  let t = a:v1
  let p = getpos(".")
  if t == "sc"
    let s = substitute(expand("<cword>"), "_\\(.\\)", "\\u\\1", "g")
    let s = substitute(s, '\(\l\)', '\u\1', '')
    execute ":normal diw"
  elseif t == "sk"
    let s = substitute(expand("<cword>"), "_", "-", "g")
    execute ":normal diw"
  elseif t == "cs"
    let s = substitute(expand("<cword>"), '\(\l\)\(\u\)', '\1_\l\2', "g")
    let s = substitute(s, '\(\u\)', '\l\1', '')
    execute ":normal diw"
  elseif t == "ck"
    let s = substitute(expand("<cword>"), "\\(\\u\\)", "-\\l\\1", "g")
    execute ":normal diw"
  elseif t == "kc"
    let s = substitute(expand("<cword>"), "-\\(.\\)", "\\u\\1", "g")
    execute ":normal diW"
  elseif t == "ks"
    let s = substitute(expand("<cword>"), "-", "_", "g")
    execute ":normal diW"
  endif
  execute ":normal i" . s
  call setpos(".", p)
  echo s
endfunction
nnoremap <C-x>sc :<C-u>call <SID>change_case("sc")<CR>
nnoremap <C-x>sk :<C-u>call <SID>change_case("sk")<CR>
nnoremap <C-x>cs :<C-u>call <SID>change_case("cs")<CR>
nnoremap <C-x>ck :<C-u>call <SID>change_case("ck")<CR>
nnoremap <C-x>kc :<C-u>call <SID>change_case("kc")<CR>
nnoremap <C-x>ks :<C-u>call <SID>change_case("ks")<CR>

" use it later...
nnoremap <c-j> <Nop>
inoremap <c-j> <Nop>
vnoremap <c-j> <Nop>
nnoremap <c-k> <Nop>
inoremap <c-k> <Nop>
vnoremap <c-k> <Nop>
