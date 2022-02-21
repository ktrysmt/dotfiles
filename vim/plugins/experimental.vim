
" -----
" Jetpack
" -----
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
let g:jetpack#optimization=2
call jetpack#begin()
" [snip]
Jetpack 'hrsh7th/vim-vsnip'
Jetpack 'hrsh7th/vim-vsnip-integ'
Jetpack 'rafamadriz/friendly-snippets'
" [nvim-lsp and comp]
Jetpack 'neovim/nvim-lspconfig'
Jetpack 'williamboman/nvim-lsp-installer'
Jetpack 'hrsh7th/cmp-nvim-lsp'
Jetpack 'hrsh7th/cmp-buffer'
Jetpack 'hrsh7th/cmp-path'
Jetpack 'hrsh7th/cmp-cmdline'
Jetpack 'hrsh7th/nvim-cmp'
Jetpack 'hrsh7th/cmp-vsnip'
" [other]
Jetpack 'lambdalisue/fern-git-status.vim'
Jetpack 'nvim-lualine/lualine.nvim'
Jetpack 'kyazdani42/nvim-web-devicons'
call jetpack#end()

runtime! vim/plugins/experimental/*/*.vim
