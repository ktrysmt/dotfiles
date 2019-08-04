"---------------------------
"" General
"---------------------------
"" set envs
let $GO111MODULE = "auto"
"" set parameters
set encoding=utf8
scriptencoding utf-8
if !has('gui_running')
      \ && exists('&termguicolors')
      \ && $COLORTERM ==# 'truecolor'
  if !has('nvim')
    let &t_8f = "\e[38;2;%lu;%lu;%lum"
    let &t_8b = "\e[48;2;%lu;%lu;%lum"
  endif
  set termguicolors
endif
set secure
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
set completeopt=noinsert,menuone,noselect
set wildmenu
set history=5000
set guifont=Cica:h15
filetype plugin indent on
" 不可視文字を可視化する場合は以下をアンコメント
set list
" set listchars=tab:^-,trail:-,extends:»,precedes:«,nbsp:%
if has('nvim')
  set inccommand=split
  tnoremap <silent> <ESC> <C-\><C-n>
  set sh=zsh
end

"" Clipboard
if has('win32') || has('win64') || has('mac')
  set clipboard=unnamed
else
  set clipboard=unnamed,unnamedplus
endif

"" Resolve PATH
let s:is_windows = has('win32') || has('win64')
function! s:configure_path(name, pathlist) abort
  let path_separator = s:is_windows ? ';' : ':'
  let pathlist = split(expand(a:name), path_separator)
  for path in map(filter(a:pathlist, '!empty(v:val)'), 'expand(v:val)')
    if isdirectory(path) && index(pathlist, path) == -1
      call insert(pathlist, path, 0)
    endif
  endfor
  execute printf('let %s = join(pathlist, ''%s'')', a:name, path_separator)
endfunction
call s:configure_path('$PATH', [
    \ '/usr/local/bin',
    \])
call s:configure_path('$MANPATH', [
    \ '/usr/local/share/man/',
    \ '/usr/share/man/',
    \])

"" Fix python version
function! s:pick_executable(pathspecs) abort
  for pathspec in filter(a:pathspecs, '!empty(v:val)')
    for path in reverse(glob(pathspec, 0, 1))
      if executable(path)
        return path
      endif
    endfor
  endfor
  return ''
endfunction
if has('nvim')
  let g:python_host_prog = s:pick_executable([
        \ '/usr/local/bin/python2',
        \ '/home/linuxbrew/.linuxbrew/bin/python2',
        \ '/usr/bin/python2',
        \ '/bin/python2',
        \])
  let g:python3_host_prog = s:pick_executable([
        \ '/usr/local/bin/python3',
        \ '/home/linuxbrew/.linuxbrew/bin/python3',
        \ '/usr/bin/python3',
        \ '/bin/python3',
        \])
endif

