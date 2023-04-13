. "$HOME/.cargo/env"

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --reload gpg-agent

export PATH="$PATH:/opt/jetbrains/bin:/opt/jetbrains/scripts"
