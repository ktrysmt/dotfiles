set runtimepath+=~/dotfiles/

runtime! vim/init/*.vim
runtime! vim/stable/*/*.vim
" runtime! vim/experimental/*/*.vim

if filereadable(expand('~/.vimrc.private'))
  source ~/.vimrc.private
endif
