set runtimepath+=~/dotfiles/

runtime vim/general.vim
runtime vim/autocmd.vim
runtime vim/mappings.vim
runtime vim/tabcontrol.vim

runtime vim/plugins/stable.vim
runtime! vim/stable/configs/*.vim

" runtime vim/plugin-experimental.vim
" runtime! vim/experimental/configs/*.vim

if filereadable(expand('~/.vimrc.private'))
  runtime ~/.vimrc.private
endif
