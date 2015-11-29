"---------------------------
" General Settings
"---------------------------
let mapleader = "\<Space>"
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
set tabstop=8
set vb t_vb=
set whichwrap=b,s,[,],<,>,~
set number
set noswapfile
set nrformats=
set cindent
nnoremap Y y$
set display=lastline
set pumheight=10
set showmatch
set matchtime=1
set wrap
set wildmode=longest:full,full
set ignorecase
nnoremap + <C-a>
nnoremap - <C-x>
nmap <ESC><ESC> :nohlsearch<CR><ESC>
runtime macros/matchit.vim

"---------------------------
"" Neobundle Settings.
"---------------------------
set runtimepath+=~/.vim/bundle/neobundle.vim/
call neobundle#begin(expand('~/.vim/bundle/'))
NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'jpo/vim-railscasts-theme'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'Townk/vim-autoclose'
NeoBundle 'mattn/emmet-vim'
NeoBundle 'vim-utils/vim-troll-stopper'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'seletskiy/vim-autosurround'
NeoBundle 'scrooloose/nerdcommenter'
NeoBundle 'Shougo/vimproc', {
  \ 'build' : {
    \ 'windows' : 'make -f make_mingw32.mak',
    \ 'cygwin' : 'make -f make_cygwin.mak',
    \ 'mac' : 'make -f make_mac.mak',
    \ 'unix' : 'make -f make_unix.mak',
  \ },
\ }
NeoBundle 'LeafCage/yankround.vim'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'Shougo/neocomplete.vim'
NeoBundle 'itchyny/lightline.vim'
NeoBundle 'soramugi/auto-ctags.vim'
NeoBundle 'jelera/vim-javascript-syntax'
NeoBundle 'vim-scripts/jQuery'
NeoBundle 'editorconfig/editorconfig-vim'
NeoBundle 'jiangmiao/simple-javascript-indenter'
NeoBundle 'mattn/jscomplete-vim'
NeoBundle 'majutsushi/tagbar'
NeoBundle 'szw/vim-tags'
NeoBundle 'ujihisa/shadow.vim'
NeoBundle '907th/vim-auto-save'
NeoBundle 'Shougo/neosnippet.vim'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'lambdalisue/vim-unified-diff'
NeoBundle 'fatih/vim-go'
NeoBundle 'tpope/vim-abolish'
NeoBundle 'Lokaltog/vim-easymotion'
NeoBundle 'vimtaku/hl_matchit.vim'
NeoBundle "matchit.zip"
NeoBundle "osyo-manga/vim-over"
NeoBundleLazy 'leafgarland/typescript-vim', {
\ 'autoload' : {
\   'filetypes' : ['typescript'], 
\ }
\}
NeoBundleLazy 'jason0x43/vim-js-indent', {
\ 'autoload' : {
\   'filetypes' : ['javascript', 'typescript'],
\ }
\}
NeoBundle 'Quramy/tsuquyomi'
" use: npm install -g typescript-tools
"NeoBundleLazy 'clausreinke/typescript-tools.vim', {
"\ 'build' : 'npm install -g',
"\ 'autoload' : {
"\   'filetypes' : ['typescript'],
"\ }
"\}
call neobundle#end()
filetype plugin indent on
NeoBundleCheck
syntax on
colorscheme railscasts
highlight Normal ctermbg=none

"-------------------------
" Unite Settings
"-------------------------
let g:unite_enable_split_vertically = 1
:map <C-p> :Unite yankround<Return>

"-------------------------
" Unite with ag
"-------------------------
" insert modeで開始
"let g:unite_enable_start_insert = 1
" 大文字小文字を区別しない
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1
" grep検索
nnoremap <silent> ,g  :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
" カーソル位置の単語をgrep検索
nnoremap <silent> ,cg :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>
" grep検索結果の再呼出
nnoremap <silent> ,r  :<C-u>UniteResume search-buffer<CR>
" unite grep に ag(The Silver Searcher) を使う
if executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
  let g:unite_source_grep_recursive_opt = ''
endif

"-------------------------
" neocomplete
"-------------------------
"Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'
" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
   \ 'default' : '',
   \ 'vimshell' : $HOME.'/.vimshell_hist',
   \ 'php' : $HOME.'/.vim/dictionaries/php.dict',
   \ 'scheme' : $HOME.'/.gosh_completions'
   \ }
" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
 let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'
" Plugin key-mappings.
inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()
" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
 return neocomplete#close_popup() . "\<CR>"
 " For no inserting <CR> key.
 "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplete#close_popup()
