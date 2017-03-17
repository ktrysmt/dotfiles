"---------------------------
" General Settings
"---------------------------
let mapleader = "\<Space>"
set encoding=utf-8
scriptencoding
set fileencodings=utf-8,euc-jp,sjis,iso-2022-jp,
set fileformats=unix,dos,mac
set ambiwidth=double
set backspace=start,eol,indent
set bs=2
set expandtab
set guioptions-=T
set hidden
set hlsearch
set virtualedit=all
set incsearch
set laststatus=2
set nocompatible
set ruler
set shiftwidth=2
set statusline=%F%r%h%=
set showmatch
set tabstop=2
set softtabstop=2
set showcmd
set smartcase
set vb t_vb=
set whichwrap=b,s,[,],<,>,~
set number
set noswapfile
set nrformats=
set cindent
set display=lastline
set pumheight=10
set showmatch
set matchtime=1
set wrap
set wildmode=longest:full,full
set ignorecase
set completeopt-=preview
set wildmenu 
set history=5000 
nnoremap cn *``cgn
nmap <ESC><ESC> :nohlsearch<CR><ESC>
runtime macros/matchit.vim
cabbr w!! w !sudo tee > /dev/null %
augroup highlightIdegraphicSpace
  autocmd!
  autocmd Colorscheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
  autocmd VimEnter,WinEnter * match IdeographicSpace /　/
augroup END
filetype plugin indent on
autocmd QuickFixCmdPost *grep* cwindow

"---------------------------
" Vimrc
"---------------------------
command! Rv source $MYVIMRC
command! Ev edit $MYVIMRC
command! Edv edit $HOME/dotfiles/.vimrc

"---------------------------
"" Vim-Plug Settings.
"---------------------------
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif
call plug#begin()
" [for All]
Plug 'tomasr/molokai'
Plug 'vim-scripts/mru.vim'
Plug 'Townk/vim-autoclose'
Plug 'Shougo/unite.vim'
Plug 'junegunn/vim-easy-align'
Plug 'LeafCage/yankround.vim'
Plug 'Shougo/neocomplete.vim'
Plug 'itchyny/lightline.vim'
Plug 'soramugi/auto-ctags.vim'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }
Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle' }
Plug 'szw/vim-tags'
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'
Plug 'lambdalisue/vim-unified-diff'
Plug 'Lokaltog/vim-easymotion'
Plug 'vimtaku/hl_matchit.vim'
Plug 'osyo-manga/vim-over'
Plug 'neomake/neomake'
Plug 'tomtom/tcomment_vim'
Plug 'kana/vim-operator-user'
" Plug 'kana/vim-operator-replace'
Plug 'rhysd/vim-operator-surround'
Plug 'osyo-manga/vim-operator-stay-cursor'
Plug 'thinca/vim-qfreplace'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
" [for HTML/CSS ]
Plug 'mattn/emmet-vim', { 'for': ['html', 'css'] }
" [for Javascript]
Plug 'jaawerth/nrun.vim', { 'for': ['javascript'] } 
Plug 'ternjs/tern_for_vim', { 'for': ['javascript', 'html'], 'dir': '~/.vim/plugged/tern_for_vim', 'do': 'yarn' }
Plug 'ruanyl/vim-fixmyjs', { 'for': ['javascript'] }
Plug 'pangloss/vim-javascript', { 'for': ['javascript'] }
" [for Go]
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'thinca/vim-quickrun', { 'for': ['go', 'rust'] }
" [for Rust]
Plug 'scrooloose/syntastic', { 'for': ['rust'] }
Plug 'rust-lang/rust.vim', { 'for': ['rust'] }
Plug 'racer-rust/vim-racer', { 'for': ['rust'] }
call plug#end()

"-------------------------
" Color Scheme
"-------------------------
syntax on
colorscheme molokai
autocmd colorscheme molokai highlight Visual ctermbg=8
highlight Normal ctermbg=none

"-------------------------
" Unite Settings
"-------------------------
let g:unite_enable_split_vertically = 1
:map <C-p> :Unite yankround<Return>

"-------------------------
" neocomplete
"-------------------------
let g:acp_enableAtStartup = 0
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'
let g:neocomplete#sources#dictionary#dictionaries = {
   \ 'default' : '',
   \ 'vimshell' : $HOME.'/.vimshell_hist',
   \ 'scheme' : $HOME.'/.gosh_completions'
   \ }
if !exists('g:neocomplete#keyword_patterns')
 let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType * setlocal completeopt-=preview
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS

"-------------------------
" lightline
"-------------------------
let g:lightline = {'colorscheme': 'wombat'}
set laststatus=2
if !has('gui_running')
set t_Co=256
endif

"-------------------------
" ctags
"-------------------------
let g:auto_ctags = 1
set tags+=.git/tags
let g:auto_ctags_directory_list = ['.git']
let g:auto_ctags_tags_args = '--tag-relative --recurse --sort=yes --format=2'

"-------------------------
" tagbar
"-------------------------
nmap <silent> <C-a>      :TagbarToggle<CR>
vmap <silent> <C-a> <Esc>:TagbarToggle<CR>
omap <silent> <C-a>      :TagbarToggle<CR>
imap <silent> <C-a> <Esc>:TagbarToggle<CR>
cmap <silent> <C-a> <C-u>:TagbarToggle<CR>

