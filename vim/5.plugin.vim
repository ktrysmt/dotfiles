if empty(glob('~/.config/nvim/autoload/jetpack.vim'))
  silent execute '!curl -fLo ~/.config/nvim/autoload/jetpack.vim --create-dirs  https://raw.githubusercontent.com/tani/vim-jetpack/master/autoload/jetpack.vim'
  function! s:initialize_jetpack() abort
    execute ":JetpackSync"
    execute ":qa"
  endfunction
  augroup PluginSetting
    autocmd!
    autocmd VimEnter * call s:initialize_jetpack()
  augroup END
endif

let g:jetpack#optimization=1

call jetpack#begin()

" [appearance]
Jetpack 'KKPMW/moonshine-vim'
Jetpack 'RRethy/vim-illuminate'
Jetpack 'itchyny/lightline.vim'
" Jetpack 'nvim-treesitter/nvim-treesitter', { 'do' : ':TSUpdate'}

" [filer]
Jetpack 'lambdalisue/fern.vim'

" [window]
Jetpack 'airblade/vim-gitgutter'
Jetpack 'liuchengxu/vista.vim', { "on": "Vista" }
Jetpack 'LeafCage/yankround.vim', { "on": "Unite" }
Jetpack 'Shougo/unite.vim', { "on": "Unite" }

" [move]
Jetpack 'osyo-manga/vim-anzu'
Jetpack 'Lokaltog/vim-easymotion', { "on": "<Plug>(easymotion-prefix)" }
Jetpack 'antoinemadec/FixCursorHold.nvim'

" [commander]
Jetpack 'jreybert/vimagit', { "on": "MagitOnly" }
Jetpack 'tpope/vim-fugitive', { "on": "Git" }
Jetpack 'tomtom/tcomment_vim'
Jetpack 'thinca/vim-qfreplace'
" Jetpack 'tpope/vim-dispatch'

" [operator]
Jetpack 'machakann/vim-sandwich'
Jetpack 'cohama/lexima.vim'
" Jetpack 'kana/vim-operator-user'
" Jetpack 'osyo-manga/vim-operator-stay-cursor'
" Jetpack 'rhysd/vim-operator-surround'
Jetpack 'terryma/vim-expand-region'

" [fzf]
Jetpack 'junegunn/fzf'
Jetpack 'junegunn/fzf.vim'

" [snip]
Jetpack 'hrsh7th/vim-vsnip'
Jetpack 'hrsh7th/vim-vsnip-integ'
Jetpack 'rafamadriz/friendly-snippets'

" [completion/lsp]
Jetpack 'prabirshrestha/vim-lsp'
Jetpack 'prabirshrestha/async.vim'
Jetpack 'prabirshrestha/asyncomplete.vim'
Jetpack 'prabirshrestha/asyncomplete-lsp.vim'
Jetpack 'prabirshrestha/asyncomplete-buffer.vim'
Jetpack 'mattn/vim-lsp-settings'
Jetpack 'wellle/tmux-complete.vim'

" [html/css]
Jetpack 'mattn/emmet-vim', { 'for': [ 'html', 'css', 'javascript', 'typescript', 'typescriptreact'] }

" [terraform]
Jetpack 'hashivim/vim-terraform', { 'for': [ 'tf', 'terraform'] }

" [dockerfile]
Jetpack 'ekalinin/Dockerfile.vim', { 'for': [ 'tf', 'Dockerfile'] }

" [c/cpp]
Jetpack 'rhysd/vim-clang-format', { 'for': [ 'c', 'cpp'] }

" [typescript]
Jetpack 'w0rp/ale', { 'for': ['javascript', 'typescript', 'typescriptreact'] }
Jetpack 'leafgarland/typescript-vim', { 'for': ['typescript', 'typescriptreact'] }
Jetpack 'peitalin/vim-jsx-typescript', { 'for': ['typescript', 'typescriptreact'] }
Jetpack 'eliba2/vim-node-inspect', { 'for': ['javascript', 'typescript', 'typescriptreact'] }

call jetpack#end()

runtime! vim/plugins/*.vim
