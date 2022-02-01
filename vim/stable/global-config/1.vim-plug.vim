"" Settings

if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  augroup VimPlugSetting
    autocmd!
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  augroup END
endif

call plug#begin()

" [colorscheme]
Plug 'KKPMW/moonshine-vim'

" [filer]
Plug 'lambdalisue/fern.vim'
" Plug 'lambdalisue/fern-git-status.vim'
Plug 'antoinemadec/FixCursorHold.nvim'

" [general]
Plug 'ryanoasis/vim-devicons'
Plug 'cohama/lexima.vim'
Plug 'Shougo/unite.vim'
Plug 'LeafCage/yankround.vim'
Plug 'osyo-manga/vim-anzu'
Plug 'tpope/vim-dispatch'
Plug 'itchyny/lightline.vim'
Plug 'liuchengxu/vista.vim'
Plug 'lambdalisue/vim-unified-diff'
Plug 'Lokaltog/vim-easymotion'
Plug 'tmhedberg/matchit'
Plug 'vimtaku/hl_matchit.vim'
Plug 'tomtom/tcomment_vim'
Plug 'kana/vim-operator-user'
Plug 'rhysd/vim-operator-surround'
Plug 'osyo-manga/vim-operator-stay-cursor'
Plug 'thinca/vim-qfreplace'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'editorconfig/editorconfig-vim'
Plug 'thinca/vim-quickrun'
Plug 'terryma/vim-expand-region'
Plug 'RRethy/vim-illuminate'
Plug 'chase/vim-ansible-yaml'
Plug 'ncm2/float-preview.nvim'
Plug 'junegunn/vim-easy-align'
Plug 'jreybert/vimagit'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'vim-scripts/VOoM'

" [fzf]
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" [async/lsp]
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
Plug 'mattn/vim-lsp-settings'
Plug 'wellle/tmux-complete.vim'

" [snip]
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'thomasfaingnaert/vim-lsp-snippets'
Plug 'thomasfaingnaert/vim-lsp-ultisnips'

" [html/css]
Plug 'mattn/emmet-vim', { 'for': ['html', 'css', 'javascript', 'typescript', 'typescriptreact'] }

" [terraform]
Plug 'hashivim/vim-terraform', { 'for': ['tf', 'terraform'] }

" [dockerfile]
Plug 'ekalinin/Dockerfile.vim', { 'for': ['tf', 'Dockerfile'] }

" [c/cpp]
Plug 'rhysd/vim-clang-format', { 'for': ['c', 'cpp'] }

" [typescript]
Plug 'w0rp/ale', { 'for': ['javascript', 'typescript', 'typescriptreact'] }
Plug 'leafgarland/typescript-vim', { 'for': ['typescript', 'typescriptreact'] }
Plug 'peitalin/vim-jsx-typescript', { 'for': ['typescript', 'typescriptreact'] }
Plug 'eliba2/vim-node-inspect', { 'for': ['javascript', 'typescript', 'typescriptreact'] }

call plug#end()

