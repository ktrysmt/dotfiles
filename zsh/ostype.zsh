if [[ "$OSTYPE" == "linux-gnu" ]]; then
  export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH
  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
  export MANPATH="/home/linuxbrew/.linuxbrew/share/man:$MANPATH"
  export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:$INFOPATH"

  if [[ "$USERNAME" == "vagrant" ]]; then
    # linux on Vagrant
  fi
  if [ -n "$WSL_DISTRO_NAME" ]; then
    # WSL2
    function open() {
      if [ $# != 1 ]; then
        explorer.exe .
      else
        if [ -e $1 ]; then
          explorer.exe $(wslpath -w $1) 2> /dev/null
        else
          echo "open: $1 : No such file or directory"
        fi
      fi
    }
  fi

elif [[ "$OSTYPE" == "darwin"* ]]; then
  export HOMEBREW_CASK_OPTS="--appdir=/Applications";
  # curl
  export PATH="/usr/local/opt/curl/bin:$PATH"
  export LDFLAGS="-L/usr/local/opt/curl/lib"
  export CPPFLAGS="-I/usr/local/opt/curl/include"
  export PKG_CONFIG_PATH="/usr/local/opt/curl/lib/pkgconfig"
  # openssl
  export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
  export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
  export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"
  export PKG_CONFIG_PATH="/usr/local/opt/openssl@1.1/lib/pkgconfig"
elif [[ "$OSTYPE" == "cygwin" ]]; then
  #
elif [[ "$OSTYPE" == "msys" ]]; then
  #
elif [[ "$OSTYPE" == "win32" ]]; then
  #
elif [[ "$OSTYPE" == "freebsd"* ]]; then
  #
else
  # Unknown.
fi