"" leader mapping
let mapleader = "\<Space>"
nnoremap cn *Ncgn
nnoremap cN *NcgN
nnoremap <Leader>%s  :%s/\v
nmap <ESC><ESC> :nohlsearch<CR><ESC>
map <C-g> :echo expand('%:p')<Return>
nnoremap <silent> <Leader>co :copen<cr>
nnoremap <silent> <Leader>cl :cclose<cr>
nnoremap <silent> <expr> <Leader>a (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":Ag\<cr>"
nnoremap <silent> <expr> <Leader>x (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":Commands\<cr>"
nnoremap <silent> <expr> <Leader>f (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":Files\<cr>"
nnoremap <silent> <expr> <Leader>d (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":GFiles?\<cr>"
nnoremap <silent> <expr> <Leader>b (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":Buffers\<cr>"
nnoremap <silent> <expr> <Leader>h (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":History:\<cr>"
nnoremap <silent> <expr> <Leader>r (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":Ripgrep\<cr>"
nnoremap <silent> <expr> <Leader>w (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":Windows\<cr>"
nnoremap <silent> <Leader>gm :Gmerge<CR>
nnoremap <silent> <Leader>gs :Gstatus<CR>
nnoremap <silent> <Leader>gl :Glog<CR>
nnoremap <silent> <Leader>gb :Gblame<CR>
nnoremap <Leader>gca :Gcommit -a -m "
nnoremap <Leader>gps :Dispatch! git push origin<cr>
nnoremap <Leader>gpl :Dispatch! git pull origin<cr>
nnoremap <silent> <Leader>t :new \| :terminal<CR>
nnoremap <silent> <Leader>T :tabnew \| :terminal<CR>
nnoremap <silent> <Leader>vt :vne \| :terminal<CR>
nnoremap <Leader>n :ALENextWrap<CR>
nnoremap <Leader>got :GoToggleBreakpoint<CR>
nnoremap <Leader>god :GoDebug<CR>
map <C-]> :tab <CR>:exec("tjump ".expand("<cword>"))<CR>
map <leader><C-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

nnoremap <silent> <C-x>sc :<C-u>call <SID>change_case("sc")<CR>
nnoremap <silent> <C-x>sk :<C-u>call <SID>change_case("sk")<CR>
nnoremap <silent> <C-x>cs :<C-u>call <SID>change_case("cs")<CR>
nnoremap <silent> <C-x>ck :<C-u>call <SID>change_case("ck")<CR>
nnoremap <silent> <C-x>kc :<C-u>call <SID>change_case("kc")<CR>
nnoremap <silent> <C-x>ks :<C-u>call <SID>change_case("ks")<CR>

"" change case (snake,camel,kebab)
function! s:change_case(v1, ...)
  let t = a:v1
  let p = getpos(".")
  if t == "sc"
    let s = substitute(expand("<cword>"), "_\\(.\\)", "\\u\\1", "g")
    execute ":normal diw"
  elseif t == "sk"
    let s = substitute(expand("<cword>"), "_", "-", "g")
    execute ":normal diw"
  elseif t == "cs"
    let s = substitute(expand("<cword>"), "\\(\\u\\)", "_\\l\\1", "g")
    execute ":normal diw"
  elseif t == "ck"
    let s = substitute(expand("<cword>"), "\\(\\u\\)", "-\\l\\1", "g")
    execute ":normal diw"
  elseif t == "kc"
    let s = substitute(expand("<cWORD>"), "-\\(.\\)", "\\u\\1", "g")
    execute ":normal diW"
  elseif t == "ks"
    let s = substitute(expand("<cWORD>"), "-", "_", "g")
    execute ":normal diW"
  endif
  execute ":normal i" . s
  call setpos(".", p)
endfunction

"" autocmd
autocmd BufWritePre * :%s/\s\+$//ge
autocmd VimEnter * nested if @% != '' | :NERDTreeFind | wincmd p | endif
autocmd InsertLeave * set nopaste
autocmd QuickFixCmdPost *grep* cwindow
augroup highlightIdegraphicSpace
  autocmd!
  autocmd Colorscheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
  autocmd VimEnter,WinEnter * match IdeographicSpace /　/
augroup END
augroup FiletypeGroup
  autocmd!
  au BufNewFile,BufRead *.yml.j2,*.yaml.j2 set ft=yaml " or, set ft=ansible by vim-ansible-yaml
  au BufNewFile,BufRead *.conf,*.conf.j2 set ft=conf
  au BufNewFile,BufRead *.jsx set filetype=javascript.jsx
augroup END
augroup MyAutoCmd
  autocmd! *
augroup END
autocmd MyAutoCmd BufWritePost *
      \ if &filetype ==# '' && exists('b:ftdetect') |
      \  unlet! b:ftdetect |
      \  filetype detect |
      \ endif
let g:quickrun_config = {} " rustc -> cargo run
autocmd BufNewFile,BufRead *.rs  let g:quickrun_config.rust = {'exec' : 'cargo run'}

"" Toggle window zoom
function! s:toggle_window_zoom() abort
    if exists('t:zoom_winrestcmd')
        execute t:zoom_winrestcmd
        unlet t:zoom_winrestcmd
    else
        let t:zoom_winrestcmd = winrestcmd()
        resize
        vertical resize
    endif
endfunction
nnoremap <silent> <Plug>(my-zoom-window)
      \ :<C-u>call <SID>toggle_window_zoom()<CR>
nmap <C-w>z <Plug>(my-zoom-window)
nmap <C-w><C-z> <Plug>(my-zoom-window)

"" custom commands
command! -nargs=* -complete=file Rg :tabnew | :silent grep --sort-files <args>
command! -nargs=* -complete=file Rgg :tabnew | :silent grep <args>
command! -bang -nargs=* Ripgrep
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview({'options': '--exact --reverse --delimiter : --nth 3..'}, 'right:50%:hidden', '?'),
  \   <bang>0)
command! Rv source $MYVIMRC
command! Ev tabnew | edit $MYVIMRC
command! Edv edit $HOME/dotfiles/.vimrc
cabbr w!! w !sudo tee > /dev/null %

" terminal colors
let g:terminal_color_0  = "#1b2b34" "black
let g:terminal_color_1  = "#ed5f67" "red
let g:terminal_color_2  = "#9ac895" "green
let g:terminal_color_3  = "#fbc963" "yellow
let g:terminal_color_4  = "#669acd" "blue
let g:terminal_color_5  = "#c695c6" "magenta
let g:terminal_color_6  = "#5fb4b4" "cyan
let g:terminal_color_7  = "#c1c6cf" "white
let g:terminal_color_8  = "#65737e" "bright black
let g:terminal_color_9  = "#fa9257" "bright red
let g:terminal_color_10 = "#343d46" "bright green
let g:terminal_color_11 = "#4f5b66" "bright yellow
let g:terminal_color_12 = "#a8aebb" "bright blue
let g:terminal_color_13 = "#ced4df" "bright magenta
let g:terminal_color_14 = "#ac7967" "bright cyan
let g:terminal_color_15 = "#d9dfea" "bright white
let g:terminal_color_background="#1b2b34" "background
let g:terminal_color_foreground="#c1c6cf" "foreground


"---------------------------
"" Vim-Plug
"---------------------------
"" Settings
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif
call plug#begin()
"" [general]
Plug 'Shougo/unite.vim'
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  " Plug 'tbodt/deoplete-tabnine', { 'do': './install.sh' } " Completion by ML
else
  Plug 'Shougo/neocomplete.vim'
end
Plug 'haya14busa/vim-edgemotion'
Plug 'janko-m/vim-test'
Plug 'kristijanhusak/vim-hybrid-material'
Plug 'Townk/vim-autoclose'
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'junegunn/vim-easy-align'
Plug 'LeafCage/yankround.vim'
Plug 'haya14busa/incsearch.vim'
Plug 'haya14busa/vim-asterisk'
Plug 'osyo-manga/vim-anzu'
Plug 'tpope/vim-dispatch'
Plug 'itchyny/lightline.vim'
Plug 'soramugi/auto-ctags.vim'
Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle' }
Plug 'szw/vim-tags'
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'
Plug 'lambdalisue/vim-unified-diff'
Plug 'Lokaltog/vim-easymotion'
Plug 'tmhedberg/matchit'
Plug 'vimtaku/hl_matchit.vim'
Plug 'osyo-manga/vim-over'
Plug 'w0rp/ale'
Plug 'tomtom/tcomment_vim'
Plug 'kana/vim-operator-user'
Plug 'rhysd/vim-operator-surround'
Plug 'osyo-manga/vim-operator-stay-cursor'
Plug 'thinca/vim-qfreplace'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'editorconfig/editorconfig-vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'elzr/vim-json'
" [lsp]
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'natebosch/vim-lsc'
" [html/css]
Plug 'mattn/emmet-vim', { 'for': ['html', 'css', 'javascript'] }
" [php]
Plug 'lvht/phpcd.vim', { 'for': ['php'] }
" [js]
if has('nvim')
  Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern' }
else
  Plug 'ternjs/tern_for_vim', { 'for': ['javascript', 'javascript.jsx', 'html'], 'dir': '~/.vim/plugged/tern_for_vim', 'do': 'yarn' }
end
Plug 'styled-components/vim-styled-components', { 'branch': 'main', 'for': ['javascript', 'javascript.jsx', 'css'] }
Plug 'maxmellon/vim-jsx-pretty', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'ruanyl/vim-fixmyjs', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'hail2u/vim-css3-syntax', { 'for': ['javascript', 'javascript.jsx', 'css'] }
Plug 'othree/yajs.vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'othree/html5.vim', { 'for': ['javascript', 'javascript.jsx', 'html'] }
Plug 'othree/es.next.syntax.vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'othree/javascript-libraries-syntax.vim', { 'for': ['javascript', 'javascript.jsx'] }
" [go]
Plug 'tpope/vim-pathogen', { 'for': 'go' } " for vim-godebug
Plug 'jodosha/vim-godebug', { 'for': 'go' }
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'thinca/vim-quickrun'
if has('nvim')
  Plug 'nsf/gocode', { 'for': 'go', 'rtp': 'nvim', 'do': '~/.config/nvim/plugged/gocode/nvim/symlink.sh' }
  Plug 'zchee/deoplete-go', { 'for': 'go', 'do': 'make'}
end
" [rust]
Plug 'scrooloose/syntastic', { 'for': ['rust'] }
Plug 'rust-lang/rust.vim', { 'for': ['rust'] }
Plug 'racer-rust/vim-racer', { 'for': ['rust'] }
" [terraform]
Plug 'hashivim/vim-terraform', { 'for': ['tf', 'terraform'] }
" [dockerfile]
Plug 'docker/docker', { 'for': ['tf', 'Dockerfile'] }
" [ansible]
" Plug 'chase/vim-ansible-yaml', { 'for': ['ansible','jinja','yaml'] }
call plug#end()



"---------------------------
"" Plugin configuration
"---------------------------
"" custom theme
syntax on
set background=dark
autocmd ColorScheme * hi LineNr ctermfg=239
autocmd ColorScheme * hi Normal ctermbg=none
colorscheme hybrid_material

"" unite settings
let g:unite_enable_split_vertically = 1
nnoremap <silent> <C-p> :Unite -create -buffer-name=yankround yankround<Return>

"" tabnine
if has('nvim')
  call deoplete#custom#var('tabnine', {
        \ 'line_limit': 1000,
        \ 'max_num_results': 4,
        \ })
endif

"" lsp
let g:lsp_async_completion = 1
let g:lsp_diagnostics_enabled = 0
if executable('gopls')
  augroup LspGo
    au!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'go-lang',
        \ 'cmd': {server_info->['gopls', '-mode', 'stdio']},
        \ 'whitelist': ['go'],
        \ })
    autocmd FileType go setlocal omnifunc=lsp#complete
  augroup END
endif

"" fzf.vim
if has('nvim')
  function! s:fzf_statusline()
    " Override statusline as you like
    highlight fzf1 ctermfg=161 ctermbg=251
    highlight fzf2 ctermfg=23 ctermbg=251
    highlight fzf3 ctermfg=237 ctermbg=251
    setlocal statusline=%#fzf1#\ >\ %#fzf2#fz%#fzf3#f
  endfunction
  autocmd! User FzfStatusLine call <SID>fzf_statusline()
  command! -bang Windows call fzf#vim#windows({'options': ['--query', '!NERD ']}, <bang>0)
endif

"" vim-table-mode
let g:table_mode_corner='|'


"" vim-test
let g:test#preserve_screen = 1
let test#strategy = {
  \ 'nearest': 'neovim',
  \ 'file':    'dispatch',
  \ 'suite':   'basic',
\}

"" vim-json
let g:vim_json_syntax_conceal = 0

"" completion
if has('nvim')
  " deoplete
  let g:deoplete#enable_smart_case = 1
  let g:deoplete#enable_at_startup = 1
  inoremap <expr><C-h> deoplete#smart_close_popup()."\<C-h>"
  inoremap <expr><BS>  deoplete#smart_close_popup()."\<C-h>"
  inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
  function! s:my_cr_function() abort
    return deoplete#close_popup() . "\<CR>"
  endfunction
  " deoplete-go
  let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
  let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']
  let g:deoplete#sources#go#use_cache = 1
  let g:deoplete#sources#go#json_directory = $HOME.'/.local/data/deoplete-go'
  let g:deoplete#sources#go#align_class = 1
  let g:deoplete#sources#go#package_dot = 1
else
  " use neoccomplete
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
end

"" lightline
set laststatus=2
set t_Co=256
if !has('gui_running')
  set t_Co=256
endif
let g:lightline = {
  \'colorscheme': 'wombat',
  \'active': {
  \  'left': [
  \    ['mode', 'paste'],
  \    ['readonly', 'filename', 'modified'],
  \    ['ale'],
  \  ]
  \},
  \'component_function': {
  \  'ale': 'ALEStatus'
  \},
\}

"" ale
let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '⬥ ok']
let g:ale_fixers = {
  \ 'javascript': ['eslint','prettier'],
  \ 'jsx': ['eslint'],
  \ 'css': ['stylelint'],
  \ 'ruby': ['rubocop'],
  \ 'rust': ['rustfmt'],
\}
let g:ale_fix_on_save = 1
let g:ale_linters = {
  \ 'jsx': ['eslint', 'stylelint'],
  \ 'css': ['stylelint'],
  \ 'go' : ['gometalinter'],
  \ 'ruby' : ['rubocop','ruby'],
  \ 'yaml' : [''],
  \ 'rust' : ['rustc'],
\}
let g:ale_linter_aliases = {'jsx': 'css'}
let g:ale_go_gometalinter_options = '--vendored-linters --disable-all --enable=gotype --enable=vet --enable=golint -t'

