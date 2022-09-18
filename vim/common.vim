" -----
" skip native
" -----
"let g:did_install_default_menus = 1
"let g:did_install_syntax_menu   = 1
"let g:did_indent_on             = 1
"let g:did_load_filetypes        = 1
"let g:did_load_ftplugin         = 1
"let g:loaded_2html_plugin       = 1
"let g:loaded_gzip               = 1
"let g:loaded_man                = 1
"let g:loaded_matchit            = 1
"let g:loaded_matchparen         = 1
"let g:loaded_netrwPlugin        = 1
"let g:loaded_remote_plugins     = 1
"let g:loaded_shada_plugin       = 1
"let g:loaded_spellfile_plugin   = 1
"let g:loaded_tarPlugin          = 1
"let g:loaded_tutor_mode_plugin  = 1
"let g:loaded_zipPlugin          = 1
"let g:skip_loading_mswin        = 1


" -----
" set
" -----
set encoding=utf-8
set fileencodings=utf-8,euc-jp,sjis,iso-2022-jp,
set fileformats=unix,dos,mac
scriptencoding utf-8

set sh=zsh

set ambiwidth=double
set backspace=start,eol,indent
set bs=2
set cindent
set completeopt=menuone,noselect,noinsert
set cursorline
set diffopt=internal,filler,algorithm:histogram,indent-heuristic
set display=lastline
set expandtab
set guioptions-=T
set hidden
set history=4096
set hlsearch
set ignorecase
set inccommand=split
set incsearch
set laststatus=2
set lazyredraw
set list
set matchtime=1
set noswapfile
set nrformats=
set number
set ruler
set secure
set shiftwidth=2
set shortmess+=I
set showcmd
set showmatch
set showtabline=2
set smartcase
set softtabstop=2
set tabstop=2
set ttyfast
set vb t_vb=
set virtualedit=all
set whichwrap=b,s,[,],<,>,~
set wildmenu
set wildmode=longest:full,full
set wrap

filetype plugin indent on

if has('win32') || has('win64') || has('mac')
  set clipboard=unnamed
else
  set clipboard=unnamedplus
endif


" -----
" vimgrep
" -----
if executable("rg")
    set grepprg=rg\ --vimgrep\ --no-heading\ --sort-files
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif


" -----
" commands
" -----
command! -nargs=* -complete=file Rg :silent grep <args>
command! Rv source $MYVIMRC
command! Ev edit $HOME/dotfiles/.vimrc
cabbr w!! w !sudo tee > /dev/null %


" -----
" autocmd
" -----
augroup GeneralAutocmdSetting
  " common
  autocmd!
  autocmd BufWritePre * :%s/\s\+$//ge
  autocmd InsertLeave * set nopaste
  autocmd QuickFixCmdPost *grep* cwindow
  autocmd Filetype json setl conceallevel=0
  " highlight
  autocmd Colorscheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
  autocmd WinEnter * match IdeographicSpace /　/
  " jinja
  autocmd BufNewFile,BufRead *.jinja2,*.j2,*.jinja set ft=jinja
augroup END


" -----
" mappings
" -----
let mapleader = "\<Space>"

tnoremap <ESC> <C-\><C-n>

nnoremap / /\v
nnoremap j gj
nnoremap k gk
nnoremap cn *Ncgn
nnoremap cN *NcgN

nnoremap <C-g> :echo expand('%:p')<Return>

nnoremap <silent> <Leader>p "0p
vnoremap <silent> <Leader>p "0p
nnoremap <silent> <ESC><ESC> :nohlsearch<CR><ESC>
nnoremap <silent> <Leader>t :new \| :terminal<CR><insert>
nnoremap <silent> <Leader>T :tabnew \| :terminal<CR><insert>
nnoremap <silent> <Leader>vt :vne \| :terminal<CR><insert>

" move by byte unit on insert mode
inoremap <C-f> <Right>
inoremap <C-b> <Left>
inoremap <C-c> <ESC>

" switch buffer
nnoremap <C-j> :bprev<CR>
nnoremap <C-k> :bnext<CR>

" use it later...
nnoremap <c-j> <Nop>
inoremap <c-j> <Nop>
vnoremap <c-j> <Nop>
nnoremap <c-k> <Nop>
inoremap <c-k> <Nop>
vnoremap <c-k> <Nop>

nnoremap <silent> <Leader>co :copen<cr>
nnoremap <silent> <Leader>cl :cclose<cr>
nnoremap <silent> <Leader>cc :call ToggleQuickFix()<cr>
function! ToggleQuickFix()
  if getqflist({'winid' : 0}).winid
    cclose
  else
    copen
  endif
endfunction

nmap <C-w>> <C-w>><SID>ws
nmap <C-w>< <C-w><<SID>ws
nnoremap <script> <SID>ws> <C-w>><SID>ws
nnoremap <script> <SID>ws< <C-w><<SID>ws
nmap <SID>ws <Nop>

" cursorhold
vnoremap y mcy`c

" devide delete and cut
" vnoremap d "_d
" nnoremap d "_d
" vnoremap D "_D
" nnoremap D "_D
" vnoremap x "_x
" nnoremap x "_x
" vnoremap s "_s
" nnoremap s "_s
" nnoremap t d
" vnoremap t x
" nnoremap tt dd
" nnoremap T D




" -----
"" tab control
" -----
function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction

function! s:my_tabline()  "{{{
  let s = ''
  for i in range(1, tabpagenr('$'))
    let bufnrs = tabpagebuflist(i)
    let bufnr = bufnrs[tabpagewinnr(i) - 1]  " first window, first appears
    let no = i  " display 0-origin tabpagenr.
    let mod = getbufvar(bufnr, '&modified') ? '!' : ' '
    let title = fnamemodify(bufname(bufnr), ':t')
    let title = '[' . title . ']'
    let s .= '%'.i.'T'
    let s .= '%#' . (i == tabpagenr() ? 'TabLineSel' : 'TabLine') . '#'
    let s .= no . ':' . title
    let s .= mod
    let s .= '%#TabLineFill# '
  endfor
  let s .= '%#TabLineFill#%T%=%#TabLine#'
  return s
endfunction "}}}

let &tabline = '%!'. s:SID_PREFIX() . 'my_tabline()'

" The prefix key.
nnoremap    [Tag]   <Nop>
nmap    t [Tag]

" Tab jump
for n in range(1, 9)
  execute 'nnoremap [Tag]'.n  ':<C-u>tabnext'.n.'<CR>'
endfor

" Tab map
nnoremap [Tag]c :tablast <bar> tabnew<CR>
nnoremap [Tag]x :tabclose<CR>
nnoremap <Tab>      gt
nnoremap <S-Tab>    gT
