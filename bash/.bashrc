# Not a full bashrc, just additions

### ...set user PATH ###

export PATH="$PATH:$HOME/scripts" # For all the scripting fun
alias chrome=google-chrome-stable
alias lso='ls -hal --time-style long-iso'

export EDITOR=/usr/bin/vim -e
export VISUAL=/usr/bin/vim

# Add Java home
export JAVA_HOME=/usr/lib/jvm/java

# Build-specific modifications
export PATH="$PATH:/opt/gcc-arm-<current_version>-x86_64-arm-none-eabi/bin"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig" # For pkgconf-based systems

# Exit if not an interactive shell
[ -z "$PS1" ] && return

### ...end of file ###

export POWERLINE=~/.config/powerline
if [ -f `which powerline-daemon` ]; then
	powerline-daemon -q
	POWERLINE_BASH_CONTINUATION=1
	POWERLINE_BASH_SELECT=1
	. /usr/share/powerline/bash/powerline.sh
fi

neofetch  --title_fqdn on --distro_shorthand on --refresh_rate on --gtk2 off --gtk3 off --memory_percent on # --gpu_type dedicated