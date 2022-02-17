if empty(glob('~/.local/share/nvim/site/autoload/jetpack.vim'))
  silent execute '!curl -fLo ~/.local/share/nvim/site/autoload/jetpack.vim --create-dirs  https://raw.githubusercontent.com/tani/vim-jetpack/master/autoload/jetpack.vim'
  autocmd VimEnter * JetpackSync | source $MYVIMRC
endif

call jetpack#begin()

" [colorscheme]
Jetpack 'KKPMW/moonshine-vim'

" [filer]
Jetpack 'lambdalisue/fern.vim'
" Jetpack 'lambdalisue/fern-git-status.vim'
Jetpack 'antoinemadec/FixCursorHold.nvim'

" [general]
Jetpack 'ryanoasis/vim-devicons'
Jetpack 'cohama/lexima.vim'
Jetpack 'Shougo/unite.vim'
Jetpack 'LeafCage/yankround.vim'
Jetpack 'osyo-manga/vim-anzu'
Jetpack 'tpope/vim-dispatch'
Jetpack 'itchyny/lightline.vim'
Jetpack 'liuchengxu/vista.vim'
Jetpack 'lambdalisue/vim-unified-diff'
Jetpack 'Lokaltog/vim-easymotion'
Jetpack 'tmhedberg/matchit'
Jetpack 'vimtaku/hl_matchit.vim'
Jetpack 'tomtom/tcomment_vim'
Jetpack 'kana/vim-operator-user'
Jetpack 'rhysd/vim-operator-surround'
Jetpack 'osyo-manga/vim-operator-stay-cursor'
Jetpack 'thinca/vim-qfreplace'
Jetpack 'tpope/vim-fugitive'
Jetpack 'airblade/vim-gitgutter'
Jetpack 'editorconfig/editorconfig-vim'
Jetpack 'thinca/vim-quickrun'
Jetpack 'terryma/vim-expand-region'
Jetpack 'RRethy/vim-illuminate'
Jetpack 'chase/vim-ansible-yaml'
Jetpack 'ncm2/float-preview.nvim'
Jetpack 'junegunn/vim-easy-align'
Jetpack 'jreybert/vimagit'

" [fzf]
Jetpack 'junegunn/fzf'
Jetpack 'junegunn/fzf.vim'

" [async/lsp]
Jetpack 'prabirshrestha/vim-lsp'
Jetpack 'prabirshrestha/async.vim'
Jetpack 'prabirshrestha/asyncomplete.vim'
Jetpack 'prabirshrestha/asyncomplete-lsp.vim'
Jetpack 'prabirshrestha/asyncomplete-buffer.vim'
Jetpack 'mattn/vim-lsp-settings'
Jetpack 'wellle/tmux-complete.vim'

" [snip]
Jetpack 'hrsh7th/vim-vsnip'
Jetpack 'hrsh7th/vim-vsnip-integ'
Jetpack 'rafamadriz/friendly-snippets'

" [html/css]
Jetpack 'mattn/emmet-vim', { 'for': ['html', 'css', 'javascript', 'typescript', 'typescriptreact'] }

" [terraform]
Jetpack 'hashivim/vim-terraform', { 'for': ['tf', 'terraform'] }

" [dockerfile]
Jetpack 'ekalinin/Dockerfile.vim', { 'for': ['tf', 'Dockerfile'] }

" [c/cpp]
Jetpack 'rhysd/vim-clang-format', { 'for': ['c', 'cpp'] }

" [typescript]
Jetpack 'w0rp/ale', { 'for': ['javascript', 'typescript', 'typescriptreact'] }
Jetpack 'leafgarland/typescript-vim', { 'for': ['typescript', 'typescriptreact'] }
Jetpack 'peitalin/vim-jsx-typescript', { 'for': ['typescript', 'typescriptreact'] }
Jetpack 'eliba2/vim-node-inspect', { 'for': ['javascript', 'typescript', 'typescriptreact'] }

call jetpack#end()

