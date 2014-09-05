syntax on

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

set cindent 

"--------------------------- 
"" Neobundle Settings. 
"--------------------------- 
" bundleで管理するディレクトリを指定 
set runtimepath+=~/.vim/bundle/neobundle.vim/ 

" Required: 
call neobundle#begin(expand('~/.vim/bundle/')) 

" neobundle自体をneobundleで管理 
NeoBundleFetch 'Shougo/neobundle.vim' 

" プラグイン 
NeoBundle 'scrooloose/nerdtree' 
NeoBundle 'Townk/vim-autoclose' 
NeoBundle 'mattn/emmet-vim' 
"NeoBundle 'thinca/vim-quickrun' 
NeoBundle 'scrooloose/syntastic' 
NeoBundle 'Shougo/unite.vim' 
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
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'itchyny/lightline.vim'
NeoBundle 'soramugi/auto-ctags.vim'
"NeoBundle 'Shougo/vimshell.vim'
"NeoBundle 'vim-scripts/taglist.vim'
NeoBundle 'jelera/vim-javascript-syntax'
NeoBundle 'vim-scripts/jQuery'
NeoBundle 'jiangmiao/simple-javascript-indenter'
NeoBundle 'mattn/jscomplete-vim'
NeoBundle 'majutsushi/tagbar'
NeoBundle 'nono/vim-handlebars'
NeoBundle 'haya14busa/vim-easymotion'
NeoBundle 'vim-scripts/taglist.vim'
NeoBundle 'szw/vim-tags'

call neobundle#end() 

" Required: 
filetype plugin indent on 

" 未インストールのプラグインがある場合、インストールするかどうかを尋ねてくれるようにする設定 
" 毎回聞かれると邪魔な場合もあるので、この設定は任意です。 
NeoBundleCheck 

"------------------------- 
" Unite Settings. 
"------------------------- 

" Vertical 
let g:unite_enable_split_vertically = 1 
" YankRound 
:map <C-p> :Unite yankround<Return>



"------------------------- 
" 入力補完 
"------------------------- 
autocmd BufRead *.php\|*.ctp\|*.tpl :set dictionary=~/.vim/dictionaries/php.dict filetype=php 
let g:neocomplcache_enable_at_startup = 1 
let g:neocomplcache_enable_camel_case_completion = 1 
let g:neocomplcache_enable_underbar_completion = 1 
let g:neocomplcache_smart_case = 1 
let g:neocomplcache_min_syntax_length = 3 
let g:neocomplcache_manual_completion_start_length = 0 
let g:neocomplcache_caching_percent_in_statusline = 1 
let g:neocomplcache_enable_skip_completion = 1 
let g:neocomplcache_skip_input_time = '0.5' 

"------------------------- 
" syntax 
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
" lightline settiong 
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
set tags+=$HOME/tags 
let g:auto_ctags_directory_list = [$HOME] 
let g:auto_ctags_tags_args = '--tag-relative --recurse --sort=yes'



"-------------------------                                                                        
" カーソル行をハイライト
"-------------------------
set cursorline
augroup cch
  autocmd! cch
  autocmd WinLeave * set nocursorline
  autocmd WinEnter,BufRead * set cursorline
augroup END
hi clear CursorLine
hi CursorLine gui=underline
"highlight CursorLine cterm=underline ctermbg=black guibg=black
highlight CursorLine cterm=underline ctermfg=NONE ctermbg=NONE

"Escの2回押しでハイライト消去 
nmap <ESC><ESC> :nohlsearch<CR><ESC> 

" 保存時に行末の空白を除去する

autocmd BufWritePre * :%s/\s\+$//ge 
" 保存時にtabをスペースに変換する 
autocmd BufWritePre * :%s/\t/ /ge

"-------------------------
" taglist
"-------------------------
let Tlist_Ctags_Cmd = "/usr/local/bin/ctags" " 実装場所は確認
let Tlist_Show_One_File = 1
let Tlist_Use_Right_Window = 1
let Tlist_Exit_OnlyWindow = 1
