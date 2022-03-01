set runtimepath+=~/dotfiles/

runtime! vim/*.vim

if filereadable(expand('~/.vimrc.private'))
  runtime ~/.vimrc.private
endif