"" ctags
let g:auto_ctags = 0
" set tags=.git/tags
set tags+=.git/tags
" set tags+=./tags,tags;$HOME
let g:auto_ctags_directory_list = ['.git']
let g:auto_ctags_tags_args = '--tag-relative=yes --recurse --sort=yes --append=no --format=2'

"" tagbar
let g:tagbar_width = 60
nmap <silent> <C-a>      :TagbarToggle<CR>
vmap <silent> <C-a> <Esc>:TagbarToggle<CR>
omap <silent> <C-a>      :TagbarToggle<CR>
imap <silent> <C-a> <Esc>:TagbarToggle<CR>
cmap <silent> <C-a> <C-u>:TagbarToggle<CR>
let g:tagbar_autofocus = 1
let g:tagbar_type_yaml = {
    \ 'ctagstype' : 'Yaml',
    \ 'kinds'     : [
        \ 'h:headers:0:1',
    \ ],
    \ 'sort'    : 0,
\ }
let g:tagbar_type_markdown = {
    \ 'ctagstype' : 'Markdown',
    \ 'kinds'     : [
        \ 'c:chapsters:0:1',
        \ 's:sections',
        \ 'S:subsections',
        \ 't:subsubsections',
        \ 'T:level 4 subsections:0:1',
        \ 'u:level 5 subsections:0:1',
        \ 'r:regex:1:0',
    \ ],
    \ 'sort'    : 0,
\ }

