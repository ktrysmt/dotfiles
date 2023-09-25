function chpwd() {
  powered_cd_add_log
}
function powered_cd_add_log() {
  local i=0
  cat ~/.powered_cd.log | while read line; do
  (( i++ ))
  if [ i = 30 ]; then
    sed -i -e "30,30d" ~/.powered_cd.log
  elif [ "$line" = "$PWD" ]; then
    sed -i -e "${i},${i}d" ~/.powered_cd.log
  fi
done
echo "$PWD" >> ~/.powered_cd.log
}
function powered_cd() {
  if type tac > /dev/null 2>&1 ;then
    tac="tac"
  else
    tac="tail -r"
  fi
  if [ $# = 0 ]; then
    local dir=$(eval $tac ~/.powered_cd.log | fzf)
    if [ "$dir" = "" ]; then
      return 1
    elif [ -d "$dir" ]; then
      cd "$dir"
    else
      local res=$(grep -v -E "^${dir}" ~/.powered_cd.log)
      echo $res > ~/.powered_cd.log
      echo "powerd_cd: deleted old path: ${dir}"
    fi
  elif [ $# = 1 ]; then
    cd $1
  else
    echo "powered_cd: too many arguments"
  fi
}
_powered_cd() {
  _files -/
}
# compdef _powered_cd powered_cd
[ -e ~/.powered_cd.log ] || touch ~/.powered_cd.log
alias c="powered_cd"

