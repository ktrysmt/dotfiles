" -----
" set
" -----
set encoding=utf-8
scriptencoding utf-8

set sh=zsh

set lazyredraw
set ttyfast

set shortmess+=I

set secure
set fileencodings=utf-8,euc-jp,sjis,iso-2022-jp,
set fileformats=unix,dos,mac
set ambiwidth=double
set backspace=start,eol,indent
set bs=2
set expandtab
set guioptions-=T
set hidden
set virtualedit=all
set laststatus=2
set ruler
set shiftwidth=2
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
set wildmenu
set history=5000
set guifont=Cica:h15
set inccommand=split
set showtabline=2
set clipboard=unnamed
set list

set diffopt=internal,filler,algorithm:histogram,indent-heuristic

set hlsearch
set incsearch

set ph=30

filetype plugin indent on

syntax off

set cursorline

set completeopt=menuone,noinsert

" -----
" netrw
" -----
" ファイルツリーの表示形式
" 1: ls -lha
" 3: tree view
let g:netrw_liststyle = 3
" ヘッダを非表示にする
" let g:netrw_banner=0
" サイズを(K,M,G)で表示する
let g:netrw_sizestyle="H"
" 日付フォーマットを yyyy/mm/dd(曜日) hh:mm:ss で表示する
let g:netrw_timefmt="%Y/%m/%d(%a) %H:%M:%S"
" プレビューウィンドウを垂直分割で表示する
let g:netrw_preview=1
" CVSと.で始まるファイルは表示しない
" let g:netrw_list_hide = 'CVS,\(^\|\s\s\)\zs\.\S\+'
" 'v'でファイルを開くときは右側に開く。(デフォルトが左側なので入れ替え)
let g:netrw_altv = 1
" 'o'でファイルを開くときは下側に開く。(デフォルトが上側なので入れ替え)
let g:netrw_alto = 1

" -----
" vimgrep
" -----
if executable("rg")
    set grepprg=rg\ --vimgrep\ --no-heading
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

" -----
" commands
" -----
command! -nargs=* -complete=file Rg :tabnew | :silent grep --sort-files <args>
command! Rv source $MYVIMRC
command! Ev edit $HOME/dotfiles/.vimrc
cabbr w!! w !sudo tee > /dev/null %

" "" Resolve PATH
" function! s:configure_path(name, pathlist) abort
"   let path_separator = ':'
"   let pathlist = split(expand(a:name), path_separator)
"   for path in map(filter(a:pathlist, '!empty(v:val)'), 'expand(v:val)')
"     if isdirectory(path) && index(pathlist, path) == -1
"       call insert(pathlist, path, 0)
"     endif
"   endfor
"   execute printf('let %s = join(pathlist, ''%s'')', a:name, path_separator)
" endfunction
" call s:configure_path('$PATH', [
"     \ '/usr/local/bin',
"     \])
" call s:configure_path('$MANPATH', [
"     \ '/usr/local/share/man/',
"     \ '/usr/share/man/',
"     \])
"
" "" Fix python version
" function! s:pick_executable(pathspecs) abort
"   for pathspec in filter(a:pathspecs, '!empty(v:val)')
"     for path in reverse(glob(pathspec, 0, 1))
"       if executable(path)
"         return path
"       endif
"     endfor
"   endfor
"   return ''
" endfunction
" let g:python3_host_prog = s:pick_executable([
"     \ '/usr/local/bin/python3',
"     \ '/home/linuxbrew/.linuxbrew/bin/python3',
"     \ '/usr/bin/python3',
"     \ '/bin/python3',
"     \])
