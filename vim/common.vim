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

set backspace=start,eol,indent
set smartindent
set completeopt=menuone,noselect,noinsert
set cursorline
set diffopt=internal,filler,algorithm:histogram,indent-heuristic
set display=lastline
set expandtab
set hidden
set history=4096
set hlsearch
set inccommand=split
set incsearch
set laststatus=2
set lazyredraw

set list

set showmatch
set matchtime=1

set noshowmode
set noswapfile
set nrformats=
set number
set ruler
set secure
set shiftwidth=2
set shortmess+=I
set showcmd
set showtabline=1
set smartcase " or ignorecase
set softtabstop=2
set tabstop=2
set vb t_vb=
set virtualedit=all
set wildmode=longest:full,full
set wrap
"

" create pane at bottom by :new
set splitbelow

" filetype plugin indent on
"
if has('win32') || has('win64') || has('mac')
  set clipboard+=unnamed
else
  set clipboard+=unnamedplus
endif

" cursorhold
" set nostartofline

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
  autocmd!
  autocmd BufWritePre * :%s/\s\+$//ge
  autocmd InsertLeave * set nopaste
  autocmd QuickFixCmdPost *grep* cwindow
  autocmd TermOpen * setlocal norelativenumber
  autocmd TermOpen * setlocal nonumber
augroup END

augroup JsonAutocmdSetting
  autocmd!
  autocmd Filetype json setl conceallevel=0
augroup END

augroup HighlightAutocmdSetting
  autocmd!
  autocmd Colorscheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
  autocmd WinEnter * match IdeographicSpace /　/
augroup END

augroup JinjaAutocmdSetting
  autocmd!
  autocmd BufNewFile,BufRead *.j2 setfiletype yaml.ansible
augroup END

" -----
" mappings
" -----
let mapleader = "\<Space>"

tnoremap <ESC> <C-\><C-n>

tnoremap <C-W>w       <cmd>wincmd w<cr>
tnoremap <C-W>k       <cmd>wincmd k<cr>
tnoremap <C-W>j       <cmd>wincmd j<cr>
tnoremap <C-W>h       <cmd>wincmd h<cr>
tnoremap <C-W>l       <cmd>wincmd l<cr>

tnoremap <C-W>W       <cmd>wincmd W<cr>
tnoremap <C-W>K       <cmd>wincmd K<cr>
tnoremap <C-W>J       <cmd>wincmd J<cr>
tnoremap <C-W>H       <cmd>wincmd H<cr>
tnoremap <C-W>L       <cmd>wincmd L<cr>

nnoremap / /\v
nnoremap j gj
nnoremap k gk

nnoremap cn *N"_cgn
nnoremap cN *N"_cgN
xnoremap <expr> cn "\<ESC>/\<C-r>=<SID>search()\<CR>\<CR>N\"_cgn"
xnoremap <expr> cN "\<ESC>/\<C-r>=<SID>search()\<CR>\<CR>N\"_cgN"
function! s:search() abort
  let tmp = @"
  normal! gv""y
  let [text, @"] = [escape(@", '\/'), tmp]
  return '\V' .. substitute(text, "\n", '\\n', 'g')
endfunction

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

" disable select mode...
nnoremap gh <Nop>
nnoremap gH <Nop>
nnoremap g<C-h> <Nop>
nnoremap gV <Nop>

" quick fix
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

" nnoremap <C-g><C-g> :call CopyPath()<cr>
" function! CopyPath()
"   let words = split(getcwd(),"/")
"   let index = len(words) - 1
"   let path = words[index] ."/". expand('%')
"   let @" = path
" endfunction



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
