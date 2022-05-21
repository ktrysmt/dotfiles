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

let g:jetpack#optimization = 1
let g:jetpack#copy_method = 'symlink'

call jetpack#begin()

" [appearance]
Jetpack 'RRethy/vim-illuminate'
Jetpack 'itchyny/lightline.vim'
Jetpack 'KKPMW/moonshine-vim'
Jetpack 'ktrysmt/pinecone-vim'
Jetpack 'sainnhe/gruvbox-material'
" Jetpack 'nvim-treesitter/nvim-treesitter'
Jetpack 'AlessandroYorba/Despacio'

" [filer]
Jetpack 'lambdalisue/fern.vim'
Jetpack 'LumaKernel/fern-mapping-fzf.vim'

" [window]
Jetpack 'airblade/vim-gitgutter'
Jetpack 'mbbill/undotree'
call jetpack#add('liuchengxu/vista.vim', { "on": "Vista" })
call jetpack#add('LeafCage/yankround.vim', { "on": "Unite" })
call jetpack#add('Shougo/unite.vim', { "on": "Unite" })

" [move]
Jetpack 'osyo-manga/vim-anzu'
call jetpack#add('Lokaltog/vim-easymotion', { "on": "<Plug>(easymotion-prefix)" })

" [commander]
Jetpack 'tpope/vim-fugitive'
Jetpack 'tomtom/tcomment_vim'
Jetpack 'thinca/vim-qfreplace'
call jetpack#add('AndrewRadev/linediff.vim', { "on": "Linediff" })

" [operator]
Jetpack 'cohama/lexima.vim'
Jetpack 'kana/vim-operator-user'
Jetpack 'osyo-manga/vim-operator-stay-cursor'
Jetpack 'rhysd/vim-operator-surround'
Jetpack 'terryma/vim-expand-region'
Jetpack 'kana/vim-textobj-user'
Jetpack 'rhysd/vim-textobj-anyblock'

" [fzf]
Jetpack 'junegunn/fzf'
Jetpack 'junegunn/fzf.vim'

" [snip]
Jetpack 'hrsh7th/vim-vsnip'
Jetpack 'hrsh7th/vim-vsnip-integ'
Jetpack 'rafamadriz/friendly-snippets'

" [lsp/completion]
Jetpack 'prabirshrestha/vim-lsp'
Jetpack 'prabirshrestha/async.vim'
Jetpack 'prabirshrestha/asyncomplete.vim'
Jetpack 'prabirshrestha/asyncomplete-lsp.vim'
Jetpack 'prabirshrestha/asyncomplete-buffer.vim'
Jetpack 'mattn/vim-lsp-settings'

" [typescript]
call jetpack#add('dense-analysis/ale', { 'for': ['javascript', 'typescript', 'typescriptreact'] })
call jetpack#add('leafgarland/typescript-vim', { 'for': ['typescript', 'typescriptreact'] })
call jetpack#add('peitalin/vim-jsx-typescript', { 'for': ['typescript', 'typescriptreact'] })
call jetpack#add('eliba2/vim-node-inspect', { 'for': ['javascript', 'typescript', 'typescriptreact'] })

" [html/css]
call jetpack#add('mattn/emmet-vim', { 'for': [ 'html', 'css', 'javascript', 'typescript', 'typescriptreact'] })

" [terraform]
call jetpack#add('hashivim/vim-terraform', { 'for': [ 'tf', 'terraform'] })

" [dockerfile]
call jetpack#add('ekalinin/Dockerfile.vim', { 'for': [ 'tf', 'Dockerfile'] })

" [c/cpp]
call jetpack#add('rhysd/vim-clang-format', { 'for': [ 'c', 'cpp'] })

call jetpack#end()

runtime! vim/plugins/*.vim
