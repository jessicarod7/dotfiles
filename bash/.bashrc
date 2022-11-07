# Not a full bashrc, just additions

### ...set user PATH ###

export PATH="$PATH:$HOME/scripts" # For all the scripting fun
source <(op completion bash)
alias chrome=google-chrome-stable
alias lso='ls -hal --time-style long-iso'

export EDITOR="/usr/bin/vim -e"
export VISUAL=/usr/bin/vim

# Add Java home, IntelliJ to PATH
export JAVA_HOME=/usr/lib/jvm/java
export PATH="$PATH:/opt/idea/bin"
alias idea="idea.sh"

# Build-specific modifications
export PATH="$PATH:/opt/gcc-arm-<current_version>-x86_64-arm-none-eabi/bin"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/lib" # For pkgconf-based systems

### ...end of file ###

# Exit if not an interactive shell
[ -z "$PS1" ] && return

export POWERLINE=~/.config/powerline
if [ -f `which powerline-daemon` ]; then
	powerline-daemon -q
	POWERLINE_BASH_CONTINUATION=1
	POWERLINE_BASH_SELECT=1
	. /usr/share/powerline/bash/powerline.sh
fi

neofetch  --title_fqdn on --distro_shorthand on --refresh_rate on --gtk2 off --gtk3 off --memory_percent on # --gpu_type dedicated
