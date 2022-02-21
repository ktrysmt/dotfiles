set runtimepath+=~/dotfiles/

runtime! vim/*.vim

runtime vim/plugins/stable.vim
" runtime vim/plugins/experimental.vim


if filereadable(expand('~/.vimrc.private'))
  runtime ~/.vimrc.private
endif
