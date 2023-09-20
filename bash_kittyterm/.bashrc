# Not a full bashrc, just additions

### [ ... ]

# General aliases
. $HOME/scripts/xdg-base-setup.sh

alias chrome=google-chrome-stable
alias lso='ls -las --time-style=long-iso'
alias ssk='kitty +kitten ssh'
alias curln="curl -w '\n'"
alias skim="sk -m"
alias tarZ="tar -I'zstd -T0'"

# General env vars
export LC_MONETARY=en_CA.UTF-8

# Scripts
export PATH="$PATH:$HOME/scripts" # For all the scripting fun
alias colocat="python3 $HOME/scripts/colocat.py"

# Editors and terminal emulators
export EDITOR='/usr/bin/vim -e'
export VISUAL=/usr/bin/vim
export KITTY_CUSTOM="$XDG_CONFIG_HOME/kitty/kitty.d"

# YubiFriends(TM)
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
gpgconf --launch gpg-agent
gpg-connect-agent 'updatestartuptty' /bye >/dev/null

# Java home and the PATH
export JAVA_HOME=/usr/lib/jvm/java
export PATH="$PATH:$HOME/.poetry/bin"
export PATH="$PATH:$XDG_DATA_HOME/JetBrains/Toolbox/scripts"
export PATH="$PATH:/opt/zeal/bin"

# XDG base directories
# .m2 is a symlink to $XDG_DATA_HOME/maven - what could possibly go wrong?
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
. "$CARGO_HOME/env"
export GOPATH="$XDG_DATA_HOME/go"
export PATH="$PATH:$GOPATH/bin"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgreprc"

### [ ... ]

# Exit if not an interactive shell
[ -z "$PS1" ] && return

# Powerline
export POWERLINE=~/.config/powerline
if [ -f `which powerline-daemon` ]; then
	powerline-daemon -q
	POWERLINE_BASH_CONTINUATION=1
	POWERLINE_BASH_SELECT=1
	. $HOME/.local/lib/python3.11/site-packages/powerline/bindings/bash/powerline.sh
fi

# Neofetch
neofetch  --title_fqdn on --distro_shorthand on --refresh_rate on --gtk2 off --gtk3 off --memory_percent on # --gpu_type dedicated
### [ EOF ]