"" neosnippet
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

"" vimdiff
set diffexpr=unified_diff#diffexpr()
let unified_diff#executable = 'git'
let unified_diff#arguments = [
      \   'diff', '--no-index', '--no-color', '--no-ext-diff', '--unified=0',
      \ ]
let unified_diff#iwhite_arguments = [
      \   '--ignore--all-space',
      \ ]

"" easymotion
let g:EasyMotion_keys='hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB'
let g:EasyMotion_leader_key=";"
let g:EasyMotion_grouping=1

"" edgemotion
map <C-j> <Plug>(edgemotion-j)
map <C-k> <Plug>(edgemotion-k)

"" for hl_matchit
let g:hl_matchit_enable_on_vim_startup = 1
let g:hl_matchit_hl_groupname = 'Title'
let g:hl_matchit_allow_ft = 'vim\|ruby\|sh\|php\|javascript\|go\|rust'

"" vim-go
let g:go_bin_path = expand(globpath($GOPATH, "bin"))
let g:go_play_open_browser = 0
let g:go_fmt_fail_silently = 1
let g:go_fmt_autosave = 1
if executable('gopls')
  let g:go_def_mode='godef'
  let g:go_info_mode='gopls'
endif
" let g:go_fmt_command = "gofmt"
" let g:go_fmt_command = "goimports"
" let g:go_fmt_options = "-s"
let g:go_fmt_options = {
  \ 'gofmt': '-s',
  \ }
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_disable_autoinstall = 0
let g:go_gocode_unimported_packages = 1
command! GoDebugStart : "dummy for :GoDebugTest at vim-go