inoremap <expr><C-e>  neocomplete#cancel_popup()
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? neocomplete#close_popup() : "\<Space>"
" For cursor moving in insert mode(Not recommended)
"inoremap <expr><Left>  neocomplete#close_popup() . "\<Left>"
"inoremap <expr><Right> neocomplete#close_popup() . "\<Right>"
"inoremap <expr><Up>    neocomplete#close_popup() . "\<Up>"
"inoremap <expr><Down>  neocomplete#close_popup() . "\<Down>"
" Or set this.
"let g:neocomplete#enable_cursor_hold_i = 1
" Or set this.
"let g:neocomplete#enable_insert_char_pre = 1
" AutoComplPop like behavior.
"let g:neocomplete#enable_auto_select = 1
" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplete#enable_auto_select = 1
"let g:neocomplete#disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"
" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
"autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
"autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
"autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
"let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

"-------------------------
" syntax check
"-------------------------
let g:syntastic_check_on_open = 1
let g:syntastic_enable_signs = 1
let g:syntastic_echo_current_error = 1
let g:syntastic_auto_loc_list = 2
let g:syntastic_enable_highlighting = 1
let g:syntastic_php_php_args = '-l'
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

"-------------------------
" lightline
"-------------------------
let g:lightline = {'colorscheme': 'landscape'}
set laststatus=2
if !has('gui_running')
set t_Co=256
endif

"-------------------------
" ctags
"-------------------------
let g:auto_ctags = 1
set tags+=.git/tags
let g:auto_ctags_directory_list = [$HOME]
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
" auto save
"-------------------------
let g:auto_save = 0
let g:auto_save_in_insert_mode = 0  " do not save while in insert mode

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
let NERDTreeShowHidden = 1
let file_name = expand("%:p")
if has('vim_starting') &&  file_name == ""
    autocmd VimEnter * execute 'NERDTree ./'
endif


"-------------------------
" NERDTree
"-------------------------
" Plugin key-mappings.
imap <C-s>     <Plug>(neosnippet_expand_or_jump)
smap <C-s>     <Plug>(neosnippet_expand_or_jump)
xmap <C-s>     <Plug>(neosnippet_expand_target)
" SuperTab like snippets behavior.
imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)"
\: pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)"
\: "\<TAB>"
" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif

"-------------------------
" vimdiff
"-------------------------
set diffexpr=unified_diff#diffexpr()
" configure with the followings (default values are shown below)
let unified_diff#executable = 'git'
let unified_diff#arguments = [
      \   'diff', '--no-index', '--no-color', '--no-ext-diff', '--unified=0',
      \ ]
let unified_diff#iwhite_arguments = [
      \   '--ignore--all-space',
      \ ]

"-------------------------
" incsearch
"-------------------------
"map /  <Plug>(incsearch-forward)
"map ?  <Plug>(incsearch-backward)
"map g/ <Plug>(incsearch-stay)

"-------------------------
" easymotion
"-------------------------
" ホームポジションに近いキーを使う [「ホームポジションに近いキーを使う]
let g:EasyMotion_keys='hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB'
" 「;」 + 何かにマッピング [「「;」+何かにマッピング]
let g:EasyMotion_leader_key=";"
" 1 ストローク選択を優先する [「1ストローク選択を優先する]
let g:EasyMotion_grouping=1
" カラー設定変更 [「カラー設定変更]
"hi EasyMotionTarget ctermbg=none ctermfg=red
"hi EasyMotionShade ctermbg=none ctermfg=blue

"-------------------------
" visualmark.vim
"-------------------------
" http://nanasi.jp/articles/vim/visualmark_vim.html
map <unique> <F3> <Plug>Vm_toggle_sign
map <silent> <unique> mm <Plug>Vm_toggle_sign

"-------------------------
" TypeScript
"-------------------------
let g:js_indent_typescript = 1

"-------------------------
" for hl_matchit
"-------------------------
let g:hl_matchit_enable_on_vim_startup = 1
let g:hl_matchit_hl_groupname = 'Title'
let g:hl_matchit_allow_ft = 'vim\|ruby\|sh\|php'

"-------------------------
" vim-go
"-------------------------
let g:go_bin_path = expand(globpath($GOPATH, "bin"))
let g:go_play_open_browser = 0
let g:go_fmt_fail_silently = 1
let g:go_fmt_autosave = 1
let g:go_fmt_command = "gofmt"
let g:go_disable_autoinstall = 0
