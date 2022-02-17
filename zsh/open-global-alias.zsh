my-open-alias() {
  if [ -z "$RBUFFER" ] ; then
    my-open-alias-aux
  else
    zle end-of-line
  fi
}
my-open-alias-aux() {
  str=${LBUFFER%% }
  bp=$str
  str=${str##* }
  bp=${bp%%${str}}
  targets=`alias ${str}`
  if [ $targets ]; then
    cmd=`echo $targets|cut -d"=" -f2`
    LBUFFER=$bp${cmd//\'/}
  fi
}
zle -N my-open-alias
bindkey "^ " my-open-alias
