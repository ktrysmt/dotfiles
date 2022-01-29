"" custom commands
command! -nargs=* -complete=file Rg :tabnew | :silent grep --sort-files <args>

command! Rv source $MYVIMRC
command! Ev edit $HOME/dotfiles/.vimrc
cabbr w!! w !sudo tee > /dev/null %