"-------------------------
" NERDTree
"-------------------------
nmap <silent> <C-e>      :NERDTreeToggle<CR>
vmap <silent> <C-e> <Esc>:NERDTreeToggle<CR>
omap <silent> <C-e>      :NERDTreeToggle<CR>
imap <silent> <C-e> <Esc>:NERDTreeToggle<CR>
cmap <silent> <C-e> <C-u>:NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
let g:NERDTreeShowHidden=1
let NERDTreeIgnore = ['node_modules','.git', ".DS_Store"]
let g:NERDTreeChDirMode = 2

"-------------------------
" neosnippet
"-------------------------
imap <C-s>     <Plug>(neosnippet_expand_or_jump)
smap <C-s>     <Plug>(neosnippet_expand_or_jump)
xmap <C-s>     <Plug>(neosnippet_expand_target)
imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)"
\: pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)"
\: "\<TAB>"
if has('conceal')
  set conceallevel=2 concealcursor=i
endif

"-------------------------
" vimdiff
"-------------------------
set diffexpr=unified_diff#diffexpr()
let unified_diff#executable = 'git'
let unified_diff#arguments = [
      \   'diff', '--no-index', '--no-color', '--no-ext-diff', '--unified=0',
      \ ]
let unified_diff#iwhite_arguments = [
      \   '--ignore--all-space',
      \ ]

"-------------------------
" easymotion
"-------------------------
let g:EasyMotion_keys='hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB'
let g:EasyMotion_leader_key=";"
let g:EasyMotion_grouping=1

"-------------------------
" for hl_matchit
"-------------------------
let g:hl_matchit_enable_on_vim_startup = 1
let g:hl_matchit_hl_groupname = 'Title'
let g:hl_matchit_allow_ft = 'vim\|ruby\|sh\|php\|javascript\|go\|rust'

"-------------------------
" vim-go
"-------------------------
let g:go_bin_path = expand(globpath($GOPATH, "bin"))
let g:go_play_open_browser = 0
let g:go_fmt_fail_silently = 1
let g:go_fmt_autosave = 1
let g:go_fmt_command = "gofmt"
let g:go_fmt_options = "-s"
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_disable_autoinstall = 0

"-------------------------
" tab control
"-------------------------
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
set showtabline=2
" The prefix key.
nnoremap    [Tag]   <Nop>
nmap    t [Tag]
" Tab jump
for n in range(1, 9)
  execute 'nnoremap <silent> [Tag]'.n  ':<C-u>tabnext'.n.'<CR>'
endfor
" Tab map
map <silent> [Tag]c :tablast <bar> tabnew<CR>
map <silent> [Tag]x :tabclose<CR>
map <silent> [Tag]n :tabnext<CR>
map <silent> [Tag]p :tabprevious<CR>

"-------------------------
" emmet
"-------------------------
let g:user_emmet_leader_key='<C-y>'
let g:user_emmet_mode='i'
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall

"-------------------------
" Neomake
"-------------------------
autocmd! BufWritePost,BufEnter * Neomake
if (&ft=='go')
  let g:neomake_go_enabled_makers = ['go', 'golint', 'govet']
endif
if (&ft=='javascript')
  let g:neomake_javascript_eslint_exe = nrun#Which('eslint')
  let g:neomake_javascript_enabled_makers = ['eslint']
endif
let g:neomake_error_sign = {'text': '>>', 'texthl': 'Error'}
let g:neomake_warning_sign = {'text': '>>',  'texthl': 'Todo'}
let g:neomake_verbose = 0

"-------------------------
" rust
"-------------------------
let g:rustfmt_autosave = 1
augroup NeomakeRustConfig
  autocmd!
  autocmd BufWritePost *.rs Neomake! clippy
augroup END
let g:racer_cmd = '$HOME/.cargo/bin/racer'
let g:rustfmt_command = '$HOME/.cargo/bin/rustfmt'
let $RUST_SRC_PATH = '$HOME/.cargo/src'

"-------------------------
" easy-align
"-------------------------
vmap <Enter> <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

"-------------------------
" operetor-user
"-------------------------
" nmap s <Plug>(operator-replace)
map <silent> sa <Plug>(operator-surround-append)
map <silent> sd <Plug>(operator-surround-delete)
map <silent> sr <Plug>(operator-surround-replace)
map y <Plug>(operator-stay-cursor-yank)

"-------------------------
" vp doesn't replace paste buffer
"-------------------------
function! RestoreRegister()
  let @" = s:restore_reg
  return ''
endfunction
function! s:Repl()
  let s:restore_reg = @"
  return "p@=RestoreRegister()\<cr>"
endfunction
vmap <silent> <expr> p <sid>Repl()

"-------------------------
" fzf
"-------------------------
augroup gopkgs
  autocmd!
  autocmd FileType go command! -buffer Import exe 'GoImport' fzf#run({'source': 'gopkgs'})[0]
  autocmd FileType go command! -buffer Doc exe 'GoDoc' fzf#run({'source': 'gopkgs'})[0]
augroup END

"-------------------------
" env
"-------------------------
if has("mac")
" mac用の設定
elseif has("unix")
" unix固有の設定
elseif has("win64")
" 64bit_windows固有の設定
elseif has("win32unix")
" Cygwin固有の設定
elseif has("win32")
" 32bit_windows固有の設定
endif
