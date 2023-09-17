. $HOME/scripts/xdg-base-setup.sh

export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
. "$CARGO_HOME/env"
export GOPATH="$XDG_DATA_HOME/go"
export PATH="$PATH:$GOPATH/bin"

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --reload gpg-agent

export PATH="$PATH:$XDG_DATA_HOME/JetBrains/Toolbox/scripts"
