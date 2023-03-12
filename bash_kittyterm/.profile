. "$HOME/.cargo/env"

export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --reload gpg-agent
gpg-connect-agent 'updatestartuptty' /bye >/dev/null # Don't call on remote SSH servers