"" tab control
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

"" NERDTree
nnoremap <silent> <C-e> :NERDTreeToggle<cr>
let g:NERDTreeShowHidden=1
let NERDTreeIgnore = ['node_modules$','\.git$', "\.DS_Store$"]
let g:NERDTreeChDirMode = 2
let g:NERDTreeWinSize = 45
let g:nerdtree_tabs_open_on_console_startup = 1

"" highlight in NERDTree
function! IsNERDTreeOpen()
  return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction
function! SyncNERDTree()
 if strlen(expand('%')) > 0 && &modifiable && IsNERDTreeOpen() && !&diff && !empty(&ft) && &ft != "quickrun" && &ft != "qfreplace"
   NERDTreeFind
   wincmd p
 endif
endfunction
autocmd BufEnter * call SyncNERDTree()

"" emmet
let g:user_emmet_leader_key='<C-Y>'
let g:user_emmet_mode='in'
let g:user_emmet_install_global = 0
autocmd FileType html,css,scss,javascript EmmetInstall

"" rust
let g:rustfmt_autosave = 0
let g:racer_cmd = '$HOME/.cargo/bin/racer'
let g:rustfmt_command = '$HOME/.cargo/bin/rustfmt'
" let $RUST_SRC_PATH = '$HOME/.cargo/src'
let g:racer_experimental_completer = 1
let g:racer_insert_paren = 1

