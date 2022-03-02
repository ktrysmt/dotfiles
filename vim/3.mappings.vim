" general
let mapleader = "\<Space>"

map <Leader>p "0p

nnoremap / /\v

tnoremap <ESC> <C-\><C-n>
nnoremap cn *Ncgn
nnoremap cN *NcgN
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

" use it later...
nnoremap <c-j> <Nop>
inoremap <c-j> <Nop>
vnoremap <c-j> <Nop>
nnoremap <c-k> <Nop>
inoremap <c-k> <Nop>
vnoremap <c-k> <Nop>
