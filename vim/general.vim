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

" syntax off

set cursorline

set completeopt=menuone,noinsert

" -----
" netrw
" -----
" let g:netrw_liststyle = 3
" let g:netrw_banner=1
" let g:netrw_sizestyle="H"
" let g:netrw_timefmt="%Y/%m/%d(%a) %H:%M:%S"
" let g:netrw_altv = 1
" let g:netrw_alto = 1
"
" let g:netrw_keepdir = 0
" let g:netrw_winsize = 30
" let g:netrw_localcopydircmd = 'cp -r'
"
" function! s:netrw_mapping() abort
"   nmap <buffer> . gh
" endfunction
"
" let g:NetrwIsOpen=0
"
" function! s:ToggleNetrw()
"   if g:NetrwIsOpen
"     let i = bufnr("$")
"     while (i >= 1)
"       if (getbufvar(i, "&filetype") == "netrw")
"         silent exe "bwipeout " . i
"       endif
"       let i-=1
"     endwhile
"     let g:NetrwIsOpen=0
"   else
"     let g:NetrwIsOpen=1
"     silent Lexplore
"   endif
" endfunction
"
" augroup NetrwMapping
"   autocmd!
"   autocmd filetype netrw call s:netrw_mapping()
" augroup END
" augroup NetrwProjectDrawer
"   autocmd!
"   if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in")
"     silent exe "bwipeout " . bufnr("$")
"     exe 'cd '.argv()[0]
"     autocmd VimEnter * :call s:ToggleNetrw()
"   else
"     autocmd VimEnter * :call s:ToggleNetrw()
"     autocmd VimEnter * wincmd p
"   endif
" augroup END


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
