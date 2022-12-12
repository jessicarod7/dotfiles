# Not a full bashrc, just additions

### ...set user PATH ###

export PATH="$PATH:$HOME/scripts" # For all the scripting fun
source <(op completion bash)
alias chrome=google-chrome-stable
alias lso='ls -lash --time-style=long-iso'
alias ssk='kitty +kitten ssh'
alias qalc='flatpak run --command=qalc io.github.Qalculate'

# Scripts
alias colocat='python3 ~/scripts/colocat.py'
alias colodiff='python3 ~/scripts/colodiff.py'
alias git-unsync='python3 ~/scripts/git-unsync.py'

export EDITOR='/usr/bin/vim -e'
export VISUAL=/usr/bin/vim
export KITTY_CUSTOM=~/.config/kitty/kitty.d

# Add Java home, IntelliJ to PATH
export JAVA_HOME=/usr/lib/jvm/java
export PATH="$PATH:/opt/idea/bin:/opt/zeal/bin"
alias idea='idea.sh'

# Build-specific modifications
export PATH="$PATH:/opt/gcc-arm-<current_version>-x86_64-arm-none-eabi/bin"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/lib" # For pkgconf-based systems

### ...end of file ###

# Exit if not an interactive shell
[ -z "$PS1" ] && return

if [ -f `which powerline-daemon` ]; then
	powerline-daemon -q
	POWERLINE_BASH_CONTINUATION=1
	POWERLINE_BASH_SELECT=1
	. ~/.local/lib/python3.11/site-packages/powerline/bindings/bash/powerline.sh
fi

neofetch  --title_fqdn on --distro_shorthand on --refresh_rate on --gtk2 off --gtk3 off --memory_percent on # --gpu_type dedicated