"" easy-align
vmap <Enter> <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

"" operetor-user
map <silent> sa <Plug>(operator-surround-append)
map <silent> sd <Plug>(operator-surround-delete)
map <silent> sr <Plug>(operator-surround-replace)
map y <Plug>(operator-stay-cursor-yank)

"" vp doesn't replace paste buffer
map P "0p

"" ripgrep
if executable("rg")
    set grepprg=rg\ --vimgrep\ --no-heading
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

"" terraform
let g:terraform_fmt_on_save = 1

"" javascript syntax
let g:used_javascript_libs = 'react'

"" incsearch,asterisk,anzu
map g/ <Plug>(incsearch-forward)
map ? <Plug>(incsearch-backward)
map / <Plug>(incsearch-stay)
let g:incsearch#magic = '\v'
let g:incsearch#auto_nohlsearch = 1
map n <Plug>(incsearch-nohl-n)
map N <Plug>(incsearch-nohl-N)
map *  <Plug>(incsearch-nohl-*)
map #  <Plug>(incsearch-nohl-#)
nmap n <Plug>(anzu-n-with-echo)
nmap N <Plug>(anzu-N-with-echo)
map * <Plug>(incsearch-nohl0)<Plug>(asterisk-z*)
map g* <Plug>(incsearch-nohl0)<Plug>(asterisk-gz*)
map # <Plug>(incsearch-nohl0)<Plug>(asterisk-z#)
map g# <Plug>(incsearch-nohl0)<Plug>(asterisk-gz#)

"-------------------------
"" Set os env
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
