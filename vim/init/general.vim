set encoding=utf-8
scriptencoding utf-8

set sh=zsh
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
set wildmenu
set history=5000
set guifont=Cica:h15
set inccommand=split
set showtabline=2
set clipboard=unnamed
set list

" set splitright " vsplit で右に開くオプション

" search
set hlsearch
set incsearch

" compleopt
set completeopt-=preview,noselect,noinsert
set completeopt=menuone
" set completeopt=noinsert,menuone,noselect,preview " use +preview when nvim 0.4 released

" completion window / floating window
set ph=30
" set termguicolors " should use a theme supporting trueColor...
" set pumblend=10

" 不可視文字を可視化する場合は以下をアンコメント
" set listchars=tab:^-,trail:-,extends:»,precedes:«,nbsp:%
filetype plugin indent on

syntax on

set cursorline
