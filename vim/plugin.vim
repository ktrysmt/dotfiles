if empty(glob('~/.config/nvim/autoload/jetpack.vim'))
  silent execute '!curl -fLo ~/.config/nvim/autoload/jetpack.vim --create-dirs https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim'
  function! s:initialize_jetpack() abort
    execute ":JetpackSync"
  endfunction
  augroup PluginSetting
    autocmd!
    autocmd VimEnter * call s:initialize_jetpack()
  augroup END
endif

let g:jetpack_copy_method='copy'

call jetpack#begin()

call jetpack#add("tani/vim-jetpack")
" [appearance]
call jetpack#add('RRethy/vim-illuminate')
call jetpack#add('itchyny/lightline.vim')
call jetpack#add('KKPMW/moonshine-vim')
call jetpack#add('AlessandroYorba/Despacio')

" [theme]
call jetpack#add('ktrysmt/pinecone-vim')
" call jetpack#add('habamax/vim-gruvbit')

" [filer]
call jetpack#add('lambdalisue/fern.vim')
call jetpack#add('LumaKernel/fern-mapping-fzf.vim')

" [window]
call jetpack#add('airblade/vim-gitgutter')
call jetpack#add('mbbill/undotree')
call jetpack#add('liuchengxu/vista.vim')
call jetpack#add('yazgoo/yank-history')


" [move]
call jetpack#add('osyo-manga/vim-anzu')
call jetpack#add('Lokaltog/vim-easymotion', { "on": "<Plug>(easymotion-prefix)" })

" [commander]
call jetpack#add('tpope/vim-fugitive')
call jetpack#add('tomtom/tcomment_vim')
call jetpack#add('thinca/vim-qfreplace')
call jetpack#add('AndrewRadev/linediff.vim', { "on": "Linediff" })

" [operator]
call jetpack#add('cohama/lexima.vim')
call jetpack#add('kana/vim-operator-user')
call jetpack#add('osyo-manga/vim-operator-stay-cursor')
call jetpack#add('rhysd/vim-operator-surround')
call jetpack#add('terryma/vim-expand-region')
call jetpack#add('kana/vim-textobj-user')
call jetpack#add('rhysd/vim-textobj-anyblock')
call jetpack#add('nicwest/vim-camelsnek')

" [fzf]
call jetpack#add('junegunn/fzf')
call jetpack#add('junegunn/fzf.vim')

" [snip]
call jetpack#add('hrsh7th/vim-vsnip')
call jetpack#add('hrsh7th/vim-vsnip-integ')
call jetpack#add('rafamadriz/friendly-snippets')

" [lsp/completion]
call jetpack#add('prabirshrestha/vim-lsp')
call jetpack#add('prabirshrestha/async.vim')
call jetpack#add('prabirshrestha/asyncomplete.vim')
call jetpack#add('prabirshrestha/asyncomplete-lsp.vim')
call jetpack#add('prabirshrestha/asyncomplete-buffer.vim')

" [typescript]
call jetpack#add('dense-analysis/ale', { 'for': ['javascript', 'typescript', 'typescriptreact'] })
call jetpack#add('leafgarland/typescript-vim', { 'for': ['typescript', 'typescriptreact'] })
call jetpack#add('peitalin/vim-jsx-typescript', { 'for': ['typescript', 'typescriptreact'] })
call jetpack#add('eliba2/vim-node-inspect', { 'for': ['javascript', 'typescript', 'typescriptreact'] })

" [html/css]
call jetpack#add('mattn/emmet-vim', { 'for': [ 'html', 'css', 'javascript', 'typescript', 'typescriptreact'] })

" [terraform]
call jetpack#add('hashivim/vim-terraform', { 'for': ['terraform'] })

" [dockerfile]
call jetpack#add('ekalinin/Dockerfile.vim', { 'for': ['Dockerfile'] })
call jetpack#add('kwhrtsk/docker-fzf-completion', { 'for': ['Dockerfile'] })

" [jinja]
call jetpack#add('pearofducks/ansible-vim', { 'for': ['jinja2'] })

" [c/cpp]
call jetpack#add('rhysd/vim-clang-format', { 'for': ['c', 'cpp'] })

call jetpack#end()

runtime! vim/plugins/*.vim
