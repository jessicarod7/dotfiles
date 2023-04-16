export GRADLE_USER_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/gradle"
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
. "$CARGO_HOME/env"
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export PATH="$PATH:$GOPATH/bin"
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/npm/npmrc"

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --reload gpg-agent

export PATH="$PATH:/opt/jetbrains/scripts"
