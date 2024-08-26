#!/bin/bash
# This is generally being replaced by 1Password's agent. Not sure what to do with it, so I've just moved it
# wholesale for now.
GPG_TTY=$(tty)
export GPG_TTY
SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
export SSH_AUTH_SOCK
gpgconf --launch gpg-agent
gpg-connect-agent 'updatestartuptty' /bye >/dev/null